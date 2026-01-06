import {
  BadRequestException,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { ScheduleService } from '../schedule/schedule.service';

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

@Injectable()
export class ParentService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly schedule: ScheduleService,
  ) {}

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
    this.ensureParent(user);
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

    return { ok: true, childId };
  }

  async children(user: any) {
    this.ensureParent(user);
    const parentId = user.sub ?? user.id;

    const links = await this.prisma.parentChild.findMany({
      where: { parentId, status: 'APPROVED' },
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
    this.ensureParent(user);

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
    this.ensureParent(user);
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
    this.ensureParent(user);
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
    this.ensureParent(user);
    await this.assertLinked(user.sub ?? user.id, studentId);

    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: studentId },
      select: { cohortId: true },
    });
    if (!sp) throw new BadRequestException('Student not onboarded');

    return this.schedule.getWeekForCohort(sp.cohortId, weekOf);
  }

  async attendanceToday(user: any, studentId: string) {
    this.ensureParent(user);
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
    this.ensureParent(user);
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
    this.ensureParent(user);

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
    this.ensureParent(user);

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
    this.ensureParent(user);
    const parentId = user.sub ?? user.id;

    const links = await this.prisma.parentChild.findMany({
      where: { parentId, status: 'APPROVED' },
      include: { child: { select: { id: true, name: true } } },
      orderBy: { id: 'asc' },
    });

    const studentIds = links.map((l) => l.childId);

    const profiles = await this.prisma.studentProfile.findMany({
      where: { userId: { in: studentIds } },
      select: { userId: true, cohortId: true },
    });
    const profileById = new Map(profiles.map((p) => [p.userId, p]));

    const cohortIds = Array.from(new Set(profiles.map((p) => p.cohortId)));
    const cohorts = await this.prisma.cohort.findMany({
      where: { id: { in: cohortIds } },
      select: { id: true, name: true, grade: true },
    });
    const cohortById = new Map(cohorts.map((c) => [c.id, c]));

    const nameById = new Map(links.map((l) => [l.childId, l.child.name]));

    const children: any[] = [];
    for (const childId of studentIds) {
      const sp = profileById.get(childId);
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
    this.ensureParent(user);
    const parentId = user.sub ?? user.id;

    const take = Math.max(1, Math.min(100, Number(opts?.take ?? 20)));

    // If studentId was provided but becomes empty after trim -> reject (prevents accidental all-children).
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

    const links = await this.prisma.parentChild.findMany({
      where: {
        parentId,
        status: 'APPROVED',
        ...(studentId ? { childId: studentId } : {}),
      },
      select: { childId: true },
    });

    const childIds = links.map((l) => l.childId);
    if (childIds.length === 0) return { ok: true, notifications: [] };

    const students = await this.prisma.user.findMany({
      where: { id: { in: childIds } },
      select: { id: true, name: true },
    });
    const nameById = new Map(students.map((s) => [s.id, s.name ?? s.id]));

    const grades = await this.prisma.gradeRecord.findMany({
      where: { studentId: { in: childIds } },
      take,
      orderBy: [{ assessment: { date: 'desc' } }, { id: 'desc' }],
      include: {
        assessment: {
          include: {
            course: { select: { id: true, name: true, subject: true } },
          },
        },
      },
    });

    const notifications: any[] = grades.map((g) => ({
      type: 'GRADE_POSTED',
      at: g.assessment.date.toISOString(),
      studentId: g.studentId,
      studentName: nameById.get(g.studentId) ?? null,
      title: `New grade in ${g.assessment.course?.name ?? 'course'}`,
      data: {
        grade: g.grade,
        comment: g.comment,
        assessment: {
          id: g.assessment.id,
          title: g.assessment.title,
          date: g.assessment.date.toISOString(),
        },
        course: g.assessment.course
          ? {
              id: g.assessment.course.id,
              name: g.assessment.course.name,
              subject: g.assessment.course.subject,
            }
          : null,
      },
    }));

    // Attendance notifications for TODAY
    const ymd = ymdInJerusalem(new Date());
    const start = new Date(`${ymd}T00:00:00.000Z`);
    const end = new Date(`${ymd}T23:59:59.999Z`);

    const attendanceSessions = await this.prisma.attendanceSession.findMany({
      where: {
        date: { gte: start, lte: end },
        records: { some: { studentId: { in: childIds } } },
      },
      include: {
        course: true,
        records: { where: { studentId: { in: childIds } } }, // critical: avoid leaking other students
      },
    });

    for (const ses of attendanceSessions ?? []) {
      for (const r of ses.records ?? []) {
        notifications.push({
          type: 'ATTENDANCE_MARKED',
          at: (r.updatedAt ?? r.markedAt).toISOString(),
          studentId: r.studentId,
          studentName: nameById.get(r.studentId) ?? null,
          title: `Attendance: ${ses.course?.name ?? 'course'} (period ${ses.period})`,
          data: {
            date: (r.updatedAt ?? r.markedAt).toISOString(),
            period: ses.period,
            status: r.status,
            note: r.note ?? null,
            course: ses.course
              ? {
                  id: ses.course.id,
                  name: ses.course.name,
                  subject: ses.course.subject,
                }
              : null,
          },
        });
      }
    }

    notifications.sort((a, b) => (a.at < b.at ? 1 : a.at > b.at ? -1 : 0));
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

  async unreadCount(user: any, studentId?: string, since?: string) {
    this.ensureParent(user);
    const parentId = user.sub ?? user.id;

    // determine cutoff (STRICT)
    let cutoff: Date | null = null;

    if (since) {
      const d = new Date(since);
      if (Number.isNaN(d.getTime())) {
        throw new BadRequestException('since must be a valid ISO date');
      }
      cutoff = d;
    }

    if (!cutoff) cutoff = await this.getLastSeenAt(parentId);

    const links = await this.prisma.parentChild.findMany({
      where: { parentId, status: 'APPROVED' },
      select: { childId: true },
    });
    const childIds = links.map((l) => l.childId);

    if (studentId) {
      await this.assertLinked(parentId, studentId);
    }

    const targetIds = studentId ? [studentId] : childIds;

    if (targetIds.length === 0) {
      return {
        ok: true,
        unread: 0,
        since: cutoff.toISOString(),
        breakdown: { grades: 0, attendance: 0 },
      };
    }

    const gradeCount = await this.prisma.gradeRecord.count({
      where: {
        studentId: { in: targetIds },
        assessment: { date: { gt: cutoff } },
      },
    });

    const attendanceCount = await this.prisma.attendanceRecord.count({
      where: {
        studentId: { in: targetIds },
        markedAt: { gt: cutoff },
      },
    });
    return {
      ok: true,
      unread: gradeCount + attendanceCount,
      since: cutoff.toISOString(),
      breakdown: { grades: gradeCount, attendance: attendanceCount },
    };
  }

  async markSeen(user: any) {
    this.ensureParent(user);
    const parentId = user.sub ?? user.id;

    const now = new Date();
    const row = await this.prisma.parentNotificationState.upsert({
      where: { parentId },
      update: { lastSeenAt: now },
      create: { parentId, lastSeenAt: now },
      select: { lastSeenAt: true },
    });

    return { ok: true, lastSeenAt: row.lastSeenAt.toISOString() };
  }
}
