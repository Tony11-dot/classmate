import { Injectable, BadRequestException, NotFoundException, Logger } from '@nestjs/common';
import { randomBytes, createHash } from 'crypto';
import * as bcrypt from 'bcrypt';

import { PrismaService } from '../../prisma/prisma.service';
import { EmailService } from './email.service';
import { SmsService } from './sms.service';
import { encryptPassword } from '../../common/password-vault';

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
      select: { id: true, email: true, phone: true, name: true, schoolId: true, emailVerifiedAt: true, phoneVerifiedAt: true } as any,
    });
    if (byEmail) return byEmail as any;

    // Fallback to username (also lower-cased to match how it's stored).
    const byUsername = await this.prisma.user.findFirst({
      where: { username: lower } as any,
      select: { id: true, email: true, phone: true, name: true, schoolId: true, emailVerifiedAt: true, phoneVerifiedAt: true } as any,
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
    const recipientName = (user.name || '').trim() || null;

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
          id: true, email: true, phone: true, name: true, schoolId: true,
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
    const recipientName = (target.name || '').trim() || null;

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
      this.prisma.user.update({ where: { id: row.userId }, data: { password: hash, passwordEnc: encryptPassword(pw) } }),
      this.prisma.passwordResetToken.update({ where: { id: row.id }, data: { usedAt: new Date() } }),
      // Invalidate any sibling tokens so they can't be redeemed either.
      this.prisma.passwordResetToken.updateMany({
        where: { userId: row.userId, usedAt: null, id: { not: row.id } },
        data: { usedAt: new Date() },
      }),
    ]);
  }
}
