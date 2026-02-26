import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Role, normalizeRoles, hasRole } from '../roles';

export const ROLES_KEY = 'roles_required';

function normalizeRequired(required: Role[] | Role | undefined | null): Role[] {
  if (!required) return [];
  return Array.isArray(required) ? required : [required];
}

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(ctx: ExecutionContext): boolean {
    const requiredRaw = this.reflector.getAllAndOverride<Role[] | undefined>(
      ROLES_KEY,
      [ctx.getHandler(), ctx.getClass()],
    );

    const required = normalizeRequired(requiredRaw);
    if (!required || required.length === 0) return true;

    const req = ctx.switchToHttp().getRequest<any>();
    if (!req?.user) throw new UnauthorizedException('Missing auth');

    const roles = normalizeRoles(req.user?.roles);
    if (!hasRole(roles, required)) {
      throw new ForbiddenException('Insufficient role');
    }
    return true;
  }
}
