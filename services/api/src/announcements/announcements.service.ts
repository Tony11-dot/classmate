import {
  BadRequestException,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { hasAnyRole } from '../auth/permissions';
import { RealtimeService } from '../realtime/realtime.service';

function parseDateish(input?: string): Date | null {
  if (!input) return null;
  // accept YYYY-MM-DD or ISO
  const iso = input.length === 10 ? `${input}T00:00:00.000Z` : input;
  const dt = new Date(iso);
  if (Number.isNaN(dt.getTime()))
    throw new BadRequestException(`Invalid date: ${input}`);
  return dt;
}

@Injectable()
export class AnnouncementsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly realtime: RealtimeService,
  ) {}

  private ensureCanPost(user: any) {
    const roles: string[] = user?.roles ?? [];
    if (!hasAnyRole({ roles }, ['ADMIN', 'SECRETARY', 'TEACHER'])) {
      throw new ForbiddenException('Admin/Secretary/Teacher only');
    }
  }

  async create(
    user: any,
    body: {
      title: string;
      body: string;
      pinned?: boolean;
      publishAt?: string;
      expiresAt?: string;
      targets?: {
        userId?: string;
        role?: any;
        grade?: number;
        cohortId?: string;
      }[];
    },
  ) {
    this.ensureCanPost(user);

    const title = (body?.title ?? '').trim();
    const text = (body?.body ?? '').trim();
    if (!title) throw new BadRequestException('title is required');
    if (!text) throw new BadRequestException('body is required');

    const publishAt = parseDateish(body.publishAt) ?? new Date();
    const expiresAt = parseDateish(body.expiresAt);

    if (expiresAt && expiresAt <= publishAt) {
      throw new BadRequestException('expiresAt must be after publishAt');
    }

    const targets = Array.isArray(body.targets) ? body.targets : [];

    // basic sanity: reject empty target objects
    for (const t of targets) {
      const ok = t.userId || t.role || t.grade !== undefined || t.cohortId;
      if (!ok)
        throw new BadRequestException('targets[] contains an empty target');
    }

    const created = await this.prisma.announcement.create({
      data: {
        title,
        body: text,
        pinned: !!body.pinned,
        publishAt,
        expiresAt: expiresAt ?? undefined,
        createdBy: user.id,
        targets: targets.length
          ? {
              create: targets.map((t) => ({
                userId: t.userId ?? undefined,
                role: t.role ?? undefined,
                grade: t.grade ?? undefined,
                cohortId: t.cohortId ?? undefined,
              })),
            }
          : undefined,
      },
      include: {
        targets: true,
        creator: { select: { id: true, email: true, name: true } },
      },
    });

    // Emit real-time notification to explicitly targeted users only.
    // For broadcast announcements (targets=[]) the feed is role-filtered server-side,
    // so all connected users will pick it up on their next poll/refresh.
    try {
      const targetUserIds: string[] = [];
      if (created.targets?.length) {
        for (const t of created.targets) {
          if (t.userId) targetUserIds.push(t.userId);
        }
      }
      if (targetUserIds.length) {
        this.realtime.emitToUsers(targetUserIds, { type: 'notification', userId: '' });
      }
    } catch {}
    return { ok: true, announcement: created };
  }

  async feed(user: any, opts: { take: number; skip: number }) {
    const take = Number.isFinite(opts.take)
      ? Math.min(Math.max(opts.take, 1), 100)
      : 20;
    const skip = Number.isFinite(opts.skip) ? Math.max(opts.skip, 0) : 0;

    const now = new Date();
    const roles: any[] = user?.roles ?? [];

    // Build cohortIds + grades that should apply to this user:
    const cohortIds: string[] = [];
    const grades: number[] = [];

    // Student: use their own cohort
    if (hasAnyRole({ roles }, ['STUDENT']) && user?.studentProfile?.cohortId) {
      cohortIds.push(user.studentProfile.cohortId);

      const cohort = await this.prisma.cohort.findUnique({
        where: { id: user.studentProfile.cohortId },
        select: { grade: true },
      });
      if (cohort?.grade !== undefined) grades.push(cohort.grade);
    }

    // Parent: include all approved children cohorts/grades
    if (hasAnyRole({ roles }, ['PARENT'])) {
      const links = await this.prisma.parentChild.findMany({
        where: { parentId: user.id, status: 'APPROVED' },
        select: {
          child: {
            select: {
              studentProfile: { select: { cohortId: true } },
            },
          },
        },
      });

      const childCohortIds = links
        .map((l) => l.child.studentProfile?.cohortId)
        .filter(Boolean) as string[];

      for (const id of childCohortIds) cohortIds.push(id);

      if (childCohortIds.length) {
        const cohorts = await this.prisma.cohort.findMany({
          where: { id: { in: childCohortIds } },
          select: { grade: true },
        });
        for (const c of cohorts)
          if (c.grade !== undefined) grades.push(c.grade);
      }
    }

    // de-dupe
    const cohortIdsUniq = Array.from(new Set(cohortIds));
    const gradesUniq = Array.from(new Set(grades));

    const orTarget: any[] = [
      // broadcast: no targets at all
      { targets: { none: {} } },

      // targeted by direct userId
      { targets: { some: { userId: user.id } } },

      // targeted by role
      roles.length ? { targets: { some: { role: { in: roles } } } } : null,

      // targeted by cohort
      cohortIdsUniq.length
        ? { targets: { some: { cohortId: { in: cohortIdsUniq } } } }
        : null,

      // targeted by grade
      gradesUniq.length
        ? { targets: { some: { grade: { in: gradesUniq } } } }
        : null,
    ].filter(Boolean);

    const announcements = await this.prisma.announcement.findMany({
      where: {
        publishAt: { lte: now },
        OR: [{ expiresAt: null }, { expiresAt: { gt: now } }],
        AND: [{ OR: orTarget }],
      },
      include: {
        targets: true,
        creator: { select: { id: true, email: true, name: true } },
      },
      orderBy: [
        { pinned: 'desc' },
        { publishAt: 'desc' },
        { createdAt: 'desc' },
      ],
      take,
      skip,
    });

    return { ok: true, announcements };
  }

  private async visibleAnnouncementIds(user: any): Promise<string[]> {
    const now = new Date();
    const roles: any[] = user?.roles ?? [];

    const cohortIds: string[] = [];
    const grades: number[] = [];

    if (hasAnyRole({ roles }, ['STUDENT']) && user?.studentProfile?.cohortId) {
      cohortIds.push(user.studentProfile.cohortId);
      const cohort = await this.prisma.cohort.findUnique({
        where: { id: user.studentProfile.cohortId },
        select: { grade: true },
      });
      if (cohort?.grade !== undefined) grades.push(cohort.grade);
    }

    if (hasAnyRole({ roles }, ['PARENT'])) {
      const links = await this.prisma.parentChild.findMany({
        where: { parentId: user.id, status: 'APPROVED' },
        select: {
          child: { select: { studentProfile: { select: { cohortId: true } } } },
        },
      });

      const childCohortIds = links
        .map((l) => l.child.studentProfile?.cohortId)
        .filter(Boolean) as string[];

      for (const id of childCohortIds) cohortIds.push(id);

      if (childCohortIds.length) {
        const cohorts = await this.prisma.cohort.findMany({
          where: { id: { in: childCohortIds } },
          select: { grade: true },
        });
        for (const c of cohorts)
          if (c.grade !== undefined) grades.push(c.grade);
      }
    }

    const cohortIdsUniq = Array.from(new Set(cohortIds));
    const gradesUniq = Array.from(new Set(grades));

    const orTarget: any[] = [
      { targets: { none: {} } },
      { targets: { some: { userId: user.id } } },
      roles.length ? { targets: { some: { role: { in: roles } } } } : null,
      cohortIdsUniq.length
        ? { targets: { some: { cohortId: { in: cohortIdsUniq } } } }
        : null,
      gradesUniq.length
        ? { targets: { some: { grade: { in: gradesUniq } } } }
        : null,
    ].filter(Boolean);

    const rows = await this.prisma.announcement.findMany({
      where: {
        publishAt: { lte: now },
        OR: [{ expiresAt: null }, { expiresAt: { gt: now } }],
        AND: [{ OR: orTarget }],
      },
      select: { id: true },
      orderBy: [
        { pinned: 'desc' },
        { publishAt: 'desc' },
        { createdAt: 'desc' },
      ],
      take: 500,
    });

    return rows.map((r) => r.id);
  }

  async unreadCount(user: any) {
    const ids = await this.visibleAnnouncementIds(user);
    if (!ids.length) return { ok: true, unread: 0 };

    const seen = await this.prisma.announcementSeen.count({
      where: { userId: user.id, announcementId: { in: ids } },
    });

    return { ok: true, unread: Math.max(ids.length - seen, 0) };
  }

  async markSeen(user: any, body: { announcementId?: string }) {
    const ids = body?.announcementId
      ? [body.announcementId]
      : await this.visibleAnnouncementIds(user);

    if (!ids.length) return { ok: true, marked: 0 };

    const rows = await this.prisma.announcementSeen.createMany({
      data: ids.map((id) => ({ userId: user.id, announcementId: id })),
      skipDuplicates: true,
    });

    return { ok: true, marked: rows.count };
  }

  async targets(user: any) {
    const roles = ['STUDENT', 'PARENT', 'TEACHER', 'SECRETARY', 'ADMIN'];

    const gradeRows = await this.prisma.cohort.findMany({
      select: { grade: true },
      distinct: ['grade'],
      orderBy: { grade: 'asc' },
    });

    const grades = gradeRows
      .map((r) => r.grade)
      .filter((g) => g !== null && g !== undefined);

    const gradeList = grades.length ? grades : [7, 8, 9, 10, 11, 12];

    const cohorts = await this.prisma.cohort.findMany({
      select: { id: true, name: true, grade: true },
      orderBy: [{ grade: 'asc' }, { name: 'asc' }],
      take: 500,
    });

    return { ok: true, roles, grades: gradeList, cohorts };
  }
}
