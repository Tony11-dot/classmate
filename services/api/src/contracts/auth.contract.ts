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

// /auth/me response
export const AuthMeResponseSchema = z.object({
  id: z.string().nullable(),
  email: z.string().nullable(),
  username: z.string().nullable().optional(),
  roles: z.array(RoleSchema).default([]),
  actingStudentId: z.string().nullable(),
  schoolId: z.string().nullable(),
  cohortId: z.string().nullable(),
  cohortName: z.string().nullable().optional(),
  schoolName: z.string().nullable(),
  schoolLogoUrl: z.string().nullable(),
  schoolMinGrade: z.number().int().nullable().optional(),
  schoolMaxGrade: z.number().int().nullable().optional(),
  fullName: z.string().nullable().optional(),
  displayName: z.string().nullable().optional(),
  nameEn: z.string().nullable().optional(),
  nameAr: z.string().nullable().optional(),
  nameHe: z.string().nullable().optional(),
  nameFr: z.string().nullable().optional(),
  nameRu: z.string().nullable().optional(),
  displayNameLang: z.string().nullable().optional(),
  phone: z.string().nullable().optional(),
  emailVerifiedAt: z.string().nullable().optional(),
  phoneVerifiedAt: z.string().nullable().optional(),
}).passthrough();

export type LoginRequest = z.infer<typeof LoginRequestSchema>;
export type LoginResponse = z.infer<typeof LoginResponseSchema>;
export type AuthMeResponse = z.infer<typeof AuthMeResponseSchema>;
