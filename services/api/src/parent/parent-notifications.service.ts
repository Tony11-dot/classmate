import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

type ListArgs = { limit: number; cursor?: string; unseenOnly: boolean };

@Injectable()
export class ParentNotificationsService {
  constructor(private readonly prisma: PrismaService) {}

  // CHANGE THIS MODEL ACCESSOR to match your schema:
  // - this.prisma.parentNotification OR this.prisma.notification OR this.prisma.parentAlert, etc.
  private get model() {
    const anyPrisma: any = this.prisma as any;
    return (
      anyPrisma.parentNotification ||
      anyPrisma.notification ||
      anyPrisma.parentAlert ||
      anyPrisma.parentNotificationState
    );
  }

  private get modelName() {
    const anyPrisma: any = this.prisma as any;
    if (anyPrisma.parentNotification) return 'parentNotification';
    if (anyPrisma.notification) return 'notification';
    if (anyPrisma.parentAlert) return 'parentAlert';
    if (anyPrisma.parentNotificationState) return 'parentNotificationState';
    return 'unknown';
  }

  async list(parentUserId: string, args: ListArgs) {
    if (this.modelName === 'unknown') {
      throw new Error('No notifications model found on PrismaClient. Check schema.prisma models.');
    }

    const take = args.limit;

    // CHANGE these where keys to match your schema:
    // - parentId / userId / recipientId
    const whereBase: any = {
      OR: [{ parentId: parentUserId }, { userId: parentUserId }, { recipientId: parentUserId }],
    };

    const where: any = {
      ...whereBase,
      ...(args.unseenOnly ? { seenAt: null } : {}),
    };

    const rows = await this.model.findMany({
      where,
      take: take + 1,
      ...(args.cursor
        ? {
            cursor: { id: args.cursor },
            skip: 1,
          }
        : {}),
      orderBy: { createdAt: 'desc' },
    });

    const hasMore = rows.length > take;
    const items = hasMore ? rows.slice(0, take) : rows;
    const nextCursor = hasMore ? items[items.length - 1]?.id : null;

    return { items, nextCursor };
  }

  async unreadCount(parentUserId: string) {
    if (this.modelName === 'unknown') {
      throw new Error('No notifications model found on PrismaClient. Check schema.prisma models.');
    }

    const where: any = {
      seenAt: null,
      OR: [{ parentId: parentUserId }, { userId: parentUserId }, { recipientId: parentUserId }],
    };

    const count = await this.model.count({ where });
    return { count };
  }

  async markSeen(parentUserId: string, ids: string[]) {
    if (this.modelName === 'unknown') {
      throw new Error('No notifications model found on PrismaClient. Check schema.prisma models.');
    }
    if (!ids.length) return { updated: 0 };

    // CHANGE these where keys to match your schema:
    const where: any = {
      id: { in: ids },
      OR: [{ parentId: parentUserId }, { userId: parentUserId }, { recipientId: parentUserId }],
      // idempotent: only update unseen
      seenAt: null,
    };

    const res = await this.model.updateMany({
      where,
      data: { seenAt: new Date() },
    });

    return { updated: res.count };
  }
}
