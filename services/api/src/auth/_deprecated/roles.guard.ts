// @ts-nocheck
import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY, AppRole } from './roles.decorator';

function normalizeRoles(input: any): string[] {
  if (!input) return [];
  if (Array.isArray(input)) {
    return input
      .map((r) =>
        typeof r === 'string' ? r : (r?.role ?? r?.name ?? r?.value),
      )
      .filter(Boolean)
      .map((x) => String(x));
  }
  if (typeof input === 'string') return [input];
  // sometimes: { roles: [...] } or { role: 'ADMIN' }
  const maybe = input.roles ?? input.role;
  return normalizeRoles(maybe);
}

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(ctx: ExecutionContext): boolean {
    const required = this.reflector.getAllAndOverride<AppRole[]>(ROLES_KEY, [
      ctx.getHandler(),
      ctx.getClass(),
    ]);

    if (!required || required.length === 0) return true;

    const req = ctx.switchToHttp().getRequest();

    // If RolesGuard runs before JwtAuthGuard (global guard ordering),
    // req.user isn't set yet. Let JwtAuthGuard handle auth.
    if (!req.user) return true;

    if (!required?.length) return true;

    const roles = normalizeRoles(req.user?.roles ?? req.user?.role ?? []);

    return required.some((r) => roles.includes(r));
  }
}

export {};
