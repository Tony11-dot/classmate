import { Test, TestingModule } from '@nestjs/testing';
import { JwtService } from '@nestjs/jwt';
import {
  BadRequestException,
  ConflictException,
  UnauthorizedException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../../prisma/prisma.service';
import { EmailService } from '../../auth/password-reset/email.service';
import {
  CLASSNOTES_TOKEN_KIND,
  ClassNotesAccountService,
} from './classnotes-account.service';

/// A ClassNotes account row, as the service selects it.
function account(over: Partial<any> = {}) {
  return {
    id: 'acc-1',
    email: 'tony@example.com',
    name: 'Tony',
    passwordHash: bcrypt.hashSync('correct-horse', 4),
    createdAt: new Date('2026-01-01T00:00:00Z'),
    tokenInvalidBefore: null,
    ...over,
  };
}

describe('ClassNotesAccountService', () => {
  let service: ClassNotesAccountService;
  let prisma: any;
  let email: any;

  beforeEach(async () => {
    prisma = {
      classNotesAccount: {
        findUnique: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
        delete: jest.fn(),
      },
      classNotesPasswordResetToken: {
        create: jest.fn(),
        findUnique: jest.fn(),
        update: jest.fn(),
        updateMany: jest.fn(),
      },
      classNotesPage: { deleteMany: jest.fn() },
      classNotesNotebook: { deleteMany: jest.fn() },
      classNotesShelf: { deleteMany: jest.fn() },
      classNotesSettings: { deleteMany: jest.fn() },
      $transaction: jest.fn(async (ops: any[]) => ops),
    };
    email = { sendPasswordReset: jest.fn(), isConfigured: true };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ClassNotesAccountService,
        { provide: PrismaService, useValue: prisma },
        { provide: EmailService, useValue: email },
        {
          provide: JwtService,
          useValue: { sign: jest.fn((p: any) => `signed:${JSON.stringify(p)}`) },
        },
      ],
    }).compile();
    service = module.get(ClassNotesAccountService);
  });

  // ─────────────── identity hygiene ───────────────

  it('treats one address as one account however it was typed', () => {
    // Signup lower-cases, so login has to as well or the account becomes
    // unreachable from the keyboard that created it.
    expect(ClassNotesAccountService.normalizeEmail('  Tony@Example.COM ')).toBe(
      'tony@example.com',
    );
  });

  it('refuses a password under the eight-character floor and accepts one at it', () => {
    expect(ClassNotesAccountService.passwordProblem('short12')).not.toBeNull();
    expect(ClassNotesAccountService.passwordProblem('exactly8')).toBeNull();
    expect(ClassNotesAccountService.passwordProblem('a'.repeat(201))).not.toBeNull();
  });

  it('rejects addresses the column cannot usefully hold', () => {
    expect(ClassNotesAccountService.isPlausibleEmail('tony@example.com')).toBe(true);
    expect(ClassNotesAccountService.isPlausibleEmail('tony@example')).toBe(false);
    expect(ClassNotesAccountService.isPlausibleEmail('not an email')).toBe(false);
  });

  // ─────────────── register ───────────────

  it('creates an account, hashes the password, and never stores the plaintext', async () => {
    prisma.classNotesAccount.findUnique.mockResolvedValue(null);
    prisma.classNotesAccount.create.mockImplementation(async ({ data }: any) => ({
      id: 'acc-new',
      email: data.email,
      name: data.name,
      createdAt: new Date(),
    }));

    const result = await service.register({
      email: ' Tony@Example.com ',
      password: 'correct-horse',
      name: '  Tony  ',
    });

    const written = prisma.classNotesAccount.create.mock.calls[0][0].data;
    expect(written.email).toBe('tony@example.com');
    expect(written.name).toBe('Tony');
    expect(written.passwordHash).not.toContain('correct-horse');
    expect(await bcrypt.compare('correct-horse', written.passwordHash)).toBe(true);
    expect(result.token).toContain(CLASSNOTES_TOKEN_KIND);
  });

  it('names a new account after the email when no name is given', async () => {
    prisma.classNotesAccount.findUnique.mockResolvedValue(null);
    prisma.classNotesAccount.create.mockImplementation(async ({ data }: any) => ({
      id: 'a',
      email: data.email,
      name: data.name,
      createdAt: new Date(),
    }));
    await service.register({ email: 'tony@example.com', password: 'correct-horse' });
    expect(prisma.classNotesAccount.create.mock.calls[0][0].data.name).toBe('tony');
  });

  it('refuses a second account on the same address', async () => {
    prisma.classNotesAccount.findUnique.mockResolvedValue({ id: 'acc-1' });
    await expect(
      service.register({ email: 'tony@example.com', password: 'correct-horse' }),
    ).rejects.toBeInstanceOf(ConflictException);
  });

  it('refuses to create an account with a weak password', async () => {
    prisma.classNotesAccount.findUnique.mockResolvedValue(null);
    await expect(
      service.register({ email: 'tony@example.com', password: 'abc' }),
    ).rejects.toBeInstanceOf(BadRequestException);
    expect(prisma.classNotesAccount.create).not.toHaveBeenCalled();
  });

  // ─────────────── login ───────────────

  it('signs a ClassNotes-kind token on a correct password', async () => {
    prisma.classNotesAccount.findUnique.mockResolvedValue(account());
    const result = await service.login({
      email: 'TONY@example.com',
      password: 'correct-horse',
    });
    const payload = JSON.parse(result.token.replace('signed:', ''));
    expect(payload).toEqual({ sub: 'acc-1', kind: CLASSNOTES_TOKEN_KIND });
    expect(result.account.email).toBe('tony@example.com');
  });

  it('cannot be used to find out which addresses have accounts', async () => {
    // A wrong password and an unknown address must be indistinguishable —
    // same exception type and the same message — or this endpoint enumerates
    // the user base.
    prisma.classNotesAccount.findUnique.mockResolvedValue(null);
    const missing = await service
      .login({ email: 'nobody@example.com', password: 'correct-horse' })
      .catch((e) => e);
    prisma.classNotesAccount.findUnique.mockResolvedValue(account());
    const wrong = await service
      .login({ email: 'tony@example.com', password: 'wrong-password' })
      .catch((e) => e);

    expect(missing).toBeInstanceOf(UnauthorizedException);
    expect(wrong).toBeInstanceOf(UnauthorizedException);
    expect(missing.message).toBe(wrong.message);
  });

  // ─────────────── token resolution / revocation ───────────────

  it('resolves a live token to its account', async () => {
    prisma.classNotesAccount.findUnique.mockResolvedValue(account());
    const resolved = await service.resolveToken('acc-1', 1_800_000_000);
    expect(resolved?.id).toBe('acc-1');
  });

  it('refuses a token for an account that no longer exists', async () => {
    prisma.classNotesAccount.findUnique.mockResolvedValue(null);
    expect(await service.resolveToken('gone', 1_800_000_000)).toBeNull();
  });

  it('refuses a token issued before the last password change, and accepts a later one', async () => {
    // The whole point of tokenInvalidBefore: changing a password ends the other
    // sessions NOW rather than leaving them live for the rest of the 90 days.
    const cutoff = new Date('2026-06-01T00:00:00Z');
    prisma.classNotesAccount.findUnique.mockResolvedValue(
      account({ tokenInvalidBefore: cutoff }),
    );
    const cutoffSeconds = Math.floor(cutoff.getTime() / 1000);
    expect(await service.resolveToken('acc-1', cutoffSeconds - 1)).toBeNull();
    expect(await service.resolveToken('acc-1', cutoffSeconds)).not.toBeNull();
  });

  // ─────────────── change password ───────────────

  it('requires the current password before changing it, and revokes other sessions', async () => {
    prisma.classNotesAccount.findUnique.mockResolvedValue(account());
    await expect(
      service.changePassword('acc-1', 'not-my-password', 'brand-new-one'),
    ).rejects.toBeInstanceOf(UnauthorizedException);
    expect(prisma.classNotesAccount.update).not.toHaveBeenCalled();

    await service.changePassword('acc-1', 'correct-horse', 'brand-new-one');
    const data = prisma.classNotesAccount.update.mock.calls[0][0].data;
    expect(await bcrypt.compare('brand-new-one', data.passwordHash)).toBe(true);
    expect(data.tokenInvalidBefore).toBeInstanceOf(Date);
  });

  // ─────────────── delete account ───────────────

  it('deletes the notebooks, shelves and settings along with the account', async () => {
    // These rows no longer cascade from a user table, so a delete that only
    // removed the account would leave the user's books on the server forever.
    prisma.classNotesAccount.findUnique.mockResolvedValue(account());
    await service.deleteAccount('acc-1', 'correct-horse');
    expect(prisma.classNotesPage.deleteMany).toHaveBeenCalledWith({
      where: { userId: 'acc-1' },
    });
    expect(prisma.classNotesNotebook.deleteMany).toHaveBeenCalledWith({
      where: { userId: 'acc-1' },
    });
    expect(prisma.classNotesShelf.deleteMany).toHaveBeenCalledWith({
      where: { userId: 'acc-1' },
    });
    expect(prisma.classNotesSettings.deleteMany).toHaveBeenCalledWith({
      where: { userId: 'acc-1' },
    });
    expect(prisma.classNotesAccount.delete).toHaveBeenCalledWith({
      where: { id: 'acc-1' },
    });
  });

  it('refuses to delete an account without the password', async () => {
    prisma.classNotesAccount.findUnique.mockResolvedValue(account());
    await expect(service.deleteAccount('acc-1', 'wrong')).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
    expect(prisma.$transaction).not.toHaveBeenCalled();
  });

  // ─────────────── password reset ───────────────

  it('reports the same thing whether or not the address has an account', async () => {
    prisma.classNotesAccount.findUnique.mockResolvedValue(null);
    const unknown = await service.requestPasswordReset('nobody@example.com');
    prisma.classNotesAccount.findUnique.mockResolvedValue(account());
    const known = await service.requestPasswordReset('tony@example.com');
    expect(unknown).toEqual(known);
    expect(known.sent).toBe(true);
  });

  it('emails a link and stores only its hash', async () => {
    prisma.classNotesAccount.findUnique.mockResolvedValue(account());
    await service.requestPasswordReset('tony@example.com');
    const stored = prisma.classNotesPasswordResetToken.create.mock.calls[0][0].data;
    const sentUrl = email.sendPasswordReset.mock.calls[0][0].resetUrl;
    const rawToken = new URL(sentUrl).searchParams.get('token')!;
    expect(rawToken).toBeTruthy();
    // The raw token is in the mail and NOT in the database.
    expect(stored.tokenHash).not.toBe(rawToken);
    expect(stored.tokenHash).toHaveLength(64);
    expect(stored.expiresAt.getTime()).toBeGreaterThan(Date.now());
  });

  it('still reports success when the mailer is broken', async () => {
    prisma.classNotesAccount.findUnique.mockResolvedValue(account());
    email.sendPasswordReset.mockRejectedValue(new Error('resend down'));
    await expect(service.requestPasswordReset('tony@example.com')).resolves.toEqual({
      sent: true,
      message: expect.any(String),
    });
  });

  it('refuses an expired, an already-used and an unknown reset token', async () => {
    const base = { id: 'tok', accountId: 'acc-1', tokenHash: 'h' };
    for (const row of [
      null,
      { ...base, usedAt: new Date(), expiresAt: new Date(Date.now() + 60_000) },
      { ...base, usedAt: null, expiresAt: new Date(Date.now() - 60_000) },
    ]) {
      prisma.classNotesPasswordResetToken.findUnique.mockResolvedValue(row);
      await expect(
        service.consumePasswordReset('raw-token', 'brand-new-one'),
      ).rejects.toBeInstanceOf(BadRequestException);
    }
  });

  it('consumes a valid reset token exactly once and kills the rest', async () => {
    prisma.classNotesPasswordResetToken.findUnique.mockResolvedValue({
      id: 'tok',
      accountId: 'acc-1',
      tokenHash: 'h',
      usedAt: null,
      expiresAt: new Date(Date.now() + 60_000),
    });
    await service.consumePasswordReset('raw-token', 'brand-new-one');
    expect(prisma.classNotesPasswordResetToken.update).toHaveBeenCalledWith(
      expect.objectContaining({ where: { id: 'tok' } }),
    );
    expect(prisma.classNotesPasswordResetToken.updateMany).toHaveBeenCalledWith(
      expect.objectContaining({ where: { accountId: 'acc-1', usedAt: null } }),
    );
  });
});
