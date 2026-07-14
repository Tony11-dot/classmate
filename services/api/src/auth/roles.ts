export const APP_ROLES = [
  'ADMIN',
  'TEACHER',
  'STUDENT',
  'PARENT',
  'TUTOR',
  'SECRETARY',
  'MANAGER',
] as const;

export type AppRole = (typeof APP_ROLES)[number];

/**
 * Compatibility: existing code uses Role.ADMIN / Role.PARENT / ...
 * Keep enum keys UPPERCASE.
 */
export enum Role {
  ADMIN = 'ADMIN',
  TEACHER = 'TEACHER',
  STUDENT = 'STUDENT',
  PARENT = 'PARENT',
  TUTOR = 'TUTOR',
  SECRETARY = 'SECRETARY',
  MANAGER = 'MANAGER',
}

/**
 * Compatibility: some code imports UserRole
 */
export type UserRole = Role;

/**
 * Explicit "any authenticated user" allow-list. Used to tag routes that were
 * historically reachable by every role, now that the RolesGuard default-denies
 * untagged routes. Prefer a narrower @Roles(...) whenever a route is really
 * role-specific.
 */
export const ALL_APP_ROLES: Role[] = [
  Role.STUDENT,
  Role.TEACHER,
  Role.PARENT,
  Role.ADMIN,
  Role.SECRETARY,
  Role.MANAGER,
];

export function isRole(v: unknown): v is AppRole {
  return typeof v === 'string' && (APP_ROLES as readonly string[]).includes(v);
}

export function normalizeRoles(input: unknown): AppRole[] {
  const raw =
    input && typeof input === 'object' && 'roles' in (input as any)
      ? (input as any).roles
      : input;

  if (!raw) return [];

  if (Array.isArray(raw)) {
    return raw.filter(isRole);
  }

  if (typeof raw === 'string') {
    return raw
      .split(/[,\s]+/g)
      .map((s) => s.trim())
      .filter(Boolean)
      .filter(isRole);
  }

  return [];
}

export function hasRole(userRoles: unknown, required: AppRole | readonly AppRole[]): boolean {
  const roles = normalizeRoles(userRoles);
  if (Array.isArray(required)) return required.some((r) => roles.includes(r));
  return roles.includes(required as AppRole);
}

/**
 * Some places might call hasAnyRole(...)
 */
export function hasAnyRole(userRoles: unknown, required: readonly AppRole[]): boolean {
  return hasRole(userRoles, required);
}
