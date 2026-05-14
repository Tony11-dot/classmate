import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy as CustomStrategy } from 'passport-custom';
import type { Request } from 'express';
import { PrismaService } from '../prisma/prisma.service';
import { Role } from '@prisma/client';
import * as bcrypt from 'bcrypt';

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
  constructor(private readonly prisma: PrismaService) {
    super();
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
      update: { grade: 10 },
      create: { name: DEV_COHORT_NAME, grade: 10 },
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
          select: { id: true, email: true, username: true, name: true, displayName: true, schoolId: true, roles: { select: { role: true } } },
        }) as any;

        let userId = existing?.id;
        let userEmail = existing?.email ?? (isEmail ? identifier : null);
        let userName =
          existing?.displayName ??
          existing?.name ??
          identifier.split('@')[0];
        let cohortId: string | undefined;

        if (!userId) {
          const passwordHash = await bcrypt.hash(`dev-token:${identifier}`, 10);
          const created = await this.prisma.user.create({
            data: {
              ...(isEmail ? { email: identifier } : { username: identifier }),
              name: identifier.split('@')[0],
              password: passwordHash,
            },
            select: { id: true, email: true, username: true, name: true, displayName: true },
          });
          userId = created.id;
          userEmail = created.email;
          userName = created.displayName ?? created.name ?? identifier.split('@')[0];
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

        const resolvedSchoolId = existing?.schoolId ?? schoolId ?? null;

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
        authHeader: (req as any)?.headers?.authorization,
        tokenLen: String(((req as any)?.headers?.authorization || '')).length,
        nodeEnv: process.env.NODE_ENV,
        allowDevToken: process.env.ALLOW_DEV_TOKEN,
        port: process.env.PORT,
      });
    }

    throw new UnauthorizedException('Invalid token');
  }
}
