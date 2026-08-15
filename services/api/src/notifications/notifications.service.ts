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

    const items = rows.map((row: any) => {
      // The deep-link target lives in the row's `data` blob (formId,
      // assignmentId, …). It was never serialized, so a tapped notification
      // fell back to the notification's OWN id → "Form not found". Resolve a
      // single entityId the client can route on.
      const d = (row.data ?? {}) as any;
      const entityId = String(
        d.formId ?? d.assignmentId ?? d.meetingId ?? d.examId ??
        d.announcementId ?? d.materialId ?? d.classroomId ??
        d.diplomaId ?? d.certificateId ?? d.solutionId ?? '',
      ).trim();
      return {
      id: String(row.id),
      title: String(row.title ?? row.type ?? 'Notification'),
      body: String(row.body ?? row.message ?? ''),
      source: String(row.type ?? 'system').toLowerCase(),
      entityId,
      createdAt: row.createdAt,
      isRead: row.seenAt != null,
      severity:
        String(row.type ?? '').toLowerCase().includes('alert')
          ? 'critical'
          : String(row.type ?? '').toLowerCase().includes('attendance')
              ? 'warning'
              : 'info',
      };
    });

    return {
      ok: true,
      items,
    };
  }

  async seen(user: any, ids: unknown) {
    const userId = this.userIdOf(user);
    if (!userId) {
      return { ok: true, updated: 0 };
    }

    const cleaned = Array.isArray(ids)
      ? ids
          .map((item) => String(item ?? '').trim())
          .filter((item) => item.length > 0)
      : [];

    if (cleaned.length === 0) {
      return { ok: true, updated: 0 };
    }

    const result = await this.prisma.notification.updateMany({
      where: {
        userId,
        id: { in: cleaned },
        seenAt: null,
      },
      data: {
        seenAt: new Date(),
      },
    });

    return { ok: true, updated: Number(result.count ?? 0) };
  }

  async seenAll(user: any) {
    const userId = this.userIdOf(user);
    if (!userId) {
      return { ok: true, updated: 0 };
    }

    const result = await this.prisma.notification.updateMany({
      where: {
        userId,
        seenAt: null,
      },
      data: {
        seenAt: new Date(),
      },
    });

    return { ok: true, updated: Number(result.count ?? 0) };
  }
}
