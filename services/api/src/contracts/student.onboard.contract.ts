import { z } from 'zod';

export const StudentOnboardBodySchema = z.object({
  cohortId: z.string().min(1),
  joinCode: z.string().min(1),
  displayName: z.string().min(1).optional(),
  phone: z.string().min(3).optional(),
  englishLevel: z.coerce.number().int().min(1).max(6),
  mathLevel: z.coerce.number().int().min(1).max(6),
}).passthrough();

export const OkResponseSchema = z.object({ ok: z.boolean() }).passthrough();

export const StudentParentLinkCodeBodySchema = z.object({
  expiresInHours: z.coerce.number().int().min(1).max(24 * 30).optional(),
  length: z.coerce.number().int().min(4).max(8).optional(),
}).passthrough();

export const StudentParentLinkCodeResponseSchema = z.object({
  ok: z.boolean(),
  code: z.string(),
  expiresAt: z.string(),
}).passthrough();

export type StudentOnboardBody = z.infer<typeof StudentOnboardBodySchema>;
