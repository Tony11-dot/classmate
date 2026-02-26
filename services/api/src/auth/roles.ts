export enum Role {
  STUDENT = 'STUDENT',
  PARENT = 'PARENT',
  TEACHER = 'TEACHER',
  ADMIN = 'ADMIN',
  SECRETARY = 'SECRETARY',
}

export type AppRole = Role;

export function isRole(value: any): value is Role {
  return Object.values(Role).includes(value);
}

export function normalizeRoles(input: any): Role[] {
  const arr = Array.isArray(input) ? input : (input ? [input] : []);
  return arr
    .map((r) => String(r).toUpperCase().trim())
    .filter(isRole);
}

export function hasRole(userRoles: any, required: Role | Role[]): boolean {
  const have = new Set(normalizeRoles(userRoles));
  const need = normalizeRoles(required);
  return need.length === 0 ? true : need.some((r) => have.has(r));
}
