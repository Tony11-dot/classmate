export enum Role {
  STUDENT = 'STUDENT',
  PARENT = 'PARENT',
  TEACHER = 'TEACHER',
  SECRETARY = 'SECRETARY',
  ADMIN = 'ADMIN',
}

export type RoleLike = Role | `${Role}` | string;

export const normalizeRoles = (roles: unknown): Role[] => {
  if (!roles) return [];

  const arr: string[] = Array.isArray(roles)
    ? roles.map((r) => String(r))
    : typeof roles === 'string'
      ? roles.split(',').map((s) => s.trim())
      : [];

  return arr
    .map((r) => String(r).toUpperCase().trim())
    .filter(Boolean)
    .map((r) =>
      (Object.values(Role) as string[]).includes(r) ? (r as Role) : null,
    )
    .filter((r): r is Role => !!r);
};

export const hasRole = (userRoles: Role[], required: Role | Role[]): boolean => {
  const req = Array.isArray(required) ? required : [required];
  return req.some((r) => userRoles.includes(r));
};
