import { z } from 'zod';

export const RoleSchema = z.enum(['STUDENT', 'PARENT', 'TEACHER', 'SECRETARY', 'ADMIN']);

export const AuthMeResponseSchema = z.object({
  id: z.string().nullable(),
  email: z.string().nullable(),
  roles: z.array(RoleSchema).default([]),
  actingStudentId: z.string().nullable(),
  schoolId: z.string().nullable(),
  cohortId: z.string().nullable(),
});

export type AuthMeResponse = z.infer<typeof AuthMeResponseSchema>;
