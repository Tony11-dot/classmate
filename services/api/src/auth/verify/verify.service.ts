import { BadRequestException, ForbiddenException, Injectable, Logger, NotFoundException } from '@nestjs/common';
import * as crypto from 'crypto';
import { PrismaService } from '../../prisma/prisma.service';
import { EmailService } from '../password-reset/email.service';
import { SmsService } from '../password-reset/sms.service';

export type Channel = 'email' | 'sms';
export type Kind = 'verify-current' | 'change';

/** How long a freshly issued 6-digit code is good for. */
const CODE_TTL_MIN = 15;
/** Max guesses against a single code before we refuse it — burn the row. */
const MAX_ATTEMPTS = 5;
/** Don't let users spam new codes for the same purpose. */
const COOLDOWN_SECONDS = 30;

@Injectable()
export class VerifyService {
  private readonly logger = new Logger(VerifyService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly email: EmailService,
    private readonly sms: SmsService,
  ) {}

  // ── start: issue + send a code ──────────────────────────────────────────────

  /**
   * Issues a verification code and sends it via the requested channel.
   *
   * When `newValue` is provided, this is a CHANGE flow: the code is sent to
   * the user's CURRENT email/phone (proving they own what they're moving
   * away from) and the change is applied later on confirm.
   *
   * When `newValue` is omitted, this is a verify-current flow: the code is
   * sent to (and on confirm marks verified) the user's current email/phone.
   *
   * If the user has no current value at all, the code goes to `newValue` and
   * acts as a first-time set + verify in one step.
   */
  async startVerification(args: {
    userId: string;
    channel: Channel;
    newValue?: string | null;
  }): Promise<{ ok: true; target: string; expiresInMinutes: number; sent: boolean }> {
    const { userId, channel } = args;
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, email: true, phone: true, name: true, school: { select: { name: true } } } as any,
    }) as any;
    if (!user) throw new NotFoundException('User not found');

    const rawCurrent: string | null = channel === 'email' ? (user.email ?? null) : (user.phone ?? null);
    const newValue = args.newValue?.trim() || null;

    // A stored value only counts as "current" for the change flow if it's
    // actually deliverable. Legacy rows can carry phones without the leading
    // `+` (early signup before E.164 was enforced) or empty/garbage emails;
    // in those cases we can't send a verification code to the old value, so
    // treat the change as a first-time SET (code goes to the new value).
    const looksDeliverable = (v: string | null): boolean => {
      if (!v) return false;
      return channel === 'email' ? v.includes('@') : v.startsWith('+');
    };
    const current = looksDeliverable(rawCurrent) ? rawCurrent! : null;

    // Pick the address the code is actually sent TO. CHANGE flows send to the
    // OLD value; first-time SET (no current) sends to the new value; pure
    // verify of the current sends to the current.
    let target: string;
    let kind: Kind;
    if (newValue && current) {
      if (newValue.toLowerCase() === current.toLowerCase()) {
        throw new BadRequestException('New value is the same as the current one');
      }
      // Standard change flow: prove ownership of OLD before swapping.
      target = current;
      kind = 'change';
    } else if (newValue && !current) {
      // First-time set, or legacy-malformed current — send code to NEW value.
      target = newValue;
      kind = 'change';
    } else if (current) {
      // Verifying the current value.
      target = current;
      kind = 'verify-current';
    } else {
      throw new BadRequestException(
        channel === 'email'
          ? 'No email on file — provide a newValue to set + verify in one step.'
          : 'No phone on file — provide a newValue to set + verify in one step.',
      );
    }

    if (channel === 'email' && !target.includes('@')) {
      throw new BadRequestException('Target is not a valid email address');
    }
    if (channel === 'sms' && !target.startsWith('+')) {
      throw new BadRequestException('Phone must be in E.164 format (e.g. +15551234567)');
    }

    // Rate-limit: at most one new code per (user, channel, kind) every COOLDOWN_SECONDS.
    const recent = await this.prisma.verificationCode.findFirst({
      where: { userId, channel, kind, createdAt: { gt: new Date(Date.now() - COOLDOWN_SECONDS * 1000) } },
      orderBy: { createdAt: 'desc' },
      select: { id: true, createdAt: true },
    });
    if (recent && process.env.NODE_ENV !== 'test') {
      const waitSec = Math.ceil((recent.createdAt.getTime() + COOLDOWN_SECONDS * 1000 - Date.now()) / 1000);
      throw new BadRequestException(`Please wait ${waitSec}s before requesting another code.`);
    }

    // Invalidate any older live codes for the same (user, channel, kind) so
    // the freshly issued one is unambiguously the right one to redeem.
    await this.prisma.verificationCode.updateMany({
      where: { userId, channel, kind, usedAt: null },
      data: { usedAt: new Date() },
    });

    const rawCode = randomDigits(6);
    const codeHash = sha256(rawCode);
    const expiresAt = new Date(Date.now() + CODE_TTL_MIN * 60 * 1000);

    await this.prisma.verificationCode.create({
      data: {
        userId,
        channel,
        kind,
        target,
        newValue,
        codeHash,
        expiresAt,
      },
    });

    const schoolName: string | null = user.school?.name ?? null;
    let sent = false;
    try {
      if (channel === 'email') {
        sent = await this.sendEmailCode({ to: target, code: rawCode, schoolName });
      } else {
        sent = await this.sendSmsCode({ to: target, code: rawCode, schoolName });
      }
    } catch (err) {
      this.logger.error(`Failed to send verify code to ${target}: ${(err as Error).message}`);
      // Don't leak the failure to the client — they can request again.
      sent = false;
    }

    return { ok: true, target: maskTarget(target, channel), expiresInMinutes: CODE_TTL_MIN, sent };
  }

  // ── confirm: redeem the code, mark verified or apply change ─────────────────

  async confirmVerification(args: {
    userId: string;
    channel: Channel;
    code: string;
    /** Required when redeeming a 'change' code. */
    newValue?: string | null;
  }): Promise<{ ok: true; changed: boolean }> {
    const { userId, channel } = args;
    const code = String(args.code ?? '').trim();
    if (!/^\d{4,8}$/.test(code)) throw new BadRequestException('Invalid code format');

    const codeHash = sha256(code);
    const row = await this.prisma.verificationCode.findFirst({
      where: { userId, channel, usedAt: null, expiresAt: { gt: new Date() } },
      orderBy: { createdAt: 'desc' },
    });
    if (!row) throw new ForbiddenException('No active verification code. Request a new one.');

    if (row.attempts >= MAX_ATTEMPTS) {
      throw new ForbiddenException('Too many wrong attempts. Request a new code.');
    }

    if (row.codeHash !== codeHash) {
      await this.prisma.verificationCode.update({
        where: { id: row.id },
        data: { attempts: { increment: 1 } },
      });
      throw new ForbiddenException('Incorrect code');
    }

    // Mark this row consumed up-front so nothing can re-redeem it.
    await this.prisma.verificationCode.update({
      where: { id: row.id },
      data: { usedAt: new Date() },
    });

    if (row.kind === 'verify-current') {
      await this.prisma.user.update({
        where: { id: userId },
        data: channel === 'email'
          ? { emailVerifiedAt: new Date() } as any
          : { phoneVerifiedAt: new Date() } as any,
      });
      return { ok: true, changed: false };
    }

    // CHANGE flow: the row was issued for { newValue: row.newValue }. Honor
    // that even if the caller forgot to pass it, but if they passed one
    // different, reject — could be a tampered client.
    const intended = row.newValue?.trim() ?? '';
    const provided = (args.newValue ?? '').trim();
    if (provided && intended && provided.toLowerCase() !== intended.toLowerCase()) {
      throw new ForbiddenException('newValue does not match the value this code was issued for.');
    }
    const finalNewValue = provided || intended;
    if (!finalNewValue) throw new BadRequestException('newValue is required to apply a change');

    // Format guard mirrors startVerification.
    if (channel === 'email' && !finalNewValue.includes('@')) {
      throw new BadRequestException('newValue is not a valid email address');
    }
    if (channel === 'sms' && !finalNewValue.startsWith('+')) {
      throw new BadRequestException('newValue must be in E.164 format');
    }

    // Reject if some other account already owns the new value (global unique).
    if (channel === 'email') {
      const conflict = await this.prisma.user.findFirst({ where: { email: finalNewValue.toLowerCase() } });
      if (conflict && conflict.id !== userId) {
        throw new BadRequestException('That email is already in use by another account.');
      }
    }

    await this.prisma.user.update({
      where: { id: userId },
      data: channel === 'email'
        ? { email: finalNewValue.toLowerCase(), emailVerifiedAt: null } as any
        : { phone: finalNewValue, phoneVerifiedAt: null } as any,
    });

    return { ok: true, changed: true };
  }

  // ── tiny status helper used by /me to populate the profile screen ───────────

  async statusFor(userId: string): Promise<{
    email: string | null; emailVerifiedAt: string | null;
    phone: string | null; phoneVerifiedAt: string | null;
  }> {
    const u = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { email: true, phone: true, emailVerifiedAt: true, phoneVerifiedAt: true } as any,
    }) as any;
    return {
      email: u?.email ?? null,
      emailVerifiedAt: u?.emailVerifiedAt ? new Date(u.emailVerifiedAt).toISOString() : null,
      phone: u?.phone ?? null,
      phoneVerifiedAt: u?.phoneVerifiedAt ? new Date(u.phoneVerifiedAt).toISOString() : null,
    };
  }

  // ── senders ──────────────────────────────────────────────────────────────────

  private async sendEmailCode(args: { to: string; code: string; schoolName: string | null }): Promise<boolean> {
    return this.email.sendVerificationCode({
      to: args.to,
      code: args.code,
      schoolName: args.schoolName,
      expiresInMinutes: CODE_TTL_MIN,
    });
  }

  private async sendSmsCode(args: { to: string; code: string; schoolName: string | null }): Promise<boolean> {
    if (!this.sms.isConfigured) {
      this.logger.warn(`Twilio not configured; would have texted verify code ${args.code} to ${args.to}`);
      return false;
    }
    const label = args.schoolName ?? 'ClassMate';
    const body = `${label} code: ${args.code} (expires in ${CODE_TTL_MIN} min). If you didn't ask, ignore this.`;
    await this.sms.send(args.to, body);
    return true;
  }
}

// ── utils ─────────────────────────────────────────────────────────────────────

function randomDigits(len: number): string {
  const digits = '0123456789';
  let out = '';
  for (let i = 0; i < len; i++) out += digits[crypto.randomInt(0, digits.length)];
  return out;
}

function sha256(s: string): string {
  return crypto.createHash('sha256').update(s).digest('hex');
}

/** Returns a partly redacted copy of an email/phone for echoing back to the UI. */
function maskTarget(value: string, channel: Channel): string {
  if (channel === 'email') {
    const [local, domain] = value.split('@');
    if (!domain || local.length <= 2) return value.replace(/.(?=.{2})/g, '•');
    return `${local[0]}${'•'.repeat(Math.max(1, local.length - 2))}${local[local.length - 1]}@${domain}`;
  }
  // SMS: keep country code + last 2 digits, mask the rest.
  if (value.length <= 5) return value;
  return `${value.slice(0, value.length - 6)}••••${value.slice(-2)}`;
}
