import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import type { AppRole } from './roles';
import { isRole } from './roles';
import * as bcrypt from 'bcrypt';

@Injectable()
export class DevOverrideGuard implements CanActivate {
  constructor(private readonly prisma: PrismaService) {}

  async canActivate(ctx: ExecutionContext): Promise<boolean> {
    const req = ctx.switchToHttp().getRequest<any>();
    const appEnv = process.env.APP_ENV ?? process.env.NODE_ENV ?? 'production';
    const isDev =
      String(appEnv).toLowerCase().includes('dev') || String(appEnv).toLowerCase().includes('test');

    if (!isDev) return true;

    const h = req.headers || {};

    // A) Keep legacy dev override headers (no DB touch)
    const role = h['x-dev-role'] ?? h['X-DEV-ROLE'];
    const userId = h['x-dev-user-id'] ?? h['X-DEV-USER-ID'];
    if (role && isRole(role)) {
      req.user = req.user ?? {};
      req.user.roles = [role as AppRole];
      if (userId) req.user.id = String(userId);
      return true;
    }

    // B) Canonical dev tokens: "dev-token-<email>"
    const rawAuth = h['authorization'] ?? h['Authorization'] ?? '';
    const m = String(rawAuth).match(/^Bearer\s+(dev-token-(.+))$/i);
    if (!m) return true;

    const email = String(m[2] ?? '').trim().toLowerCase();
    if (!email || !email.includes('@')) return true;

    // Ensure DB user exists and attach canonical UUID id.
    // StudentProfile.userId references User.id (UUID), NOT email.
    // User.password is required by schema, so we create a non-loginable random hash.
    const random = `dev-token:${email}:${Date.now()}:${Math.random()}`;
    const passwordHash = await bcrypt.hash(random, 10);

    const dbUser = await this.prisma.user.upsert({
      where: { email },
      update: {},
      create: {
        email,
        name: email.split('@')[0],
        password: passwordHash,
      },
      select: { id: true, email: true },
    });

    req.user = req.user ?? {};
    req.user.id = dbUser.id;
    req.user.sub = dbUser.id;
    req.user.email = dbUser.email;

    // Roles are resolved elsewhere; do not overwrite here.
    return true;
  }
}
