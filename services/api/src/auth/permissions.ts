export type Role =
  | 'STUDENT'
  | 'TEACHER'
  | 'ADMIN'
  | 'PARENT'
  | 'SECRETARY'
  | 'MANAGER'
  // Not a school role, and deliberately not in `ALL_APP_ROLES`: it is the ONLY
  // role a ClassNotes account carries, and the only route that lists it is
  // ClassNotes' own. The RolesGuard default-denies an authenticated route whose
  // @Roles tag it does not match, so that one omission is what keeps a
  // notebook-app session out of every school endpoint on this API.
  | 'CLASSNOTES';

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
