import { z } from 'zod';

// Canonical API shape for parent notifications.
// Strict = no legacy keys like "at" can slip in.
export const ParentNotificationDtoSchema = z
  .object({
    id: z.string(),
    type: z.string(),
    createdAt: z.string().datetime().nullable(),
    seenAt: z.string().datetime().nullable(),
    studentId: z.string().nullable(),
    title: z.string(),
    message: z.string().nullable(),
    data: z.any().nullable(),
  })
  .strict();

export type ParentNotificationDto = z.infer<typeof ParentNotificationDtoSchema>;
