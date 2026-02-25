import { z } from 'zod';

export const DayOfWeek = z.enum(['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']);
export type DayOfWeek = z.infer<typeof DayOfWeek>;

export const ScheduleItemDto = z.object({
  id: z.string().min(1),
  title: z.string().min(1),
  location: z.string().nullable(),
  dayOfWeek: DayOfWeek,
  // "HH:MM" 24h
  startTime: z.string().regex(/^\d{2}:\d{2}$/),
  endTime: z.string().regex(/^\d{2}:\d{2}$/),
  classroomId: z.string().min(1).nullable(),
});

export type ScheduleItemDto = z.infer<typeof ScheduleItemDto>;

export const ScheduleListResponse = z.array(ScheduleItemDto);
