import { z } from 'zod';

export const TutorRoleSchema = z.enum(['USER', 'ASSISTANT', 'SYSTEM']);

export const TutorSessionSchema = z.object({
  id: z.string(),
  characterId: z.string().nullable().optional(),
  createdAt: z.string().optional(),
});

export const TutorMessageSchema = z.object({
  id: z.string().optional(),
  role: TutorRoleSchema,
  content: z.string(),
  createdAt: z.string().optional(),
});

export const TutorCreateSessionResponseSchema = z.object({
  session: TutorSessionSchema.optional(),
  id: z.string().optional(),
}).transform((x) => ({ id: (x.session?.id ?? x.id) as string }));

export type TutorCreateSessionResponse = z.infer<typeof TutorCreateSessionResponseSchema>;
export type TutorMessage = z.infer<typeof TutorMessageSchema>;
