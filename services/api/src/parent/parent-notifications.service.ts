import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

type ListArgs = { limit: number; cursor?: string; unseenOnly: boolean };

@Injectable()
export class ParentNotificationsService {
  constructor(private readonly prisma: PrismaService) {}

  // Always use the real table/model for notifications
  private get model() {
    const anyPrisma: any = this.prisma as any;
    // prefer the actual notifications model
    return anyPrisma.parentNotification || anyPrisma.ParentNotification;
  }

  async list(parentUserId: string, args: ListArgs) {
    if (!parentUserId) throw new UnauthorizedException();

    const limitRaw: any = (args as any).limit;
    const takeNum = Array.isArray(limitRaw) ? Number(limitRaw[0]) : Number(limitRaw);
    const take = Number.isFinite(takeNum) && takeNum > 0 ? Math.min(takeNum, 100) : 30;

const where: any = {
      parentId: parentUserId,
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

    // match the legacy shape you already return everywhere
    return { ok: true, notifications: items, nextCursor };
  }

  async unreadCount(parentUserId: string) {
    if (!parentUserId) throw new UnauthorizedException();

    const where: any = { parentId: parentUserId, seenAt: null };
    const count = await this.model.count({ where });
    return { ok: true, unread: count };
  }

  async markSeen(parentUserId: string, ids: string[]) {
    if (!parentUserId) throw new UnauthorizedException();
    if (!ids.length) return { updated: 0 };

    const res = await this.model.updateMany({
      where: {
        id: { in: ids },
        parentId: parentUserId,
        seenAt: null,
      },
      data: { seenAt: new Date() },
    });

    return { updated: res.count };
  }
}
