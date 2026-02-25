import { z } from 'zod';

export const LoginRequest = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

export type LoginRequest = z.infer<typeof LoginRequest>;

export const LoginResponse = z.object({
  token: z.string().min(1),
});

export type LoginResponse = z.infer<typeof LoginResponse>;
