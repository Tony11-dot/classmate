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
      select: { id: true, email: true, phone: true, name: true, nameEn: true, schoolId: true } as any,
    });
    if (byEmail) return byEmail as any;

    // Fallback to username (also lower-cased to match how it's stored).
    const byUsername = await this.prisma.user.findFirst({
      where: { username: lower } as any,
      select: { id: true, email: true, phone: true, name: true, nameEn: true, schoolId: true } as any,
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
