import { z } from 'zod';

export const IsoDateSchema = z.string().min(8);

export const StudentScheduleAttachmentSchema = z.object({
  id: z.string(),
  title: z.string(),
  url: z.string(),
  mime: z.string().nullable().optional(),
  description: z.string().nullable().optional(),
  subject: z.string().nullable().optional(),
});

export const StudentScheduleItemSchema = z.object({
  id: z.string(),
  startsAt: z.string(),
  endsAt: z.string(),

  period: z.number().nullable().optional(),
  title: z.string(),
  location: z.string().nullable().optional(),
  cohortId: z.string().nullable().optional(),
  subject: z.string().nullable().optional(),
  // Schedule tile metadata that was previously stripped by the
  // controller's response reshape — the student tile reads these to
  // render the teacher name, caption row, and "N materials" count
  // pill + detail-sheet attachment pills.
  teacherName: z.string().nullable().optional(),
  teacherId: z.string().nullable().optional(),
  caption: z.string().nullable().optional(),
  classroomId: z.string().nullable().optional(),
  date: z.string().nullable().optional(),
  attachments: z.array(StudentScheduleAttachmentSchema).default([]),
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
