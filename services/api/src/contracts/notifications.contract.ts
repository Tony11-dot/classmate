import { z } from 'zod';

export const NotificationDto = z.object({
  id: z.string(),
  userId: z.string().optional(),
  type: z.string().optional(),
  title: z.string().nullable().optional(),
  body: z.string().nullable().optional(),
  data: z.any().optional(),
  createdAt: z.string().optional(),
  readAt: z.string().nullable().optional(),
  seenAt: z.string().nullable().optional(),
});

export const NotificationsListDto = z.array(NotificationDto);

export const NotificationsSeenResDto = z.object({
  ok: z.boolean(),
  updated: z.number().int().nonnegative().optional(),
});

export const NotificationsSeenReqDto = z.object({
  ids: z.array(z.string()).min(1),
});
