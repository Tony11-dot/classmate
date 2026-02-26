import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { normalizeRoles } from '../roles';

@Injectable()
export class DevAuthGuard implements CanActivate {
  canActivate(ctx: ExecutionContext): boolean {
    const isDev = String(process.env.NODE_ENV || 'development') === 'development';
    const enabled = String(process.env.DEV_AUTH_BYPASS || '') === '1';
    if (!(isDev && enabled)) return true;
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
