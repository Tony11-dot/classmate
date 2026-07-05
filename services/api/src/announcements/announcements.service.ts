import {
  BadRequestException,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { hasAnyRole } from '../auth/permissions';
import { RealtimeService } from '../realtime/realtime.service';
import { NotificationsHubService } from '../notifications/notifications-hub.service';

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
    private readonly hub: NotificationsHubService,
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
      attachments?: any[];
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
    const attachments = Array.isArray(body.attachments) ? body.attachments : [];

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
        attachments: attachments as any,
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

    // Expand the targets into a concrete list of recipient userIds and
    // hand the dispatch over to the hub — it owns the Notification
    // persistence, SSE push, and parent fan-out.
    try {
      const recipientIds = await this.resolveAudienceUserIds(user, created.targets ?? [], !created.targets?.length);
      if (recipientIds.length > 0) {
        await this.hub.notify({
          recipientUserIds: recipientIds,
          type: 'ANNOUNCEMENT',
          title: title,
          body: text.slice(0, 200),
          template: { key: 'announcement', args: { title } },
          data: { announcementId: created.id },
        });
      }
    } catch (e) {
      console.error('[announcements] notify dispatch failed:', e);
    }
    return { ok: true, announcement: created };
  }

  /// Convert the saved AnnouncementTarget rows into the actual list of
  /// userIds the announcement reaches. Empty targets + isBroadcast =
  /// every user in the school.
  private async resolveAudienceUserIds(
    user: any,
    targets: Array<{
      userId?: string | null;
      role?: string | null;
      grade?: number | null;
      cohortId?: string | null;
    }>,
    isBroadcast: boolean,
  ): Promise<string[]> {
    const schoolId = (user as any)?.schoolId ?? null;
    const result = new Set<string>();

    if (isBroadcast) {
      if (!schoolId) return [];
      const rows = await this.prisma.user.findMany({
        where: { schoolId, id: { not: user.id } },
        select: { id: true },
      });
      rows.forEach((r) => result.add(r.id));
      return Array.from(result);
    }

    const directIds = new Set<string>();
    const roles = new Set<string>();
    const cohortIds = new Set<string>();
    const grades = new Set<number>();
    for (const t of targets) {
      if (t.userId) directIds.add(t.userId);
      if (t.role) roles.add(String(t.role).toUpperCase());
      if (t.cohortId) cohortIds.add(t.cohortId);
      if (typeof t.grade === 'number') grades.add(t.grade);
    }

    // School isolation: direct user targets must belong to the sender's school
    // (the backend can't trust client-supplied userIds across schools).
    if (directIds.size > 0) {
      if (schoolId) {
        const rows = await this.prisma.user.findMany({
          where: { id: { in: Array.from(directIds) }, schoolId },
          select: { id: true },
        });
        rows.forEach((r) => result.add(r.id));
      } else {
        directIds.forEach((id) => result.add(id));
      }
    }

    if (roles.size > 0 && schoolId) {
      const rows = await this.prisma.user.findMany({
        where: {
          schoolId,
          roles: { some: { role: { in: Array.from(roles) as any } } },
        },
        select: { id: true },
      });
      rows.forEach((r) => result.add(r.id));
    }

    if (cohortIds.size > 0) {
      const rows = await this.prisma.studentCohort.findMany({
        // School isolation: only resolve cohorts belonging to the sender's school.
        where: {
          cohortId: { in: Array.from(cohortIds) },
          ...(schoolId ? { cohort: { schoolId } } : {}),
        },
        select: { studentId: true },
      });
      rows.forEach((r) => result.add(r.studentId));
    }

    if (grades.size > 0 && schoolId) {
      const rows = await this.prisma.user.findMany({
        where: {
          schoolId,
          roles: { some: { role: 'STUDENT' as any } },
          studentProfile: { grade: { in: Array.from(grades) } },
        },
        select: { id: true },
      });
      rows.forEach((r) => r.id && result.add(r.id));
    }

    result.delete(user.id);
    return Array.from(result);
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

    // Student: include their cohort + grade. Reads the student's own
    // grade off StudentProfile in addition to any cohort grade so a
    // student in no cohort (or whose cohort's grade array is empty)
    // still matches grade-targeted announcements.
    if (hasAnyRole({ roles }, ['STUDENT'])) {
      const profile = await this.prisma.studentProfile.findUnique({
        where: { userId: user.id },
        select: { cohortId: true, grade: true },
      });
      if (profile?.cohortId) {
        cohortIds.push(profile.cohortId);
        const cohort = await this.prisma.cohort.findUnique({
          where: { id: profile.cohortId },
          select: { grade: true, grades: true } as any,
        }) as any;
        const cohortGrades: number[] = Array.isArray(cohort?.grades) && cohort.grades.length
          ? cohort.grades
          : (cohort?.grade != null ? [cohort.grade] : []);
        for (const g of cohortGrades) grades.push(g);
      }
      if (typeof profile?.grade === 'number') {
        grades.push(profile.grade);
      }
      // Also include any extra cohorts via StudentCohort (many-to-many)
      const studentCohorts = await this.prisma.studentCohort.findMany({
        where: { studentId: user.id },
        select: { cohortId: true },
      });
      for (const sc of studentCohorts) {
        if (sc.cohortId) cohortIds.push(sc.cohortId);
      }
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
          select: { grade: true, grades: true } as any,
        }) as any[];
        for (const c of cohorts) {
          const cg: number[] = Array.isArray(c.grades) && c.grades.length
            ? c.grades
            : (c.grade != null ? [c.grade] : []);
          for (const g of cg) grades.push(g);
        }
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
        // School isolation: only announcements authored inside the viewer's
        // own school. Announcement has no schoolId of its own, so we scope by
        // the creator's school — this prevents broadcast/role/grade-targeted
        // announcements from leaking across schools.
        creator: { is: { schoolId: (user as any)?.schoolId ?? null } },
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

  /// Announcements the current user PUBLISHED (createdBy == user.id),
  /// newest first. Backs the teacher "Published" tab so an author can
  /// always see what they sent regardless of who it was targeted at.
  async mine(user: any, opts: { take: number; skip: number }) {
    this.ensureCanPost(user);
    const take = Number.isFinite(opts.take)
      ? Math.min(Math.max(opts.take, 1), 100)
      : 50;
    const skip = Number.isFinite(opts.skip) ? Math.max(opts.skip, 0) : 0;

    const announcements = await this.prisma.announcement.findMany({
      where: { createdBy: user.id },
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
        select: { grade: true, grades: true } as any,
      }) as any;
      const cohortGrades: number[] = Array.isArray(cohort?.grades) && cohort.grades.length
        ? cohort.grades
        : (cohort?.grade != null ? [cohort.grade] : []);
      for (const g of cohortGrades) grades.push(g);
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
          select: { grade: true, grades: true } as any,
        }) as any[];
        for (const c of cohorts) {
          const cg: number[] = Array.isArray(c.grades) && c.grades.length
            ? c.grades
            : (c.grade != null ? [c.grade] : []);
          for (const g of cg) grades.push(g);
        }
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
        // Same school-isolation scoping as feed() — see note there.
        creator: { is: { schoolId: (user as any)?.schoolId ?? null } },
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
    // Only staff may compose announcements, so only staff may enumerate the
    // audience picker — and it must be scoped to their own school.
    this.ensureCanPost(user);
    const schoolId = (user as any)?.schoolId ?? null;
    const schoolWhere = { schoolId } as const;

    const roles = ['STUDENT', 'PARENT', 'TEACHER', 'SECRETARY', 'ADMIN'];

    const gradeRows = await this.prisma.cohort.findMany({
      where: schoolWhere,
      select: { grade: true },
      distinct: ['grade'],
      orderBy: { grade: 'asc' },
    });

    const grades = gradeRows
      .map((r) => r.grade)
      .filter((g) => g !== null && g !== undefined);

    const gradeList = grades.length ? grades : [7, 8, 9, 10, 11, 12];

    const cohorts = await this.prisma.cohort.findMany({
      where: schoolWhere,
      select: { id: true, name: true, grade: true },
      orderBy: [{ grade: 'asc' }, { name: 'asc' }],
      take: 500,
    });

    return { ok: true, roles, grades: gradeList, cohorts };
  }
}
