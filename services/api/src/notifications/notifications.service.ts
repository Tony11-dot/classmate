import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ListNotificationsDto } from './dto/list-notifications.dto';

@Injectable()
export class NotificationsService {
  constructor(private readonly prisma: PrismaService) {}

  private userIdOf(user: any): string {
    return String(user?.sub ?? user?.id ?? user?.userId ?? '');
  }

  async list(user: any, dto: ListNotificationsDto) {
    const userId = this.userIdOf(user);
    const take = Math.min(100, Math.max(1, Number(dto.limit ?? 50)));

    if (!userId) {
      return { ok: true, items: [] };
    }

    const rows = await this.prisma.notification.findMany({
      where: {
        userId,
      },
      orderBy: [{ createdAt: 'desc' }],
      take,
    });

    const items = rows.map((row: any) => ({
      id: String(row.id),
      title: String(row.title ?? row.type ?? 'Notification'),
      body: String(row.body ?? row.message ?? ''),
      source: String(row.type ?? 'system').toLowerCase(),
      createdAt: row.createdAt,
      isRead: row.seenAt != null || row.readAt != null || row.isRead == true,
      severity:
        String(row.type ?? '').toLowerCase().includes('alert')
          ? 'critical'
          : String(row.type ?? '').toLowerCase().includes('attendance')
              ? 'warning'
              : 'info',
    }));

    return {
      ok: true,
      items,
    };
  }
}
