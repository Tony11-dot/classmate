export type Role =
  | 'STUDENT'
  | 'TEACHER'
  | 'ADMIN'
  | 'PARENT'
  | 'SECRETARY';

type UserLike = { roles?: string[] | undefined } | undefined | null;

export function getRoles(user: UserLike): Role[] {
  const roles = (user?.roles ?? []) as string[];
  // normalize to uppercase strings, drop empties
  return roles.map((r) => String(r).toUpperCase()).filter(Boolean) as Role[];
}

export function hasRole(user: UserLike, role: Role): boolean {
  return getRoles(user).includes(role);
}

export function hasAnyRole(user: UserLike, roles: Role[]): boolean {
  const have = getRoles(user);
  return roles.some((r) => have.includes(r));
}

export const isAdmin = (user: UserLike) => hasRole(user, 'ADMIN');
export const isStaff = (user: UserLike) => hasAnyRole(user, ['ADMIN', 'TEACHER', 'SECRETARY']);
