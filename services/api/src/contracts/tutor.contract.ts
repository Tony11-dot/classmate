import { z } from 'zod';

export const TutorTodoSchema = z.object({});
export type TutorTodo = z.infer<typeof TutorTodoSchema>;
