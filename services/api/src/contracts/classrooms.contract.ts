import { z } from 'zod';

export const ClassroomsTodoSchema = z.object({});
export type ClassroomsTodo = z.infer<typeof ClassroomsTodoSchema>;
