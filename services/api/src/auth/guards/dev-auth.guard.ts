import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { env } from '../../config/env';
import { normalizeRoles } from '../roles';

@Injectable()
export class DevAuthGuard implements CanActivate {
  canActivate(ctx: ExecutionContext): boolean {
    // Only allow in development AND explicitly enabled
    const enabled = String(process.env.DEV_AUTH_BYPASS || '') === '1';
    if (!enabled) return true;

    // env parsing ensures we know the API is configured; but don't block if env is strict
    const req = ctx.switchToHttp().getRequest<any>();
    const userId = String(req.headers['x-dev-user'] || '').trim();
    const rolesRaw = req.headers['x-dev-roles'];

    if (!userId) return true;

    const roles = normalizeRoles(
      typeof rolesRaw === 'string' ? rolesRaw.split(',').map((s) => s.trim()) : []
    );

    req.user = { id: userId, sub: userId, userId, roles };
    return true;
  }
}
