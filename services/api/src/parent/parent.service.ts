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
import { StudentInsightsService } from '../student/student-insights.service';

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

type StudentProfileLite = { userId: string; cohortId: string | null };

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
    private readonly insights: StudentInsightsService,
  ) {}

  async insightsForChild(user: any, studentId: string) {
    const parentId = user?.sub ?? user?.id;
    await requireParentChild(this.prisma, parentId, studentId);
    return this.insights.getStudentInsights(user, studentId);
  }

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
      schoolId: (l.child as any).schoolId ?? null, // parent uses this as X-Acting-Student-Id context
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
      include: { assessment: true },
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
          subject: (r.assessment as any).subject ?? null,
          cohortId: r.assessment.cohortId,
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
      include: { assessment: true },
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
          subject: (r.assessment as any).subject ?? null,
          cohortId: r.assessment.cohortId,
        },
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
    // Run the two reads in parallel — they're independent and the parent
    // app fires these as part of a burst on landing screen. Roughly halves
    // the perceived latency on cold-cache loads.
    const [, sp] = await Promise.all([
      this.assertLinked(parentId, studentId),
      this.prisma.studentProfile.findUnique({
        where: { userId: studentId },
        select: { cohortId: true },
      }),
    ]);
    if (!sp) throw new BadRequestException('Student not onboarded');

    return this.schedule.getTodayForCohort(sp.cohortId ?? '');
  }

  async scheduleWeek(user: any, studentId: string, weekOf?: string) {
    if (
      !user?.roles?.includes('STUDENT') &&
      !user?.roles?.includes('PARENT') &&
      !user?.roles?.includes('ADMIN')
    )
      throw new ForbiddenException('Auth required');
    const parentId = user.sub ?? user.id;
    const [, sp] = await Promise.all([
      this.assertLinked(parentId, studentId),
      this.prisma.studentProfile.findUnique({
        where: { userId: studentId },
        select: { cohortId: true, user: { select: { schoolId: true } } },
      }),
    ]);
    if (!sp) throw new BadRequestException('Student not onboarded');

    // Use the SAME resolver the child's own schedule uses — it unions
    // cohort + by-grade + direct-student audiences. getWeekForCohort only
    // covered cohort slots, so a child with no cohort (grade/student
    // targeted) produced an error → "Could not load schedule".
    return this.schedule.getWeekForStudent({
      schoolId: String((sp as any).user?.schoolId ?? user.schoolId ?? ''),
      studentId: String(studentId),
      cohortId: String(sp.cohortId ?? ''),
      weekOf,
    });
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
      include: { records: { where: { studentId } } },
    });

    return {
      date: ymd,
      sessions: sessions.map((s) => ({
        period: s.period,
        status: s.records[0]?.status ?? 'UNMARKED',
        note: s.records[0]?.note ?? null,
        subject: null,
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
      include: { records: { where: { studentId } } },
    });

    return {
      weekStart: start.toISOString(),
      weekEnd: end.toISOString(),
      sessions: sessions.map((s) => ({
        date: s.date.toISOString(),
        period: s.period,
        status: s.records[0]?.status ?? 'UNMARKED',
        note: s.records[0]?.note ?? null,
        subject: null,
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
        ? this.schedule.getTodayForCohort(sp.cohortId ?? '')
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
      this.schedule.getWeekForCohort(sp.cohortId ?? ''),
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

    const cohortIds = Array.from(new Set(profiles.map((p) => p.cohortId).filter((id): id is string => id !== null)));
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
          ? this.schedule.getTodayForCohort(sp.cohortId ?? '')
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

  // ────────────────────────────────────────────────────────────────
  // Child-scoped feeds — mirror the equivalent student methods but
  // pivot the identity to the parent's selected child. Each one runs
  // `requireParentChild()` first so a crafted POST can't peek at
  // another family's data.
  // ────────────────────────────────────────────────────────────────

  /// Mirror of student.service.myExams(), pivoted to a child.
  async examsForChild(user: any, studentId: string) {
    const parentId = user?.sub ?? user?.id;
    await requireParentChild(this.prisma, parentId, studentId);

    const [cohortLinks, profile, childRow] = await Promise.all([
      this.prisma.studentCohort.findMany({
        where: { studentId },
        select: { cohortId: true },
      }),
      this.prisma.studentProfile.findUnique({
        where: { userId: studentId },
        select: { grade: true },
      }),
      this.prisma.user.findUnique({
        where: { id: studentId },
        select: { schoolId: true },
      }),
    ]);
    const cohortIds = cohortLinks.map((c) => c.cohortId);
    const grade = profile?.grade ?? null;
    const schoolId = childRow?.schoolId ?? null;

    const exams = await this.prisma.teacherExam.findMany({
      where: {
        published: true,
        teacher: { ...(schoolId ? { schoolId } : {}) },
        OR: [
          // Gate the broadcast clause to records with NO narrower targeting, so a
          // grade-only item (stored as EVERYONE + targetGrades) no longer leaks
          // school-wide — it is matched by the targetGrades clause instead.
          { targetType: 'EVERYONE', targetCohortIds: { isEmpty: true }, targetStudentIds: { isEmpty: true }, targetGrades: { isEmpty: true } },
          { targetStudentIds: { has: studentId } },
          ...(cohortIds.length ? [{ targetCohortIds: { hasSome: cohortIds } }] : []),
          ...(grade != null ? [{ targetGrades: { has: grade } }] : []),
        ],
      },
      orderBy: { date: 'desc' },
      include: { teacher: { select: { name: true } } },
    });

    const items = await Promise.all(exams.map(async (exam) => {
      const assessment = await this.prisma.assessment.findFirst({
        where: { examId: exam.id, cohortId: { in: [...cohortIds, ''] } },
        select: { id: true },
      });
      const childGrade = assessment ? await this.prisma.gradeRecord.findFirst({
        where: { assessmentId: assessment.id, studentId },
        select: { grade: true },
      }) : null;
      return {
        id: exam.id,
        title: exam.title,
        subject: exam.subject ?? null,
        date: exam.date,
        maxGrade: exam.maxGrade ?? 100,
        grade: childGrade?.grade ?? null,
        teacherName: (exam as any).teacher?.name ?? null,
      };
    }));

    return { ok: true, items };
  }

  /// Mirror of student.service.myTeacherAssignments(), pivoted to a child.
  async assignmentsForChild(user: any, studentId: string) {
    const parentId = user?.sub ?? user?.id;
    await requireParentChild(this.prisma, parentId, studentId);

    const [cohortLinks, profile, childRow] = await Promise.all([
      this.prisma.studentCohort.findMany({
        where: { studentId },
        select: { cohortId: true },
      }),
      this.prisma.studentProfile.findUnique({
        where: { userId: studentId },
        select: { grade: true },
      }),
      this.prisma.user.findUnique({
        where: { id: studentId },
        select: { schoolId: true },
      }),
    ]);
    const cohortIds = cohortLinks.map((c) => c.cohortId);
    const grade = profile?.grade ?? null;
    const schoolId = childRow?.schoolId ?? null;

    const assignments = await this.prisma.teacherAssignment.findMany({
      where: {
        published: true,
        teacher: { ...(schoolId ? { schoolId } : {}) },
        OR: [
          // Gate the broadcast clause to records with NO narrower targeting, so a
          // grade-only item (stored as EVERYONE + targetGrades) no longer leaks
          // school-wide — it is matched by the targetGrades clause instead.
          { targetType: 'EVERYONE', targetCohortIds: { isEmpty: true }, targetStudentIds: { isEmpty: true }, targetGrades: { isEmpty: true } },
          { targetStudentIds: { has: studentId } },
          ...(cohortIds.length ? [{ targetCohortIds: { hasSome: cohortIds } }] : []),
          ...(grade != null ? [{ targetGrades: { has: grade } }] : []),
        ],
      },
      orderBy: [{ dueAt: 'asc' }, { createdAt: 'desc' }],
      include: { teacher: { select: { name: true } } },
    });

    const items = await Promise.all(assignments.map(async (a) => {
      const sub = await this.prisma.teacherAssignmentSubmission.findFirst({
        where: { assignmentId: a.id, studentId },
        select: { id: true, submittedAt: true, grade: true },
      });
      return {
        id: a.id,
        title: a.title,
        description: a.description ?? null,
        subject: a.subject ?? null,
        dueAt: a.dueAt ?? null,
        maxGrade: a.maxGrade ?? null,
        attachments: a.attachments,
        teacherName: (a as any).teacher?.name ?? null,
        submitted: !!sub,
        submittedAt: sub?.submittedAt ?? null,
        grade: sub?.grade ?? null,
      };
    }));

    return { ok: true, items };
  }

  /// Mirror of student.service.myDiplomas(), pivoted to a child.
  async diplomasForChild(user: any, studentId: string) {
    const parentId = user?.sub ?? user?.id;
    await requireParentChild(this.prisma, parentId, studentId);

    const diplomas = await this.prisma.teacherDiploma.findMany({
      where: { studentId },
      orderBy: { issuedAt: 'desc' },
      include: { teacher: { select: { name: true } } },
    });

    return {
      ok: true,
      diplomas: diplomas.map((d) => ({
        id: d.id,
        studentName: d.studentName,
        title: d.title,
        subject: d.subject ?? '',
        grade: d.grade ?? '',
        distinction: d.distinction ?? '',
        notes: d.notes ?? '',
        issuedAt: d.issuedAt.toISOString(),
        issuedBy: (d as any).teacher?.name ?? null,
        attachments: Array.isArray((d as any).attachments) ? (d as any).attachments : [],
      })),
    };
  }

  /// Aggregated meetings across every classroom the child is a member of.
  /// Returns the same shape the student materials/meetings UI expects.
  async meetingsForChild(user: any, studentId: string) {
    const parentId = user?.sub ?? user?.id;
    await requireParentChild(this.prisma, parentId, studentId);

    const [profile, studentCohorts, memberships] = await Promise.all([
      this.prisma.studentProfile.findUnique({
        where: { userId: studentId },
        select: { grade: true },
      }),
      this.prisma.studentCohort.findMany({
        where: { studentId },
        select: { cohortId: true },
      }),
      this.prisma.classroomMember.findMany({
        where: { studentId },
        select: {
          classroomId: true,
          classroom: { select: { name: true, subject: true } },
        },
      }),
    ]);
    const grade = profile?.grade ?? null;
    const cohortIds = studentCohorts.map((c) => c.cohortId);
    const classroomIds = memberships.map((m) => m.classroomId);
    const classroomMap = new Map(memberships.map((m) => [m.classroomId, m.classroom]));

    const [classroomMeetings, teacherMeetings] = await Promise.all([
      classroomIds.length
        ? this.prisma.classroomMeeting.findMany({
            where: { classroomId: { in: classroomIds } },
            orderBy: [{ startsAt: 'asc' }],
          })
        : [],
      // Direct-target teacher meetings (no classroom mirror). Match the
      // same audience rules the student-side uses so the two surfaces
      // stay in sync.
      this.prisma.teacherMeeting.findMany({
        where: {
          OR: [
            // Gate the broadcast clause to records with NO narrower targeting, so a
            // grade-only item (stored as EVERYONE + targetGrades) no longer leaks
            // school-wide — it is matched by the targetGrades clause instead.
            { targetType: 'EVERYONE', targetCohortIds: { isEmpty: true }, targetStudentIds: { isEmpty: true }, targetGrades: { isEmpty: true } },
            { targetStudentIds: { has: studentId } },
            ...(cohortIds.length ? [{ targetCohortIds: { hasSome: cohortIds } }] : []),
            ...(grade != null ? [{ targetGrades: { has: grade } }] : []),
          ],
        },
        orderBy: [{ startsAt: 'asc' }],
      }),
    ]);

    const mirroredTeacherIds = new Set(
      (classroomMeetings as any[])
        .map((m) => m.teacherMeetingId)
        .filter((v): v is string => typeof v === 'string' && v.length > 0),
    );

    const items = [
      ...classroomMeetings.map((m) => ({
        ...m,
        classroomName: classroomMap.get(m.classroomId)?.name ?? null,
        classroomSubject: classroomMap.get(m.classroomId)?.subject ?? null,
      })),
      ...teacherMeetings
        .filter((tm) => !mirroredTeacherIds.has(tm.id))
        .map((tm) => ({
          ...tm,
          classroomName: null,
          classroomSubject: tm.subject ?? null,
        })),
    ].sort((a, b) => {
      const da = (a as any).startsAt ? new Date((a as any).startsAt).getTime() : 0;
      const db = (b as any).startsAt ? new Date((b as any).startsAt).getTime() : 0;
      return da - db;
    });

    return { ok: true, items };
  }

  /// Mirror of student.classrooms.allMaterials(), pivoted to a child.
  /// Same dedup logic across classroom / direct-target / slot-cascade.
  async materialsForChild(user: any, studentId: string) {
    const parentId = user?.sub ?? user?.id;
    await requireParentChild(this.prisma, parentId, studentId);

    const [profile, studentCohorts, memberships] = await Promise.all([
      this.prisma.studentProfile.findUnique({
        where: { userId: studentId },
        select: { grade: true },
      }),
      this.prisma.studentCohort.findMany({
        where: { studentId },
        select: { cohortId: true },
      }),
      this.prisma.classroomMember.findMany({
        where: { studentId },
        select: {
          classroomId: true,
          classroom: { select: { name: true, subject: true } },
        },
      }),
    ]);
    const grade = profile?.grade ?? null;
    const cohortIds = studentCohorts.map((c) => c.cohortId);
    const classroomIds = memberships.map((m) => m.classroomId);
    const classroomNameMap = new Map(memberships.map((m) => [m.classroomId, m.classroom]));

    const slotWhere: any = {
      OR: [
        { students: { some: { studentId } } },
        ...(cohortIds.length ? [{ cohorts: { some: { cohortId: { in: cohortIds } } } }] : []),
        ...(grade != null ? [{ audienceGrade: grade }] : []),
      ],
    };
    const slotIds = (slotWhere.OR.length
      ? await this.prisma.scheduleSlot.findMany({ where: slotWhere, select: { id: true } })
      : []
    ).map((s: any) => s.id);

    const [classroomMaterials, teacherMaterials, slotMaterialRows] = await Promise.all([
      classroomIds.length
        ? this.prisma.classroomMaterial.findMany({
            where: { classroomId: { in: classroomIds } },
            orderBy: { createdAt: 'desc' },
          })
        : [],
      this.prisma.teacherMaterial.findMany({
        where: {
          published: true,
          OR: [
            // Gate the broadcast clause to records with NO narrower targeting, so a
            // grade-only item (stored as EVERYONE + targetGrades) no longer leaks
            // school-wide — it is matched by the targetGrades clause instead.
            { targetType: 'EVERYONE', targetCohortIds: { isEmpty: true }, targetStudentIds: { isEmpty: true }, targetGrades: { isEmpty: true } },
            { targetStudentIds: { has: studentId } },
            ...(cohortIds.length ? [{ targetCohortIds: { hasSome: cohortIds } }] : []),
            ...(grade != null ? [{ targetGrades: { has: grade } }] : []),
          ],
        },
        orderBy: { createdAt: 'desc' },
        include: { teacher: { select: { name: true } } },
      }),
      slotIds.length
        ? this.prisma.scheduleSlotMaterial.findMany({
            where: { slotId: { in: slotIds } },
            include: {
              material: { include: { teacher: { select: { name: true } } } },
              slot: { select: { subject: true, period: true } },
            },
          })
        : [],
    ]);

    const seenTeacherMaterialIds = new Set<string>();
    const teacherFromDirect = teacherMaterials.map((m) => {
      seenTeacherMaterialIds.add(m.id);
      return {
        ...m,
        _source: 'teacher',
        _teacherName: (m as any).teacher?.name ?? null,
      };
    });
    const teacherFromSlots = slotMaterialRows
      .filter((r: any) => r.material && !seenTeacherMaterialIds.has(r.material.id))
      .map((r: any) => {
        seenTeacherMaterialIds.add(r.material.id);
        return {
          ...r.material,
          _source: 'period',
          _teacherName: r.material.teacher?.name ?? null,
          _subject: r.material.subject ?? r.slot?.subject ?? null,
        };
      });

    const items = [
      ...classroomMaterials.map((m) => ({
        ...m,
        _source: 'classroom',
        _classroomName: classroomNameMap.get(m.classroomId)?.name ?? null,
        _subject: classroomNameMap.get(m.classroomId)?.subject ?? null,
      })),
      ...teacherFromDirect,
      ...teacherFromSlots,
    ].sort((a: any, b: any) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());

    return { ok: true, items };
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

    return { ok: true, students };
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
      include: { session: true },
      orderBy: [{ session: { date: 'desc' } }, { session: { period: 'asc' } }],
    });

    return {
      ok: true,
      from: fromYmd,
      to: toYmd,
      items: records.map((r) => ({
        date: new Intl.DateTimeFormat('en-CA', { timeZone: 'UTC' }).format(
          (r as any).session?.date,
        ),
        period: (r as any).session?.period,
        status: r.status,
        note: r.note,
        course: null,
      })),
    };
  }
}
