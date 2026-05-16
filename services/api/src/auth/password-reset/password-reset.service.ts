import { Injectable, BadRequestException, NotFoundException, Logger } from '@nestjs/common';
import { randomBytes, createHash } from 'crypto';
import * as bcrypt from 'bcrypt';

import { PrismaService } from '../../prisma/prisma.service';
import { EmailService } from './email.service';
import { SmsService } from './sms.service';

export type ResetChannel = 'email' | 'sms';

const TOKEN_TTL_MINUTES = 60;
const TOKEN_BYTES = 32; // 256 bits, base64url-encoded

@Injectable()
export class PasswordResetService {
  private readonly logger = new Logger(PasswordResetService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly email: EmailService,
    private readonly sms: SmsService,
  ) {}

  /**
   * Resolves the supplied identifier (email or username) to a real user. If no
   * such user exists we *do not throw* — the calling controller should return
   * the same success response either way so attackers can't enumerate accounts.
   * Returns null when nothing matches.
   */
  private async findUserByIdentifier(identifier: string) {
    const id = identifier.trim();
    if (!id) return null;

    // Prefer email match (lower-cased).
    const lower = id.toLowerCase();
    const byEmail = await this.prisma.user.findFirst({
      where: { email: lower },
      select: { id: true, email: true, phone: true, name: true, nameEn: true, schoolId: true, emailVerifiedAt: true, phoneVerifiedAt: true } as any,
    });
    if (byEmail) return byEmail as any;

    // Fallback to username (also lower-cased to match how it's stored).
    const byUsername = await this.prisma.user.findFirst({
      where: { username: lower } as any,
      select: { id: true, email: true, phone: true, name: true, nameEn: true, schoolId: true, emailVerifiedAt: true, phoneVerifiedAt: true } as any,
    });
    return (byUsername ?? null) as any;
  }

  private hashToken(raw: string): string {
    return createHash('sha256').update(raw).digest('hex');
  }

  private get baseUrl(): string {
    const explicit = process.env.PUBLIC_APP_URL?.trim();
    if (explicit) return explicit.replace(/\/+$/, '');
    // Reasonable default for Railway deploy.
    return 'https://pacific-enchantment-production-7a80.up.railway.app';
  }

  /**
   * Generates and stores a single-use token, then dispatches it via the chosen
   * channel. Idempotent w.r.t. multiple requests — each one issues a new token,
   * leaving older unused tokens in place (they expire on their own).
   *
   * Always resolves successfully even when no user matched; callers should
   * return a generic "if an account exists, we sent…" response.
   */
  async requestReset(args: { identifier: string; channel: ResetChannel }): Promise<void> {
    const user = await this.findUserByIdentifier(args.identifier);
    if (!user) {
      this.logger.log(`No user matched identifier=${args.identifier.slice(0, 3)}… (silently succeeding)`);
      return;
    }

    if (args.channel === 'email' && !(user.email && user.email.trim())) {
      this.logger.warn(`User ${user.id} has no email on file; skipping email reset`);
      return;
    }
    if (args.channel === 'sms' && !(user.phone && user.phone.trim())) {
      this.logger.warn(`User ${user.id} has no phone on file; skipping SMS reset`);
      return;
    }

    // Refuse reset on an unverified channel — owner-of-channel hasn't been
    // proven. Same anti-enumeration posture as no-such-user: silent return,
    // generic message at the controller layer.
    if (args.channel === 'email' && !(user as any).emailVerifiedAt) {
      this.logger.warn(`User ${user.id} email not verified; skipping email reset`);
      return;
    }
    if (args.channel === 'sms' && !(user as any).phoneVerifiedAt) {
      this.logger.warn(`User ${user.id} phone not verified; skipping SMS reset`);
      return;
    }

    const rawToken = randomBytes(TOKEN_BYTES).toString('base64url');
    const tokenHash = this.hashToken(rawToken);
    const expiresAt = new Date(Date.now() + TOKEN_TTL_MINUTES * 60_000);

    await this.prisma.passwordResetToken.create({
      data: {
        userId: user.id,
        tokenHash,
        channel: args.channel,
        expiresAt,
      },
    });

    const resetUrl = `${this.baseUrl}/reset-password?token=${rawToken}`;
    const schoolName = await this.lookupSchoolName(user.schoolId);
    const recipientName = (user.nameEn || user.name || '').trim() || null;

    if (args.channel === 'email') {
      await this.email.sendPasswordReset({
        to: user.email!,
        recipientName,
        schoolName,
        resetUrl,
        expiresInMinutes: TOKEN_TTL_MINUTES,
      });
    } else {
      await this.sms.sendPasswordResetSms({
        to: user.phone!,
        resetUrl,
        expiresInMinutes: TOKEN_TTL_MINUTES,
        schoolName,
      });
    }
  }

  private async lookupSchoolName(schoolId: string | null | undefined): Promise<string | null> {
    if (!schoolId) return null;
    try {
      const row = await this.prisma.school.findUnique({
        where: { id: schoolId },
        select: { name: true },
      });
      return row?.name ?? null;
    } catch {
      return null;
    }
  }

  /**
   * Called after an admin directly changes a user's password (see
   * admin.service.setUserPassword). Creates a fresh single-use reset token
   * and emails/SMSes the affected user a "your password was changed" notice
   * with a one-click link to set their own password.
   *
   * Resolves silently when:
   *   - The user has no email AND no phone (we have no way to reach them).
   *   - Email/SMS providers aren't configured (logged as warnings).
   * Never throws — a notification failure must not block the password
   * change that already happened.
   */
  async notifyPasswordChanged(args: { targetUserId: string; byAdminName: string }): Promise<void> {
    let target: any;
    try {
      target = await this.prisma.user.findUnique({
        where: { id: args.targetUserId },
        select: {
          id: true, email: true, phone: true, name: true, nameEn: true, schoolId: true,
        } as any,
      });
    } catch (err) {
      this.logger.warn(`notifyPasswordChanged: could not load user ${args.targetUserId}: ${(err as Error).message}`);
      return;
    }
    if (!target) return;

    const hasEmail = !!(target.email && target.email.trim());
    const hasPhone = !!(target.phone && target.phone.trim());
    if (!hasEmail && !hasPhone) {
      this.logger.log(`notifyPasswordChanged: user ${target.id} has neither email nor phone; skipping notify`);
      return;
    }

    const rawToken = randomBytes(TOKEN_BYTES).toString('base64url');
    const tokenHash = this.hashToken(rawToken);
    const expiresAt = new Date(Date.now() + TOKEN_TTL_MINUTES * 60_000);
    const channel: ResetChannel = hasEmail ? 'email' : 'sms';

    try {
      await this.prisma.passwordResetToken.create({
        data: { userId: target.id, tokenHash, channel, expiresAt },
      });
    } catch (err) {
      this.logger.warn(`notifyPasswordChanged: token persist failed: ${(err as Error).message}`);
      return;
    }

    const resetUrl = `${this.baseUrl}/reset-password?token=${rawToken}`;
    const schoolName = await this.lookupSchoolName(target.schoolId);
    const recipientName = (target.nameEn || target.name || '').trim() || null;

    // Send via every available channel — email first (richer), SMS as a
    // belt-and-suspenders fallback when both are on file.
    if (hasEmail) {
      try {
        await this.email.sendPasswordChangedNotification({
          to: target.email!,
          recipientName,
          schoolName,
          byAdminName: args.byAdminName,
          resetUrl,
          expiresInMinutes: TOKEN_TTL_MINUTES,
        });
      } catch (err) {
        this.logger.warn(`notifyPasswordChanged: email send failed: ${(err as Error).message}`);
      }
    }
    if (hasPhone) {
      try {
        await this.sms.sendPasswordChangedSms({
          to: target.phone!,
          byAdminName: args.byAdminName,
          resetUrl,
          expiresInMinutes: TOKEN_TTL_MINUTES,
          schoolName,
        });
      } catch (err) {
        this.logger.warn(`notifyPasswordChanged: sms send failed: ${(err as Error).message}`);
      }
    }
  }

  // ── Admin-mediated password change (Path B) ─────────────────────────────

  /**
   * Looks up the admins eligible to approve a password change for the user
   * identified by email-or-username. Returns the user's school name (so the
   * UI can render "Ask one of <school>'s admins:") and a list of admin
   * candidates. Always returns 200 with empty data when the identifier
   * doesn't match anything — same anti-enumeration posture as forgot-password.
   */
  async lookupAdminsForRequest(identifier: string): Promise<{
    schoolName: string | null;
    admins: { id: string; name: string; email: string | null }[];
  }> {
    const user = await this.findUserByIdentifier(identifier);
    if (!user) return { schoolName: null, admins: [] };
    if (!user.schoolId) return { schoolName: null, admins: [] };

    const schoolName = await this.lookupSchoolName(user.schoolId);
    const admins = await this.prisma.user.findMany({
      where: {
        schoolId: user.schoolId,
        roles: { some: { role: 'ADMIN' as any } },
      } as any,
      select: { id: true, name: true, nameEn: true, email: true } as any,
      orderBy: { name: 'asc' },
    }) as any[];

    return {
      schoolName,
      admins: admins.map((a: any) => ({
        id: a.id,
        name: (a.nameEn || a.name || a.email || 'Admin').toString(),
        email: a.email,
      })),
    };
  }

  /**
   * User submits their desired password and picks an admin to approve.
   * Stores the bcrypt hash so admins NEVER see the raw value. Notifies the
   * chosen admin out-of-band (email + SMS). Always returns success so callers
   * can't probe for valid (identifier, adminId) pairs.
   */
  async submitPasswordChangeRequest(args: {
    identifier: string;
    adminId: string;
    desiredPassword: string;
  }): Promise<void> {
    const pw = args.desiredPassword ?? '';
    if (pw.length < 8) throw new BadRequestException('Password must be at least 8 characters.');

    const user = await this.findUserByIdentifier(args.identifier);
    if (!user || !user.schoolId) {
      this.logger.log(`submitPasswordChangeRequest: no user / no school for identifier=${args.identifier.slice(0, 3)}… (silently succeeding)`);
      return;
    }

    // Verify the chosen admin actually belongs to this user's school.
    const admin = await this.prisma.user.findFirst({
      where: {
        id: args.adminId,
        schoolId: user.schoolId,
        roles: { some: { role: 'ADMIN' as any } },
      } as any,
      select: { id: true, name: true, nameEn: true, email: true, phone: true } as any,
    }) as any;
    if (!admin) {
      this.logger.warn(`submitPasswordChangeRequest: admin ${args.adminId} not valid for user ${user.id}`);
      return;
    }

    const passwordHash = await bcrypt.hash(pw, 10);
    const expiresAt = new Date(Date.now() + 24 * 60 * 60_000); // 24h

    await this.prisma.passwordChangeRequest.create({
      data: { userId: user.id, toAdminId: admin.id, passwordHash, expiresAt },
    });

    // Best-effort notification (don't block the user's submit on send failure).
    const schoolName = await this.lookupSchoolName(user.schoolId);
    const requesterName = (user.nameEn || user.name || 'A user').toString();
    if (admin.email) {
      try {
        await this.email.sendPasswordChangeRequestToAdmin({
          to: admin.email,
          adminName: (admin.nameEn || admin.name || 'Admin').toString(),
          requesterName,
          requesterIdentifier: user.email || (user as any).username || '',
          schoolName,
        });
      } catch (err) {
        this.logger.warn(`submitPasswordChangeRequest: email notify failed: ${(err as Error).message}`);
      }
    }
    if (admin.phone) {
      try {
        await this.sms.sendPasswordChangeRequestToAdmin({
          to: admin.phone,
          requesterName,
          schoolName,
        });
      } catch (err) {
        this.logger.warn(`submitPasswordChangeRequest: sms notify failed: ${(err as Error).message}`);
      }
    }
  }

  /** Admin approves: copy the stored hash into the user's password. */
  async approveChangeRequest(approvingAdminId: string, requestId: string): Promise<void> {
    const req = await this.prisma.passwordChangeRequest.findUnique({ where: { id: requestId } });
    if (!req) throw new NotFoundException('Request not found');
    if (req.toAdminId !== approvingAdminId) {
      throw new BadRequestException("This request wasn't sent to you.");
    }
    if (req.status !== 'PENDING') throw new BadRequestException(`Request is already ${req.status}.`);
    if (req.expiresAt.getTime() < Date.now()) {
      await this.prisma.passwordChangeRequest.update({
        where: { id: requestId },
        data: { status: 'EXPIRED', resolvedAt: new Date() },
      });
      throw new BadRequestException('Request has expired.');
    }

    await this.prisma.$transaction([
      this.prisma.user.update({ where: { id: req.userId }, data: { password: req.passwordHash } }),
      this.prisma.passwordChangeRequest.update({
        where: { id: requestId },
        data: { status: 'APPROVED', resolvedAt: new Date() },
      }),
      // Invalidate any of the user's still-pending self-service reset tokens.
      this.prisma.passwordResetToken.updateMany({
        where: { userId: req.userId, usedAt: null },
        data: { usedAt: new Date() },
      }),
    ]);
  }

  /** Admin rejects (no password change happens). */
  async rejectChangeRequest(approvingAdminId: string, requestId: string): Promise<void> {
    const req = await this.prisma.passwordChangeRequest.findUnique({ where: { id: requestId } });
    if (!req) throw new NotFoundException('Request not found');
    if (req.toAdminId !== approvingAdminId) {
      throw new BadRequestException("This request wasn't sent to you.");
    }
    if (req.status !== 'PENDING') throw new BadRequestException(`Request is already ${req.status}.`);

    await this.prisma.passwordChangeRequest.update({
      where: { id: requestId },
      data: { status: 'REJECTED', resolvedAt: new Date() },
    });
  }

  /** Pending requests routed to a specific admin, newest first. */
  async listPendingForAdmin(adminId: string): Promise<any[]> {
    const rows = await this.prisma.passwordChangeRequest.findMany({
      where: { toAdminId: adminId, status: 'PENDING', expiresAt: { gt: new Date() } },
      orderBy: { createdAt: 'desc' },
      include: {
        user: { select: { id: true, name: true, nameEn: true, email: true, username: true } as any } as any,
      } as any,
    }) as any[];
    return rows.map((r: any) => ({
      id: r.id,
      requesterName: (r.user?.nameEn || r.user?.name || 'A user').toString(),
      requesterEmail: r.user?.email,
      requesterUsername: r.user?.username,
      createdAt: r.createdAt,
      expiresAt: r.expiresAt,
    }));
  }

  /**
   * Validates the raw token, sets the user's new password (bcrypt-hashed),
   * marks the token used, and invalidates any other still-pending tokens for
   * the same user.
   */
  async consumeReset(args: { token: string; newPassword: string }): Promise<void> {
    const raw = args.token.trim();
    const pw = args.newPassword;
    if (!raw) throw new BadRequestException('Token is required.');
    if (!pw || pw.length < 8) throw new BadRequestException('Password must be at least 8 characters.');

    const tokenHash = this.hashToken(raw);
    const row = await this.prisma.passwordResetToken.findUnique({ where: { tokenHash } });
    if (!row) throw new NotFoundException('This reset link is invalid or has already been used.');
    if (row.usedAt) throw new BadRequestException('This reset link has already been used.');
    if (row.expiresAt.getTime() < Date.now()) throw new BadRequestException('This reset link has expired.');

    const hash = await bcrypt.hash(pw, 10);
    await this.prisma.$transaction([
      this.prisma.user.update({ where: { id: row.userId }, data: { password: hash } }),
      this.prisma.passwordResetToken.update({ where: { id: row.id }, data: { usedAt: new Date() } }),
      // Invalidate any sibling tokens so they can't be redeemed either.
      this.prisma.passwordResetToken.updateMany({
        where: { userId: row.userId, usedAt: null, id: { not: row.id } },
        data: { usedAt: new Date() },
      }),
    ]);
  }
}
