import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { normalizeRoles } from '../roles';

@Injectable()
export class DevAuthGuard implements CanActivate {
  canActivate(ctx: ExecutionContext): boolean {
    const isDev = process.env.NODE_ENV === 'development';
    const enabled = process.env.DEV_AUTH_BYPASS === '1';

    if (!isDev || !enabled) return true;

    const req = ctx.switchToHttp().getRequest<any>();
    const userId = String(req.headers['x-dev-user'] || '').trim();
    const rolesRaw = req.headers['x-dev-roles'];

    if (!userId) return true;

    const roles =
      typeof rolesRaw === 'string'
        ? normalizeRoles(rolesRaw.split(',').map((s) => s.trim()))
        : [];

    
req.user = { id: userId, sub: userId, userId, roles };
    try {
      const h = req.headers ?? {};
      const acting = (h["x-acting-student-id"] ?? h["X-Acting-Student-Id"]) as any;
      const school = (h["x-school-id"] ?? h["X-School-Id"]) as any;
      if (acting) (req.user as any).actingStudentId = String(Array.isArray(acting) ? acting[0] : acting);
      if (school) (req.user as any).schoolId = String(Array.isArray(school) ? school[0] : school);
    } catch {}

    return true;
  }
}
