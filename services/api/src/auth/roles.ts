export enum Role {
  STUDENT = 'STUDENT',
  PARENT = 'PARENT',
  TEACHER = 'TEACHER',
  ADMIN = 'ADMIN',
}

export type RoleLike = Role | `${Role}` | string;

export const normalizeRoles = (roles: unknown): Role[] => {
  if (!Array.isArray(roles)) return [];
  return roles
    .map((r) => String(r).toUpperCase().trim())
    .filter(Boolean)
    .map((r) => (Object.values(Role) as string[]).includes(r) ? (r as Role) : null)
    .filter((r): r is Role => !!r);
};

export const hasRole = (userRoles: Role[], required: Role | Role[]): boolean => {
  const req = Array.isArray(required) ? required : [required];
  return req.some((r) => userRoles.includes(r));
};
