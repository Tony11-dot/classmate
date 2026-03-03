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

    // Dev headers bypass (works even if APP_ENV misconfigured)
    const role = h['x-dev-role'] ?? h['X-DEV-ROLE'];
    const userId = h['x-dev-user-id'] ?? h['X-DEV-USER-ID'];

    if (role && isRole(role)) {
      req.user = req.user ?? {};
      req.user.roles = [String(role) as AppRole];
      if (userId) {
        req.user.id = String(userId);
        req.user.sub = String(userId);
      }
return true;
    }

    const ok = (await super.canActivate(context)) as boolean;
    if (ok) {
      req.user = req.user ?? {};
}
    return ok;
  }
}
