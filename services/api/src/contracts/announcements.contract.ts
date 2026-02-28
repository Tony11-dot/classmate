import { z } from 'zod';

export const AnnouncementTargetDto = z.object({
  id: z.string().optional(),
  announcementId: z.string().optional(),
  userId: z.string().nullable().optional(),
  role: z.string().nullable().optional(),
  grade: z.number().int().nullable().optional(),
  cohortId: z.string().nullable().optional(),
});

export const AnnouncementCreatorDto = z
  .object({
    id: z.string(),
    email: z.string().optional(),
    name: z.string().nullable().optional(),
  })
  .partial();

export const AnnouncementDto = z.object({
  id: z.string(),
  title: z.string(),
  body: z.string().nullable().optional(),
  createdBy: z.string().optional(),
  createdAt: z.string().optional(),
  publishAt: z.string().optional(),
  expiresAt: z.string().nullable().optional(),
  pinned: z.boolean().optional(),
  targets: z.array(AnnouncementTargetDto).optional(),
  creator: AnnouncementCreatorDto.optional(),
});

export const AnnouncementFeedResDto = z.object({
  ok: z.boolean(),
  announcements: z.array(AnnouncementDto),
});

export const AnnouncementUnreadCountResDto = z.object({
  ok: z.boolean(),
  unread: z.number().int().nonnegative(),
});

export const AnnouncementMarkSeenReqDto = z.union([
  z.object({ ids: z.array(z.string()).min(1) }),
  z.object({ announcementId: z.string().min(1) }),
]);

export const AnnouncementMarkSeenResDto = z.object({
  ok: z.boolean(),
});
