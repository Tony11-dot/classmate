import {
  BadRequestException,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { parentAllowedChildIds, requireParentChild } from '../auth/scope';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { ScheduleService } from '../schedule/schedule.service';
import { ParentNotificationDtoSchema } from './dto/parent-notification.dto';
import { hasAnyRole } from '../auth/permissions';

function ymdInJerusalem(date = new Date()): string {
  return new Intl.DateTimeFormat('en-CA', {
    timeZone: 'Asia/Jerusalem',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(date); // YYYY-MM-DD
}

function dayOfWeekInJerusalem(date = new Date()): number {
  const wk = new Intl.DateTimeFormat('en-US', {
    timeZone: 'Asia/Jerusalem',
    weekday: 'short',
  }).format(date);
  const map: Record<string, number> = {
    Sun: 0,
    Mon: 1,
    Tue: 2,
    Wed: 3,
    Thu: 4,
    Fri: 5,
    Sat: 6,
  };
  return map[wk] ?? 0;
}

function startOfWeekSundayInJerusalem(anyDate: Date): Date {
  const dow = dayOfWeekInJerusalem(anyDate);
  const d = new Date(anyDate.getTime());
  d.setDate(d.getDate() - dow);
  d.setHours(0, 0, 0, 0);
  return d;
}

type StudentProfileLite = { userId: string; cohortId: string };

@Injectable()
export class ParentService {
  private isAdmin(user: any) {
    const roles: string[] = user?.roles ?? [];
    return hasAnyRole({ roles }, ['ADMIN']);
  }

  private async ensureParentStudentScope(user: any, studentId?: string) {
    if (this.isAdmin(user)) return { studentId };
    const parentId = user?.id;
    if (!parentId) throw new ForbiddenException('Missing user');
    if (studentId) {
      await requireParentChild(this.prisma, parentId, studentId);
      return { studentId };
    }
    const ids = await parentAllowedChildIds(this.prisma, parentId);
    return { allowedStudentIds: ids };
  }

  constructor(
    private readonly prisma: PrismaService,
    private readonly schedule: ScheduleService,
  ) {}

  // normalize notification payload
  private notifDto(n: any) {
    const rawAt = n?.at ?? n?.createdAt; // prefer createdAt; legacy fields may exist
    const createdAt = rawAt ? new Date(rawAt).toISOString() : null;
    const seenAt = n?.seenAt ? new Date(n.seenAt).toISOString() : null;

    return {
      id: n.id,
      parentId: n.parentId,
      studentId: n.studentId ?? null,
      type: n.type,
      title: n.title,
      message: n.message ?? null,
      data: n.data ?? null,
      createdAt,
      seenAt,
    };
  }

  private ensureParent(user: any) {
    if (!user?.roles?.includes('PARENT'))
      throw new ForbiddenException('Parent only');
  }

  private async assertLinked(parentId: string, childId: string) {
    const link = await this.prisma.parentChild.findUnique({
      where: { parentId_childId: { parentId, childId } },
      select: { status: true },
    });
    if (!link || link.status !== 'APPROVED')
      throw new ForbiddenException('Not linked to this child');
  }

  async link(user: any, body: { code: string }) {
    if (
      !user?.roles?.includes('STUDENT') &&
      !user?.roles?.includes('PARENT') &&
      !user?.roles?.includes('ADMIN')
    )
      throw new ForbiddenException('Auth required');
    const parentId = user.sub ?? user.id;

    if (!body?.code) throw new BadRequestException('code is required');

    const now = new Date();
    const codes = await this.prisma.parentLinkCode.findMany({
      where: { expiresAt: { gt: now } },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });

    let childId: string | null = null;
    for (const c of codes) {
      const ok = await bcrypt.compare(body.code, c.codeHash);
      if (ok) {
        childId = c.childId;
        break;
      }
    }

    if (!childId) throw new BadRequestException('Invalid or expired code');

    await this.prisma.parentChild.upsert({
      where: { parentId_childId: { parentId, childId } },
      update: { status: 'APPROVED' },
      create: { parentId, childId, status: 'APPROVED' },
    });

    // ensure parent role exists (so next login token includes PARENT)
    await this.prisma.userRole.upsert({
      where: { userId_role: { userId: parentId, role: 'PARENT' } },
      update: {},
      create: { userId: parentId, role: 'PARENT' },
    });

    return { ok: true, childId };
  }

  async children(user: any) {
    if (
      !user?.roles?.includes('STUDENT') &&
      !user?.roles?.includes('PARENT') &&
      !user?.roles?.includes('ADMIN')
    )
      throw new ForbiddenException('Auth required');
    const parentId = user.sub ?? user.id;

    const links = await this.prisma.parentChild.findMany({
      where: {
        parentId,
        status: 'APPROVED',
      },
      include: {
        child: {
          include: {
            studentProfile: { include: { cohort: true } },
          },
        },
      },
      orderBy: { id: 'asc' },
    });

    return links.map((l) => ({
      studentId: l.childId,
      name: l.child.name,
      status: l.status,
      cohort: l.child.studentProfile?.cohort
        ? {
            id: l.child.studentProfile.cohort.id,
            name: l.child.studentProfile.cohort.name,
            grade: (l.child.studentProfile.cohort as any).grade ?? null,
          }
        : null,
    }));
  }

  async grades(user: any, limit?: number) {
    if (
      !user?.roles?.includes('STUDENT') &&
      !user?.roles?.includes('PARENT') &&
      !user?.roles?.includes('ADMIN')
    )
      throw new ForbiddenException('Auth required');

    const take = Math.max(1, Math.min(100, Number(limit ?? 20)));
    const parentId = user.sub ?? user.id;

    const links = await this.prisma.parentChild.findMany({
      where: { parentId, status: 'APPROVED' },
      select: { childId: true },
    });

    const childIds = links.map((l) => l.childId);
    if (childIds.length === 0) return { ok: true, grades: [] };

    const rows = await this.prisma.gradeRecord.findMany({
      take,
      where: { studentId: { in: childIds } },
      orderBy: [{ assessment: { date: 'desc' } }, { id: 'desc' }],
      include: { assessment: { include: { course: true } } },
    });

    return {
      ok: true,
      grades: rows.map((r) => ({
        studentId: r.studentId,
        grade: r.grade,
        comment: r.comment,
        assessment: {
          id: r.assessment.id,
          title: r.assessment.title,
          date: r.assessment.date.toISOString(),
        },
        course: {
          id: r.assessment.course.id,
          name: r.assessment.course.name,
          subject: r.assessment.course.subject,
        },
      })),
    };
  }

  async childGrades(user: any, studentId: string) {
    if (
      !user?.roles?.includes('STUDENT') &&
      !user?.roles?.includes('PARENT') &&
      !user?.roles?.includes('ADMIN')
    )
      throw new ForbiddenException('Auth required');
    const parentId = user.sub ?? user.id;

    if (!studentId) throw new BadRequestException('studentId is required');
    await this.assertLinked(parentId, studentId);

    const records = await this.prisma.gradeRecord.findMany({
      take: 20,
      where: { studentId },
      orderBy: [{ assessment: { date: 'desc' } }, { id: 'desc' }],
      include: {
        assessment: {
          include: {
            course: { select: { id: true, name: true, subject: true } },
          },
        },
      },
    });

    return {
      ok: true,
      grades: records.map((r) => ({
        studentId: r.studentId,
        grade: r.grade,
        comment: r.comment,
        assessment: {
          id: r.assessment.id,
          title: r.assessment.title,
          date: r.assessment.date.toISOString(),
        },
        course: r.assessment.course
          ? {
              id: r.assessment.course.id,
              name: r.assessment.course.name,
              subject: r.assessment.course.subject,
            }
          : null,
      })),
    };
  }

  async scheduleToday(user: any, studentId: string) {
    if (
      !user?.roles?.includes('STUDENT') &&
      !user?.roles?.includes('PARENT') &&
      !user?.roles?.includes('ADMIN')
    )
      throw new ForbiddenException('Auth required');
    const parentId = user.sub ?? user.id;

    if (!studentId) throw new BadRequestException('studentId is required');
    await this.assertLinked(parentId, studentId);

    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: studentId },
    });
    if (!sp) throw new BadRequestException('Student not onboarded');

    return this.schedule.getTodayForCohort(sp.cohortId);
  }

  async scheduleWeek(user: any, studentId: string, weekOf?: string) {
    if (
      !user?.roles?.includes('STUDENT') &&
      !user?.roles?.includes('PARENT') &&
      !user?.roles?.includes('ADMIN')
    )
      throw new ForbiddenException('Auth required');
    await this.assertLinked(user.sub ?? user.id, studentId);

    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: studentId },
      select: { cohortId: true },
    });
    if (!sp) throw new BadRequestException('Student not onboarded');

    return this.schedule.getWeekForCohort(sp.cohortId, weekOf);
  }

  async attendanceToday(user: any, studentId: string) {
    if (
      !user?.roles?.includes('STUDENT') &&
      !user?.roles?.includes('PARENT') &&
      !user?.roles?.includes('ADMIN')
    )
      throw new ForbiddenException('Auth required');
    const parentId = user.sub ?? user.id;

    if (!studentId) throw new BadRequestException('studentId is required');
    await this.assertLinked(parentId, studentId);

    const ymd = ymdInJerusalem(new Date());
    const date = new Date(`${ymd}T00:00:00.000Z`);

    const sessions = await this.prisma.attendanceSession.findMany({
      where: { date, records: { some: { studentId } } },
      orderBy: { period: 'asc' },
      include: { course: true, records: { where: { studentId } } },
    });

    return {
      date: ymd,
      sessions: sessions.map((s) => ({
        period: s.period,
        status: s.records[0]?.status ?? 'UNMARKED',
        note: s.records[0]?.note ?? null,
        course: s.course
          ? { id: s.course.id, name: s.course.name, subject: s.course.subject }
          : null,
      })),
    };
  }

  async attendanceWeek(user: any, studentId: string, weekOf?: string) {
    if (
      !user?.roles?.includes('STUDENT') &&
      !user?.roles?.includes('PARENT') &&
      !user?.roles?.includes('ADMIN')
    )
      throw new ForbiddenException('Auth required');
    const parentId = user.sub ?? user.id;

    if (!studentId) throw new BadRequestException('studentId is required');
    await this.assertLinked(parentId, studentId);

    const base = weekOf ? new Date(`${weekOf}T00:00:00.000Z`) : new Date();
    const start = startOfWeekSundayInJerusalem(
      Number.isNaN(base.getTime()) ? new Date() : base,
    );
    const end = new Date(start.getTime());
    end.setDate(end.getDate() + 7);

    const sessions = await this.prisma.attendanceSession.findMany({
      where: {
        date: { gte: start, lt: end },
        records: { some: { studentId } },
      },
      orderBy: [{ date: 'asc' }, { period: 'asc' }],
      include: { course: true, records: { where: { studentId } } },
    });

    return {
      weekStart: start.toISOString(),
      weekEnd: end.toISOString(),
      sessions: sessions.map((s) => ({
        date: s.date.toISOString(),
        period: s.period,
        status: s.records[0]?.status ?? 'UNMARKED',
        note: s.records[0]?.note ?? null,
        course: s.course
          ? { id: s.course.id, name: s.course.name, subject: s.course.subject }
          : null,
      })),
    };
  }

  async overview(user: any, studentId: string) {
    if (
      !user?.roles?.includes('STUDENT') &&
      !user?.roles?.includes('PARENT') &&
      !user?.roles?.includes('ADMIN')
    )
      throw new ForbiddenException('Auth required');

    const parentId = user.sub ?? user.id;
    if (!studentId) throw new BadRequestException('studentId is required');

    await this.assertLinked(parentId, studentId);

    const child = await this.prisma.user.findUnique({
      where: { id: studentId },
      select: { id: true, name: true },
    });

    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: studentId },
      select: { cohortId: true },
    });

    const [todaySchedule, todayAttendance, allGrades] = await Promise.all([
      sp
        ? this.schedule.getTodayForCohort(sp.cohortId)
        : { dayOfWeek: null, date: null, slots: [] },
      this.attendanceToday(user, studentId),
      this.grades(user),
    ]);

    const grades = (allGrades?.grades || []).filter(
      (g: any) => g.studentId === studentId,
    );

    return {
      student: {
        studentId,
        name: child?.name ?? null,
        cohortId: sp?.cohortId ?? null,
      },
      todaySchedule,
      todayAttendance,
      grades: { ok: true, grades },
    };
  }

  async overviewWeek(user: any, studentId: string) {
    if (
      !user?.roles?.includes('STUDENT') &&
      !user?.roles?.includes('PARENT') &&
      !user?.roles?.includes('ADMIN')
    )
      throw new ForbiddenException('Auth required');

    const parentId = user.sub ?? user.id;

    if (!studentId) throw new BadRequestException('studentId is required');
    await this.assertLinked(parentId, studentId);

    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: studentId },
      select: { cohortId: true },
    });
    if (!sp) throw new BadRequestException('Student not onboarded');

    const [weekSchedule, attendanceWeek, grades] = await Promise.all([
      this.schedule.getWeekForCohort(sp.cohortId),
      this.attendanceWeek(user, studentId),
      this.childGrades(user, studentId),
    ]);

    return {
      studentId,
      cohortId: sp.cohortId,
      weekSchedule,
      attendanceWeek,
      grades,
    };
  }

  async dashboard(user: any) {
    if (
      !user?.roles?.includes('STUDENT') &&
      !user?.roles?.includes('PARENT') &&
      !user?.roles?.includes('ADMIN')
    )
      throw new ForbiddenException('Auth required');
    const parentId = user.sub ?? user.id;

    const links = await this.prisma.parentChild.findMany({
      where: { parentId, status: 'APPROVED' },
      include: { child: { select: { id: true, name: true } } },
      orderBy: { id: 'asc' },
    });

    const studentIds = links.map((l) => l.childId);

    const profiles: StudentProfileLite[] =
      await this.prisma.studentProfile.findMany({
        where: { userId: { in: studentIds } },
        select: { userId: true, cohortId: true },
      });
    const profileById = new Map<string, StudentProfileLite>(
      profiles.map((p) => [p.userId, p]),
    );

    const cohortIds = Array.from(new Set(profiles.map((p) => p.cohortId)));
    const cohorts = await this.prisma.cohort.findMany({
      where: { id: { in: cohortIds } },
      select: { id: true, name: true, grade: true },
    });
    const cohortById = new Map(cohorts.map((c) => [c.id, c]));

    const nameById = new Map(links.map((l) => [l.childId, l.child.name]));

    const children: any[] = [];
    for (const childId of studentIds) {
      const sp = profileById.get(childId) as any;
      const cohort = sp ? (cohortById.get(sp.cohortId) ?? null) : null;

      const [todaySchedule, todayAttendance, grades] = await Promise.all([
        sp
          ? this.schedule.getTodayForCohort(sp.cohortId)
          : { dayOfWeek: null, date: null, slots: [] },
        this.attendanceToday(user, childId),
        this.childGrades(user, childId),
      ]);

      children.push({
        student: { studentId: childId, name: nameById.get(childId) ?? null },
        cohort,
        todaySchedule,
        todayAttendance,
        grades,
      });
    }

    return { ok: true, count: children.length, children };
  }

  async notifications(user: any, opts?: { studentId?: string; take?: number }) {
    if (
      !user?.roles?.includes('STUDENT') &&
      !user?.roles?.includes('PARENT') &&
      !user?.roles?.includes('ADMIN')
    )
      throw new ForbiddenException('Auth required');
    const parentId = user.sub ?? user.id;
    const take = Math.max(1, Math.min(100, Number(opts?.take ?? 20)));

    // If studentId was provided but becomes empty after trim -> reject
    if (
      typeof opts?.studentId === 'string' &&
      opts.studentId.length > 0 &&
      !opts.studentId.trim()
    ) {
      throw new BadRequestException('studentId is invalid');
    }
    const studentId = opts?.studentId?.trim() || null;

    if (studentId) {
      await this.assertLinked(parentId, studentId);
    }

    const rows = await this.prisma.parentNotification.findMany({
      where: {
        parentId,
        // hide legacy notifications from older attendance implementation
        type: { notIn: ['ATTENDANCE_MARKED'] as any },

        ...(studentId ? { studentId } : {}),
      },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take,
    });

    const notifications = rows
      .map((n: any) => this.notifDto(n))
      .map((n) => ({
        id: n.id,
        type: n.type,
        createdAt: n.createdAt,
        studentId: n.studentId,
        title: n.title,
        message: n.message,
        data: n.data,
        seenAt: n.seenAt,
      }));

    // dev/test contract guard (prevents legacy keys like "at" from creeping back)
    if (process.env.NODE_ENV !== 'production') {
      for (const x of notifications) ParentNotificationDtoSchema.parse(x);
    }

    return { ok: true, notifications };
  }

  private async getLastSeenAt(parentId: string) {
    const row = await this.prisma.parentNotificationState.upsert({
      where: { parentId },
      update: {},
      create: { parentId },
      select: { lastSeenAt: true },
    });
    return row.lastSeenAt;
  }

  async unreadCount(user: any, opts?: { studentId?: string; since?: string }) {
    if (
      !user?.roles?.includes('STUDENT') &&
      !user?.roles?.includes('PARENT') &&
      !user?.roles?.includes('ADMIN')
    )
      throw new ForbiddenException('Auth required');
    const parentId = user.sub ?? user.id;

    const state = await this.prisma.parentNotificationState.findUnique({
      where: { parentId },
      select: { lastSeenAt: true },
    });

    const cutoff = opts?.since
      ? new Date(opts.since)
      : (state?.lastSeenAt ?? null);

    const where: any = {
      parentId,
      seenAt: null,
    };

    if (opts?.studentId) where.studentId = opts.studentId;
    // NOTE: unread is based on seenAt=null only (no createdAt cutoff)

    const unread = await this.prisma.parentNotification.count({ where });

    const grouped = await this.prisma.parentNotification.groupBy({
      by: ['type'],
      where,
      _count: { _all: true },
    });

    const breakdown: Record<string, number> = {};
    for (const g of grouped) breakdown[g.type] = g._count._all;

    return {
      ok: true,
      unread,
      since: cutoff ? cutoff.toISOString() : null,
      breakdown,
    };
  }

  async lookup(user: any) {
    if (
      !user?.roles?.includes('STUDENT') &&
      !user?.roles?.includes('PARENT') &&
      !user?.roles?.includes('ADMIN')
    )
      throw new ForbiddenException('Auth required');
    const parentId = user.sub ?? user.id;

    const links = await this.prisma.parentChild.findMany({
      where: { parentId, status: 'APPROVED' as any },
      include: {
        child: {
          select: {
            displayName: true,
            legalName: true,
            name: true,
            email: true,
          },
        },
      },
    });

    const students = links.map((l) => ({
      id: l.childId,
      name:
        l.child?.displayName ||
        l.child?.legalName ||
        l.child?.name ||
        l.child?.email ||
        l.childId,
    }));

    // courses referenced by recent notifications (last 200)
    const recent = await this.prisma.parentNotification.findMany({
      where: { parentId },
      orderBy: { createdAt: 'desc' },
      take: 200,
      select: { data: true },
    });

    const courseIds = Array.from(
      new Set(
        recent
          .map((n) => (n.data as any)?.courseId || (n.data as any)?.course?.id)
          .filter(Boolean),
      ),
    );

    const courses = courseIds.length
      ? await this.prisma.course.findMany({
          where: { id: { in: courseIds } },
          select: { id: true, name: true, subject: true, cohortId: true },
        })
      : [];

    return { ok: true, students, courses };
  }

  async markSeen(user: any, ids?: string[]) {
    if (
      !user?.roles?.includes('STUDENT') &&
      !user?.roles?.includes('PARENT') &&
      !user?.roles?.includes('ADMIN')
    )
      throw new ForbiddenException('Auth required');
    const parentId = user.sub ?? user.id;

    const now = new Date();
    const list = Array.isArray(ids) ? ids.filter(Boolean) : [];

    if (list.length > 0) {
      await this.prisma.parentNotification.updateMany({
        where: { parentId, id: { in: list } },
        data: { seenAt: now },
      });
    } else {
      // mark all unseen as seen
      await this.prisma.parentNotification.updateMany({
        where: { parentId, seenAt: null },
        data: { seenAt: now },
      });
    }

    // keep state for compatibility with "since"
    await this.prisma.parentNotificationState.upsert({
      where: { parentId },
      update: { lastSeenAt: now },
      create: { parentId, lastSeenAt: now },
    });

    return { ok: true, lastSeenAt: now.toISOString() };
  }

  async getChildAttendance(
    user: any,
    q: { childId: string; from?: string; to?: string },
  ) {
    // allow ADMIN for testing
    if (!user?.roles?.includes('PARENT') && !user?.roles?.includes('ADMIN')) {
      throw new ForbiddenException('Parent only');
    }

    const parentId = user.sub ?? user.id;
    const childId = q.childId;
    if (!childId) throw new BadRequestException('childId is required');

    const link = await this.prisma.parentChild.findFirst({
      where: {
        parentId: user.id,
        childId: childId,
        status: 'APPROVED',
      },
    });
    if (!link) throw new ForbiddenException('Not linked');

    const toYmd =
      q.to ??
      new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Jerusalem' }).format(
        new Date(),
      );

    const fromYmd =
      q.from ??
      new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Jerusalem' }).format(
        new Date(Date.now() - 29 * 24 * 60 * 60 * 1000),
      );

    const from = new Date(fromYmd + 'T00:00:00.000Z');
    const to = new Date(toYmd + 'T00:00:00.000Z');
    const toPlus = new Date(to.getTime() + 24 * 60 * 60 * 1000);

    const records = await this.prisma.attendanceRecord.findMany({
      where: {
        studentId: childId,
        session: { date: { gte: from, lt: toPlus } },
      },
      include: { session: { include: { course: true } } },
      orderBy: [{ session: { date: 'desc' } }, { session: { period: 'asc' } }],
    });

    return {
      ok: true,
      from: fromYmd,
      to: toYmd,
      items: records.map((r) => ({
        date: new Intl.DateTimeFormat('en-CA', { timeZone: 'UTC' }).format(
          r.session.date,
        ),
        period: r.session.period,
        status: r.status,
        note: r.note,
        course: r.session.course
          ? {
              id: r.session.course.id,
              name: r.session.course.name,
              subject: r.session.course.subject,
            }
          : null,
      })),
    };
  }
}
