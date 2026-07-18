import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy as CustomStrategy } from 'passport-custom';
import { JwtService } from '@nestjs/jwt';
import type { Request } from 'express';
import { PrismaService } from '../prisma/prisma.service';
import { Role } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { deriveUsernameCandidate, ensureUniqueUsername } from '../common/username';

// Platform-owner allowlist. Any account whose email OR username matches is
// always granted MANAGER on every request — no DB row required, so it works
// even on a freshly-reset database. `Testarossa1939` is this account's
// password and is intentionally NOT referenced here. Additional managers are
// granted the role in the DB via the in-app "add manager" flow.
const MANAGER_ALLOWLIST_EMAILS = new Set(['aboudtony22@gmail.com']);
const MANAGER_ALLOWLIST_USERNAMES = new Set(['rafanadal22']);

function isManagerAllowlisted(email?: string | null, username?: string | null): boolean {
  if (email && MANAGER_ALLOWLIST_EMAILS.has(String(email).trim().toLowerCase())) return true;
  if (username && MANAGER_ALLOWLIST_USERNAMES.has(String(username).trim().toLowerCase())) return true;
  return false;
}

function rolesFromEmail(email: string): Role[] {
  const e = String(email || '').toLowerCase();
  if (e.includes('admin')) return [Role.ADMIN];
  if (e.includes('teacher')) return [Role.TEACHER];
  if (e.includes('secretary')) return [Role.SECRETARY];
  if (e.includes('parent')) return [Role.PARENT];
  return [Role.STUDENT];
}

function firstHeader(h: any, k1: string, k2: string): string | undefined {
  const v = h?.[k1] ?? h?.[k2];
  if (!v) return undefined;
  return String(Array.isArray(v) ? v[0] : v).trim() || undefined;
}

const DEV_COHORT_NAME = 'Dev Cohort';

type DevProvisionedStudent = {
  cohortId: string;
};

@Injectable()
export class JwtStrategy extends PassportStrategy(CustomStrategy, 'jwt') {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
  ) {
    super();
  }

  /** Verifies a signed JWT (issued by AuthService.login) and hydrates the
   * user object the rest of the app expects. Returns null if the token isn't
   * a valid JWT — caller falls through to the dev-token path. */
  private async tryRealJwt(token: string, schoolId?: string, actingStudentId?: string): Promise<any | null> {
    let payload: any;
    try {
      payload = await this.jwt.verifyAsync(token);
    } catch {
      // JWT failed verification (expired, or signed with a rotated secret).
      // Never log the token or its payload — that's credential material. The
      // client simply re-authenticates on a 401.
      return null;
    }
    const userId = String(payload?.sub ?? '').trim();
    if (!userId) {
      return null;
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { roles: true, studentProfile: { select: { cohortId: true } } } as any,
    }) as any;
    if (!user) {
      throw new UnauthorizedException('Account no longer exists');
    }

    // Server-side revocation: password change/reset stamps tokenInvalidBefore,
    // killing every previously issued token immediately instead of waiting out
    // the 90-day expiry. Compared at second granularity (JWT iat is seconds),
    // so the fresh token the change-password endpoint returns in the same
    // second stays valid.
    if (user.tokenInvalidBefore) {
      const iat = Number(payload?.iat ?? 0);
      if (iat && iat < Math.floor(user.tokenInvalidBefore.getTime() / 1000)) {
        throw new UnauthorizedException('Session expired — please sign in again');
      }
    }

    const roles: Role[] = (user.roles ?? []).map((r: any) => r.role);
    // Platform-owner bootstrap: always grant MANAGER to the allowlisted account.
    if (isManagerAllowlisted(user.email, user.username) && !roles.includes(Role.MANAGER)) {
      roles.push(Role.MANAGER);
    }
    const displayName = user.name ?? user.email?.split('@')[0] ?? '';
    const cohortId = user.studentProfile?.cohortId ?? payload?.cohortId ?? undefined;
    const resolvedSchoolId = user.schoolId ?? schoolId ?? null;

    return {
      sub: user.id,
      id: user.id,
      userId: user.id,
      email: user.email,
      username: user.username,
      roles,
      role: roles[0],
      name: displayName,
      displayName,
      fullName: displayName,
      ...(cohortId ? { cohortId } : {}),
      ...(actingStudentId ? { actingStudentId } : {}),
      ...(resolvedSchoolId ? { schoolId: resolvedSchoolId } : {}),
    };
  }

  private async ensureDevStudentProfile(userId: string): Promise<DevProvisionedStudent> {
    const existingProfile = await this.prisma.studentProfile.findUnique({
      where: { userId },
      select: { cohortId: true },
    });

    if (existingProfile?.cohortId) {
      return { cohortId: existingProfile.cohortId };
    }

    const cohort = await this.prisma.cohort.upsert({
      where: { name: DEV_COHORT_NAME },
      update: { grade: 10, grades: [10] },
      create: { name: DEV_COHORT_NAME, grade: 10, grades: [10] },
      select: { id: true },
    });

    await this.prisma.studentProfile.upsert({
      where: { userId },
      update: {
        cohortId: cohort.id,
        englishLevel: 4,
        mathLevel: 4,
      },
      create: {
        userId,
        cohortId: cohort.id,
        englishLevel: 4,
        mathLevel: 4,
      },
    });

    return { cohortId: cohort.id };
  }

  async validate(req: Request): Promise<any> {
    const h: any = (req as any)?.headers ?? {};
    const actingStudentId = firstHeader(h, 'x-acting-student-id', 'X-Acting-Student-Id');
    const schoolId = firstHeader(h, 'x-school-id', 'X-School-Id');

    const auth = String((req as any)?.headers?.authorization ?? '');
    const token = auth.replace(/^Bearer\s+/i, '').trim();

    // 1) Real signed JWT (issued by /auth/login). This is the main path in
    //    production — dev tokens are now off by default.
    if (token && !token.startsWith('dev-token-')) {
      const real = await this.tryRealJwt(token, schoolId, actingStudentId);
      if (real) return real;
    }

    // 2) Dev token shortcut — gated behind ALLOW_DEV_TOKEN=1. Used by the
    //    cmr local-dev alias and by smoke tests.
    if (
      (process.env.NODE_ENV !== 'production' || process.env.ALLOW_DEV_TOKEN === '1') &&
      token.startsWith('dev-token-')
    ) {
      const identifier = token.replace('dev-token-', '').trim().toLowerCase();
      const isEmail = identifier.includes('@');
      const inferredRoles = rolesFromEmail(identifier);

      try {
        const existing = await this.prisma.user.findFirst({
          where: isEmail
            ? { email: identifier }
            : { OR: [{ username: identifier }, { email: identifier }] },
          select: { id: true, email: true, username: true, name: true, schoolId: true, roles: { select: { role: true } } },
        }) as any;

        let userId = existing?.id;
        let userEmail = existing?.email ?? (isEmail ? identifier : null);
        let userName = existing?.name ?? identifier.split('@')[0];
        let cohortId: string | undefined;

        if (!userId) {
          const passwordHash = await bcrypt.hash(`dev-token:${identifier}`, 10);
          // Every user must have a username. If the dev-token identifier
          // is already a username, use it directly; otherwise derive from
          // the email local-part.
          const usernameCandidate = isEmail
              ? deriveUsernameCandidate(identifier)
              : identifier.toLowerCase().replace(/[^a-z0-9_.-]/g, '');
          const username = await ensureUniqueUsername(this.prisma, usernameCandidate);
          const created = await this.prisma.user.create({
            data: {
              ...(isEmail ? { email: identifier } : {}),
              username,
              name: identifier.split('@')[0],
              password: passwordHash,
            },
            select: { id: true, email: true, username: true, name: true },
          });
          userId = created.id;
          userEmail = created.email;
          userName = created.name ?? identifier.split('@')[0];
        }

        // Use DB roles if the user already exists, otherwise fall back to email inference
        const dbRoles: Role[] = existing?.roles?.map((r: any) => r.role) ?? [];
        const activeRoles = dbRoles.length > 0 ? dbRoles : inferredRoles;

        await this.prisma.userRole.upsert({
          where: { userId_role: { userId, role: activeRoles[0] } },
          update: {},
          create: { userId, role: activeRoles[0] },
        }).catch((e) => { if (e?.code !== 'P2002') throw e; });

        if (activeRoles.includes(Role.STUDENT)) {
          const provisioned = await this.ensureDevStudentProfile(userId);
          cohortId = provisioned.cohortId;
        }

        let resolvedSchoolId = existing?.schoolId ?? schoolId ?? null;

        // Parent multi-school support:
        // If a parent has no schoolId but is acting as a child, resolve the school
        // from the child's profile. Also verify the parent actually has access to that child.
        if (!resolvedSchoolId && actingStudentId && activeRoles.includes(Role.PARENT)) {
          const link = await this.prisma.parentChild.findFirst({
            where: { parentId: userId, childId: actingStudentId, status: 'APPROVED' },
          });
          if (link) {
            const childRow = await this.prisma.user.findUnique({
              where: { id: actingStudentId },
              select: { schoolId: true, studentProfile: { select: { cohortId: true } } },
            });
            resolvedSchoolId = childRow?.schoolId ?? null;
            if (!cohortId) cohortId = childRow?.studentProfile?.cohortId ?? undefined;
          }
          // If no valid link, actingStudentId is silently ignored for school context
        }

        return {
          sub: userId,
          id: userId,
          userId: userId,
          email: userEmail,
          roles: activeRoles,
          role: activeRoles[0],
          name: userName,
          displayName: userName,
          fullName: userName,
          ...(cohortId ? { cohortId } : {}),
          ...(actingStudentId ? { actingStudentId } : {}),
          ...(resolvedSchoolId ? { schoolId: resolvedSchoolId } : {}),
        };
      } catch (error: any) {
        console.error('DEV_TOKEN_VALIDATE_ERROR', {
          message: error?.message,
          code: error?.code,
          meta: error?.meta,
          stack: error?.stack,
        });
        throw error;
      }
    }

    if (process.env.JWT_VALIDATE_DEBUG === '1') {
      console.error('JWT_VALIDATE_DEBUG', {
        // Never log the raw Authorization header (it's the bearer token).
        tokenLen: String(((req as any)?.headers?.authorization || '')).length,
        nodeEnv: process.env.NODE_ENV,
        allowDevToken: process.env.ALLOW_DEV_TOKEN,
        port: process.env.PORT,
      });
    }

    throw new UnauthorizedException('Invalid token');
  }
}
