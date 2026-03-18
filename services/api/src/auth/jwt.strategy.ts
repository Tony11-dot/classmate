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

@Injectable()
export class JwtStrategy extends PassportStrategy(CustomStrategy, 'jwt') {
  constructor(private readonly prisma: PrismaService) {
    super();
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
      const email = token.replace('dev-token-', '').trim().toLowerCase();
      if (!email) throw new UnauthorizedException('Invalid token');

      const passwordHash = await bcrypt.hash(`dev-token:${email}`, 10);

      const user = await this.prisma.user.upsert({
        where: { email },
        update: {},
        create: {
          email,
          name: email.split('@')[0] || email,
          password: passwordHash,
        },
        select: {
          id: true,
          email: true,
          name: true,
          displayName: true,
        },
      });

      return {
        sub: user.id,
        id: user.id,
        userId: user.id,
        email: user.email,
        roles: rolesFromEmail(user.email),
        name: user.displayName ?? user.name ?? user.email,
        actingStudentId: actingStudentId ?? null,
        schoolId: schoolId ?? null,
        cohortId: null,
        isDevToken: true,
      };
    }

    if (process.env.JWT_VALIDATE_DEBUG === '1') {
      console.error('JWT_VALIDATE_DEBUG', {
        authHeader: (req as any)?.headers?.authorization,
        tokenLen: String(((req as any)?.headers?.authorization || '')).length,
        user: (req as any)?.user,
        nodeEnv: process.env.NODE_ENV,
        e2e: process.env.E2E,
        port: process.env.PORT,
      });
    }

    throw new UnauthorizedException('Invalid token');
  }
}
