import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY } from '../decorators/roles.decorator';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';
import { hasAnyRole } from '../permissions';
import { isDevAuthBypassEnabled } from '../dev-bypass';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    // Local-dev convenience bypass — gated behind an explicit opt-in flag AND
    // a strict non-prod env (see isDevAuthBypassEnabled). Never true in prod.
    if (isDevAuthBypassEnabled()) return true;

    // Honor @Public FIRST — public routes are exempt from the default-deny.
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;

    const required = this.reflector.getAllAndOverride<string[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    // DEFAULT-DENY: an authenticated route with no @Roles tag is denied.
    if (!required || required.length === 0) return false;

    const { user } = context.switchToHttp().getRequest();
    if (!user) return false;
    return hasAnyRole(user, required as any);
  }
}
