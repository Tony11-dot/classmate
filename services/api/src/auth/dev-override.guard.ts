import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { IS_PUBLIC_KEY } from './public.decorator';
import { Reflector } from '@nestjs/core';
import { PrismaService } from '../prisma/prisma.service';
import type { AppRole } from './roles';
import { isRole } from './roles';
import * as bcrypt from 'bcrypt';
import { deriveUsernameCandidate, ensureUniqueUsername } from '../common/username';

@Injectable()
export class DevOverrideGuard implements CanActivate {
  constructor(
    private readonly prisma: PrismaService,
    private readonly reflector: Reflector,
  ) {}

  async canActivate(ctx: ExecutionContext): Promise<boolean> {
    const req = ctx.switchToHttp().getRequest<any>();
    const appEnv = process.env.APP_ENV ?? process.env.NODE_ENV ?? 'production';
    const isDev =
      String(appEnv).toLowerCase().includes('dev') ||
      String(appEnv).toLowerCase().includes('test');

    if (!isDev) return true;

    const h = req.headers || {};

    // Always stash raw headers for downstream dev helpers (student subjects, etc.)
    req.user = req.user ?? {};
    req.user.__headers = h;

    // A) Legacy dev override headers (no DB touch)
    const role = h['x-dev-role'] ?? h['X-DEV-ROLE'];
    const userId = h['x-dev-user-id'] ?? h['X-DEV-USER-ID'];
    if (role && isRole(role)) {
      req.user.roles = [String(role) as AppRole];
      if (userId) {
        req.user.id = String(userId);
        req.user.sub = String(userId);
      }
      return true;
    }

    // B) Canonical dev tokens: "dev-token-<email>"
    const rawAuth = h['authorization'] ?? h['Authorization'] ?? '';
    const m = String(rawAuth).match(/^Bearer\s+(dev-token-(.+))$/i);
    if (!m) return true;

    const email = String(m[2] ?? '')
      .trim()
      .toLowerCase();
    if (!email || !email.includes('@')) return true;

    const random = `dev-token:${email}:${Date.now()}:${Math.random()}`;
    const passwordHash = await bcrypt.hash(random, 10);

    // Username is the app's primary identifier — even dev-token shortcut
    // signups must have one. Derive from the email local-part on create.
    const usernameCandidate = deriveUsernameCandidate(email);
    const username = await ensureUniqueUsername(this.prisma, usernameCandidate);

    const dbUser = await this.prisma.user.upsert({
      where: { email },
      update: {},
      create: {
        email,
        username,
        name: email.split('@')[0],
        password: passwordHash,
      },
      select: { id: true, email: true },
    });

    req.user.id = dbUser.id;
    req.user.sub = dbUser.id;
    req.user.email = dbUser.email;

    // Roles resolved elsewhere; do not overwrite here.
    return true;
  }
}
