function getAuthHeader(req: any): string {
  const h = req?.headers ?? {};
  const v = (h.authorization ?? h.Authorization ?? req?.get?.('authorization') ?? req?.get?.('Authorization') ?? '') as any;
  return typeof v === 'string' ? v.trim() : '';
}

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
    // If RolesGuard runs before JwtAuthGuard (global guard ordering),
    // req.user isn't set yet. Let JwtAuthGuard handle auth.
    if (!req?.user) return true;

    const roles = normalizeRoles(req.user?.roles);
    if (!hasRole(roles, required)) {
      throw new ForbiddenException('Insufficient role');
    }
    return true;
  }
}
