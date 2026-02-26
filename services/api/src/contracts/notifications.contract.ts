import { z } from 'zod';

export const NotificationsTodoSchema = z.object({});
export type NotificationsTodo = z.infer<typeof NotificationsTodoSchema>;
