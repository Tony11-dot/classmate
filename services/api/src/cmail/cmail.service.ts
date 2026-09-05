import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { NotificationsHubService } from '../notifications/notifications-hub.service';
import { hasAnyRole } from '../auth/roles';
import { SendCMailDto } from './dto/send-cmail.dto';

/// CMail — school-internal mail. Composition is staff-only (ADMIN / TEACHER /
/// SECRETARY); everyone in the school can receive and read. All queries are
/// school-scoped: recipients are always resolved FROM `user.findMany({
/// schoolId })`, so a forged cohortId/userId from another school resolves to
/// nobody. Attachments must point at this API's own /uploads/ storage.
@Injectable()
export class CMailService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly hub: NotificationsHubService,
  ) {}

  private me(user: any): { userId: string; schoolId: string; isAdmin: boolean; isStaff: boolean } {
    const userId = String(user?.id ?? user?.sub ?? '');
    const schoolId = user?.schoolId ? String(user.schoolId) : '';
    if (!userId) throw new UnauthorizedException();
    return {
      userId,
      schoolId,
      isAdmin: hasAnyRole(user, ['ADMIN']),
      isStaff: hasAnyRole(user, ['ADMIN', 'TEACHER', 'SECRETARY']),
    };
  }

  private staff(user: any) {
    const me = this.me(user);
    if (!me.isStaff) throw new ForbiddenException('Staff only');
    if (!me.schoolId) throw new ForbiddenException('No school on account');
    return me;
  }

  /// Composer data: the school's grades, cohorts and people for the
  /// audience pickers. Staff-only (it enumerates the school directory).
  async ddl(user: any) {
    const { schoolId } = this.staff(user);
    const [cohorts, people] = await Promise.all([
      this.prisma.cohort.findMany({
        where: { schoolId },
        select: { id: true, name: true, grade: true },
        orderBy: [{ grade: 'asc' }, { name: 'asc' }],
      }),
      this.prisma.user.findMany({
        where: { schoolId },
        select: {
          id: true,
          name: true,
          roles: { select: { role: true } },
          studentProfile: { select: { grade: true, cohort: { select: { grade: true } } } },
        },
        orderBy: { name: 'asc' },
      }),
    ]);
    const grades = [...new Set(cohorts.map((c) => c.grade))].sort((a, b) => a - b);
    return {
      ok: true,
      grades,
      cohorts: cohorts.map((c) => ({ id: c.id, name: c.name, grade: c.grade })),
      people: people.map((p) => ({
        id: p.id,
        name: p.name,
        role: p.roles[0]?.role ?? 'STUDENT',
        grade: p.studentProfile?.grade ?? p.studentProfile?.cohort?.grade ?? null,
      })),
    };
  }

  /// Attachment URLs may only point at this API's own upload storage —
  /// otherwise a mail could smuggle an arbitrary external link styled as a
  /// trusted attachment. Server-relative only: /uploads/attachment returns
  /// relative paths, and an absolute URL could smuggle a foreign host that
  /// merely CONTAINS "/uploads/" in its path.
  private assertOwnUploadUrl(url: string) {
    if (!/^\/uploads\/[A-Za-z0-9._\-\/]+$/.test(url)) {
      throw new BadRequestException('Attachments must be uploaded files');
    }
  }

  private async resolveRecipients(schoolId: string, dto: SendCMailDto): Promise<string[]> {
    const base = { schoolId } as const;
    let where: any;
    switch (dto.audience) {
      case 'SCHOOL':
        where = { ...base };
        break;
      case 'STUDENTS':
        where = { ...base, roles: { some: { role: 'STUDENT' } } };
        break;
      case 'TEACHERS':
        where = { ...base, roles: { some: { role: 'TEACHER' } } };
        break;
      case 'PARENTS':
        where = { ...base, roles: { some: { role: 'PARENT' } } };
        break;
      case 'STAFF':
        where = { ...base, roles: { some: { role: { in: ['TEACHER', 'ADMIN', 'SECRETARY'] } } } };
        break;
      case 'GRADES': {
        const grades = (dto.grades ?? []).filter((g) => Number.isInteger(g));
        if (!grades.length) throw new BadRequestException('Pick at least one grade');
        where = {
          ...base,
          roles: { some: { role: 'STUDENT' } },
          studentProfile: {
            OR: [{ grade: { in: grades } }, { cohort: { grade: { in: grades } } }],
          },
        };
        break;
      }
      case 'COHORTS': {
        const cohortIds = dto.cohortIds ?? [];
        if (!cohortIds.length) throw new BadRequestException('Pick at least one class');
        where = {
          ...base,
          roles: { some: { role: 'STUDENT' } },
          studentProfile: {
            OR: [
              { cohortId: { in: cohortIds } },
              { cohorts: { some: { cohortId: { in: cohortIds } } } },
            ],
          },
        };
        break;
      }
      case 'USERS': {
        const userIds = dto.userIds ?? [];
        if (!userIds.length) throw new BadRequestException('Pick at least one person');
        where = { ...base, id: { in: userIds } };
        break;
      }
      default:
        throw new BadRequestException('Unknown audience');
    }
    const users = await this.prisma.user.findMany({ where, select: { id: true } });
    return users.map((u) => u.id);
  }

  async send(user: any, dto: SendCMailDto) {
    const { userId, schoolId } = this.staff(user);
    for (const a of dto.attachments ?? []) this.assertOwnUploadUrl(a.url);

    // Broadcasts never notify the sender, but if they deliberately picked
    // themselves under "Specific people" the mail should still reach their own
    // inbox (QA #47).
    const keepSelf =
      dto.audience === 'USERS' && (dto.userIds ?? []).includes(userId);
    const recipientIds = (await this.resolveRecipients(schoolId, dto)).filter(
      (id) => keepSelf || id !== userId,
    );
    if (!recipientIds.length) {
      throw new BadRequestException('This audience has no recipients');
    }

    const cohortNames = dto.cohortIds?.length
      ? (
          await this.prisma.cohort.findMany({
            where: { id: { in: dto.cohortIds }, schoolId },
            select: { name: true },
          })
        ).map((c) => c.name)
      : [];

    const mail = await this.prisma.cMailMessage.create({
      data: {
        schoolId,
        senderId: userId,
        subject: dto.subject.trim(),
        body: dto.body ?? '',
        audience: dto.audience,
        audienceMeta: {
          grades: dto.grades ?? [],
          cohortNames,
          userCount: recipientIds.length,
        },
        attachments: {
          create: (dto.attachments ?? []).map((a) => ({
            url: a.url,
            mimeType: a.mimeType ?? null,
            fileName: a.fileName ?? null,
            fileSize: a.fileSize ?? null,
          })),
        },
      },
    });
    await this.prisma.cMailRecipient.createMany({
      data: recipientIds.map((rid) => ({ mailId: mail.id, userId: rid })),
      skipDuplicates: true,
    });

    // In-app + push notification; a failed notify never fails the send.
    try {
      await this.hub.notify({
        recipientUserIds: recipientIds,
        type: 'CMAIL',
        title: dto.subject.trim(),
        body: (dto.body ?? '').slice(0, 140),
        data: { cmailId: mail.id },
        fanOutToParents: false,
      });
    } catch {
      /* non-fatal */
    }

    return { ok: true, mailId: mail.id, recipientCount: recipientIds.length };
  }

  async inbox(user: any) {
    const { userId } = this.me(user);
    const rows = await this.prisma.cMailRecipient.findMany({
      where: { userId, deletedAt: null },
      include: {
        mail: {
          select: {
            id: true,
            subject: true,
            body: true,
            senderId: true,
            createdAt: true,
            _count: { select: { attachments: true } },
          },
        },
      },
      orderBy: { mail: { createdAt: 'desc' } },
      take: 200,
    });

    const senderIds = [...new Set(rows.map((r) => r.mail.senderId))];
    const senders = senderIds.length
      ? await this.prisma.user.findMany({
          where: { id: { in: senderIds } },
          select: { id: true, name: true },
        })
      : [];
    const senderMap = new Map(senders.map((s) => [s.id, s.name]));

    return {
      ok: true,
      mails: rows.map((r) => ({
        id: r.mail.id,
        subject: r.mail.subject,
        preview: r.mail.body.slice(0, 160),
        senderName: senderMap.get(r.mail.senderId) ?? '',
        attachmentCount: r.mail._count.attachments,
        read: r.readAt != null,
        createdAt: r.mail.createdAt.toISOString(),
      })),
      unreadCount: rows.filter((r) => r.readAt == null).length,
    };
  }

  async sent(user: any) {
    const { userId, schoolId } = this.staff(user);
    const mails = await this.prisma.cMailMessage.findMany({
      where: { schoolId, senderId: userId },
      select: {
        id: true,
        subject: true,
        body: true,
        audience: true,
        audienceMeta: true,
        createdAt: true,
        _count: { select: { attachments: true, recipients: true } },
      },
      orderBy: { createdAt: 'desc' },
      take: 200,
    });
    const readCounts = mails.length
      ? await this.prisma.cMailRecipient.groupBy({
          by: ['mailId'],
          where: { mailId: { in: mails.map((m) => m.id) }, readAt: { not: null } },
          _count: { _all: true },
        })
      : [];
    const readMap = new Map(readCounts.map((r) => [r.mailId, r._count._all]));
    return {
      ok: true,
      mails: mails.map((m) => ({
        id: m.id,
        subject: m.subject,
        preview: m.body.slice(0, 160),
        audience: m.audience,
        audienceMeta: m.audienceMeta,
        attachmentCount: m._count.attachments,
        recipientCount: m._count.recipients,
        readCount: readMap.get(m.id) ?? 0,
        createdAt: m.createdAt.toISOString(),
      })),
    };
  }

  async unreadCount(user: any) {
    const { userId } = this.me(user);
    const count = await this.prisma.cMailRecipient.count({
      where: { userId, deletedAt: null, readAt: null },
    });
    return { ok: true, count };
  }

  /// Toggle MY read state for a mail without opening it (inbox long-press).
  /// Recipient-scoped: only affects the caller's row, never the sender stats
  /// beyond the natural read-count change.
  async setRead(user: any, mailId: string, read: boolean) {
    const { userId } = this.me(user);
    const row = await this.prisma.cMailRecipient.findFirst({
      where: { mailId, userId, deletedAt: null },
    });
    if (!row) throw new NotFoundException('Mail not found');
    await this.prisma.cMailRecipient.update({
      where: { id: row.id },
      data: { readAt: read ? (row.readAt ?? new Date()) : null },
    });
    return { ok: true };
  }

  /// Full mail. Allowed for the sender and any (non-deleted) recipient —
  /// nobody else, including same-school users outside the audience.
  async detail(user: any, mailId: string) {
    const { userId, schoolId } = this.me(user);
    const mail = await this.prisma.cMailMessage.findFirst({
      where: { id: mailId, ...(schoolId ? { schoolId } : {}) },
      include: {
        attachments: true,
        _count: { select: { recipients: true } },
      },
    });
    if (!mail) throw new NotFoundException('Mail not found');

    const isSender = mail.senderId === userId;
    const recipientRow = isSender
      ? null
      : await this.prisma.cMailRecipient.findFirst({
          where: { mailId, userId, deletedAt: null },
        });
    if (!isSender && !recipientRow) throw new NotFoundException('Mail not found');

    if (recipientRow && recipientRow.readAt == null) {
      await this.prisma.cMailRecipient.update({
        where: { id: recipientRow.id },
        data: { readAt: new Date() },
      });
    }

    const sender = await this.prisma.user.findUnique({
      where: { id: mail.senderId },
      select: { name: true },
    });

    return {
      ok: true,
      mail: {
        id: mail.id,
        subject: mail.subject,
        body: mail.body,
        senderId: mail.senderId,
        senderName: sender?.name ?? '',
        audience: mail.audience,
        audienceMeta: mail.audienceMeta,
        recipientCount: mail._count.recipients,
        isSender,
        attachments: mail.attachments.map((a) => ({
          url: a.url,
          mimeType: a.mimeType,
          fileName: a.fileName,
          fileSize: a.fileSize,
        })),
        createdAt: mail.createdAt.toISOString(),
      },
    };
  }

  /// The recipient roster for a mail — sender-only, so the "N recipients"
  /// chip can be opened to see exactly who it went to (QA #44). Capped so a
  /// school-wide broadcast can't return an unbounded list.
  async recipients(user: any, mailId: string) {
    const { userId, schoolId } = this.me(user);
    const mail = await this.prisma.cMailMessage.findFirst({
      where: { id: mailId, ...(schoolId ? { schoolId } : {}) },
      select: { id: true, senderId: true },
    });
    if (!mail) throw new NotFoundException('Mail not found');
    if (mail.senderId !== userId)
      throw new ForbiddenException('Only the sender can view recipients');

    const rows = await this.prisma.cMailRecipient.findMany({
      where: { mailId },
      select: { userId: true, readAt: true },
      take: 1000,
    });
    const users = rows.length
      ? await this.prisma.user.findMany({
          where: { id: { in: rows.map((r) => r.userId) } },
          select: { id: true, name: true, roles: { select: { role: true } } },
        })
      : [];
    const nameMap = new Map(users.map((u) => [u.id, u]));
    return {
      ok: true,
      recipients: rows
        .map((r) => {
          const u = nameMap.get(r.userId);
          return {
            id: r.userId,
            name: u?.name ?? '',
            role: u?.roles?.[0]?.role ?? null,
            read: r.readAt != null,
          };
        })
        .sort((a, b) => a.name.localeCompare(b.name)),
    };
  }

  /// Sender (or a same-school ADMIN) deletes the mail for everyone;
  /// a recipient only soft-deletes their own copy.
  async delete(user: any, mailId: string) {
    const { userId, schoolId, isAdmin } = this.me(user);
    const mail = await this.prisma.cMailMessage.findFirst({
      where: { id: mailId, ...(schoolId ? { schoolId } : {}) },
      select: { id: true, senderId: true, schoolId: true },
    });
    if (!mail) throw new NotFoundException('Mail not found');

    if (mail.senderId === userId || (isAdmin && mail.schoolId === schoolId)) {
      await this.prisma.cMailMessage.delete({ where: { id: mail.id } });
      return { ok: true, deleted: 'all' };
    }

    const row = await this.prisma.cMailRecipient.findFirst({
      where: { mailId, userId, deletedAt: null },
    });
    if (!row) throw new NotFoundException('Mail not found');
    await this.prisma.cMailRecipient.update({
      where: { id: row.id },
      data: { deletedAt: new Date() },
    });
    return { ok: true, deleted: 'me' };
  }
}
