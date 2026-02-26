export type AppRole =
  | 'STUDENT'
  | 'PARENT'
  | 'TEACHER'
  | 'ADMIN'
  | 'SCHOOL_ADMIN';

export const ALL_ROLES: AppRole[] = [
  'STUDENT',
  'PARENT',
  'TEACHER',
  'ADMIN',
  'SCHOOL_ADMIN',
];

export function isRole(x: any): x is AppRole {
  return typeof x === 'string' && (ALL_ROLES as string[]).includes(x);
}
