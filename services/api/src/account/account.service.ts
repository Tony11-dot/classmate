import {
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { CURRENT_CONSENT_VERSION, parseBirthDate } from '../common/consent';

/**
 * Self-service data-subject rights (Israel Privacy Amendment 13 / general
 * data-protection): a user can EXPORT a copy of their own data and DELETE
 * their own account. Everything here is strictly scoped to the caller's own
 * user id — no cross-user access. PII fields come back decrypted (the Prisma
 * layer transparently decrypts the caller's own values for their own export).
 */
@Injectable()
export class AccountService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Record the caller's acceptance of the Privacy Policy + Terms. Used by the
   * first-login consent gate for school-provisioned users (who never went
   * through self-signup). Idempotent — safe to call again on re-consent.
   */
  async recordConsent(
    userId: string,
    body?: { guardianConsent?: boolean; birthDate?: string; consentVersion?: string },
  ) {
    const birthDate = parseBirthDate(body?.birthDate);
    await this.prisma.user.update({
      where: { id: userId },
      data: {
        consentAcceptedAt: new Date(),
        consentVersion:
          String(body?.consentVersion ?? '').trim() || CURRENT_CONSENT_VERSION,
        guardianConsent: !!body?.guardianConsent,
        ...(birthDate ? { birthDate } : {}),
      } as any,
    });
    return { ok: true, consentVersion: CURRENT_CONSENT_VERSION };
  }

  /** A machine-readable copy of everything tied to this account. */
  async exportMyData(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        roles: true,
        studentProfile: true,
        notifications: true,
        deviceTokens: true,
        subscriptions: true,
        parentLinks: true,
        childLinks: true,
      },
    });
    if (!user) throw new NotFoundException('Account not found');

    // Never hand back the password hash in an export.
    const { password: _pw, ...safeUser } = user as any;

    return {
      exportedAt: new Date().toISOString(),
      account: safeUser,
      note:
        'This is a copy of the personal data associated with your ClassMate account. ' +
        'Academic records (grades, attendance) are maintained by your school as the data controller.',
    };
  }

  /**
   * Permanently delete the caller's own account. Requires the current password
   * as confirmation so a stolen/borrowed session can't nuke an account. The
   * DB cascade removes the user's owned rows (same path admin deletion uses).
   */
  async deleteMyAccount(userId: string, currentPassword?: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, password: true },
    });
    if (!user) throw new NotFoundException('Account not found');

    const ok =
      !!currentPassword &&
      (await bcrypt.compare(String(currentPassword), user.password));
    if (!ok) {
      throw new UnauthorizedException(
        'Current password is required to delete your account.',
      );
    }

    await this.prisma.user.delete({ where: { id: userId } });
    return { ok: true };
  }
}
