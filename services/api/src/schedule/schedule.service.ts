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
  /// Resolved teacher display name (joined from User.name). Null when the
  /// slot has no teacher assigned. Clients render it as a subtitle.
  teacherName?: string | null;
  teacherId?: string | null;
  /// Color override for the period (#RRGGBB). Lets the client pick a tint
  /// without re-deriving from subject names.
  color?: string | null;
  /// Optional free-text caption shown above "subject · teacher" on the
  /// schedule tile.
  caption?: string | null;
  /// Materials attached to this slot, ready to render as tappable pills
  /// on the student detail sheet (id, title, url, mime).
  attachments?: Array<{
    id: string;
    title: string;
    url: string;
    mime: string;
    description?: string | null;
    subject?: string | null;
  }>;
};

const DOW_STR: DayOfWeek[] = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

// Default bell schedule. Used when the school hasn't configured its own
// times under Admin → School Settings → Periods. Once a school sets
// SchoolPeriodDefault rows, those take precedence for everyone in that
// school. Per-slot startTime/endTime overrides still win above either.
const PERIOD_TIME: Record<number, { start: string; end: string }> = {
  1: { start: '08:00', end: '08:45' },
  2: { start: '08:45', end: '09:30' },
  3: { start: '09:30', end: '10:15' },
  4: { start: '10:45', end: '11:30' }, // 30-min break between P3 and P4
  5: { start: '11:30', end: '12:15' },
  6: { start: '12:15', end: '13:00' },
  7: { start: '13:00', end: '13:45' },
  8: { start: '13:45', end: '14:30' },
  9: { start: '14:30', end: '15:15' },
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

    // Pull cohort row + student's own grade so we can match slots via:
    //   1. Direct enrollment (ScheduleSlotStudent)
    //   2. Cohort membership (ScheduleSlotCohort) — includes multi-cohort
    //      links via StudentCohort
    //   3. Grade audience (ScheduleSlot.audienceGrade == student.grade) —
    //      catches "By Grade N" slots even when the student isn't in any of
    //      the grade's cohorts
    const [cohort, studentProfile] = await Promise.all([
      cohortId
        ? this.prisma.cohort.findUnique({
            where: { id: cohortId },
            select: { grade: true, grades: true } as any,
          })
        : Promise.resolve(null),
      this.prisma.studentProfile.findUnique({
        where: { userId: studentId },
        select: { grade: true } as any,
      }),
    ]) as [any, any];

    // Multi-grade cohorts pull templates for every grade they span. Falls back
    // to single `grade` when grades[] hasn't been backfilled yet, then to the
    // student's own profile grade if they have no cohort.
    const studentGrade: number | null =
      typeof studentProfile?.grade === 'number' ? studentProfile.grade : null;
    let gradesForTemplates: number[] = [];
    if (cohort) {
      gradesForTemplates = Array.isArray(cohort.grades) && cohort.grades.length
        ? cohort.grades
        : (cohort.grade != null ? [cohort.grade] : []);
    }
    if (!gradesForTemplates.length && studentGrade != null) {
      gradesForTemplates = [studentGrade];
    }

    const [studentBinds, cohortBinds, gradeTemplates] = await Promise.all([
      this.prisma.studentScheduleTemplate.findMany({
        where: { studentId, template: { schoolId, kind: 'STUDENT' } },
        orderBy: [{ priority: 'asc' }, { id: 'asc' }],
        include: { template: true },
      }),
      cohortId
        ? this.prisma.cohortScheduleTemplate.findMany({
            where: { cohortId },
            orderBy: [{ priority: 'asc' }, { id: 'asc' }],
            include: { template: true },
          })
        : Promise.resolve([] as any[]),
      gradesForTemplates.length
        ? this.prisma.scheduleTemplate.findMany({
            where: { schoolId, kind: 'GRADE', grade: { in: gradesForTemplates } },
            orderBy: [{ id: 'asc' }],
          })
        : Promise.resolve([] as any[]),
    ]);

    const orderedTemplateIds: string[] = [
      ...studentBinds.map((b) => b.templateId),
      ...cohortBinds.map((b: any) => b.templateId),
      ...gradeTemplates.map((t: any) => t.id),
    ].filter(Boolean);

    const tmplSlots = orderedTemplateIds.length
      ? await this.prisma.scheduleTemplateSlot.findMany({
          where: { templateId: { in: orderedTemplateIds } },
          include: {
            teacher: { select: { id: true, name: true, displayName: true, nameEn: true } },
          } as any,
        })
      : [];

    // Fetch slots the student can see: directly assigned, via any cohort
    // they belong to, OR via the slot's explicit audienceGrade matching the
    // student's grade.
    const studentCohortLinks = await this.prisma.studentCohort.findMany({
      where: { studentId },
      select: { cohortId: true },
    });
    const uniqueCohortIds = Array.from(new Set(
      [cohortId, ...studentCohortLinks.map((sc) => sc.cohortId)].filter(Boolean) as string[],
    ));

    const [byStudent, byCohort, byGrade] = await Promise.all([
      this.prisma.scheduleSlotStudent.findMany({
        where: { studentId },
        select: { slotId: true },
      }),
      uniqueCohortIds.length
        ? this.prisma.scheduleSlotCohort.findMany({
            where: { cohortId: { in: uniqueCohortIds } },
            select: { slotId: true },
          })
        : Promise.resolve([] as any[]),
      studentGrade != null
        ? this.prisma.scheduleSlot.findMany({
            where: { schoolId, audienceGrade: studentGrade } as any,
            select: { id: true },
          })
        : Promise.resolve([] as any[]),
    ]);

    const slotIds = Array.from(new Set([
      ...byStudent.map((r) => r.slotId),
      ...byCohort.map((r: any) => r.slotId),
      ...byGrade.map((r: any) => r.id),
    ]));

    // Explicit select with a graceful fallback — if a column is in the
    // Prisma schema but the DB hasn't pushed it yet (mid-deploy state),
    // the rich query throws and we retry without the newest column.
    // Without this, a brand-new column blanks the entire schedule until
    // db push catches up.
    let legacy: any[] = [];
    if (slotIds.length) {
      try {
        legacy = await this.prisma.scheduleSlot.findMany({
          where: { id: { in: slotIds } },
          select: {
            id: true,
            schoolId: true,
            dayOfWeek: true,
            period: true,
            teacherId: true,
            classroomId: true,
            subject: true,
            startTime: true,
            endTime: true,
            frequencyWeeks: true,
            startDate: true,
            color: true,
            audienceGrade: true,
            skipDates: true,
            studentDateSkips: true,
            caption: true,
            teacher: { select: { id: true, name: true, displayName: true, nameEn: true } },
            classroom: {
              select: {
                id: true,
                name: true,
                teacher: { select: { id: true, name: true, displayName: true, nameEn: true } },
              },
            },
            materials: {
              select: {
                material: {
                  select: {
                    id: true, title: true, description: true,
                    url: true, attachments: true, subject: true,
                  },
                },
              },
            },
          } as any,
        });
      } catch (firstErr) {
        // Strip the most recently-added column (`studentDateSkips`) and
        // retry. Per-date suppression simply becomes a no-op against
        // these rows until the DB catches up — strictly better than
        // returning an empty schedule.
        try {
          legacy = await this.prisma.scheduleSlot.findMany({
            where: { id: { in: slotIds } },
            select: {
              id: true,
              schoolId: true,
              dayOfWeek: true,
              period: true,
              teacherId: true,
              classroomId: true,
              subject: true,
              startTime: true,
              endTime: true,
              frequencyWeeks: true,
              startDate: true,
              color: true,
              audienceGrade: true,
              skipDates: true,
              teacher: { select: { id: true, name: true, displayName: true, nameEn: true } },
              classroom: {
                select: {
                  id: true,
                  name: true,
                  teacher: { select: { id: true, name: true, displayName: true, nameEn: true } },
                },
              },
            } as any,
          });
        } catch {
          // eslint-disable-next-line no-console
          console.error('[schedule.resolve] slot fetch failed', firstErr);
          legacy = [];
        }
      }
    }
    // Note: the legacy `skipForStudentIds` field is intentionally NOT
    // applied here — it was a forever-scoped per-student skip from an
    // earlier override design that stayed sticky even after the
    // overriding slot was gone.  Per-date suppression now flows through
    // `studentDateSkips`, applied per-day in getWeekForStudent.

    // Multiple slots at the same (day, period) are legitimate now:
    //   - student in two cohorts both teaching at Mon P1
    //   - an individual one-off layered on top of a cohort slot
    //   - the conflict dialog's "Show both" outcome
    // The previous one-slot-per-key Map dropped everything past the first.
    // Keep template-vs-legacy precedence per (day, period) but allow an
    // array of legacy rows where templates don't already own the slot.
    const byKey = new Map<string, any[]>();
    const keyOf = (d: number, p: number) => `${d}:${p}`;
    const templateOwned = new Set<string>();

    for (const tid of orderedTemplateIds) {
      for (const r of tmplSlots) {
        if (String(r.templateId) !== String(tid)) continue;
        const k = keyOf(Number(r.dayOfWeek), Number(r.period));
        if (templateOwned.has(k)) continue;
        templateOwned.add(k);
        byKey.set(k, [r]);
      }
    }

    for (const r of legacy) {
      const k = keyOf(Number(r.dayOfWeek), Number(r.period));
      // Template slots from a binding hide individual/legacy slots for the
      // same time — that's the long-standing precedence rule, preserved here.
      if (templateOwned.has(k)) continue;
      const arr = byKey.get(k) ?? [];
      arr.push(r);
      byKey.set(k, arr);
    }

    const templateRows: any[] = [];
    const sortedKeys = Array.from(byKey.keys()).sort((a, b) => {
      const [da, pa] = a.split(':').map(Number);
      const [db, pb] = b.split(':').map(Number);
      if (da !== db) return da - db;
      return pa - pb;
    });
    for (const k of sortedKeys) {
      for (const r of byKey.get(k)!) templateRows.push(r);
    }

    return { templateRows };
  }

  constructor(private readonly prisma: PrismaService) {}

  /// Resolves the start/end clock for a period.  Priority: per-slot
  /// override > school's configured bell schedule (SchoolPeriodDefault) >
  /// the hardcoded MVP defaults.  When the school has set its own bell
  /// schedule under Admin → School Settings → Periods, that's what the
  /// student/teacher schedule tiles should show.
  private timesForPeriod(
    period: number,
    slotOverride?: { startTime?: string | null; endTime?: string | null },
    schoolDefaults?: Map<number, { start: string; end: string }>,
  ): { start: string; end: string } {
    if (slotOverride?.startTime && slotOverride?.endTime) {
      return { start: slotOverride.startTime, end: slotOverride.endTime };
    }
    const fromSchool = schoolDefaults?.get(period);
    if (fromSchool) return fromSchool;
    return PERIOD_TIME[period] ?? { start: '00:00', end: '00:00' };
  }

  /// Loads the school's bell schedule once per request as a Map<period, time>.
  /// Empty map when the school hasn't configured anything yet — timesForPeriod
  /// then falls through to the hardcoded defaults.
  private async _schoolPeriodTimes(
    schoolId: string,
  ): Promise<Map<number, { start: string; end: string }>> {
    const out = new Map<number, { start: string; end: string }>();
    if (!schoolId) return out;
    try {
      const rows = await this.prisma.schoolPeriodDefault.findMany({
        where: { schoolId },
        select: { period: true, startTime: true, endTime: true },
      });
      for (const r of rows) {
        if (r.startTime && r.endTime) {
          out.set(Number(r.period), { start: r.startTime, end: r.endTime });
        }
      }
    } catch {
      // schoolPeriodDefault is optional infra — never block schedule fetch on it.
    }
    return out;
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
    teacherId?: string | null;
    teacherName?: string | null;
    color?: string | null;
    caption?: string | null;
    attachments?: ScheduleItem['attachments'];
    schoolDefaults?: Map<number, { start: string; end: string }>;
  }): ScheduleItem {
    const t = this.timesForPeriod(
      params.period,
      { startTime: params.startTimeOverride, endTime: params.endTimeOverride },
      params.schoolDefaults,
    );
    // Title is just the subject (or the classroom's own name when set,
    // or a generic Period N when neither is available).  Previously
    // appended " — P{period}" which doubled up the period info shown
    // in the time block and made the subject read twice on the tile.
    const title =
      params.classroomName ??
      (params.subject ? params.subject : `Period ${params.period}`);
    return {
      id: params.slotId,
      title,
      location: params.location ?? params.classroomName ?? null,
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
      teacherId: params.teacherId ?? null,
      teacherName: params.teacherName ?? null,
      color: params.color ?? null,
      caption: params.caption ?? null,
      attachments: params.attachments ?? [],
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
      include: {
        teacher: { select: { id: true, name: true } },
        classroom: { select: { id: true, name: true } },
      } as any,
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
      include: {
        teacher: { select: { id: true, name: true, displayName: true, nameEn: true } },
      } as any,
    });
  }

  /// Picks the best display name for a User-shaped relation. Prefers the
  /// curated displayName, falls back through nameEn → name, returns null
  /// when every field is empty. Used for the schedule tile's subtitle so
  /// students see a real teacher name even when the User row was created
  /// with just a username as `name`.
  private _pickDisplayName(u: any): string | null {
    if (!u || typeof u !== 'object') return null;
    const fields = ['displayName', 'nameEn', 'name'];
    for (const f of fields) {
      const v = typeof u[f] === 'string' ? u[f].trim() : '';
      if (v.length > 0) return v;
    }
    return null;
  }

  /// Filters out template rows whose `studentDateSkips` matches the
  /// `<studentId>:<dateYmd>` pair currently being rendered.  Drives the
  /// date-scoped Override semantic: a Once override stamps the existing
  /// slot for the override date only, so the existing slot keeps
  /// rendering on every OTHER date.
  /// Flattens a slot row's `materials` relation into the attachment
  /// shape ScheduleItem expects (id, title, url, mime). Inlines the
  /// first attachment's URL when the material itself has none, so the
  /// student tile always gets a tappable pill.
  private _materialsFromSlotRow(row: any): ScheduleItem['attachments'] {
    const rel = Array.isArray(row?.materials) ? row.materials : [];
    return rel
      .map((r: any) => r?.material)
      .filter((m: any) => m && typeof m === 'object')
      .map((m: any) => {
        const list = Array.isArray(m.attachments) ? m.attachments : [];
        const first = list.find((a: any) => a && typeof a === 'object') ?? null;
        const url = (typeof m.url === 'string' && m.url.length > 0)
          ? m.url
          : (first && typeof first.url === 'string' ? first.url : '');
        const mime = first && typeof first.mime === 'string' ? first.mime : '';
        return {
          id: String(m.id),
          title: String(m.title ?? 'Material'),
          url,
          mime,
          description: m.description ?? null,
          subject: m.subject ?? null,
        };
      });
  }

  private _applyStudentDateSkips(
    templateRows: any[],
    studentId: string,
    dateYmd: string,
  ): any[] {
    if (!studentId) return templateRows;
    const needle = `${studentId}:${dateYmd}`;
    return templateRows.filter((r: any) => {
      const skips: string[] = Array.isArray(r?.studentDateSkips) ? r.studentDateSkips : [];
      return !skips.includes(needle);
    });
  }

  private applyOverridesForDate(params: {
    date: Date; // UTC midnight
    templateRows: any[];
    overrideRows: any[]; // already filtered for that date
    schoolDefaults?: Map<number, { start: string; end: string }>;
  }): ScheduleItem[] {
    const dateYmd = ymdUTC(params.date);
    const dow = dayOfWeekInJerusalem(params.date); // 0..6
    const tmpl = params.templateRows.filter((r) => {
      if (Number(r.dayOfWeek) !== dow) return false;
      const freq = Number((r as any).frequencyWeeks ?? 1);
      const sd: string | null = typeof (r as any).startDate === 'string' &&
              /^\d{4}-\d{2}-\d{2}$/.test((r as any).startDate)
          ? (r as any).startDate
          : null;
      // Once — exactly the anchor date.
      if (freq === 0) {
        return sd !== null && sd === dateYmd;
      }
      // Recurring with anchor: only render when the date is an integer
      // number of `freq` weeks from the anchor (and not before it).
      // freq=1 collapses to "every matching weekday from the anchor".
      // freq=2 = biweekly, freq=4 = monthly etc.
      if (freq >= 2 && sd !== null) {
        const startMs = Date.UTC(
          Number(sd.slice(0, 4)),
          Number(sd.slice(5, 7)) - 1,
          Number(sd.slice(8, 10)),
        );
        const currentMs = Date.UTC(
          Number(dateYmd.slice(0, 4)),
          Number(dateYmd.slice(5, 7)) - 1,
          Number(dateYmd.slice(8, 10)),
        );
        if (currentMs < startMs) return false;
        const weeksSince = (currentMs - startMs) / (7 * 86400000);
        if (!Number.isInteger(weeksSince)) return false; // shouldn't happen, same weekday
        if (weeksSince % freq !== 0) return false;
      } else if (freq === 1 && sd !== null) {
        // Optional anchor for weekly slots — render only on or after sd.
        if (dateYmd < sd) return false;
      }
      const skipDates: string[] = Array.isArray((r as any).skipDates)
        ? (r as any).skipDates
        : [];
      if (skipDates.includes(dateYmd)) return false;
      return true;
    });

    type Entry = {
      id: string;
      isOverride: boolean;
      location: string | null;
      subject: string | null;
      startTime?: string | null;
      endTime?: string | null;
      classroomId?: string | null;
      classroomName?: string | null;
      teacherId?: string | null;
      teacherName?: string | null;
      color?: string | null;
      caption?: string | null;
      attachments?: ScheduleItem['attachments'];
    };
    // Per-period: an ARRAY of entries instead of one, so two cohort
    // classes the student is in at Mon P1 both surface (same with
    // an individual override layered alongside a cohort slot).  The
    // prior one-entry-per-period Map silently dropped the second.
    // A ScheduleOverride still REPLACES every template entry at its
    // period for the date — that's the intended override semantic.
    const byPeriod = new Map<number, Entry[]>();

    for (const r of tmpl) {
      const p = Number(r.period);
      const arr = byPeriod.get(p) ?? [];
      // Teacher name resolution: prefer the slot's own teacher relation,
      // fall back to the classroom's teacher when the slot left it null.
      // Within each user, prefer displayName → nameEn → name so a row
      // whose `name` is just a username still surfaces a real name.
      const slotTeacherName = this._pickDisplayName((r as any).teacher);
      const classroomTeacherName = this._pickDisplayName(
        (r as any).classroom?.teacher,
      );
      arr.push({
        id: String(r.id),
        isOverride: false,
        location: (r as any).location ?? null,
        subject: (r as any).subject ?? null,
        startTime: (r as any).startTime ?? null,
        endTime: (r as any).endTime ?? null,
        classroomId: (r as any).classroomId ?? null,
        // Joined relations come from the slot queries that include teacher
        // and classroom — see resolveTemplateSlotsForStudent / templateForCohort.
        classroomName: (r as any).classroom?.name ?? null,
        teacherId: (r as any).teacherId
          ?? (r as any).teacher?.id
          ?? (r as any).classroom?.teacher?.id
          ?? null,
        teacherName: slotTeacherName ?? classroomTeacherName ?? null,
        color: (r as any).color ?? null,
        caption: (r as any).caption ?? null,
        attachments: this._materialsFromSlotRow(r),
      });
      byPeriod.set(p, arr);
    }

    for (const o of params.overrideRows) {
      byPeriod.set(Number(o.period), [
        {
          id: String(o.id),
          isOverride: true,
          location: (o as any).location ?? null,
          subject: (o as any).subject ?? null,
          startTime: (o as any).startTime ?? null,
          endTime: (o as any).endTime ?? null,
          classroomId: null,
          // Override may swap the teacher for the day.
          teacherId: (o as any).teacherId ?? (o as any).teacher?.id ?? null,
          teacherName: this._pickDisplayName((o as any).teacher),
          color: null,
        },
      ]);
    }

    const periods = Array.from(byPeriod.keys()).sort((a, b) => a - b);

    const items: ScheduleItem[] = [];
    for (const p of periods) {
      for (const entry of byPeriod.get(p)!) {
        items.push(this.rowToItem({
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
          classroomName: entry.classroomName,
          teacherId: entry.teacherId,
          teacherName: entry.teacherName,
          color: entry.color,
          caption: entry.caption,
          attachments: entry.attachments,
          schoolDefaults: params.schoolDefaults,
        }));
      }
    }
    return items;
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

    const schoolDefaults = await this._schoolPeriodTimes(params.schoolId);
    return this.applyOverridesForDate({
      date: today,
      templateRows: this._applyStudentDateSkips(templateRows, params.studentId, ymdUTC(today)),
      overrideRows,
      schoolDefaults,
    });
  }

  async getWeekForStudent(params: {
    schoolId: string;
    studentId: string;
    cohortId: string;
    weekOf?: string;
  }): Promise<ScheduleItem[]> {
    const { templateRows } = await this.resolveTemplateSlotsForStudent(params);
    const schoolDefaults = await this._schoolPeriodTimes(params.schoolId);

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
        templateRows: this._applyStudentDateSkips(templateRows, params.studentId, dateYmd),
        overrideRows,
        schoolDefaults,
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
