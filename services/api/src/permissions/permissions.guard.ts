import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { REQUIRE_PERMISSION_KEY } from './permissions.decorator';
import { PermissionsService } from './permissions.service';
import { isDevAuthBypassEnabled } from '../auth/dev-bypass';

/**
 * Global guard, registered AFTER RolesGuard. It does two jobs:
 *
 *  1. For any authenticated request with a school, it attaches the user's
 *     effective capability keys to `req.user.grantedPermissions`, so sync
 *     service-layer code (admin.service, etc.) can double-check a grant without
 *     another async DB hop. Defense in depth — the service never has to trust
 *     the controller alone.
 *
 *  2. If the handler (or its class) carries @RequirePermission(key), it enforces
 *     that the user actually holds `key`, 403-ing otherwise.
 *
 * It never *grants* access a route's @Roles tag didn't already allow — RolesGuard
 * runs first and has the final say on role membership.
 */
@Injectable()
export class PermissionsGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly permissions: PermissionsService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    if (isDevAuthBypassEnabled()) return true;

    const req = context.switchToHttp().getRequest();
    const user = req?.user;

    // No authenticated user → nothing to attach; let other guards decide.
    // (JwtAuthGuard/RolesGuard already ran and would have rejected if needed.)
    if (!user) return true;

    // Attach effective grants for downstream service checks (best effort).
    try {
      (user as any).grantedPermissions = await this.permissions.grantedKeysFor(user);
    } catch {
      (user as any).grantedPermissions = [];
    }

    const required = this.reflector.getAllAndOverride<string>(
      REQUIRE_PERMISSION_KEY,
      [context.getHandler(), context.getClass()],
    );
    if (!required) return true; // route doesn't gate on a capability

    const ok = await this.permissions.can(user, required);
    if (!ok) {
      throw new ForbiddenException(
        'You do not have permission to perform this action. Ask an administrator to enable it.',
      );
    }
    return true;
  }
}
