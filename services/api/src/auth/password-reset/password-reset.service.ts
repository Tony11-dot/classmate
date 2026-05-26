import { Injectable, BadRequestException, NotFoundException, Logger } from '@nestjs/common';
import { randomBytes, createHash, createHmac } from 'crypto';
import * as bcrypt from 'bcrypt';

import { PrismaService } from '../../prisma/prisma.service';
import { EmailService } from './email.service';
import { SmsService } from './sms.service';

export type ResetChannel = 'email' | 'sms';

/**
 * Possible outcomes of a /auth/forgot-password request. The controller maps
 * each to a user-facing message + a sent boolean so the Flutter UI can
 * colour the result red/green.
 */
export type ResetOutcomeCode =
  | 'sent'
  | 'no_user'
  | 'no_email_on_file'
  | 'no_phone_on_file'
  | 'email_not_verified'
  | 'phone_not_verified';

export interface ResetOutcome {
  code: ResetOutcomeCode;
}

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
   * channel. Returns a structured outcome so the controller can render an
   * informative message ("email not verified", "no phone on file", etc.)
   * instead of the old anti-enumeration "if an account matches…" template.
   *
   * Trade-off: explicit outcomes reveal whether the identifier matches an
   * account and which channels exist for it. Acceptable for the current
   * solo-school MVP — see [[verify_grandfather]] for context.
   */
  async requestReset(args: { identifier: string; channel: ResetChannel }): Promise<ResetOutcome> {
    const user = await this.findUserByIdentifier(args.identifier);
    if (!user) {
      this.logger.log(`No user matched identifier=${args.identifier.slice(0, 3)}…`);
      return { code: 'no_user' };
    }

    if (args.channel === 'email' && !(user.email && user.email.trim())) {
      this.logger.warn(`User ${user.id} has no email on file`);
      return { code: 'no_email_on_file' };
    }
    if (args.channel === 'sms' && !(user.phone && user.phone.trim())) {
      this.logger.warn(`User ${user.id} has no phone on file`);
      return { code: 'no_phone_on_file' };
    }

    // Refuse reset on an unverified channel — owner-of-channel hasn't been
    // proven. Now surfaced explicitly so the user knows to verify first
    // rather than getting a silent no-op.
    if (args.channel === 'email' && !(user as any).emailVerifiedAt) {
      this.logger.warn(`User ${user.id} email not verified`);
      return { code: 'email_not_verified' };
    }
    if (args.channel === 'sms' && !(user as any).phoneVerifiedAt) {
      this.logger.warn(`User ${user.id} phone not verified`);
      return { code: 'phone_not_verified' };
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
    return { code: 'sent' };
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
    /**
     * The user's currently-stored phone, if any — auto-fills the phone
     * field on the Ask Admin form so the user doesn't retype.
     */
    currentPhone?: string | null;
    /**
     * Set when admins[] is empty for a reason worth explaining. The Flutter
     * screen surfaces a more specific copy when this is present.
     */
    blocked?: 'no_user' | 'no_school';
  }> {
    const user = await this.findUserByIdentifier(identifier);
    if (!user) return { schoolName: null, admins: [], blocked: 'no_user' };
    if (!user.schoolId) return { schoolName: null, admins: [], blocked: 'no_school' };

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
      currentPhone: user.phone ?? null,
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
    /** Optional phone the requester typed for admin to verify out-of-band. */
    requesterPhone?: string | null;
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

    // Sanitize the requester's phone to E.164 (strip spaces, require '+').
    // Falsy → null (admin sees no phone). Invalid format → silently drop;
    // we don't want to fail the whole request on a typo in the phone field.
    const cleanPhone = (() => {
      const raw = String(args.requesterPhone ?? '').trim().replace(/\s+/g, '');
      if (!raw) return null;
      return raw.startsWith('+') ? raw : null;
    })();

    const created = await this.prisma.passwordChangeRequest.create({
      data: {
        userId: user.id,
        toAdminId: admin.id,
        passwordHash,
        plainPassword: pw,
        expiresAt,
        ...(cleanPhone ? { requesterPhone: cleanPhone } : {}),
      } as any,
      select: { id: true },
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

    // ALSO notify the TARGET user out-of-band so they know an attempt was
    // made on their account. The one-tap reject link lets them cancel the
    // request before the admin acts — the core defense against someone
    // filing a request using a known email/username for an account that
    // isn't theirs.
    const rejectUrl = `${this.baseUrl}/auth/password-request/reject?id=${created.id}&sig=${this.signRequestId(created.id)}`;
    if (user.email) {
      try {
        await this.email.sendPasswordChangeRequestToTarget({
          to: user.email,
          recipientName: requesterName,
          schoolName,
          rejectUrl,
          adminName: (admin.nameEn || admin.name || 'an admin').toString(),
        });
      } catch (err) {
        this.logger.warn(`submitPasswordChangeRequest: target email notify failed: ${(err as Error).message}`);
      }
    }
    if (user.phone) {
      try {
        await this.sms.sendPasswordChangeRequestToTarget({
          to: user.phone,
          rejectUrl,
          schoolName,
        });
      } catch (err) {
        this.logger.warn(`submitPasswordChangeRequest: target sms notify failed: ${(err as Error).message}`);
      }
    }
  }

  /**
   * Public reject path — user clicks the link in the heads-up email/SMS we
   * sent them and marks their own pending request as REJECTED. Validated by
   * HMAC over the request id with JWT_SECRET so only links we issued work
   * (no enumeration). Returns the resolved status so the controller can
   * render a confirmation page.
   */
  async rejectViaPublicLink(requestId: string, providedSig: string): Promise<'rejected' | 'already_resolved' | 'expired' | 'not_found' | 'bad_sig'> {
    const expected = this.signRequestId(requestId);
    if (!providedSig || providedSig.length !== expected.length) return 'bad_sig';
    // Constant-time compare to avoid leaking via timing.
    let mismatch = 0;
    for (let i = 0; i < expected.length; i++) {
      mismatch |= expected.charCodeAt(i) ^ providedSig.charCodeAt(i);
    }
    if (mismatch !== 0) return 'bad_sig';

    const req = await this.prisma.passwordChangeRequest.findUnique({ where: { id: requestId } });
    if (!req) return 'not_found';
    if (req.status !== 'PENDING') return 'already_resolved';
    if (req.expiresAt.getTime() < Date.now()) {
      await this.prisma.passwordChangeRequest.update({
        where: { id: requestId },
        data: { status: 'EXPIRED', resolvedAt: new Date() },
      });
      return 'expired';
    }
    await this.prisma.passwordChangeRequest.update({
      where: { id: requestId },
      data: { status: 'REJECTED', resolvedAt: new Date(), plainPassword: null } as any,
    });
    return 'rejected';
  }

  /** HMAC-SHA256(requestId) using JWT_SECRET. Hex digest, lowercase. */
  private signRequestId(requestId: string): string {
    const secret = process.env.JWT_SECRET || 'dev-secret-do-not-use-in-prod';
    return createHmac('sha256', secret).update(requestId).digest('hex');
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
      this.prisma.user.update({
        where: { id: req.userId },
        data: {
          password: req.passwordHash,
          // Only overwrite plainPassword if the request carried it (older
          // pending requests pre-migration may not have one).
          ...((req as any).plainPassword ? { plainPassword: (req as any).plainPassword } : {}),
        },
      }),
      // Clear plainPassword from the request once consumed.
      this.prisma.passwordChangeRequest.update({
        where: { id: requestId },
        data: { status: 'APPROVED', resolvedAt: new Date(), plainPassword: null } as any,
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
      data: { status: 'REJECTED', resolvedAt: new Date(), plainPassword: null } as any,
    });
  }

  /** Pending requests routed to a specific admin, newest first. */
  async listPendingForAdmin(adminId: string): Promise<any[]> {
    const rows = await this.prisma.passwordChangeRequest.findMany({
      where: { toAdminId: adminId, status: 'PENDING', expiresAt: { gt: new Date() } },
      orderBy: { createdAt: 'desc' },
      include: {
        user: { select: { id: true, name: true, nameEn: true, email: true, username: true, phone: true } as any } as any,
      } as any,
    }) as any[];
    return rows.map((r: any) => ({
      id: r.id,
      requesterName: (r.user?.nameEn || r.user?.name || 'A user').toString(),
      requesterEmail: r.user?.email,
      requesterUsername: r.user?.username,
      // Prefer the phone the requester typed at submit time (their proof of
      // contact). Fall back to whatever's on their user record.
      requesterPhone: r.requesterPhone || r.user?.phone || null,
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
      this.prisma.user.update({ where: { id: row.userId }, data: { password: hash, plainPassword: pw } }),
      this.prisma.passwordResetToken.update({ where: { id: row.id }, data: { usedAt: new Date() } }),
      // Invalidate any sibling tokens so they can't be redeemed either.
      this.prisma.passwordResetToken.updateMany({
        where: { userId: row.userId, usedAt: null, id: { not: row.id } },
        data: { usedAt: new Date() },
      }),
    ]);
  }
}
