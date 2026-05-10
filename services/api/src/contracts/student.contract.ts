import { z } from 'zod';

export const IsoDateSchema = z.string().min(8);

export const StudentScheduleItemSchema = z.object({
  id: z.string(),
  startsAt: z.string(),
  endsAt: z.string(),
  
  period: z.number().nullable().optional(),
title: z.string(),
  location: z.string().nullable().optional(),
  cohortId: z.string().nullable().optional(),
  subject: z.string().nullable().optional(),
});

export const StudentScheduleTodayResponseSchema = z.object({
  ok: z.literal(true),
  items: z.object({
    date: IsoDateSchema,
    items: z.array(StudentScheduleItemSchema).default([]),
  }),
});

export const StudentScheduleWeekQuerySchema = z.object({
  weekOf: IsoDateSchema.optional(),
});

export const StudentScheduleWeekResponseSchema = z.object({
  ok: z.literal(true),
  items: z.object({
    weekOf: IsoDateSchema,
    days: z.array(
      z.object({
        date: IsoDateSchema,
        items: z.array(StudentScheduleItemSchema).default([]),
      }),
    ),
  }),
});

export type StudentScheduleItem = z.infer<typeof StudentScheduleItemSchema>;
export type StudentScheduleTodayResponse = z.infer<typeof StudentScheduleTodayResponseSchema>;
export type StudentScheduleWeekQuery = z.infer<typeof StudentScheduleWeekQuerySchema>;
export type StudentScheduleWeekResponse = z.infer<typeof StudentScheduleWeekResponseSchema>;
