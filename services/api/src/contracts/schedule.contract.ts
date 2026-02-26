import { z } from 'zod';

export const DayOfWeekSchema = z.enum([
  'SUNDAY',
  'MONDAY',
  'TUESDAY',
  'WEDNESDAY',
  'THURSDAY',
  'FRIDAY',
  'SATURDAY',
]);
export type DayOfWeek = z.infer<typeof DayOfWeekSchema>;

export const ScheduleTodoSchema = z.object({});
export type ScheduleTodo = z.infer<typeof ScheduleTodoSchema>;
