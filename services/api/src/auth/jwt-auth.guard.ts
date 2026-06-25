import { ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AuthGuard } from '@nestjs/passport';
import { IS_PUBLIC_KEY } from './public.decorator';
import { isDevAuthBypassEnabled } from './dev-bypass';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  constructor(private readonly reflector: Reflector) {
    super();
  }

  canActivate(context: ExecutionContext) {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (isPublic) return true;

    const req = context.switchToHttp().getRequest<any>();
    const devUser =
      String(
        req?.headers?.['x-dev-user'] ??
          req?.headers?.['X-DEV-USER'] ??
          req?.headers?.['x-dev-user-id'] ??
          req?.headers?.['X-DEV-USER-ID'] ??
          '',
      ).trim();

    if (isDevAuthBypassEnabled() && devUser) {
      const devRolesRaw =
        String(
          req?.headers?.['x-dev-roles'] ??
            req?.headers?.['X-DEV-ROLES'] ??
            req?.headers?.['x-dev-role'] ??
            req?.headers?.['X-DEV-ROLE'] ??
            '',
        ).trim();

      const devRoles = devRolesRaw
        .split(',')
        .map((v) => v.trim().toUpperCase())
        .filter((v) => v.length > 0);

      req.user = {
        ...(req.user ?? {}),
        id: devUser,
        sub: devUser,
        userId: devUser,
        roles: devRoles,
      };

      return true;
    }

    return super.canActivate(context);
  }
}
