import { ExecutionContext, Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { loadEnv } from '../env';
import { hasAnyRole } from '../auth/permissions';

@Injectable()
export class E2ESeedGuard extends AuthGuard('jwt') {
  async canActivate(context: ExecutionContext) {
    const env = loadEnv();

    // ✅ In dev/test, allow seeding without auth (controller exists only if ENABLE_E2E_SEED anyway)
    if (env.ENABLE_E2E_SEED && env.NODE_ENV !== 'production') return true;

    // ✅ In prod, require JWT...
    const ok = (await super.canActivate(context)) as boolean;
    if (!ok) return false;

    // ...and ADMIN role.
    const req = context.switchToHttp().getRequest();
    const roles: string[] = req.user?.roles ?? [];
    return hasAnyRole({ roles }, ['ADMIN']);
  }
}
