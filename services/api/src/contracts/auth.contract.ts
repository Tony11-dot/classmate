import { z } from 'zod';

export const RoleSchema = z.enum([
  'STUDENT',
  'PARENT',
  'TEACHER',
  'SECRETARY',
  'ADMIN',
]);
export type Role = z.infer<typeof RoleSchema>;

export const LoginRequestSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});
export type LoginRequest = z.infer<typeof LoginRequestSchema>;

export const LoginResponseSchema = z.object({
  accessToken: z.string().min(1),
});
export type LoginResponse = z.infer<typeof LoginResponseSchema>;

export const MeUserSchema = z.object({
  id: z.string().min(1),
  sub: z.string().optional(),
  userId: z.string().optional(),
  email: z.string().email().optional(),
  roles: z.array(RoleSchema).default([]),
}).passthrough();
export type MeUser = z.infer<typeof MeUserSchema>;

export const MeResponseSchema = z.object({
  ok: z.boolean(),
  user: MeUserSchema,
});
export type MeResponse = z.infer<typeof MeResponseSchema>;
