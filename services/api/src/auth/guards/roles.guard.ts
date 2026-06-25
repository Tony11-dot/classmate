import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY } from '../decorators/roles.decorator';
import { hasAnyRole } from '../permissions';
import { isDevAuthBypassEnabled } from '../dev-bypass';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    // Local-dev convenience bypass — gated behind an explicit opt-in flag AND
    // a strict non-prod env (see isDevAuthBypassEnabled). Never true in prod.
    if (isDevAuthBypassEnabled()) return true;

    const required = this.reflector.getAllAndOverride<string[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!required || required.length === 0) return true;

    const { user } = context.switchToHttp().getRequest();
    // Defer to JwtAuthGuard when this guard happens to run before user has
    // been populated — JwtAuthGuard will 401 if the request is unauthenticated;
    // otherwise our @UseGuards(JwtAuthGuard, RolesGuard) at the controller
    // level will re-run us with user set.
    if (!user) return true;
    return hasAnyRole(user, required as any);
  }
}
