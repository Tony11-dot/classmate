import { RegisterDto } from './dto/register.dto';
import { BadRequestException, Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { deriveUsernameCandidate, ensureUniqueUsername } from '../common/username';
import { CURRENT_CONSENT_VERSION, parseBirthDate } from '../common/consent';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwt: JwtService,
  ) {}

  async login(identifier: string, password: string) {
  // identifier can be email or username
  const isEmail = identifier.includes('@');
  const user = await this.prisma.user.findFirst({
    where: isEmail ? { email: identifier } : { OR: [{ username: identifier }, { email: identifier }] },
    include: { roles: true },
  });

  if (!user) return null;

  const ok = await bcrypt.compare(password, user.password);

  if (!ok) return null;

  const student = await this.prisma.studentProfile.findUnique({
    where: { userId: user.id },
  });

  const token = this.jwt.sign({
    sub: user.id,
    roles: user.roles.map((r) => r.role),
    actingStudentId: user.id,
    cohortId: student ? student.cohortId : null,
  });

  return { token };
}

  async register(dto: RegisterDto) {
    const nEmail = String((dto as any)?.email ?? '').trim();
    const nName = String((dto as any)?.name ?? '').trim();
    const nPassword = String((dto as any)?.password ?? '').trim();
    const nUsername = String((dto as any)?.username ?? '').trim().toLowerCase();
    if (!nEmail || !nName || !nPassword) throw new BadRequestException('Invalid register payload');
    const email = nEmail.toLowerCase();
    const name = nName;
    const existing = await this.prisma.user.findUnique({ where: { email } });
    if (existing) return { ok: false, code: 'EMAIL_TAKEN' };

    const hash = await bcrypt.hash(nPassword, 10);

    // Username is the app's primary login identifier — every user must
    // have one. If the caller supplied it (web/manual signup), use that;
    // otherwise derive one from the email local-part and ensure uniqueness.
    const usernameCandidate = nUsername.length > 0
        ? nUsername.replace(/[^a-z0-9_.-]/g, '')
        : deriveUsernameCandidate(email, name);
    const username = await ensureUniqueUsername(this.prisma, usernameCandidate);

    // Record the lawful basis for processing this account's data. Completing
    // signup through the app UI (which shows the explicit consent checkbox)
    // constitutes acceptance; we stamp it here so every new account carries a
    // consent timestamp + policy version. birthDate/guardianConsent are stored
    // when the client supplies them.
    const birthDate = parseBirthDate((dto as any)?.birthDate);
    const consentVersion =
      String((dto as any)?.consentVersion ?? '').trim() || CURRENT_CONSENT_VERSION;

    const user = await this.prisma.user.create({
      data: {
        email,
        username,
        name,
        password: hash,
        birthDate: birthDate ?? undefined,
        consentAcceptedAt: new Date(),
        consentVersion,
        guardianConsent: !!(dto as any)?.guardianConsent,
        roles: { create: [{ role: 'STUDENT' }] },
      } as any,
      include: { roles: true },
    });

    const token = this.jwt.sign({
      sub: user.id,
      roles: user.roles.map((r) => r.role),
    });

    return {
  token,
  user: {
    id: user.id,
    email: user.email,
    roles: user.roles.map((r) => r.role),
  }
};
  }
}
