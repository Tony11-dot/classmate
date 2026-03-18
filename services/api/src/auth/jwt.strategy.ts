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

    // E2E/dev shortcut: Bearer dev-token-<email>
    if ((process.env.NODE_ENV !== 'production' || process.env.ALLOW_DEV_TOKEN === '1') && token.startsWith('dev-token-')) {
      const email = token.replace('dev-token-', '').trim().toLowerCase();

      // Ensure DB user exists; StudentProfile.userId references User.id (UUID), NOT email.
      // User.password is required by schema, so create a non-loginable random hash.
      const random = `dev-token:${email}:${Date.now()}:${Math.random()}`;
      const passwordHash = await bcrypt.hash(random, 10);

      const u = await this.prisma.user.upsert({
        where: { email },
        update: {},
        create: {
          email,
          name: email.split('@')[0],
          password: passwordHash,
        },
        select: { id: true, email: true },
      });

      const roles = await this.prisma.userRole
        .findMany({ where: { userId: u.id } })
        .catch(() => []);

      return {
        sub: u.id,
        id: u.id,
        email: u.email,
        roles: roles.length ? roles.map((r: any) => r.role) : rolesFromEmail(email),
        ...(actingStudentId ? { actingStudentId } : {}),
        ...(schoolId ? { schoolId } : {}),
      };
    }

    // Debug only if explicitly enabled (avoid noisy logs)
    if (process.env.JWT_VALIDATE_DEBUG === '1') {
      // eslint-disable-next-line no-console
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
