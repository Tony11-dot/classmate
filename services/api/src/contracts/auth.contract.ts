import { z } from 'zod';

export const RoleSchema = z.enum(['STUDENT', 'PARENT', 'TEACHER', 'SECRETARY', 'ADMIN']);

// SDK expects these:
export const LoginRequestSchema = z.object({
  email: z.string().email(),
  // keep optional fields to avoid breaking callers if they send more
  password: z.string().optional(),
}).passthrough();

export const LoginResponseSchema = z.object({
  token: z.string(),
}).passthrough();

// Existing /auth/me response
export const AuthMeResponseSchema = z.object({
  id: z.string().nullable(),
  email: z.string().nullable(),
  roles: z.array(RoleSchema).default([]),
  actingStudentId: z.string().nullable(),
  schoolId: z.string().nullable(),
  cohortId: z.string().nullable(),
}).passthrough();

export type LoginRequest = z.infer<typeof LoginRequestSchema>;
export type LoginResponse = z.infer<typeof LoginResponseSchema>;
export type AuthMeResponse = z.infer<typeof AuthMeResponseSchema>;
