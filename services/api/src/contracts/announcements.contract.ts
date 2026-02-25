import { z } from 'zod';

export const AnnouncementTargetDto = z.object({
  role: z.string(),
  cohortId: z.string().nullable().optional(),
  classroomId: z.string().nullable().optional(),
});

export const AnnouncementDto = z.object({
  id: z.string(),
  title: z.string(),
  body: z.string().nullable().optional(),
  createdAt: z.string().optional(),
  authorId: z.string().nullable().optional(),
  targets: z.array(AnnouncementTargetDto).optional(),
  seen: z.boolean().optional(),
});

export const AnnouncementFeedDto = z.array(AnnouncementDto);

export const AnnouncementUnreadCountDto = z.object({
  unread: z.number().int().nonnegative(),
});

export const AnnouncementMarkSeenReqDto = z.object({
  ids: z.array(z.string()).min(1),
});

export const AnnouncementMarkSeenResDto = z.object({
  ok: z.boolean(),
});
