import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

type DayOfWeek = 'SUN' | 'MON' | 'TUE' | 'WED' | 'THU' | 'FRI' | 'SAT';

export type ScheduleItem = {
  id: string; // slot/override id
  title: string; // course name or "Free"
  location: string | null;
  dayOfWeek: DayOfWeek;
  startsAt: string; // HH:mm
  endsAt: string; // HH:mm

  // deprecated (back-compat)
  startTime?: string; // HH:mm
  endTime?: string; // HH:mm
  classroomId: string | null;

  // extra fields (safe for clients to ignore)
  date?: string; // YYYY-MM-DD (UTC normalized)
  period?: number;
  subject: string | null;
  cohortId?: string;
  cohortName?: string;
  isOverride?: boolean;
};

const DOW_STR: DayOfWeek[] = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

// MVP bell schedule (edit later)
const PERIOD_TIME: Record<number, { start: string; end: string }> = {
  1: { start: '08:00', end: '08:45' },
  2: { start: '08:50', end: '09:35' },
  3: { start: '09:45', end: '10:30' },
  4: { start: '10:35', end: '11:20' },
  5: { start: '11:30', end: '12:15' },
  6: { start: '12:20', end: '13:05' },
  7: { start: '13:15', end: '14:00' },
  8: { start: '14:05', end: '14:50' },
  9: { start: '15:00', end: '15:45' },
  10: { start: '15:50', end: '16:35' },
};

function ymdInJerusalem(date = new Date()): string {
  return new Intl.DateTimeFormat('en-CA', {
    timeZone: 'Asia/Jerusalem',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(date);
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

function parseWeekOf(weekOf?: string): Date {
  // weekOf as YYYY-MM-DD in Jerusalem. Default = today (Jerusalem).
  const ymd =
    weekOf && /^\d{4}-\d{2}-\d{2}$/.test(weekOf)
      ? weekOf
      : ymdInJerusalem(new Date());
  // store dates as midnight UTC (repo convention elsewhere)
  return new Date(ymd + 'T00:00:00.000Z');
}

function startOfWeekSundayInJerusalem(anyDate: Date): Date {
  // anyDate is UTC-midnight date; we interpret "week" in Jerusalem
  const dow = dayOfWeekInJerusalem(anyDate);
  const d = new Date(anyDate.getTime());
  d.setUTCDate(d.getUTCDate() - dow);
  d.setUTCHours(0, 0, 0, 0);
  return d;
}

function addDaysUTC(d: Date, days: number): Date {
  const x = new Date(d.getTime());
  x.setUTCDate(x.getUTCDate() + days);
  return x;
}

function ymdUTC(d: Date): string {
  return new Intl.DateTimeFormat('en-CA', {
    timeZone: 'UTC',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(d);
}

@Injectable()
export class ScheduleService {
  private async resolveTemplateSlotsForStudent(params: {
    schoolId: string;
    studentId: string;
    cohortId: string;
  }): Promise<{ templateRows: any[] }> {
    const { schoolId, studentId, cohortId } = params;

    const cohort = await this.prisma.cohort.findUnique({
      where: { id: cohortId },
      select: { grade: true, grades: true } as any,
    }) as any;
    if (!cohort) return { templateRows: [] };

    // Multi-grade cohorts pull templates for every grade they span. Falls back
    // to single `grade` when grades[] hasn't been backfilled yet.
    const gradesForTemplates: number[] = Array.isArray(cohort.grades) && cohort.grades.length
      ? cohort.grades
      : (cohort.grade != null ? [cohort.grade] : []);

    const [studentBinds, cohortBinds, gradeTemplates] = await Promise.all([
      this.prisma.studentScheduleTemplate.findMany({
        where: { studentId, template: { schoolId, kind: 'STUDENT' } },
        orderBy: [{ priority: 'asc' }, { id: 'asc' }],
        include: { template: true },
      }),
      this.prisma.cohortScheduleTemplate.findMany({
        where: { cohortId },
        orderBy: [{ priority: 'asc' }, { id: 'asc' }],
        include: { template: true },
      }),
      gradesForTemplates.length
        ? this.prisma.scheduleTemplate.findMany({
            where: { schoolId, kind: 'GRADE', grade: { in: gradesForTemplates } },
            orderBy: [{ id: 'asc' }],
          })
        : Promise.resolve([] as any[]),
      Promise.resolve([]),
    ]);

    const orderedTemplateIds: string[] = [
      ...studentBinds.map((b) => b.templateId),
      ...cohortBinds.map((b) => b.templateId),
      ...gradeTemplates.map((t) => t.id),
    ].filter(Boolean);

    const tmplSlots = orderedTemplateIds.length
      ? await this.prisma.scheduleTemplateSlot.findMany({
          where: { templateId: { in: orderedTemplateIds } },
        })
      : [];

    // Fetch slots the student can see: directly assigned or via their cohorts
    const studentCohortLinks = await this.prisma.studentCohort.findMany({
      where: { studentId },
      select: { cohortId: true },
    });
    const uniqueCohortIds = Array.from(new Set([cohortId, ...studentCohortLinks.map((sc) => sc.cohortId)]));

    const [byStudent, byCohort] = await Promise.all([
      this.prisma.scheduleSlotStudent.findMany({
        where: { studentId },
        select: { slotId: true },
      }),
      this.prisma.scheduleSlotCohort.findMany({
        where: { cohortId: { in: uniqueCohortIds } },
        select: { slotId: true },
      }),
    ]);

    const slotIds = Array.from(new Set([
      ...byStudent.map((r) => r.slotId),
      ...byCohort.map((r) => r.slotId),
    ]));

    const legacy = slotIds.length
      ? await this.prisma.scheduleSlot.findMany({ where: { id: { in: slotIds } } })
      : [];

    const byKey = new Map<string, any>();
    const keyOf = (d: number, p: number) => `${d}:${p}`;

    for (const tid of orderedTemplateIds) {
      for (const r of tmplSlots) {
        if (String(r.templateId) !== String(tid)) continue;
        const k = keyOf(Number(r.dayOfWeek), Number(r.period));
        if (!byKey.has(k)) byKey.set(k, r);
      }
    }

    for (const r of legacy) {
      const k = keyOf(Number(r.dayOfWeek), Number(r.period));
      if (!byKey.has(k)) byKey.set(k, r);
    }

    const templateRows = Array.from(byKey.values()).sort((a, b) => {
      const da = Number(a.dayOfWeek) - Number(b.dayOfWeek);
      if (da) return da;
      return Number(a.period) - Number(b.period);
    });

    return { templateRows };
  }

  constructor(private readonly prisma: PrismaService) {}

  private timesForPeriod(period: number, slotOverride?: { startTime?: string | null; endTime?: string | null }): { start: string; end: string } {
    if (slotOverride?.startTime && slotOverride?.endTime) {
      return { start: slotOverride.startTime, end: slotOverride.endTime };
    }
    return PERIOD_TIME[period] ?? { start: '00:00', end: '00:00' };
  }

  private rowToItem(params: {
    slotId: string;
    dayOfWeek: number;
    period: number;
    dateYmd?: string;
    subject?: string | null;
    location?: string | null;
    isOverride?: boolean;
    startTimeOverride?: string | null;
    endTimeOverride?: string | null;
    classroomId?: string | null;
    classroomName?: string | null;
  }): ScheduleItem {
    const t = this.timesForPeriod(params.period, { startTime: params.startTimeOverride, endTime: params.endTimeOverride });
    const title = params.classroomName ?? (params.subject ? `${params.subject} — P${params.period}` : `Period ${params.period}`);
    return {
      id: params.slotId,
      title,
      location: params.location ?? null,
      dayOfWeek: DOW_STR[Math.max(0, Math.min(6, Number(params.dayOfWeek)))],
      startsAt: t.start,
      startTime: t.start,
      endsAt: t.end,
      endTime: t.end,
      classroomId: params.classroomId ?? null,
      date: params.dateYmd,
      period: params.period,
      subject: params.subject ?? null,
      isOverride: !!params.isOverride,
    };
  }

  private async templateForCohort(cohortId: string) {
    const slotIds = (await this.prisma.scheduleSlotCohort.findMany({
      where: { cohortId },
      select: { slotId: true },
    })).map((r) => r.slotId);
    if (!slotIds.length) return [];
    return this.prisma.scheduleSlot.findMany({
      where: { id: { in: slotIds } },
      orderBy: [{ dayOfWeek: 'asc' }, { period: 'asc' }],
    });
  }

  private async overridesForCohortRange(
    cohortId: string,
    from: Date,
    toExclusive: Date,
  ) {
    return this.prisma.scheduleOverride.findMany({
      where: { cohortId, date: { gte: from, lt: toExclusive } },
      orderBy: [{ date: 'asc' }, { period: 'asc' }],
    });
  }

  private applyOverridesForDate(params: {
    date: Date; // UTC midnight
    templateRows: any[];
    overrideRows: any[]; // already filtered for that date
  }): ScheduleItem[] {
    const dateYmd = ymdUTC(params.date);
    const dow = dayOfWeekInJerusalem(params.date); // 0..6
    const tmpl = params.templateRows.filter((r) => Number(r.dayOfWeek) === dow);

    const byPeriod = new Map<number, { id: string; isOverride: boolean; location: string | null; subject: string | null; startTime?: string | null; endTime?: string | null; classroomId?: string | null }>();

    for (const r of tmpl) {
      byPeriod.set(Number(r.period), {
        id: String(r.id),
        isOverride: false,
        location: (r as any).location ?? null,
        subject: (r as any).subject ?? null,
        startTime: (r as any).startTime ?? null,
        endTime: (r as any).endTime ?? null,
        classroomId: (r as any).classroomId ?? null,
      });
    }

    for (const o of params.overrideRows) {
      byPeriod.set(Number(o.period), {
        id: String(o.id),
        isOverride: true,
        location: (o as any).location ?? null,
        subject: (o as any).subject ?? null,
        startTime: (o as any).startTime ?? null,
        endTime: (o as any).endTime ?? null,
        classroomId: null,
      });
    }

    const periods = Array.from(byPeriod.keys()).sort((a, b) => a - b);

    return periods.map((p) => {
      const entry = byPeriod.get(p)!;
      return this.rowToItem({
        dayOfWeek: dow,
        period: p,
        slotId: entry.id,
        dateYmd,
        location: entry.location ?? null,
        subject: entry.subject,
        isOverride: entry.isOverride,
        startTimeOverride: entry.startTime,
        endTimeOverride: entry.endTime,
        classroomId: entry.classroomId,
      });
    });
  }

  // Existing API used by ScheduleController route: GET /api/student/schedule
  async listForStudent(studentId: string): Promise<ScheduleItem[]> {
    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: String(studentId) },
      select: { cohortId: true },
    });
    if (!sp?.cohortId) return [];
    return this.getWeekForCohort(String(sp.cohortId));
  }

  // REQUIRED by StudentService/ParentService
  async getTodayForCohort(cohortId: string): Promise<ScheduleItem[]> {
    try {
      const cid = String(cohortId || '');
      if (!cid) throw new BadRequestException('cohortId is required');

      const today = new Date(ymdInJerusalem(new Date()) + 'T00:00:00.000Z');
      const tomorrow = addDaysUTC(today, 1);

      const [templateRows, overrideRows] = await Promise.all([
        this.templateForCohort(cid),
        this.overridesForCohortRange(cid, today, tomorrow),
      ]);

      return this.applyOverridesForDate({
        date: today,
        templateRows,
        overrideRows,
      });
    } catch (e: any) {
      console.error(
        'schedule getTodayForCohort error:',
        e?.code,
        e?.message,
        e?.meta,
      );
      console.error(e?.stack);
      throw e;
    }
  }

  // REQUIRED by StudentService/ParentService
  async getWeekForCohort(
    cohortId: string,
    weekOf?: string,
  ): Promise<ScheduleItem[]> {
    const cid = String(cohortId || '');
    if (!cid) throw new BadRequestException('cohortId is required');

    const weekOfDate = parseWeekOf(weekOf);
    const start = startOfWeekSundayInJerusalem(weekOfDate);
    const end = addDaysUTC(start, 7);

    const [templateRows, overrideRows] = await Promise.all([
      this.templateForCohort(cid),
      this.overridesForCohortRange(cid, start, end),
    ]);

    const byDate = new Map<string, any[]>();
    for (const o of overrideRows) {
      const k = ymdUTC(o.date);
      const arr = byDate.get(k) ?? [];
      arr.push(o);
      byDate.set(k, arr);
    }

    const out: ScheduleItem[] = [];
    for (let i = 0; i < 7; i++) {
      const d = addDaysUTC(start, i);
      const k = ymdUTC(d);
      const o = byDate.get(k) ?? [];
      out.push(
        ...this.applyOverridesForDate({
          date: d,
          templateRows,
          overrideRows: o,
        }),
      );
    }

    // stable ordering: date, period
    out.sort((a, b) => {
      const da = String(a.date ?? '');
      const db = String(b.date ?? '');
      if (da < db) return -1;
      if (da > db) return 1;
      return Number(a.period ?? 0) - Number(b.period ?? 0);
    });

    return out;
  }

  async getTodayForStudent(params: {
    schoolId: string;
    studentId: string;
    cohortId: string;
  }): Promise<ScheduleItem[]> {
    const { templateRows } = await this.resolveTemplateSlotsForStudent(params);

    const cid = String(params.cohortId || '');
    if (!cid) throw new BadRequestException('cohortId is required');

    const today = new Date(ymdInJerusalem(new Date()) + 'T00:00:00.000Z');
    const tomorrow = addDaysUTC(today, 1);

    const overrideRows = await this.overridesForCohortRange(
      cid,
      today,
      tomorrow,
    );

    return this.applyOverridesForDate({
      date: today,
      templateRows,
      overrideRows,
    });
  }

  async getWeekForStudent(params: {
    schoolId: string;
    studentId: string;
    cohortId: string;
    weekOf?: string;
  }): Promise<ScheduleItem[]> {
    const { templateRows } = await this.resolveTemplateSlotsForStudent(params);

    const cid = String(params.cohortId || '');

    const weekOfDate = parseWeekOf(params.weekOf);
    const start = startOfWeekSundayInJerusalem(weekOfDate);

    const out: ScheduleItem[] = [];
    for (let i = 0; i < 7; i++) {
      const d = addDaysUTC(start, i);
      const dateYmd = ymdUTC(d);

      const overrideRows = cid
        ? await this.overridesForCohortRange(cid, d, addDaysUTC(d, 1))
        : [];

      const items = this.applyOverridesForDate({
        date: d,
        templateRows,
        overrideRows,
      });

      for (const it of items) (it as any).date = (it as any).date ?? dateYmd;

      out.push(...items);
    }

    // stable ordering: date, period
    out.sort((a, b) => {
      const da = String(a.date ?? '');
      const db = String(b.date ?? '');
      if (da < db) return -1;
      if (da > db) return 1;
      return Number(a.period ?? 0) - Number(b.period ?? 0);
    });

    return out;
  }
}
