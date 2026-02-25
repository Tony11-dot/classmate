import { CanActivate, ExecutionContext, ForbiddenException, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Role, normalizeRoles, hasRole } from '../roles';

export const ROLES_KEY = 'roles_required';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(ctx: ExecutionContext): boolean {
    const required = this.reflector.getAllAndOverride<Role[] | undefined>(ROLES_KEY, [
      ctx.getHandler(),
      ctx.getClass(),
    ]);

    if (!required || required.length === 0) return true;

    const req = ctx.switchToHttp().getRequest<any>();
    const roles = normalizeRoles(req.user?.roles);

    if (!hasRole(roles, required)) {
      throw new ForbiddenException('Insufficient role');
    }
    return true;
  }
}
