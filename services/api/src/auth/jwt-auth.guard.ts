import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import type { ExecutionContext } from '@nestjs/common';
import type { AppRole } from './roles';
import { isRole } from './roles';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  override async canActivate(context: ExecutionContext): Promise<boolean> {
    const req = context.switchToHttp().getRequest<any>();
    const h = req?.headers || {};

    // DEV OVERRIDE (NON-PROD ONLY): allow x-dev-* identity without JWT
    const appEnv = String(process.env.APP_ENV ?? process.env.NODE_ENV ?? 'production').toLowerCase();
    const isProd = appEnv === 'production';
    const devRole = h['x-dev-role'] ?? h['X-DEV-ROLE'];
    const devUserId = h['x-dev-user-id'] ?? h['X-DEV-USER-ID'];
    const devSchoolId = h['x-dev-school-id'] ?? h['X-DEV-SCHOOL-ID'];

    if (!isProd && devRole && isRole(devRole)) {
      req.user = req.user ?? {};
      req.user.roles = [String(devRole) as AppRole];
      if (devUserId) {
        req.user.id = String(devUserId);
        req.user.sub = String(devUserId);
        req.user.userId = String(devUserId);
      }
      if (devSchoolId) req.user.schoolId = String(devSchoolId);
      return true;
    }

    const ok = (await super.canActivate(context)) as boolean;
    if (ok) req.user = req.user ?? {};
    return ok;
  }
}
