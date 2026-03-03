import { z } from 'zod';

export const ClassroomSchema = z.object({
  id: z.string(),
  name: z.string(),
  subject: z.string().nullable().optional(),
  cohortId: z.string().nullable().optional(),
});

export const ClassroomsListResponseSchema = z.object({
  items: z.array(ClassroomSchema).default([]),
});

export type Classroom = z.infer<typeof ClassroomSchema>;
export type ClassroomsListResponse = z.infer<typeof ClassroomsListResponseSchema>;
