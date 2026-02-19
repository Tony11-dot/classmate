import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ListNotificationsDto } from './dto/list-notifications.dto';
import { CreateNotificationDto } from './dto/create-notification.dto';

@Injectable()
export class NotificationsService {
  constructor(private prisma: PrismaService) {}

  async list(userId: string, q: ListNotificationsDto) {
    const limit = q.limit ?? 30;

    const where: any = { userId };
    if (q.state === 'seen') where.seenAt = { not: null };
    if (q.state === 'unseen') where.seenAt = null;

    const rows = await this.prisma.notification.findMany({
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

  async markSeen(userId: string, ids: string[]) {
    if (!ids.length) return { ok: true, updated: 0 };

    const now = new Date();
    const res = await this.prisma.notification.updateMany({
      where: { userId, id: { in: ids }, seenAt: null },
      data: { seenAt: now },
    });

    return { ok: true, updated: res.count };
  }

  async markAllSeen(userId: string) {
    const now = new Date();
    const res = await this.prisma.notification.updateMany({
      where: { userId, seenAt: null },
      data: { seenAt: now },
    });
    return { ok: true, updated: res.count };
  }

  async createForUser(userId: string, dto: CreateNotificationDto) {
    return this.prisma.notification.create({
      data: {
        userId,
        type: dto.type,
        title: dto.title,
        body: dto.body,
        data: dto.data as any,
        severity: dto.severity ?? 'info',
      },
    });
  }

  async get(userId: string, id: string) {
    const n = await this.prisma.notification.findFirst({ where: { id, userId } });
    if (!n) throw new NotFoundException('Notification not found');
    return n;
  }
}
