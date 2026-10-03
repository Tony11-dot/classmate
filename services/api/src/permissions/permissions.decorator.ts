import { SetMetadata } from '@nestjs/common';

export const REQUIRE_PERMISSION_KEY = 'require_permission';

/**
 * Gate a route behind an admin-managed capability (see permissions.catalog.ts).
 *
 * Layers ON TOP of @Roles — RolesGuard still runs first, so the route must also
 * list every role that could ever hold the capability. ADMIN/MANAGER always
 * pass the permission check; a configurable role (SECRETARY/TEACHER) passes only
 * when the school has the capability enabled for it.
 */
export const RequirePermission = (key: string) =>
  SetMetadata(REQUIRE_PERMISSION_KEY, key);
