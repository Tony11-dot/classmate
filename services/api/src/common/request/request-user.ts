import type { AppRole, UserRole } from '../../auth/roles';

export interface RequestUser {
  // common ids we tolerate across guards/strategies
  id?: string;
  userId?: string;
  sub?: string;

  // roles (array) + optional single role (legacy)
  roles?: AppRole[] | string[];
  role?: AppRole | string;

  // optional multi-tenant context claims
  schoolId?: string;

  // "acting as" student (parent selects a child)
  actingStudentId?: string;

  // anything else from passport/jwt
  [k: string]: unknown;
}

export function requestUserId(u: RequestUser | null | undefined): string | null {
  const id = (u?.id ?? u?.userId ?? u?.sub) as string | undefined;
  return id ? String(id) : null;
}

export function requestUserRole(u: RequestUser | null | undefined): UserRole | null {
  const r = (u?.role ?? null) as string | null;
  return r ? (r as UserRole) : null;
}
