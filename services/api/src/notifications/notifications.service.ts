import { PrismaService } from '../prisma/prisma.service';
import { Injectable, NotFoundException } from '@nestjs/common';
import { ListNotificationsDto } from './dto/list-notifications.dto';
import { CreateNotificationDto } from './dto/create-notification.dto';

@Injectable()
export class NotificationsService {
  constructor(private readonly prisma: PrismaService) {}

  async list(parentId: string, q: ListNotificationsDto) {
    const limit = q.limit ?? 30;

    const where: any = { parentId };
    if (q.state === 'seen') where.seenAt = { not: null };
    if (q.state === 'unseen') where.seenAt = null;

    const rows = await this.prisma.parentNotification.findMany({
      where,
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take: limit + 1,
      ...(q.cursor
        ? {
            cursor: { id: q.cursor },
            skip: 1,
          }
        : {}),
    });

    const hasNext = rows.length > limit;
    const items = hasNext ? rows.slice(0, limit) : rows;
    const nextCursor = hasNext ? items[items.length - 1]?.id : null;

    return { items, nextCursor };
  }

  async markSeen(parentId: string, ids: string[]) {
    if (!ids.length) return { ok: true, updated: 0 };

    const now = new Date();
    const res = await this.prisma.parentNotification.updateMany({
      where: { parentId, id: { in: ids }, seenAt: null },
      data: { seenAt: now },
    });

    return { ok: true, updated: res.count };
  }

  async markAllSeen(parentId: string) {
    const now = new Date();
    const res = await this.prisma.parentNotification.updateMany({
      where: { parentId, seenAt: null },
      data: { seenAt: now },
    });
    return { ok: true, updated: res.count };
  }

  async createForUser(parentId: string, dto: CreateNotificationDto) {
    return this.prisma.parentNotification.create({
      data: {
        parentId,
        studentId: (dto as any)?.studentId ?? null,
        type: dto.type,
        title: dto.title,
        message: (dto as any)?.body ?? (dto as any)?.message ?? null,
        data: (dto as any)?.data ?? null,
      },
    });
  }

  async get(parentId: string, id: string) {
    const n = await this.prisma.parentNotification.findFirst({ where: { id, parentId } });
    if (!n) throw new NotFoundException('Notification not found');
    return n;
  }
}
