import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import type { AppRole } from './roles';
import { isRole } from './roles';

@Injectable()
export class DevOverrideGuard implements CanActivate {
  canActivate(ctx: ExecutionContext): boolean {
    const req = ctx.switchToHttp().getRequest<any>();
    const appEnv = process.env.APP_ENV ?? process.env.NODE_ENV ?? 'production';
    const isDev = String(appEnv).toLowerCase().includes('dev') || String(appEnv).toLowerCase().includes('test');

    if (!isDev) return true;

    const h = req.headers || {};
    const role = h['x-dev-role'] ?? h['X-DEV-ROLE'];
    const userId = h['x-dev-user-id'] ?? h['X-DEV-USER-ID'];

    if (role && isRole(role)) {
      req.user = req.user ?? {};
      req.user.role = role as AppRole;
      if (userId) req.user.id = String(userId);
    }

    return true;
  }
}
