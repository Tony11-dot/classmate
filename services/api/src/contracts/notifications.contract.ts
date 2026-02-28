import { z } from 'zod';

export const NotificationSeverityDto = z.enum(['info', 'success', 'warning', 'error']).catch('info');

export const NotificationDto = z.object({
  id: z.string(),
  userId: z.string().optional(),
  type: z.string(),
  title: z.string(),
  body: z.string().nullable().optional(),
  data: z.any().optional(),
  severity: NotificationSeverityDto.optional(),
  seenAt: z.string().nullable().optional(),
  createdAt: z.string().optional(),
});

export const NotificationsListResDto = z.object({
  items: z.array(NotificationDto),
  nextCursor: z.string().nullable().optional(),
});

export const NotificationsMarkSeenReqDto = z.object({
  ids: z.array(z.string()).min(1),
});

export const NotificationsMarkSeenResDto = z.object({
  ok: z.boolean(),
  updated: z.number().int().nonnegative(),
});

export const NotificationsSeenAllResDto = z.object({
  ok: z.boolean(),
  updated: z.number().int().nonnegative(),
});

export const NotificationsCreateReqDto = z.object({
  type: z.string().min(1),
  title: z.string().min(1),
  body: z.string().optional(),
  data: z.any().optional(),
  severity: NotificationSeverityDto.optional(),
});

export const NotificationsCreateResDto = NotificationDto;
