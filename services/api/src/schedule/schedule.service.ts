import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

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

function ymdInJerusalem(date = new Date()): string {
  return new Intl.DateTimeFormat('en-CA', {
    timeZone: 'Asia/Jerusalem',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(date); // YYYY-MM-DD
}

function startOfWeekSundayInJerusalem(anyDate: Date): Date {
  const dow = dayOfWeekInJerusalem(anyDate);
  const d = new Date(anyDate.getTime());
  d.setDate(d.getDate() - dow);
  d.setHours(0, 0, 0, 0);
  return d;
}

function parseYmd(ymd: string): Date {
  // Use noon UTC to avoid timezone edge cases when converting to Jerusalem weekday
  const dt = new Date(`${ymd}T12:00:00.000Z`);
  if (Number.isNaN(dt.getTime()))
    throw new BadRequestException('Invalid date (expected YYYY-MM-DD)');
  return dt;
}


type CourseLite = { id: string; name: string; subject: string | null; teacherId: string | null };
type TemplateSlotLite = { period: number; course: CourseLite | null };

@Injectable()
export class ScheduleService {
  constructor(private readonly prisma: PrismaService) {}

  async getWeekForCohort(cohortId: string, weekOfYmd?: string) {
    if (!cohortId) throw new BadRequestException('cohortId is required');

    const refDate = weekOfYmd ? parseYmd(weekOfYmd) : new Date();
    const weekStart = startOfWeekSundayInJerusalem(refDate);
    const weekEnd = new Date(weekStart.getTime());
    weekEnd.setDate(weekEnd.getDate() + 7);

    const slots = await this.prisma.scheduleSlot.findMany({
      where: { cohortId },
      orderBy: [{ dayOfWeek: 'asc' }, { period: 'asc' }],
      include: { course: true },
    });

    const overrides = await this.prisma.scheduleOverride.findMany({
      where: {
        cohortId,
        date: { gte: weekStart, lt: weekEnd },
      },
      orderBy: [{ date: 'asc' }, { period: 'asc' }],
      include: { course: true },
    });

    return {
      weekStart: weekStart.toISOString(),
      weekEnd: weekEnd.toISOString(),
      template: slots.map((s) => ({
        id: s.id,
        cohortId: s.cohortId,
        dayOfWeek: s.dayOfWeek,
        period: s.period,
        course: s.course
          ? {
              id: s.course.id,
              name: s.course.name,
              subject: s.course.subject,
              teacherId: s.course.teacherId,
            }
          : null,
      })),
      overrides: overrides.map((o) => ({
        id: o.id,
        cohortId: o.cohortId,
        date: o.date.toISOString(),
        period: o.period,
        course: o.course
          ? {
              id: o.course.id,
              name: o.course.name,
              subject: o.course.subject,
              teacherId: o.course.teacherId,
            }
          : null,
      })),
    };
  }

  async getTodayForCohort(cohortId: string) {
    if (!cohortId) throw new BadRequestException('cohortId is required');

    const now = new Date();
    const dow = dayOfWeekInJerusalem(now);
    const ymd = ymdInJerusalem(now);

    const template = await this.prisma.scheduleSlot.findMany({
      where: { cohortId, dayOfWeek: dow },
      orderBy: { period: 'asc' },
      include: { course: true },
    });

    // match overrides stored at 00:00Z for a given YYYY-MM-DD
    const start = new Date(`${ymd}T00:00:00.000Z`);
    const end = new Date(`${ymd}T23:59:59.999Z`);

    const overrides = await this.prisma.scheduleOverride.findMany({
      where: { cohortId, date: { gte: start, lte: end } },
      include: { course: true },
    });

    const overrideByPeriod = new Map<number, any>();
    for (const o of overrides) overrideByPeriod.set(o.period, o);

    const periods = template.map((t) => t.period);
    for (const o of overrides)
      if (!periods.includes(o.period)) periods.push(o.period);
    periods.sort((a, b) => a - b);

    return {
      dayOfWeek: dow,
      date: ymd,
      slots: periods.map((p) => {
        const o = overrideByPeriod.get(p);
        if (o) {
          return {
            period: p,
            source: 'OVERRIDE',
            course: o.course
              ? {
                  id: o.course.id,
                  name: o.course.name,
                  subject: o.course.subject,
                  teacherId: o.course.teacherId,
                }
              : null,
          };
        }
        const t = template.find((x) => x.period === p);
        return {
          period: p,
          source: 'TEMPLATE',
          course: t?.course
            ? {
                id: (t as any).course.id,
                name: (t as any).course.name,
                subject: (t as any).course.subject,
                teacherId: (t as any).course.teacherId,
              }
            : null,
        };
      }),
    };
  }

  async getWeekGridForCohort(cohortId: string, weekOfYmd?: string) {
    if (!cohortId) throw new BadRequestException('cohortId is required');

    const refDate = weekOfYmd ? parseYmd(weekOfYmd) : new Date();
    const weekStart = startOfWeekSundayInJerusalem(refDate);
    const weekEnd = new Date(weekStart.getTime());
    weekEnd.setDate(weekEnd.getDate() + 7);

    const cohort = await this.prisma.cohort.findUnique({
      where: { id: cohortId },
      select: { id: true, name: true, grade: true },
    });
    if (!cohort) throw new BadRequestException('Invalid cohortId');

    const slots = await this.prisma.scheduleSlot.findMany({
      where: { cohortId },
      orderBy: [{ dayOfWeek: 'asc' }, { period: 'asc' }],
      include: { course: true },
    });

    const overrides = await this.prisma.scheduleOverride.findMany({
      where: { cohortId, date: { gte: weekStart, lt: weekEnd } },
      orderBy: [{ date: 'asc' }, { period: 'asc' }],
      include: { course: true },
    });

    const maxTemplatePeriod = slots.reduce((m, t) => Math.max(m, t.period), 0);
    const maxOverridePeriod = overrides.reduce(
      (m, o) => Math.max(m, o.period),
      0,
    );
    const maxPeriod = Math.max(maxTemplatePeriod, maxOverridePeriod, 8);

    const templateKey = (dow: number, period: number) => `${dow}::${period}`;
    const templateByKey = new Map(
      slots.map((t) => [templateKey(t.dayOfWeek, t.period), t]),
    );

    const overrideByKey = new Map<string, any>();
    for (const o of overrides) {
      const ymd = ymdInJerusalem(o.date);
      overrideByKey.set(`${ymd}::${o.period}`, o);
    }

    const days: any[] = [];
    for (let dow = 0; dow <= 6; dow++) {
      const d = new Date(weekStart.getTime());
      d.setDate(d.getDate() + dow);
      const ymd = ymdInJerusalem(d);

      const outSlots: any[] = [];
      for (let p = 1; p <= maxPeriod; p++) {
        const o = overrideByKey.get(`${ymd}::${p}`);
        if (o) {
          outSlots.push({
            period: p,
            source: 'OVERRIDE',
            course: o.courseId
              ? {
                  id: o.course?.id,
                  name: o.course?.name,
                  subject: o.course?.subject,
                  teacherId: o.course?.teacherId,
                }
              : null,
          });
          continue;
        }

        const t = templateByKey.get(templateKey(dow, p));
        if (t) {
          outSlots.push({
            period: p,
            source: 'TEMPLATE',
            course: (t as any).course
              ? {
                  id: (t as any).course.id,
                  name: (t as any).course.name,
                  subject: (t as any).course.subject,
                  teacherId: (t as any).course.teacherId,
                }
              : null,
          });
          continue;
        }

        outSlots.push({ period: p, source: 'EMPTY', course: null });
      }

      days.push({ dayOfWeek: dow, date: ymd, slots: outSlots });
    }

    return {
      cohort,
      maxPeriod,
      weekStart: weekStart.toISOString(),
      weekEnd: weekEnd.toISOString(),
      days,
    };
  }
}
