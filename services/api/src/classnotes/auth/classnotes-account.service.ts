import {
  BadRequestException,
  ConflictException,
  Injectable,
  Logger,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { createHash, randomBytes } from 'crypto';
import { PrismaService } from '../../prisma/prisma.service';
import { EmailService } from '../../auth/password-reset/email.service';

/// Marks a JWT as belonging to a ClassNotes account rather than a ClassMate
/// user. `JwtStrategy` branches on it, and it is the ONLY thing that makes the
/// two token families distinguishable — both are signed with the same secret,
/// so without it a ClassNotes id would be looked up in `User`, miss, and 401.
export const CLASSNOTES_TOKEN_KIND = 'classnotes';

const BCRYPT_COST = 12;
const RESET_TTL_MINUTES = 60;

export type ClassNotesAccountProfile = {
  id: string;
  email: string;
  name: string;
  createdAt: Date;
};

/// ClassNotes' own sign-in: its own accounts, its own password hashes, its own
/// tokens. Nothing here reads or writes the ClassMate `User` table.
///
/// It lives inside this already-deployed API rather than in a service of its
/// own because the data these accounts own — `ClassNotesNotebook`,
/// `ClassNotesPage`, `ClassNotesSettings` — is already here. A separate auth
/// service would have to be called by this one on every library request just to
/// find out who was asking.
@Injectable()
export class ClassNotesAccountService {
  private readonly logger = new Logger('ClassNotesAccountService');

  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly email: EmailService,
  ) {}

  /// Lower-cased and trimmed, always, on every path that accepts an email —
  /// signup, login and reset must agree about what one account is, or a user
  /// who signs up as "Tony@x.com" cannot sign in as "tony@x.com".
  static normalizeEmail(raw: string): string {
    return String(raw ?? '').trim().toLowerCase();
  }

  /// Rejects what the e-mail column cannot usefully hold. Deliberately loose —
  /// the only authority on whether an address exists is whether the reset mail
  /// arrives, and an over-strict pattern rejects real addresses.
  static isPlausibleEmail(email: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(email);
  }

  /// The password floor. Eight characters is the NIST recommendation and the
  /// bar every store-review checklist uses; nothing here caps the length,
  /// because bcrypt handles long inputs and a cap only hurts passphrases.
  static passwordProblem(password: string): string | null {
    const value = String(password ?? '');
    if (value.length < 8) return 'Password must be at least 8 characters.';
    if (value.length > 200) return 'Password must be under 200 characters.';
    return null;
  }

  private profile(row: {
    id: string;
    email: string;
    name: string;
    createdAt: Date;
  }): ClassNotesAccountProfile {
    return { id: row.id, email: row.email, name: row.name, createdAt: row.createdAt };
  }

  /// A 90-day token, matching the ClassMate side's "stay signed in" lifetime.
  /// `kind` is what tells `JwtStrategy` which table to hydrate from.
  /// Where the reset link points: this API's OWN `/classnotes/auth/reset` page,
  /// not ClassMate's web reset page, which reads a different token table.
  /// `CLASSNOTES_RESET_URL_BASE` overrides the whole URL (minus the query) for a
  /// staging host or a future web front end.
  static resetPageBase(): string {
    const explicit = (process.env.CLASSNOTES_RESET_URL_BASE ?? '').trim().replace(/\/+$/, '');
    if (explicit) return explicit;
    const api = (process.env.PUBLIC_API_URL ?? process.env.PUBLIC_APP_URL ?? '')
      .trim()
      .replace(/\/+$/, '');
    const host = api || 'https://pacific-enchantment-production-7a80.up.railway.app';
    return `${host}/classnotes/auth/reset`;
  }

  private sign(accountId: string): string {
    return this.jwt.sign({ sub: accountId, kind: CLASSNOTES_TOKEN_KIND });
  }

  async register(args: { email: string; password: string; name?: string }) {
    const email = ClassNotesAccountService.normalizeEmail(args.email);
    if (!ClassNotesAccountService.isPlausibleEmail(email)) {
      throw new BadRequestException('Enter a valid email address.');
    }
    const problem = ClassNotesAccountService.passwordProblem(args.password);
    if (problem) throw new BadRequestException(problem);

    const existing = await this.prisma.classNotesAccount.findUnique({
      where: { email },
      select: { id: true },
    });
    if (existing) {
      throw new ConflictException('That email already has a ClassNotes account.');
    }

    const passwordHash = await bcrypt.hash(args.password, BCRYPT_COST);
    const account = await this.prisma.classNotesAccount.create({
      data: {
        email,
        passwordHash,
        name: String(args.name ?? '').trim() || email.split('@')[0],
      },
      select: { id: true, email: true, name: true, createdAt: true },
    });
    this.logger.log(`ClassNotes account created (${account.id})`);
    return { token: this.sign(account.id), account: this.profile(account) };
  }

  async login(args: { email: string; password: string }) {
    const email = ClassNotesAccountService.normalizeEmail(args.email);
    const account = await this.prisma.classNotesAccount.findUnique({
      where: { email },
    });
    // One message and one code for "no such account" and "wrong password", so
    // this endpoint cannot be used to enumerate which emails have accounts.
    const invalid = new UnauthorizedException('Incorrect email or password.');
    if (!account) throw invalid;
    const ok = await bcrypt.compare(String(args.password ?? ''), account.passwordHash);
    if (!ok) throw invalid;
    return { token: this.sign(account.id), account: this.profile(account) };
  }

  /// Hydrates the request user for a `kind: 'classnotes'` token. Returns null
  /// when the account is gone or the token predates a password change, which
  /// `JwtStrategy` turns into a 401.
  async resolveToken(accountId: string, issuedAt: number | undefined) {
    const account = await this.prisma.classNotesAccount.findUnique({
      where: { id: accountId },
      select: {
        id: true,
        email: true,
        name: true,
        createdAt: true,
        tokenInvalidBefore: true,
      },
    });
    if (!account) return null;
    if (account.tokenInvalidBefore && issuedAt) {
      // JWT `iat` is in whole seconds, so compare at that granularity —
      // otherwise the token handed back by changePassword in the same second
      // would invalidate itself.
      const cutoff = Math.floor(account.tokenInvalidBefore.getTime() / 1000);
      if (issuedAt < cutoff) return null;
    }
    return this.profile(account);
  }

  async me(accountId: string): Promise<ClassNotesAccountProfile> {
    const account = await this.prisma.classNotesAccount.findUnique({
      where: { id: accountId },
      select: { id: true, email: true, name: true, createdAt: true },
    });
    if (!account) throw new NotFoundException('Account no longer exists.');
    return this.profile(account);
  }

  async updateName(accountId: string, name: string) {
    const trimmed = String(name ?? '').trim();
    if (!trimmed) throw new BadRequestException('Enter a name.');
    const account = await this.prisma.classNotesAccount.update({
      where: { id: accountId },
      data: { name: trimmed.slice(0, 120) },
      select: { id: true, email: true, name: true, createdAt: true },
    });
    return this.profile(account);
  }

  /// Changing a password ends every OTHER session and hands this one a fresh
  /// token, so the device that made the change stays signed in.
  async changePassword(accountId: string, currentPassword: string, newPassword: string) {
    const problem = ClassNotesAccountService.passwordProblem(newPassword);
    if (problem) throw new BadRequestException(problem);
    const account = await this.prisma.classNotesAccount.findUnique({
      where: { id: accountId },
    });
    if (!account) throw new NotFoundException('Account no longer exists.');
    const ok = await bcrypt.compare(String(currentPassword ?? ''), account.passwordHash);
    if (!ok) throw new UnauthorizedException('That is not your current password.');

    await this.prisma.classNotesAccount.update({
      where: { id: accountId },
      data: {
        passwordHash: await bcrypt.hash(newPassword, BCRYPT_COST),
        tokenInvalidBefore: new Date(),
      },
    });
    return { token: this.sign(accountId) };
  }

  /// Deletes the account AND everything it owns. App Store guideline 5.1.1(v)
  /// requires an app that creates accounts to delete them from inside the app,
  /// and "delete" has to mean the notebooks too — the rows no longer cascade
  /// from a user table, so they are removed here explicitly.
  async deleteAccount(accountId: string, password: string) {
    const account = await this.prisma.classNotesAccount.findUnique({
      where: { id: accountId },
    });
    if (!account) throw new NotFoundException('Account no longer exists.');
    const ok = await bcrypt.compare(String(password ?? ''), account.passwordHash);
    if (!ok) throw new UnauthorizedException('Incorrect password.');

    await this.prisma.$transaction([
      this.prisma.classNotesPage.deleteMany({ where: { userId: accountId } }),
      this.prisma.classNotesNotebook.deleteMany({ where: { userId: accountId } }),
      this.prisma.classNotesShelf.deleteMany({ where: { userId: accountId } }),
      this.prisma.classNotesSettings.deleteMany({ where: { userId: accountId } }),
      this.prisma.classNotesAccount.delete({ where: { id: accountId } }),
    ]);
    this.logger.log(`ClassNotes account deleted (${accountId})`);
    return { deleted: true };
  }

  /// Sends a reset link. ALWAYS reports success, whether or not the address has
  /// an account: the response is visible to anyone, and a different answer for
  /// a registered address turns this into an account-existence oracle.
  async requestPasswordReset(rawEmail: string) {
    const email = ClassNotesAccountService.normalizeEmail(rawEmail);
    const sent = {
      sent: true,
      message: 'If that email has a ClassNotes account, a reset link is on its way.',
    };
    if (!ClassNotesAccountService.isPlausibleEmail(email)) return sent;

    const account = await this.prisma.classNotesAccount.findUnique({
      where: { email },
      select: { id: true, email: true, name: true },
    });
    if (!account) return sent;

    // The raw token goes in the e-mail and is never stored; only its hash is,
    // so this table is useless to anyone who reads it.
    const raw = randomBytes(32).toString('hex');
    const tokenHash = createHash('sha256').update(raw).digest('hex');
    const expiresAt = new Date(Date.now() + RESET_TTL_MINUTES * 60_000);
    await this.prisma.classNotesPasswordResetToken.create({
      data: { accountId: account.id, tokenHash, expiresAt },
    });

    const resetUrl = `${ClassNotesAccountService.resetPageBase()}?token=${raw}`;
    try {
      await this.email.sendPasswordReset({
        to: account.email,
        recipientName: account.name,
        schoolName: null,
        resetUrl,
        expiresInMinutes: RESET_TTL_MINUTES,
      });
    } catch (error) {
      // A mail failure must not tell the caller whether the account exists, so
      // it is logged and swallowed rather than surfaced.
      this.logger.error(
        `ClassNotes reset mail failed: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
    return sent;
  }

  async consumePasswordReset(rawToken: string, newPassword: string) {
    const problem = ClassNotesAccountService.passwordProblem(newPassword);
    if (problem) throw new BadRequestException(problem);
    const tokenHash = createHash('sha256').update(String(rawToken ?? '')).digest('hex');
    const row = await this.prisma.classNotesPasswordResetToken.findUnique({
      where: { tokenHash },
    });
    if (!row || row.usedAt || row.expiresAt.getTime() < Date.now()) {
      throw new BadRequestException('That reset link has expired or already been used.');
    }
    await this.prisma.$transaction([
      this.prisma.classNotesAccount.update({
        where: { id: row.accountId },
        data: {
          passwordHash: await bcrypt.hash(newPassword, BCRYPT_COST),
          tokenInvalidBefore: new Date(),
        },
      }),
      this.prisma.classNotesPasswordResetToken.update({
        where: { id: row.id },
        data: { usedAt: new Date() },
      }),
      // Every other outstanding link for this account dies with it.
      this.prisma.classNotesPasswordResetToken.updateMany({
        where: { accountId: row.accountId, usedAt: null },
        data: { usedAt: new Date() },
      }),
    ]);
    return { reset: true };
  }
}
