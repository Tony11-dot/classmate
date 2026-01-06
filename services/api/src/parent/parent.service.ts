import { BadRequestException, ForbiddenException, Injectable } from '@nestjs/common';
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
  const wk = new Intl.DateTimeFormat('en-US', { timeZone: 'Asia/Jerusalem', weekday: 'short' }).format(date);
  const map: Record<string, number> = { Sun: 0, Mon: 1, Tue: 2, Wed: 3, Thu: 4, Fri: 5, Sat: 6 };
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
    if (!user?.roles?.includes('PARENT')) throw new ForbiddenException('Parent only');
  }

  private async assertLinked(parentId: string, childId: string) {
    const link = await this.prisma.parentChild.findUnique({
      where: { parentId_childId: { parentId, childId } },
      select: { status: true },
    });
    if (!link || link.status !== 'APPROVED') throw new ForbiddenException('Not linked to this child');
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

  async grades(user: any) {
    this.ensureParent(user);
    const parentId = user.sub ?? user.id;

    const links = await this.prisma.parentChild.findMany({
      where: { parentId, status: 'APPROVED' },
      select: { childId: true },
    });

    const childIds = links.map((l) => l.childId);
    if (childIds.length === 0) return { ok: true, grades: [] };

    const rows = await this.prisma.gradeRecord.findMany({
      where: { studentId: { in: childIds } },
      orderBy: { id: 'desc' },
      include: { assessment: { include: { course: true } } },
    });

    return {
      ok: true,
      grades: rows.map((r) => ({
        studentId: r.studentId,
        grade: r.grade,
        comment: r.comment,
        assessment: { id: r.assessment.id, title: r.assessment.title, date: r.assessment.date.toISOString() },
        course: { id: r.assessment.course.id, name: r.assessment.course.name, subject: r.assessment.course.subject },
      })),
    };
  }

  async scheduleToday(user: any, studentId: string) {
    this.ensureParent(user);
    const parentId = user.sub ?? user.id;

    if (!studentId) throw new BadRequestException('studentId is required');
    await this.assertLinked(parentId, studentId);

    const sp = await this.prisma.studentProfile.findUnique({ where: { userId: studentId } });
    if (!sp) throw new BadRequestException('Student not onboarded');

    return this.schedule.getTodayForCohort(sp.cohortId);
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
        course: s.course ? { id: s.course.id, name: s.course.name, subject: s.course.subject } : null,
      })),
    };
  }

  async attendanceWeek(user: any, studentId: string) {
    this.ensureParent(user);
    const parentId = user.sub ?? user.id;

    if (!studentId) throw new BadRequestException('studentId is required');
    await this.assertLinked(parentId, studentId);

    const start = startOfWeekSundayInJerusalem(new Date());
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
        course: s.course ? { id: s.course.id, name: s.course.name, subject: s.course.subject } : null,
      })),
    };
  }

  async overview(user: any, studentId: string) {
    this.ensureParent(user);

    const parentId = user.sub ?? user.id;
    if (!studentId) throw new BadRequestException('studentId is required');

    // Must be linked (and approved)
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
      sp ? this.schedule.getTodayForCohort(sp.cohortId) : { dayOfWeek: null, date: null, slots: [] },
      this.attendanceToday(user, studentId),
      this.grades(user),
    ]);

    const grades = (allGrades?.grades || []).filter((g: any) => g.studentId === studentId);

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



}
