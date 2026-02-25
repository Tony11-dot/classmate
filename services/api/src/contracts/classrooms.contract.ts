import { z } from 'zod';

export const ClassroomSummaryDto = z.object({
  id: z.string().min(1),
  name: z.string().min(1),
  teacher: z.string().nullable(),
  studentCount: z.number().int().nonnegative(),
});

export type ClassroomSummaryDto = z.infer<typeof ClassroomSummaryDto>;

export const ClassroomDetailDto = z.object({
  id: z.string().min(1),
  name: z.string().min(1),
  teacher: z.string().nullable(),
  description: z.string().nullable(),
});

export type ClassroomDetailDto = z.infer<typeof ClassroomDetailDto>;
