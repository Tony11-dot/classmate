import { Injectable, UnauthorizedException } from '@nestjs/common';

import { PassportStrategy } from '@nestjs/passport';
import { Strategy as CustomStrategy } from 'passport-custom';
import type { Request } from 'express';
import { PrismaService } from '../prisma/prisma.service';
import { Role } from '@prisma/client';

function rolesFromEmail(email: string): Role[] {
  const e = String(email || '').toLowerCase();
  if (e.includes('admin')) return [Role.ADMIN];
  if (e.includes('teacher')) return [Role.TEACHER];
  if (e.includes('secretary')) return [Role.SECRETARY];
  if (e.includes('parent')) return [Role.PARENT];
  return [Role.STUDENT];
}

@Injectable()
export class JwtStrategy extends PassportStrategy(CustomStrategy, 'jwt') {
  constructor(private readonly prisma: PrismaService) {
    super();
  }

  async validate(req: Request): Promise<any> {
    const auth = String(req?.headers?.authorization ?? '');
    const token = auth.replace(/^Bearer\s+/i, '').trim();

    // E2E/dev shortcut: Bearer dev-token-<email>
    if ((process.env.NODE_ENV !== 'production') && token.startsWith('dev-token-')) {
      const email = token.replace('dev-token-', '').trim().toLowerCase();

      const u = await this.prisma.user.findUnique({ where: { email } });

      if (!u) {
        // Fall back to "email identity" (still allows controllers to run),
        // but will fail course ownership checks unless DB user exists.
        return {
          sub: email,
          id: email,
          email,
          roles: rolesFromEmail(email),
        };
      }

      const roles = await this.prisma.userRole
        .findMany({ where: { userId: u.id } })
        .catch(() => []);

      return {
        sub: u.id,
        id: u.id,
        email: u.email,
        roles: roles.map((r: any) => r.role),
      };
    }

    console.error('JWT_VALIDATE_DEBUG', {
  authHeader: (req as any)?.headers?.authorization,
  tokenLen: String(((req as any)?.headers?.authorization || '')).length,
  user: (req as any)?.user,
  nodeEnv: process.env.NODE_ENV,
  e2e: process.env.E2E,
  port: process.env.PORT,
});
throw new UnauthorizedException('Invalid token');
  }
}
