import { IS_PUBLIC_KEY } from './public.decorator';
import { Injectable, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AuthGuard } from '@nestjs/passport';
import type { AppRole } from './roles';
import { isRole } from './roles';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  constructor(private readonly reflector: Reflector) {
    super();
  }

  override async canActivate(context: ExecutionContext): Promise<boolean> {
    // PUBLIC metadata bypass (works for @Public())
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;

    // PUBLIC path bypass (failsafe for /health /ready /version)
    const req0 = context.switchToHttp?.().getRequest?.() ?? null;
    const pth = String(req0?.originalUrl ?? req0?.url ?? req0?.path ?? '');
    if (
      pth === '/health' ||
      pth.startsWith('/health?') ||
      pth === '/ready' ||
      pth.startsWith('/ready?') ||
      pth === '/version' ||
      pth.startsWith('/version?') ||
      pth === '/api/health' ||
      pth.startsWith('/api/health?') ||
      pth === '/api/ready' ||
      pth.startsWith('/api/ready?') ||
      pth === '/api/version' ||
      pth.startsWith('/api/version?')
    )
      return true;

    const req = context.switchToHttp().getRequest<any>();
    const h = req?.headers || {};

    // DEV OVERRIDE (NON-PROD ONLY): allow x-dev-* identity without JWT
    const appEnv = String(
      process.env.APP_ENV ?? process.env.NODE_ENV ?? 'development',
    ).toLowerCase();
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

    // DEV TOKEN (NON-PROD ONLY): accept Bearer dev-token-<email>
    // This is a convenience for mobile/dev; replace with real JWT in prod.
    const authz = String(
      (h['authorization'] ?? h['Authorization'] ?? '') as any,
    );
    const mTok = authz.match(/^Bearer\s+(dev-token-[^\s]+)$/i);
    if (!isProd && mTok) {
      const tok = String(mTok[1]);
      const email = tok.replace(/^dev-token-/i, '');
      req.user = req.user ?? {};
      req.user.email = email;
      req.user.roles = req.user.roles ?? (['STUDENT'] as AppRole[]);
      req.user.sub = req.user.sub ?? email;
      req.user.id = req.user.id ?? email;
      req.user.userId = req.user.userId ?? email;
      return true;
    }

    const ok = (await super.canActivate(context)) as boolean;
    if (ok) req.user = req.user ?? {};
    return ok;
  }
}
