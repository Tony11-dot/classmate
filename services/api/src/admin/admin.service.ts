import { BadRequestException, ForbiddenException, Injectable, HttpException, HttpStatus, NotFoundException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { subjectDefaultsBySchoolGrade, studentSubjectOverrides, defaultsKey, normalizeSubjects, normalizeSubjectsI18n } from '../subjects/subjects.store';
import { PasswordResetService } from '../auth/password-reset/password-reset.service';
import { hasAnyRole } from '../auth/permissions';

function randomDigits(len = 6) {
  const digits = '0123456789';
  let out = '';
  for (let i = 0; i < len; i++)
    out += digits[Math.floor(Math.random() * digits.length)];
  return out;
}

/**
 * Accepts either a `grades` array or a legacy single `grade`. Returns a
 * deduplicated, sorted `number[]` of valid integer grades. Empty if no usable
 * input. Callers should validate non-empty themselves.
 */
/// Normalize an incoming hex color to `#RRGGBB` (uppercase, no alpha).
/// Returns null when empty / malformed.
function normalizeHexColor(v: unknown): string | null {
  let h = String(v ?? '').trim();
  if (!h) return null;
  if (h.startsWith('#')) h = h.slice(1);
  if (h.toLowerCase().startsWith('0x')) h = h.slice(2);
  if (h.length === 8) h = h.slice(2);
  if (h.length !== 6) return null;
  if (!/^[0-9A-Fa-f]{6}$/.test(h)) return null;
  return `#${h.toUpperCase()}`;
}

function normalizeGrades(grades: unknown, fallback?: unknown): number[] {
  const raw = Array.isArray(grades) && grades.length > 0
    ? grades
    : (fallback !== undefined && fallback !== null ? [fallback] : []);
  const cleaned = raw
    .map((g) => Number(g))
    .filter((g) => Number.isInteger(g) && g > 0);
  return Array.from(new Set(cleaned)).sort((a, b) => a - b);
}

@Injectable()
export class AdminService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly passwordReset: PasswordResetService,
  ) {}

  private ensureAdmin(user: any) {
    if (!hasAnyRole(user, ['ADMIN']))
      throw new ForbiddenException('Admin or Teacher only');
  }

  async createCohort(user: any, body: { name: string; grade?: number; grades?: number[] }) {
    this.ensureAdmin(user);
    if (!body?.name) throw new BadRequestException('name is required');

    const grades = normalizeGrades(body?.grades, body?.grade);
    if (!grades.length) throw new BadRequestException('grade or grades[] required');

    const schoolId = (user as any)?.schoolId ?? null;

    try {
      const out = await this.prisma.cohort.create({
        data: { name: body.name, grade: grades[0], grades, schoolId } as any,
      });
      return out;
    } catch (e: any) {
      if (e?.code === 'P2002') {
        throw new HttpException('Cohort name already exists', HttpStatus.CONFLICT);
      }
      throw e;
    }
}

  async generateJoinCode(
    user: any,
    body: { cohortId: string; expiresInHours?: number; length?: number },
  ) {
    // allow TEACHER for join-code (e2e expects this)

    if (!hasAnyRole(user, ['ADMIN', 'TEACHER'])) throw new ForbiddenException('Admin or Teacher only');
if (!body?.cohortId) throw new BadRequestException('cohortId is required');
    const roles: string[] = Array.isArray((user as any)?.roles) ? (user as any).roles : [];
    const teacherId = (user as any)?.sub ?? (user as any)?.id;

    if (roles.includes('TEACHER') && !roles.includes('ADMIN')) {
      const slotCohort = await this.prisma.scheduleSlotCohort.findFirst({
        where: { cohortId: body.cohortId, slot: { teacherId } },
        select: { slotId: true },
      });
      if (!slotCohort) throw new ForbiddenException('Teacher not authorized for this cohort');
    }


    const cohort = await this.prisma.cohort.findUnique({
      where: { id: body.cohortId },
    });
    if (!cohort) throw new BadRequestException('Invalid cohortId');

    // rate-limit: join-code generation (per cohort)
    // max 5 codes / 60s per cohort
    const since = new Date(Date.now() - 60 * 1000);
    const recent = await this.prisma.cohortJoinCode.count({
      where: { cohortId: body.cohortId, createdAt: { gt: since } },
    });
    if (process.env.NODE_ENV !== 'test' && recent >= 5) throw new HttpException('Too many join-codes created; try again soon', HttpStatus.TOO_MANY_REQUESTS);

    const len =
      body.length && body.length >= 4 && body.length <= 10 ? body.length : 6;
    const code = randomDigits(len);
    const codeHash = await bcrypt.hash(String(code), 10);

    const expiresAt =
      body.expiresInHours && body.expiresInHours > 0
        ? new Date(Date.now() + body.expiresInHours * 60 * 60 * 1000)
        : null;

    await this.prisma.cohortJoinCode.updateMany({
      where: { cohortId: body.cohortId, active: true },
      data: { active: false },
    });

    await this.prisma.cohortJoinCode.create({
      data: {
        cohortId: body.cohortId,
        active: true,
        codeHash,
        expiresAt: expiresAt ?? undefined,
      },
    });

    return { cohortId: body.cohortId, code: String(code), expiresAt };
  }

  // ── School period defaults ───────────────────────────────────────────────────

  async getSchoolPeriodDefaults(user: any) {
    this.ensureAdmin(user);
    const schoolId = (user as any)?.schoolId;
    if (!schoolId) throw new BadRequestException('No school associated with this admin');
    const defaults = await this.prisma.schoolPeriodDefault.findMany({
      where: { schoolId },
      orderBy: { period: 'asc' },
    });
    return { ok: true, defaults };
  }

  async setSchoolPeriodDefaults(user: any, body: { defaults: { period: number; startTime: string; endTime: string }[] }) {
    this.ensureAdmin(user);
    const schoolId = (user as any)?.schoolId;
    if (!schoolId) throw new BadRequestException('No school associated with this admin');
    if (!Array.isArray(body?.defaults)) throw new BadRequestException('defaults[] is required');

    for (const d of body.defaults) {
      await this.prisma.schoolPeriodDefault.upsert({
        where: { schoolId_period: { schoolId, period: d.period } },
        update: { startTime: d.startTime, endTime: d.endTime },
        create: { schoolId, period: d.period, startTime: d.startTime, endTime: d.endTime },
      });
    }
    return { ok: true, count: body.defaults.length };
  }

  // ── Period (ScheduleSlot) CRUD ────────────────────────────────────────────────

  async listPeriods(user: any) {
    this.ensureAdmin(user);
    const schoolId = (user as any)?.schoolId ?? null;
    const slots = await this.prisma.scheduleSlot.findMany({
      where: schoolId ? { schoolId } : {},
      orderBy: [{ dayOfWeek: 'asc' }, { period: 'asc' }],
      include: {
        teacher: { select: { id: true, name: true } },
        classroom: { select: { id: true, name: true, subject: true } },
        // `cohort.id` + `cohort.grades` are needed by the schedule UI so it
        // can detect "this period covers every cohort at grade N" and
        // restore the audience as grade mode on edit.
        cohorts: {
          select: {
            cohortId: true,
            cohort: { select: { id: true, name: true, grade: true, grades: true } as any },
          },
        },
        students: { select: { studentId: true, student: { select: { user: { select: { name: true } } } } } },
      },
    });
    return { ok: true, slots };
  }

  async createPeriod(user: any, body: {
    dayOfWeek: number;
    period: number;
    teacherId?: string;
    classroomId?: string;
    cohortIds?: string[];
    studentIds?: string[];
    subject?: string;
    caption?: string;
    color?: string;
    audienceGrade?: number | null;
    startTime?: string;
    endTime?: string;
    frequencyWeeks?: number;
    startDate?: string;
  }) {
    this.ensureAdmin(user);
    const schoolId = (user as any)?.schoolId ?? null;

    const { dayOfWeek, period, teacherId, classroomId, cohortIds = [], studentIds = [], subject, caption, color, audienceGrade, startTime, endTime, frequencyWeeks = 1, startDate } = body ?? {} as any;
    if (dayOfWeek === undefined || dayOfWeek < 0 || dayOfWeek > 6) throw new BadRequestException('dayOfWeek must be 0..6');
    if (!Number.isInteger(period) || period < 1 || period > 20) throw new BadRequestException('period must be 1..20');

    // If classroomId provided, verify it belongs to the selected teacher
    if (classroomId && teacherId) {
      const cr = await this.prisma.classroom.findUnique({ where: { id: classroomId }, select: { teacherId: true } });
      if (!cr) throw new BadRequestException('Classroom not found');
      if (cr.teacherId !== teacherId) throw new BadRequestException('Classroom does not belong to the selected teacher');
    }

    const normalizedColor = normalizeHexColor(color);
    const normalizedAudienceGrade =
      typeof audienceGrade === 'number' && Number.isFinite(audienceGrade) ? audienceGrade : null;
    const slot = await this.prisma.scheduleSlot.create({
      data: {
        schoolId,
        dayOfWeek,
        period,
        teacherId: teacherId ?? null,
        classroomId: classroomId ?? null,
        subject: subject ?? null,
        caption: typeof caption === 'string' && caption.trim().length
          ? caption.trim()
          : null,
        color: normalizedColor,
        audienceGrade: normalizedAudienceGrade,
        startTime: startTime ?? null,
        endTime: endTime ?? null,
        // 0 = one-off (renders only on startDate), 1..52 = recurring.
        frequencyWeeks: Number.isInteger(frequencyWeeks) && frequencyWeeks >= 0 && frequencyWeeks <= 52
          ? frequencyWeeks
          : 1,
        startDate: startDate ?? null,
      } as any,
    });

    if (cohortIds.length) {
      await this.prisma.scheduleSlotCohort.createMany({
        data: cohortIds.map((cid: string) => ({ slotId: slot.id, cohortId: cid })),
        skipDuplicates: true,
      });
    }
    if (studentIds.length) {
      await this.prisma.scheduleSlotStudent.createMany({
        data: studentIds.map((sid: string) => ({ slotId: slot.id, studentId: sid })),
        skipDuplicates: true,
      });
    }

    // Subject sync — if the admin typed a subject not present in the
    // school's SchoolGradeSubjectDefault, add it for every grade this
    // slot covers so the next School Settings → Subjects view (and the
    // schedule subject picker, which reads from the same endpoint) finds
    // it. No-op when the subject is already catalogued.
    if (schoolId && subject) {
      const trimmedSubject = String(subject).trim();
      if (trimmedSubject) {
        // School-wide bucket (grade=0).  School Settings → Subjects also
        // reads from grade=0, so a subject typed inline in Add Period
        // appears immediately in the Settings list — single source of
        // truth, no per-grade fan-out. Pass the slot's color so the
        // subject's default color matches the admin's first choice —
        // every future period of that subject inherits it.
        await this._addSubjectToSchoolDefaults(
          schoolId,
          trimmedSubject,
          [0],
          normalizedColor,
        );
      }
    }

    return { ok: true, slot: { ...slot, cohortIds, studentIds } };
  }

  /// Adds [subject] (by `nameEn` match) to the `subjectsI18n` JSON list for
  /// each given grade's SchoolGradeSubjectDefault row, creating the row
  /// if absent.  Idempotent — duplicates are filtered case-insensitively.
  /// When `color` is supplied, attaches it to the new entry so the
  /// schedule grid + Add Period color picker default to the same hue
  /// for every later period that uses this subject.
  private async _addSubjectToSchoolDefaults(
    schoolId: string,
    subject: string,
    grades: number[],
    color?: string | null,
  ): Promise<void> {
    if (!grades.length) return;
    for (const grade of grades) {
      const row = await this.prisma.schoolGradeSubjectDefault.findUnique({
        where: { schoolId_grade_unique: { schoolId, grade } } as any,
      }) as any;
      const existingI18n = Array.isArray(row?.subjectsI18n) ? row.subjectsI18n : [];
      const existingFlat = Array.isArray(row?.subjects) ? row.subjects : [];
      const lowered = new Set<string>();
      for (const item of existingI18n) {
        const n = typeof item === 'string'
          ? item
          : String((item as any)?.nameEn ?? '');
        if (n.trim().length) lowered.add(n.trim().toLowerCase());
      }
      for (const s of existingFlat) {
        if (typeof s === 'string') lowered.add(s.trim().toLowerCase());
      }
      if (lowered.has(subject.toLowerCase())) continue;
      const newEntry: any = { nameEn: subject };
      if (color && typeof color === 'string' && color.trim().length) {
        newEntry.color = color.trim();
      }
      const newI18n = [...existingI18n, newEntry];
      const newFlat = [...existingFlat, subject];
      if (row) {
        await this.prisma.schoolGradeSubjectDefault.update({
          where: { id: row.id },
          data: { subjectsI18n: newI18n as any, subjects: newFlat },
        });
      } else {
        await this.prisma.schoolGradeSubjectDefault.create({
          data: {
            schoolId,
            grade,
            subjectsI18n: newI18n as any,
            subjects: newFlat,
          },
        });
      }
    }
  }

  async updatePeriod(user: any, id: string, body: {
    dayOfWeek?: number;
    period?: number;
    teacherId?: string | null;
    classroomId?: string | null;
    cohortIds?: string[];
    studentIds?: string[];
    subject?: string | null;
    caption?: string | null;
    color?: string | null;
    audienceGrade?: number | null;
    startTime?: string | null;
    endTime?: string | null;
    frequencyWeeks?: number;
    startDate?: string | null;
    skipDates?: string[];
    skipForStudentIds?: string[];
    studentDateSkips?: string[];
  }) {
    this.ensureAdmin(user);
    const slot = await this.prisma.scheduleSlot.findUnique({ where: { id } });
    if (!slot) throw new NotFoundException('Period not found');

    if (body.classroomId && body.teacherId) {
      const cr = await this.prisma.classroom.findUnique({ where: { id: body.classroomId }, select: { teacherId: true } });
      if (cr && cr.teacherId !== body.teacherId) throw new BadRequestException('Classroom does not belong to the selected teacher');
    }

    const data: any = {};
    if (body.dayOfWeek !== undefined) data.dayOfWeek = body.dayOfWeek;
    if (body.period !== undefined) data.period = body.period;
    if ('teacherId' in body) data.teacherId = body.teacherId ?? null;
    if ('classroomId' in body) data.classroomId = body.classroomId ?? null;
    if ('subject' in body) data.subject = body.subject ?? null;
    if ('caption' in body) {
      const c = typeof body.caption === 'string' ? body.caption.trim() : '';
      data.caption = c.length ? c : null;
    }
    if ('color' in body) data.color = normalizeHexColor(body.color);
    if ('audienceGrade' in body) {
      data.audienceGrade =
        typeof body.audienceGrade === 'number' && Number.isFinite(body.audienceGrade)
          ? body.audienceGrade
          : null;
    }
    if ('startTime' in body) data.startTime = body.startTime ?? null;
    if ('endTime' in body) data.endTime = body.endTime ?? null;
    if (body.frequencyWeeks !== undefined) {
      // Same range as createPeriod: 0 = one-off, 1..52 = recurring.
      const f = body.frequencyWeeks;
      data.frequencyWeeks = Number.isInteger(f) && f >= 0 && f <= 52 ? f : 1;
    }
    if ('startDate' in body) data.startDate = body.startDate ?? null;
    if (Array.isArray(body.skipDates)) {
      // Sanitize to strict YYYY-MM-DD strings — the renderer compares with
      // string equality, so a stray timestamp would silently fail to match.
      const re = /^\d{4}-\d{2}-\d{2}$/;
      data.skipDates = Array.from(
        new Set(body.skipDates.filter((s) => typeof s === 'string' && re.test(s))),
      );
    }
    if (Array.isArray(body.skipForStudentIds)) {
      // Legacy field — no longer read by the schedule resolver but still
      // patchable so older clients don't error.  See ScheduleSlot model
      // doc for the full picture.
      data.skipForStudentIds = Array.from(
        new Set(
          body.skipForStudentIds.filter(
            (s) => typeof s === 'string' && s.length > 0,
          ),
        ),
      );
    }
    if (Array.isArray(body.studentDateSkips)) {
      // Entries must look like "<uuid-ish>:<YYYY-MM-DD>".  Anything that
      // doesn't is silently dropped — a malformed value would never match
      // the resolver's needle, just create noise in the DB.
      const re = /^[^:]+:\d{4}-\d{2}-\d{2}$/;
      data.studentDateSkips = Array.from(
        new Set(
          body.studentDateSkips.filter(
            (s) => typeof s === 'string' && re.test(s),
          ),
        ),
      );
    }

    const updated = await this.prisma.scheduleSlot.update({ where: { id }, data });

    if (body.cohortIds !== undefined) {
      await this.prisma.scheduleSlotCohort.deleteMany({ where: { slotId: id } });
      if (body.cohortIds.length) {
        await this.prisma.scheduleSlotCohort.createMany({ data: body.cohortIds.map((cid) => ({ slotId: id, cohortId: cid })), skipDuplicates: true });
      }
    }
    if (body.studentIds !== undefined) {
      await this.prisma.scheduleSlotStudent.deleteMany({ where: { slotId: id } });
      if (body.studentIds.length) {
        await this.prisma.scheduleSlotStudent.createMany({ data: body.studentIds.map((sid) => ({ slotId: id, studentId: sid })), skipDuplicates: true });
      }
    }

    return { ok: true, slot: updated };
  }

  async deletePeriod(user: any, id: string) {
    this.ensureAdmin(user);
    await this.prisma.scheduleSlot.delete({ where: { id } });
    return { ok: true };
  }

  // ── DDL helpers ───────────────────────────────────────────────────────────────

  async listStudentsForDDL(user: any, query: { q?: string; cohortId?: string }) {
    this.requireAdminOrSecretary(user);
    const schoolId = (user as any)?.schoolId ?? null;
    const students = await this.prisma.user.findMany({
      where: {
        ...(schoolId ? { schoolId } : {}),
        roles: { some: { role: 'STUDENT' } },
        ...(query?.q ? { name: { contains: query.q, mode: 'insensitive' } } : {}),
      },
      select: {
        id: true,
        name: true,
        studentProfile: {
          select: {
            cohortId: true,
            // Student's OWN grade (set when admin creates the user). Fallback
            // for the case where they haven't been assigned to a cohort yet
            // — otherwise the AddStudents grade filter on a fresh cohort
            // returns zero matches even though students exist.
            grade: true,
            cohort: { select: { name: true, grade: true } },
            // Multi-cohort memberships via the StudentCohort join — the
            // legacy studentProfile.cohortId only tracks a single cohort,
            // so consumers that need to filter against the freshly-created
            // multi-cohort assignments must read this array.
            cohorts: { select: { cohortId: true, cohort: { select: { name: true } } } },
          },
        },
      },
      orderBy: { name: 'asc' },
      take: 100,
    });
    return {
      ok: true,
      students: students.map((s) => {
        const memberships = s.studentProfile?.cohorts ?? [];
        const cohortIds = memberships.map((m) => m.cohortId);
        const cohortNames = memberships
          .map((m) => m.cohort?.name)
          .filter((n): n is string => !!n);
        return {
          id: s.id,
          name: s.name,
          // Prefer cohort's grade (more specific when assigned) → fall back
          // to the student's own grade level → null only if neither set.
          grade: s.studentProfile?.cohort?.grade ?? (s.studentProfile as any)?.grade ?? null,
          cohortName: s.studentProfile?.cohort?.name ?? null,
          cohortId: s.studentProfile?.cohortId ?? null,
          cohortIds,
          cohortNames,
        };
      }),
    };
  }

  async listTeachersForDDL(user: any) {
    this.requireAdminOrSecretary(user);
    const schoolId = (user as any)?.schoolId ?? null;
    // Hard-require schoolId. Without it we'd return every teacher in
    // every school (cross-school leak in the period editor's teacher
    // picker). An admin should always have a schoolId on their JWT;
    // empty = misconfigured account, not a free pass.
    if (!schoolId) return { ok: true, teachers: [] };

    const teachers = await this.prisma.user.findMany({
      where: {
        schoolId,
        roles: { some: { role: 'TEACHER' } },
      },
      select: { id: true, name: true },
      orderBy: { name: 'asc' },
    });
    return { ok: true, teachers };
  }

  async listCohortsForDDL(user: any) {
    this.requireAdminOrSecretary(user);
    const schoolId = (user as any)?.schoolId ?? null;
    const cohorts = await this.prisma.cohort.findMany({
      where: schoolId ? { OR: [{ schoolId } as any, { schoolId: null }] } : {},
      select: {
        id: true,
        name: true,
        grade: true,
        grades: true,
        // Both membership sources — see listCohorts() for the same union
        // (StudentCohort join + legacy StudentProfile.cohortId scalar).
        studentLinks: { select: { studentId: true } },
        students: { select: { userId: true } },
      } as any,
      orderBy: [{ grade: 'asc' }, { name: 'asc' }],
    });
    return {
      ok: true,
      cohorts: (cohorts as any[]).map((c) => {
        const ids = new Set<string>([
          ...(Array.isArray(c.studentLinks)
            ? c.studentLinks.map((l: any) => l.studentId).filter((id: any) => !!id)
            : []),
          ...(Array.isArray(c.students)
            ? c.students.map((s: any) => s.userId).filter((id: any) => !!id)
            : []),
        ]);
        return {
          id: c.id,
          name: c.name,
          grade: c.grade,
          grades: Array.isArray(c.grades) && c.grades.length ? c.grades : [c.grade],
          studentIds: Array.from(ids),
        };
      }),
    };
  }

  async listClassroomsForTeacher(user: any, teacherId: string) {
    this.requireAdminOrSecretary(user);
    if (!teacherId) throw new BadRequestException('teacherId is required');
    const classrooms = await this.prisma.classroom.findMany({
      where: { teacherId },
      select: { id: true, name: true, subject: true },
      orderBy: { name: 'asc' },
    });
    return { ok: true, classrooms };
  }

  async setScheduleOverride(
    user: any,
    body: { cohortId: string; date: string; period: number },
  ) {
    this.ensureAdmin(user);

    const { cohortId, date, period } = body ?? ({} as any);
    if (!cohortId) throw new BadRequestException('cohortId is required');
    if (!date) throw new BadRequestException('date is required (YYYY-MM-DD)');
    if (!Number.isInteger(period) || period < 1 || period > 20)
      throw new BadRequestException('period must be 1..20');

    const dt = new Date(`${date}T00:00:00.000Z`);
    if (Number.isNaN(dt.getTime()))
      throw new BadRequestException('Invalid date format');

    return this.prisma.scheduleOverride.upsert({
      where: { cohortId_date_period: { cohortId, date: dt, period } },
      update: {},
      create: { cohortId, date: dt, period },
    });
  }

  async listScheduleOverrides(user: any, query: { cohortId: string; from: string; to: string }) {
    this.requireAdminOrSecretary(user);
    const { cohortId, from, to } = query ?? {} as any;
    if (!cohortId) throw new BadRequestException('cohortId is required');
    const fromDt = new Date(`${from}T00:00:00.000Z`);
    const toDt = new Date(`${to}T00:00:00.000Z`);
    const end = new Date(toDt); end.setUTCDate(end.getUTCDate() + 1);
    const rows = await this.prisma.scheduleOverride.findMany({
      where: { cohortId, date: { gte: fromDt, lt: end } },
      orderBy: [{ date: 'asc' }, { period: 'asc' }],
      take: 2000,
    });
    return { ok: true, overrides: rows.map((o) => ({ id: o.id, cohortId: o.cohortId, date: o.date.toISOString(), period: o.period, subject: (o as any).subject ?? null })) };
  }

  async deleteScheduleOverride(user: any, body: { cohortId: string; date: string; period: number }) {
    this.ensureAdmin(user);
    const { cohortId, date, period } = body ?? {} as any;
    if (!cohortId || !date) throw new BadRequestException('cohortId and date are required');
    const dt = new Date(`${date}T00:00:00.000Z`);
    await this.prisma.scheduleOverride.delete({ where: { cohortId_date_period: { cohortId, date: dt, period } } });
    return { ok: true };
  }

  async getCohortSchedule(user: any, cohortId: string) {
    this.requireAdminOrSecretary(user);
    if (!cohortId) throw new BadRequestException('cohortId is required');
    const slotIds = (await this.prisma.scheduleSlotCohort.findMany({ where: { cohortId }, select: { slotId: true } })).map((r) => r.slotId);
    if (!slotIds.length) return [];
    return this.prisma.scheduleSlot.findMany({ where: { id: { in: slotIds } }, orderBy: [{ dayOfWeek: 'asc' }, { period: 'asc' }] });
  }

  
  // =========================================================
  // Session 10: School subject defaults + per-student overrides
  // =========================================================

  /** Throws 403 if targetUserId does not belong to the admin's school. */
  private async assertUserInSchool(user: any, targetUserId: string): Promise<void> {
    const schoolId = (user as any)?.schoolId;
    if (!schoolId) return;
    const target = await this.prisma.user.findFirst({
      where: { id: targetUserId, schoolId },
      select: { id: true },
    });
    if (!target) throw new ForbiddenException('That user does not belong to your school');
  }

  /** Returns only IDs from the list that belong to admin's school. */
  private async filterUsersToSchool(user: any, userIds: string[]): Promise<string[]> {
    const schoolId = (user as any)?.schoolId;
    if (!schoolId || !userIds.length) return userIds;
    const valid = await this.prisma.user.findMany({
      where: { id: { in: userIds }, schoolId },
      select: { id: true },
    });
    return valid.map((u) => u.id);
  }

  private requireAdminOrSecretary(user: any) {
    const appEnv = process.env.APP_ENV ?? process.env.NODE_ENV ?? 'production';
    const isDev = appEnv.toLowerCase().includes('dev') || appEnv.toLowerCase().includes('test');
    if (isDev) return; // matches RolesGuard dev bypass

    const roles: string[] = Array.isArray(user?.roles) ? user.roles : [];
    console.log('[ADMIN_AUTH] roles:', roles, 'user.id:', user?.id);
    if (!roles.includes('ADMIN') && !roles.includes('SECRETARY')) {
      throw new ForbiddenException('Admin/Secretary only');
    }
  }

  private async resolveUserId(identifier: string): Promise<string> {
    const id = String(identifier ?? '').trim();
    if (!id) throw new BadRequestException('user identifier required');

    if (id.includes('@')) {
      const u = await this.prisma.user.findUnique({ where: { email: id } });
      if (!u) throw new BadRequestException('user not found');
      return u.id;
    }

    return id;
  }

  async setSubjectDefaults(user: any, dto: any) {
    this.requireAdminOrSecretary(user);

    const schoolId = String(dto?.schoolId ?? user?.schoolId ?? '').trim();
    if (!schoolId) throw new BadRequestException('schoolId required — ensure your account is linked to a school');
    const grade = Number(dto?.grade);
    // Authoritative shape is `subjectsI18n` (array of multilang objects). For
    // back-compat the legacy `subjects` flat list is also written and kept in
    // sync with each entry's nameEn.
    const subjectsI18n = normalizeSubjectsI18n(dto?.subjectsI18n ?? dto?.subjects);
    const subjects = subjectsI18n.map(s => s.nameEn);

    if (Number.isNaN(grade)) throw new BadRequestException('grade required');
    if (!subjectsI18n.length) throw new BadRequestException('subjects[] required');

    const row = await this.prisma.schoolGradeSubjectDefault.upsert({
      where: { schoolId_grade_unique: { schoolId, grade } },
      update: { subjects, subjectsI18n: subjectsI18n as any },
      create: { schoolId, grade, subjects, subjectsI18n: subjectsI18n as any },
      select: { schoolId: true, grade: true, subjects: true, subjectsI18n: true } as any,
    });

    return { ok: true, defaults: row };
  }
  /**
   * Returns the deduplicated union of every subject defined in this school
   * across every grade. Used by the Schedule "Add Period" subject picker so
   * admins can pick from the full library without first choosing a grade.
   * Dedup key is nameEn (case-insensitive).
   */
  async listAllSchoolSubjects(user: any) {
    this.requireAdminOrSecretary(user);
    const schoolId = (user as any)?.schoolId;
    if (!schoolId) throw new BadRequestException('No school associated with this account');

    const rows = await this.prisma.schoolGradeSubjectDefault.findMany({
      where: { schoolId },
      select: { subjectsI18n: true, subjects: true } as any,
    }) as any[];

    const byKey = new Map<string, any>();
    for (const r of rows) {
      const i18n = normalizeSubjectsI18n(r.subjectsI18n);
      const list = i18n.length ? i18n : (r.subjects ?? []).map((s: string) => ({ nameEn: s }));
      for (const s of list) {
        const key = String(s.nameEn ?? '').trim().toLowerCase();
        if (!key) continue;
        // Keep the richest entry — first non-empty for each lang wins.
        const prev = byKey.get(key) ?? { nameEn: s.nameEn };
        byKey.set(key, {
          nameEn: prev.nameEn || s.nameEn,
          nameAr: prev.nameAr || s.nameAr,
          nameHe: prev.nameHe || s.nameHe,
          nameFr: prev.nameFr || s.nameFr,
          nameRu: prev.nameRu || s.nameRu,
        });
      }
    }

    const subjects = Array.from(byKey.values()).sort((a, b) =>
      String(a.nameEn ?? '').localeCompare(String(b.nameEn ?? '')),
    );
    return { ok: true, subjects };
  }

  /**
   * Persists a single subject (5-lang names) into the SchoolGradeSubjectDefault
   * row for every grade in `grades`. Used when an admin creates a brand-new
   * subject inline from the Schedule "Add Period" flow so it becomes part of
   * the school's permanent subject library, not just a one-off slot label.
   */
  async addSubjectToGrades(user: any, dto: {
    grades?: number[];
    subject?: { nameEn?: string; nameAr?: string; nameHe?: string; nameFr?: string; nameRu?: string; color?: string };
  }) {
    this.requireAdminOrSecretary(user);
    const schoolId = (user as any)?.schoolId;
    if (!schoolId) throw new BadRequestException('No school associated with this account');

    const grades = Array.isArray(dto?.grades) ? dto.grades.map(Number).filter(Number.isFinite) : [];
    if (!grades.length) throw new BadRequestException('grades[] required');
    const nameEn = String(dto?.subject?.nameEn ?? '').trim();
    if (!nameEn) throw new BadRequestException('subject.nameEn required');

    const incoming: any = {
      nameEn,
      ...(dto?.subject?.nameAr ? { nameAr: String(dto.subject.nameAr).trim() } : {}),
      ...(dto?.subject?.nameHe ? { nameHe: String(dto.subject.nameHe).trim() } : {}),
      ...(dto?.subject?.nameFr ? { nameFr: String(dto.subject.nameFr).trim() } : {}),
      ...(dto?.subject?.nameRu ? { nameRu: String(dto.subject.nameRu).trim() } : {}),
      // Color is part of the subject's identity — the admin picks a color
      // in the subject editor and the schedule grid/picker should render
      // every period of that subject in that color until they pick an
      // override. Without this, the color was dropped here and the slot
      // re-derived a deterministic palette hue, ignoring the admin's
      // choice.
      ...(dto?.subject?.color ? { color: String(dto.subject.color).trim() } : {}),
    };

    for (const grade of grades) {
      const existing = await this.prisma.schoolGradeSubjectDefault.findUnique({
        where: { schoolId_grade_unique: { schoolId, grade } },
        select: { subjectsI18n: true } as any,
      }) as any;
      const i18n = normalizeSubjectsI18n(existing?.subjectsI18n);
      // De-dup by nameEn (case-insensitive). Replace if already present so
      // the latest 5-lang values win.
      const filtered = i18n.filter((s) => String(s.nameEn ?? '').trim().toLowerCase() !== nameEn.toLowerCase());
      const next = [...filtered, incoming];
      const subjects = next.map((s) => s.nameEn);
      await this.prisma.schoolGradeSubjectDefault.upsert({
        where: { schoolId_grade_unique: { schoolId, grade } },
        update: { subjects, subjectsI18n: next as any },
        create: { schoolId, grade, subjects, subjectsI18n: next as any },
      });
    }
    return { ok: true, grades };
  }

  async getSubjectDefaults(user: any, query: { schoolId?: string; grade?: number }) {
    this.requireAdminOrSecretary(user);

    const schoolId = String(query?.schoolId ?? user?.schoolId ?? '').trim();
    const grade = query?.grade;

    if (!schoolId) throw new BadRequestException('schoolId required — ensure your account is linked to a school');
    if (grade === undefined || Number.isNaN(Number(grade))) {
      throw new BadRequestException('grade required');
    }

    const gradeNum = Number(grade);

    // grade=0 is the "school-wide" bucket from School Settings → Subjects.
    // The Add Period subject picker reads listAllSchoolSubjects which
    // unions every grade row in the school; if grade=0 only returned the
    // grade=0 row, legacy per-grade subjects (or subjects an admin added
    // through a per-grade flow at some point) wouldn't show up in
    // Settings, breaking the parity-with-Add-Period the user expects.
    // Union them all when grade=0 is requested.
    if (gradeNum === 0) {
      const rows = await this.prisma.schoolGradeSubjectDefault.findMany({
        where: { schoolId },
        select: { subjectsI18n: true, subjects: true } as any,
      }) as any[];
      const byKey = new Map<string, any>();
      for (const r of rows) {
        const i18n = normalizeSubjectsI18n(r.subjectsI18n);
        const list = i18n.length
          ? i18n
          : (r.subjects ?? []).map((s: string) => ({ nameEn: s }));
        for (const s of list) {
          const key = String(s.nameEn ?? '').trim().toLowerCase();
          if (!key) continue;
          const prev = byKey.get(key) ?? { nameEn: s.nameEn };
          byKey.set(key, {
            nameEn: prev.nameEn || s.nameEn,
            nameAr: prev.nameAr || s.nameAr,
            nameHe: prev.nameHe || s.nameHe,
            nameFr: prev.nameFr || s.nameFr,
            nameRu: prev.nameRu || s.nameRu,
            color: prev.color || (s as any).color,
          });
        }
      }
      const finalI18n = Array.from(byKey.values()).sort((a, b) =>
        String(a.nameEn ?? '').localeCompare(String(b.nameEn ?? '')),
      );
      return {
        ok: true,
        defaults: {
          schoolId,
          grade: 0,
          subjects: finalI18n.map((s: any) => s.nameEn),
          subjectsI18n: finalI18n,
        },
      };
    }

    const row = await this.prisma.schoolGradeSubjectDefault.findUnique({
      where: { schoolId_grade_unique: { schoolId, grade: gradeNum } },
      select: { schoolId: true, grade: true, subjects: true, subjectsI18n: true } as any,
    }) as any;

    if (!row) {
      return { ok: true, defaults: { schoolId, grade: gradeNum, subjects: [], subjectsI18n: [] } };
    }
    const i18n = normalizeSubjectsI18n(row.subjectsI18n);
    const finalI18n = i18n.length ? i18n : (row.subjects ?? []).map((s: string) => ({ nameEn: s }));
    return { ok: true, defaults: { ...row, subjectsI18n: finalI18n } };
  }
  async upsertSubjectOverride(user: any, identifier: string, dto: any) {
    this.requireAdminOrSecretary(user);
  
    const userId = await this.resolveUserId(identifier);
    const enabled = Boolean(dto?.enabled);
    const subjects = normalizeSubjects(dto?.subjects);
  
    const row = await this.prisma.studentSubjectOverride.upsert({
      where: { userId },
      update: { enabled, subjects },
      create: { userId, enabled, subjects },
      select: { userId: true, enabled: true, subjects: true },
    });
  
    return { ok: true, override: row };
  }
  async getSubjectOverride(user: any, identifier: string) {
    this.requireAdminOrSecretary(user);

    const userId = await this.resolveUserId(identifier);

    const row = await this.prisma.studentSubjectOverride.findUnique({
      where: { userId },
      select: { userId: true, enabled: true, subjects: true },
    });

    return { ok: true, override: row ?? null };
  }

  // ---- School CRUD ----

  async createSchool(user: any, dto: any) {
    this.requireAdminOrSecretary(user);
    const name = String(dto?.name ?? '').trim();
    if (!name) throw new BadRequestException('name required');
    const logoUrl = dto?.logoUrl ? String(dto.logoUrl).trim() : null;
    const row = await this.prisma.school.create({
      data: { name, ...(logoUrl ? { logoUrl } : {}) },
    });
    return { ok: true, school: row };
  }

  async listSchools(user: any) {
    this.requireAdminOrSecretary(user);
    const rows = await this.prisma.school.findMany({
      orderBy: { name: 'asc' },
    });
    return { ok: true, schools: rows };
  }

  async getSchool(user: any, id: string) {
    this.requireAdminOrSecretary(user);
    const row = await this.prisma.school.findUnique({ where: { id } });
    return { ok: true, school: row ?? null };
  }

  async updateSchool(user: any, id: string, dto: any) {
    this.requireAdminOrSecretary(user);
    const data: any = {};
    if (dto?.name !== undefined) data.name = String(dto.name).trim();
    if (dto?.logoUrl !== undefined) data.logoUrl = dto.logoUrl ? String(dto.logoUrl).trim() : null;
    const row = await this.prisma.school.update({ where: { id }, data });
    return { ok: true, school: row };
  }

  async deleteSchool(user: any, id: string) {
    this.requireAdminOrSecretary(user);
    await this.prisma.school.delete({ where: { id } });
    return { ok: true };
  }

  async assignUserToSchool(user: any, schoolId: string, dto: any) {
    this.requireAdminOrSecretary(user);
    const identifier = String(dto?.userId ?? dto?.email ?? '').trim();
    if (!identifier) throw new BadRequestException('userId or email required');
    const userId = await this.resolveUserId(identifier);
    await this.prisma.user.update({ where: { id: userId }, data: { schoolId } as any });
    return { ok: true };
  }

  // ── User Management ───────────────────────────────────────────────────────────

  async listUsers(user: any, query: { q?: string; role?: string; page?: number }) {
    this.requireAdminOrSecretary(user);
    const schoolId = (user as any)?.schoolId;
    if (!schoolId) throw new BadRequestException('No school associated with this account');

    const where: any = { schoolId };
    if (query?.role) where.roles = { some: { role: query.role.toUpperCase() } };
    if (query?.q) where.name = { contains: query.q, mode: 'insensitive' };

    const [rows, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        select: {
          id: true,
          name: true,
          email: true,
          status: true,
          roles: { select: { role: true } },
        },
        orderBy: { name: 'asc' },
        take: 100,
        skip: query?.page ? query.page * 100 : 0,
      }),
      this.prisma.user.count({ where }),
    ]);

    return {
      ok: true,
      users: rows.map((u) => ({
        id: u.id,
        name: u.name,
        email: u.email,
        status: u.status,
        roles: u.roles.map((r) => r.role),
      })),
      total,
    };
  }

  async exportStudents(user: any, query: { cohortId?: string; grade?: string; generatePasswords?: string; studentIds?: string }) {
    this.requireAdminOrSecretary(user);
    const schoolId = (user as any)?.schoolId;
    if (!schoolId) throw new BadRequestException('No school associated with this account');

    const where: any = {
      schoolId,
      roles: { some: { role: 'STUDENT' } },
    };
    const rows = await this.prisma.user.findMany({
      where,
      select: {
        id: true,
        name: true,
        nameEn: true, nameAr: true, nameHe: true, nameFr: true, nameRu: true,
        email: true,
        username: true,
        phone: true,
        plainPassword: true,
        studentProfile: {
          select: {
            cohort: { select: { id: true, name: true, grade: true } },
            cohorts: { select: { cohort: { select: { id: true, name: true, grade: true } } } },
          },
        },
      } as any,
      orderBy: { name: 'asc' },
    }) as any[];

    // School name — same for every row, fetch once. Used to label the
    // export so downstream consumers (Excel, printouts) know which school.
    const school = await this.prisma.school.findUnique({
      where: { id: schoolId },
      select: { name: true },
    });
    const schoolName = school?.name ?? '';

    // Filter: specific student IDs take precedence
    let filtered = rows;
    if (query?.studentIds) {
      const ids = new Set(query.studentIds.split(',').map((s) => s.trim()).filter(Boolean));
      filtered = filtered.filter((r) => ids.has(r.id));
    } else if (query?.cohortId) {
      filtered = filtered.filter((r) =>
        r.studentProfile?.cohort?.id === query.cohortId ||
        r.studentProfile?.cohorts?.some((c) => c.cohort.id === query.cohortId)
      );
    } else if (query?.grade) {
      const g = Number(query.grade);
      filtered = filtered.filter((r) =>
        r.studentProfile?.cohort?.grade === g ||
        r.studentProfile?.cohorts?.some((c) => c.cohort.grade === g)
      );
    }

    // Non-destructive: when the admin asks for passwords, we read the
    // plaintext copy maintained alongside the bcrypt hash. Users who
    // existed before plainPassword was introduced will show an empty
    // password column until they next change/reset their password
    // (which is the only path that can backfill plaintext safely).
    const includePasswords = query?.generatePasswords === 'true';
    const result: Array<{
      id: string; nameEn: string; nameAr: string; nameHe: string; nameFr: string; nameRu: string;
      email: string | null; username?: string | null; phone: string | null;
      grade: number | null;
      cohortName: string;
      cohortNames: string[];
      schoolName: string;
      tempPassword?: string;
    }> = [];

    for (const r of filtered) {
      // Collect every cohort the student is in — primary + many-to-many —
      // and dedupe by id so the export shows the full membership list,
      // not just one. Keeps the legacy `cohortName` field as the primary
      // for any old consumer still reading the singular.
      const cohortMap = new Map<string, { id: string; name: string; grade: number | null }>();
      if (r.studentProfile?.cohort?.id) {
        cohortMap.set(r.studentProfile.cohort.id, r.studentProfile.cohort);
      }
      for (const c of r.studentProfile?.cohorts ?? []) {
        if (c?.cohort?.id) cohortMap.set(c.cohort.id, c.cohort);
      }
      const cohortList = Array.from(cohortMap.values());
      const cohortNames = cohortList.map((c) => c.name);

      const entry = {
        id: r.id,
        nameEn: r.nameEn ?? r.name,
        nameAr: r.nameAr ?? '',
        nameHe: r.nameHe ?? '',
        nameFr: r.nameFr ?? '',
        nameRu: r.nameRu ?? '',
        email: r.email ?? null,
        username: (r as any).username ?? null,
        phone: (r as any).phone ?? null,
        grade: r.studentProfile?.cohort?.grade ?? r.studentProfile?.cohorts?.[0]?.cohort?.grade ?? null,
        // Legacy singular cohort name kept for back-compat with older
        // export clients still reading the old field.
        cohortName: cohortList[0]?.name ?? '',
        cohortNames,
        schoolName,
        tempPassword: includePasswords ? ((r as any).plainPassword ?? '') : undefined,
      };
      result.push(entry);
    }

    return { ok: true, students: result, schoolName };
  }

  async exportCohorts(user: any) {
    this.requireAdminOrSecretary(user);
    const schoolId = (user as any)?.schoolId;
    if (!schoolId) throw new BadRequestException('No school associated with this account');

    const cohorts = await this.prisma.cohort.findMany({
      where: { schoolId },
      include: {
        students: { include: { user: { select: { name: true, email: true } } } },
      },
      orderBy: [{ grade: 'asc' }, { name: 'asc' }],
    });

    return {
      ok: true,
      cohorts: cohorts.map((c) => ({
        id: c.id,
        name: c.name,
        grade: c.grade,
        grades: Array.isArray((c as any).grades) && (c as any).grades.length ? (c as any).grades : [c.grade],
        studentCount: c.students.length,
      })),
    };
  }

  async getUserDetail(user: any, id: string) {
    this.requireAdminOrSecretary(user);
    const schoolId = (user as any)?.schoolId;

    const row = await this.prisma.user.findFirst({
      where: { id, ...(schoolId ? { schoolId } : {}) },
      select: {
        id: true,
        name: true,
        displayName: true,
        legalName: true,
        nameEn: true, nameAr: true, nameHe: true, nameFr: true, nameRu: true,
        email: true,
        username: true,
        phone: true,
        status: true,
        roles: { select: { role: true } },
        studentProfile: {
          select: {
            cohortId: true,
            grade: true,
            cohort: { select: { name: true, grade: true, grades: true } },
            cohorts: { select: { cohort: { select: { id: true, name: true, grade: true, grades: true } } } },
          },
        },
      } as any,
    }) as any;

    if (!row) throw new NotFoundException('User not found');

    const [attendanceRate, gradeAvg, classrooms] = await Promise.all([
      row.studentProfile
        ? this.prisma.attendanceRecord.count({
            where: { studentId: row.id, status: 'PRESENT' },
          }).then(async (present) => {
            const total = await this.prisma.attendanceRecord.count({ where: { studentId: row.id } });
            return total > 0 ? Math.round((present / total) * 100) : null;
          })
        : null,
      row.studentProfile
        ? this.prisma.gradeRecord.aggregate({
            where: { studentId: row.id },
            _avg: { grade: true },
          }).then((r) => r._avg.grade ? Math.round(r._avg.grade) : null)
        : null,
      // Classroom enrollments — every classroom the student is a member
      // of, with subject + teacher. Powers the secretary's student-detail
      // "Classrooms" section.
      row.studentProfile
        ? this.prisma.classroomMember.findMany({
            where: { studentId: row.id },
            select: {
              classroom: {
                select: {
                  id: true,
                  name: true,
                  subject: true,
                  teacher: { select: { id: true, name: true } },
                },
              },
            },
          }).then((rows) =>
            rows
              .map((r) => r.classroom)
              .filter((c) => c != null)
              .map((c: any) => ({
                id: c.id,
                name: c.name,
                subject: c.subject ?? null,
                teacherName: c.teacher?.name ?? null,
              })),
          )
        : [],
    ]);

    return {
      ok: true,
      user: {
        id: row.id,
        name: row.name,
        nameEn: (row as any).nameEn ?? row.name,
        nameAr: (row as any).nameAr ?? '',
        nameHe: (row as any).nameHe ?? '',
        nameFr: (row as any).nameFr ?? '',
        nameRu: (row as any).nameRu ?? '',
        displayName: (row as any).displayName ?? null,
        legalName: (row as any).legalName ?? null,
        email: row.email,
        username: (row as any).username ?? null,
        phone: (row as any).phone ?? null,
        status: row.status,
        roles: row.roles.map((r) => r.role),
        grade: (row.studentProfile as any)?.grade ?? null,
        cohort: row.studentProfile?.cohort ?? null,
        cohorts: row.studentProfile?.cohorts.map((c) => c.cohort) ?? [],
        classrooms,
        attendanceRate,
        gradeAvg,
      },
    };
  }

  async createUser(user: any, dto: any) {
    this.requireAdminOrSecretary(user);
    const roles: string[] = Array.isArray(user?.roles) ? user.roles : [];
    const isSecretary = roles.includes('SECRETARY') && !roles.includes('ADMIN');
    if (isSecretary) throw new ForbiddenException('Secretaries cannot create user accounts');

    const schoolId = (user as any)?.schoolId;
    if (!schoolId) throw new BadRequestException('No school associated with this account');

    // Multi-lang names
    const nameEn = String(dto?.nameEn ?? dto?.name ?? '').trim();
    const nameAr = String(dto?.nameAr ?? '').trim() || undefined;
    const nameHe = String(dto?.nameHe ?? '').trim() || undefined;
    const nameFr = String(dto?.nameFr ?? '').trim() || undefined;
    const nameRu = String(dto?.nameRu ?? '').trim() || undefined;
    const name = nameEn || String(dto?.name ?? '').trim();
    // Optional friendly name shown in drawer/profile headers. When blank,
    // clients fall back to the localized name for the user's preferred
    // language — NEVER the email prefix.
    const displayName = String(dto?.displayName ?? '').trim() || undefined;
    // Legal/full name — separate from display name so admins can keep a
    // formal record alongside what's shown to other students.
    const legalName = String(dto?.legalName ?? '').trim() || undefined;
    const rawEmail = String(dto?.email ?? '').trim().toLowerCase() || undefined;
    const rawUsername = String(dto?.username ?? '').trim().toLowerCase() || undefined;
    // Optional admin-supplied password. When omitted we auto-generate one
    // (existing behavior). When provided, validate basic strength so we
    // don't store something weaker than the floor for self-service changes.
    const explicitPassword = typeof dto?.password === 'string' ? String(dto.password) : '';
    // E.164 enforcement matches verify flow: leading '+' + digits. Empty
    // string → undefined (skipped). Stored as-is so SMS sends work.
    const rawPhone = String(dto?.phone ?? '').trim().replace(/\s+/g, '') || undefined;
    if (rawPhone && !rawPhone.startsWith('+')) {
      throw new BadRequestException('Phone must be in E.164 format (e.g. +972525488441)');
    }
    const role = String(dto?.role ?? 'STUDENT').toUpperCase();
    const grade = dto?.grade ? Number(dto.grade) : undefined;

    if (!name) throw new BadRequestException('At least an English name is required');
    // Username is mandatory across the board now — it's the universal login
    // identifier. Email stays optional (some students don't have one yet).
    if (!rawUsername) throw new BadRequestException('Username is required');
    if (rawEmail && !rawEmail.includes('@')) throw new BadRequestException('Email must be a valid email address');
    if (explicitPassword && explicitPassword.length < 8) {
      throw new BadRequestException('Password must be at least 8 characters');
    }
    if (!['STUDENT', 'TEACHER', 'ADMIN', 'PARENT', 'SECRETARY'].includes(role))
      throw new BadRequestException('invalid role');

    // Username is required (validated above) — verify global uniqueness.
    const username = rawUsername!;
    const existingUsername = await this.prisma.user.findFirst({ where: { username } });
    if (existingUsername) throw new HttpException('Username already in use', HttpStatus.CONFLICT);

    if (rawEmail) {
      const existingEmail = await this.prisma.user.findFirst({ where: { email: rawEmail } });
      if (existingEmail) throw new HttpException('Email already in use', HttpStatus.CONFLICT);
    }

    // Either honor the admin's typed password or fall back to an
    // auto-generated one. The dialog still shows the password back so the
    // admin can hand it off — whether they chose it or we generated it.
    const tempPassword = explicitPassword || `Classmate${randomDigits(6)}!`;
    const hash = await bcrypt.hash(tempPassword, 10);

    const newUser = await this.prisma.user.create({
      data: {
        name,
        nameEn: nameEn || undefined,
        ...(nameAr ? { nameAr } : {}),
        ...(nameHe ? { nameHe } : {}),
        ...(nameFr ? { nameFr } : {}),
        ...(nameRu ? { nameRu } : {}),
        ...(displayName ? { displayName } : {}),
        ...(legalName ? { legalName } : {}),
        ...(rawEmail ? { email: rawEmail } : {}),
        ...(rawPhone ? { phone: rawPhone } : {}),
        username,
        password: hash,
        plainPassword: tempPassword,
        schoolId,
        status: 'ACTIVE',
        roles: { create: [{ role: role as any }] },
      } as any,
      select: { id: true, name: true, email: true, status: true, roles: { select: { role: true } } },
    });

    if (role === 'STUDENT') {
      await this.prisma.studentProfile.create({
        data: {
          userId: newUser.id,
          englishLevel: 5,
          mathLevel: 5,
          ...(grade ? { grade } : {}),
        } as any,
      });
    }

    return {
      ok: true,
      user: { id: newUser.id, name: newUser.name, email: (newUser as any).email, username: (newUser as any).username, roles: (newUser as any).roles.map((r: any) => r.role) },
      tempPassword,
      username,
    };
  }

  async updateUser(user: any, id: string, dto: any) {
    this.requireAdminOrSecretary(user);
    const schoolId = (user as any)?.schoolId;

    const target = await this.prisma.user.findFirst({
      where: { id, ...(schoolId ? { schoolId } : {}) },
      select: { id: true },
    });
    if (!target) throw new NotFoundException('User not found');

    const data: any = {};
    if (dto?.name !== undefined || dto?.nameEn !== undefined) {
      const n = String(dto?.nameEn ?? dto?.name ?? '').trim();
      if (n) { data.name = n; data.nameEn = n; }
    }
    if (dto?.nameAr !== undefined) data.nameAr = String(dto.nameAr).trim() || null;
    if (dto?.nameHe !== undefined) data.nameHe = String(dto.nameHe).trim() || null;
    if (dto?.nameFr !== undefined) data.nameFr = String(dto.nameFr).trim() || null;
    if (dto?.nameRu !== undefined) data.nameRu = String(dto.nameRu).trim() || null;
    if (dto?.displayName !== undefined) data.displayName = String(dto.displayName).trim() || null;
    if (dto?.legalName !== undefined) data.legalName = String(dto.legalName).trim() || null;
    if (dto?.email !== undefined) {
      const em = String(dto.email).trim().toLowerCase() || null;
      if (em) {
        // Global uniqueness — emails sign you in regardless of school, so
        // two users sharing one email would break login + reset flows.
        const conflict = await this.prisma.user.findFirst({ where: { email: em } });
        if (conflict && conflict.id !== id) throw new HttpException('Email already in use', HttpStatus.CONFLICT);
      }
      data.email = em;
    }
    if (dto?.username !== undefined) {
      const un = String(dto.username).trim().toLowerCase() || null;
      if (un) {
        const conflict = await this.prisma.user.findFirst({ where: { username: un } });
        if (conflict && conflict.id !== id) throw new HttpException('Username already in use', HttpStatus.CONFLICT);
      }
      data.username = un;
    }
    if (dto?.phone !== undefined) {
      // Normalize: trim, strip whitespace; empty string → null. Keep leading
      // '+' for E.164 numbers (Twilio requires that format for SMS sends).
      const raw = String(dto.phone).trim().replace(/\s+/g, '');
      data.phone = raw.length > 0 ? raw : null;
    }

    await this.prisma.user.update({ where: { id }, data });

    if (dto?.role !== undefined) {
      const newRole = String(dto.role).toUpperCase();
      await this.prisma.userRole.deleteMany({ where: { userId: id } });
      await this.prisma.userRole.create({ data: { userId: id, role: newRole as any } });
    }

    // Update student grade if provided
    if (dto?.grade !== undefined) {
      const g = dto.grade !== null ? Number(dto.grade) : null;
      await this.prisma.studentProfile.updateMany({
        where: { userId: id },
        data: { grade: g } as any,
      });
    }

    const updated = await this.prisma.user.findUnique({
      where: { id },
      select: { id: true, name: true, nameEn: true, nameAr: true, nameHe: true, nameFr: true, nameRu: true, email: true, username: true, status: true, roles: { select: { role: true } } },
    }) as any;
    return { ok: true, user: { ...updated, roles: updated.roles.map((r: any) => r.role) } };
  }

  async getUserChildren(user: any, userId: string) {
    this.requireAdminOrSecretary(user);
    const links = await this.prisma.parentChild.findMany({
      where: { parentId: userId },
      include: {
        child: { select: { id: true, name: true, nameEn: true, email: true, username: true } },
      },
    });
    return { ok: true, children: links.map((l) => ({ linkId: `${l.parentId}_${l.childId}`, child: l.child })) };
  }

  async unlinkChild(user: any, parentId: string, childId: string) {
    this.requireAdminOrSecretary(user);
    await this.prisma.parentChild.deleteMany({ where: { parentId, childId } });
    return { ok: true };
  }

  async deleteUser(user: any, id: string) {
    const roles: string[] = Array.isArray(user?.roles) ? user.roles : [];
    if (!roles.includes('ADMIN')) throw new ForbiddenException('Only admins can delete users');
    const schoolId = (user as any)?.schoolId;

    const target = await this.prisma.user.findFirst({
      where: { id, ...(schoolId ? { schoolId } : {}) },
      select: { id: true },
    });
    if (!target) throw new NotFoundException('User not found');

    await this.prisma.user.delete({ where: { id } });
    return { ok: true };
  }

  /**
   * Admin directly sets a user's password to a value they type in. Replaces
   * the old "reset to random temp password" flow — admins kept asking why
   * they had to copy a temp password back to the user instead of just typing
   * one. School isolation is preserved.
   */
  async setUserPassword(user: any, id: string, dto: { newPassword?: string }) {
    const roles: string[] = Array.isArray(user?.roles) ? user.roles : [];
    if (!roles.includes('ADMIN')) throw new ForbiddenException('Only admins can change passwords');
    const schoolId = (user as any)?.schoolId;

    const newPassword = String(dto?.newPassword ?? '');
    if (!newPassword || newPassword.length < 8) {
      throw new BadRequestException('Password must be at least 8 characters.');
    }

    const target = await this.prisma.user.findFirst({
      where: { id, ...(schoolId ? { schoolId } : {}) },
      select: { id: true, email: true },
    });
    if (!target) throw new NotFoundException('User not found');

    const hash = await bcrypt.hash(newPassword, 10);
    await this.prisma.user.update({ where: { id }, data: { password: hash, plainPassword: newPassword } });

    // Invalidate any pending password-reset tokens for this user — the admin
    // just set the password, so old reset links shouldn't work anymore.
    await this.prisma.passwordResetToken.updateMany({
      where: { userId: id, usedAt: null },
      data: { usedAt: new Date() },
    });

    // Notify the user that an admin changed their password, with a one-click
    // link to set their own. Fire-and-forget — never let a notification
    // failure block the password change.
    const adminName = await this.lookupAdminDisplayName(user);
    void this.passwordReset
      .notifyPasswordChanged({ targetUserId: id, byAdminName: adminName })
      .catch(() => undefined);

    return { ok: true, email: target.email };
  }

  /** Pending password-change requests for THIS admin to approve. */
  async listPasswordRequests(adminId: string) {
    if (!adminId) throw new BadRequestException('Not authenticated');
    return this.passwordReset.listPendingForAdmin(adminId);
  }

  async approvePasswordRequest(adminId: string, requestId: string) {
    if (!adminId) throw new BadRequestException('Not authenticated');
    await this.passwordReset.approveChangeRequest(adminId, requestId);
  }

  async rejectPasswordRequest(adminId: string, requestId: string) {
    if (!adminId) throw new BadRequestException('Not authenticated');
    await this.passwordReset.rejectChangeRequest(adminId, requestId);
  }

  /** Best-effort display name for the admin who initiated an action. */
  private async lookupAdminDisplayName(user: any): Promise<string> {
    const fromJwt = String(user?.name ?? user?.email ?? '').trim();
    if (fromJwt) return fromJwt;
    const adminId = user?.sub ?? user?.id;
    if (!adminId) return 'an administrator';
    try {
      const row = await this.prisma.user.findUnique({
        where: { id: adminId },
        select: { nameEn: true, name: true, email: true } as any,
      }) as any;
      return (row?.nameEn || row?.name || row?.email || 'an administrator').toString();
    } catch {
      return 'an administrator';
    }
  }

  // ── Parent Links ──────────────────────────────────────────────────────────────

  async linkParent(user: any, dto: { parentId: string; studentId: string }) {
    this.requireAdminOrSecretary(user);
    if (!dto?.parentId || !dto?.studentId) throw new BadRequestException('parentId and studentId are required');
    // School isolation: both parent and student must be in the admin's school
    await Promise.all([
      this.assertUserInSchool(user, dto.parentId),
      this.assertUserInSchool(user, dto.studentId),
    ]);

    try {
      const link = await this.prisma.parentChild.create({
        data: { parentId: dto.parentId, childId: dto.studentId, status: 'APPROVED' },
      });
      return { ok: true, link };
    } catch (e: any) {
      if (e?.code === 'P2002') throw new HttpException('Link already exists', HttpStatus.CONFLICT);
      throw e;
    }
  }

  async unlinkParent(user: any, id: string) {
    this.requireAdminOrSecretary(user);
    await this.prisma.parentChild.delete({ where: { id } });
    return { ok: true };
  }

  // ── Cohort Management ─────────────────────────────────────────────────────────

  async listCohorts(user: any) {
    this.requireAdminOrSecretary(user);
    const schoolId = (user as any)?.schoolId ?? null;
    // Include cohorts that either belong to this school OR have members from this school
    const cohorts = await this.prisma.cohort.findMany({
      where: schoolId
        ? { OR: [{ schoolId } as any, { schoolId: null }] }
        : {},
      select: {
        id: true,
        name: true,
        grade: true,
        grades: true,
        // Both sources of membership — pull the ids so we can union per cohort.
        studentLinks: { select: { studentId: true } },
        students: { select: { userId: true } },
      },
      orderBy: [{ grade: 'asc' }, { name: 'asc' }],
    });
    return {
      ok: true,
      cohorts: cohorts.map((c: any) => {
        // Students belong to a cohort via two mechanisms today:
        //   1. StudentCohort join (multi-cohort, new schema)
        //   2. StudentProfile.cohortId scalar (legacy single-cohort).
        // The _count helper only sees #1, so historical rosters showed 0
        // until they were re-added.  Union both, dedupe, and report the
        // unique-student total.
        const ids = new Set<string>([
          ...(c.studentLinks ?? []).map((l: any) => l.studentId),
          ...(c.students ?? []).map((s: any) => s.userId),
        ]);
        return {
          id: c.id,
          name: c.name,
          grade: c.grade,
          grades: c.grades?.length ? c.grades : [c.grade],
          studentCount: ids.size,
        };
      }),
    };
  }

  async updateCohort(user: any, id: string, dto: any) {
    this.requireAdminOrSecretary(user);
    const data: any = {};
    if (dto?.name !== undefined) data.name = String(dto.name).trim();

    // Accept either grades[] or single grade. Keep both columns in sync so
    // every legacy reader (announcements, schedule, teacher.service, …) keeps
    // seeing a usable primary grade.
    if (dto?.grades !== undefined || dto?.grade !== undefined) {
      const grades = normalizeGrades(dto?.grades, dto?.grade);
      if (!grades.length) throw new BadRequestException('grade or grades[] required');
      data.grade = grades[0];
      data.grades = grades;
    }

    const row = await this.prisma.cohort.update({ where: { id }, data });
    return { ok: true, cohort: row };
  }

  async deleteCohort(user: any, id: string) {
    const roles: string[] = Array.isArray(user?.roles) ? user.roles : [];
    if (!roles.includes('ADMIN')) throw new ForbiddenException('Only admins can delete cohorts');

    await this.prisma.studentCohort.deleteMany({ where: { cohortId: id } });
    await this.prisma.cohort.delete({ where: { id } });
    return { ok: true };
  }

  async addStudentsToCohort(user: any, cohortId: string, dto: { studentIds: string[] }) {
    this.requireAdminOrSecretary(user);
    if (!Array.isArray(dto?.studentIds) || !dto.studentIds.length)
      throw new BadRequestException('studentIds[] is required');

    // School isolation: only add students from the same school
    const schoolStudentIds = await this.filterUsersToSchool(user, dto.studentIds);
    if (!schoolStudentIds.length) throw new ForbiddenException('None of the specified students belong to your school');

    await this.prisma.studentCohort.createMany({
      data: schoolStudentIds.map((sid) => ({ studentId: sid, cohortId })),
      skipDuplicates: true,
    });
    return { ok: true, added: schoolStudentIds.length };
  }

  async removeStudentFromCohort(user: any, cohortId: string, studentId: string) {
    this.requireAdminOrSecretary(user);
    await this.assertUserInSchool(user, studentId);
    await this.prisma.studentCohort.delete({
      where: { studentId_cohortId: { studentId, cohortId } },
    });
    return { ok: true };
  }

  async getCohortRoster(user: any, cohortId: string) {
    this.requireAdminOrSecretary(user);
    const links = await this.prisma.studentCohort.findMany({
      where: { cohortId },
      select: {
        student: { select: { userId: true, user: { select: { id: true, name: true, email: true } } } },
      },
      orderBy: { student: { user: { name: 'asc' } } },
    });
    return {
      ok: true,
      students: links.map((l) => ({
        id: l.student.user.id,
        name: l.student.user.name,
        email: l.student.user.email,
      })),
    };
  }

  // ── School Settings (scoped to admin's own school) ────────────────────────────

  async getMySchool(user: any) {
    this.requireAdminOrSecretary(user);
    const schoolId = (user as any)?.schoolId;
    if (!schoolId) return { ok: true, school: null }; // no school yet — first-time setup
    const row = await this.prisma.school.findUnique({ where: { id: schoolId } });
    return { ok: true, school: row ?? null };
  }

  async updateMySchool(user: any, dto: any) {
    this.requireAdminOrSecretary(user);
    const schoolId = (user as any)?.schoolId;
    if (!schoolId) throw new BadRequestException('No school associated with this account');

    const data: any = {};
    if (dto?.name !== undefined) data.name = String(dto.name).trim();
    if (dto?.logoUrl !== undefined) data.logoUrl = dto.logoUrl ? String(dto.logoUrl).trim() : null;
    if (dto?.minGrade !== undefined || dto?.maxGrade !== undefined) {
      const current = await this.prisma.school.findUnique({ where: { id: schoolId }, select: { minGrade: true, maxGrade: true } as any }) as any;
      const min = dto?.minGrade !== undefined ? Number(dto.minGrade) : current?.minGrade ?? 5;
      const max = dto?.maxGrade !== undefined ? Number(dto.maxGrade) : current?.maxGrade ?? 12;
      if (!Number.isFinite(min) || !Number.isFinite(max) || min < 1 || max > 20 || min > max) {
        throw new BadRequestException(`Invalid grade range ${min}–${max}. Must be 1..20 and min ≤ max.`);
      }
      data.minGrade = min;
      data.maxGrade = max;
    }

    const row = await this.prisma.school.update({ where: { id: schoolId }, data });
    return { ok: true, school: row };
  }

  // ── Analytics ─────────────────────────────────────────────────────────────────

  async getAnalyticsOverview(user: any) {
    this.requireAdminOrSecretary(user);
    const schoolId = (user as any)?.schoolId;
    if (!schoolId) throw new BadRequestException('No school associated with this account');

    const [students, teachers, cohorts, classrooms, school, subjectsRow, bellRow] = await Promise.all([
      this.prisma.user.count({ where: { schoolId, roles: { some: { role: 'STUDENT' } } } }),
      this.prisma.user.count({ where: { schoolId, roles: { some: { role: 'TEACHER' } } } }),
      this.prisma.cohort.count({ where: { OR: [{ schoolId } as any, { schoolId: null }] } }),
      this.prisma.classroom.count({ where: { schoolId } }),
      this.prisma.school.findUnique({ where: { id: schoolId }, select: { name: true, logoUrl: true } }),
      // First grade with any subject defined → cheap "do they have any?" probe.
      this.prisma.schoolGradeSubjectDefault.findFirst({ where: { schoolId }, select: { id: true } }),
      this.prisma.schoolPeriodDefault.findFirst({ where: { schoolId }, select: { id: true } }),
    ]);

    const today = new Date();
    today.setUTCHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setUTCDate(tomorrow.getUTCDate() + 1);

    const todaySessions = await this.prisma.attendanceSession.count({
      where: {
        date: { gte: today, lt: tomorrow },
        cohort: { OR: [{ schoolId } as any, { schoolId: null }] },
      },
    });

    return {
      ok: true,
      students,
      teachers,
      cohorts,
      classrooms,
      todaySessions,
      // Setup-progress signals used by the dashboard "School Setup" widget.
      schoolNameSet: !!(school?.name && school.name.trim().length > 0),
      schoolLogoSet: !!(school?.logoUrl && school.logoUrl.trim().length > 0),
      subjectsConfigured: !!subjectsRow,
      bellScheduleConfigured: !!bellRow,
    };
  }

  async getAnalyticsAttendance(user: any) {
    this.requireAdminOrSecretary(user);
    const schoolId = (user as any)?.schoolId ?? null;

    const since = new Date();
    since.setUTCDate(since.getUTCDate() - 30);

    const cohorts = await this.prisma.cohort.findMany({
      where: schoolId ? { OR: [{ schoolId } as any, { schoolId: null }] } : {},
      select: { id: true, name: true, grade: true, grades: true } as any,
      orderBy: [{ grade: 'asc' }, { name: 'asc' }],
    }) as any[];

    const results = await Promise.all(
      cohorts.map(async (c) => {
        const [present, total] = await Promise.all([
          this.prisma.attendanceRecord.count({
            where: {
              status: 'PRESENT',
              session: { cohortId: c.id, date: { gte: since } },
            },
          }),
          this.prisma.attendanceRecord.count({
            where: { session: { cohortId: c.id, date: { gte: since } } },
          }),
        ]);
        return {
          cohortId: c.id,
          cohortName: c.name,
          grade: c.grade,
          grades: Array.isArray(c.grades) && c.grades.length ? c.grades : [c.grade],
          rate: total > 0 ? Math.round((present / total) * 100) : null,
          total,
        };
      }),
    );

    return { ok: true, cohorts: results };
  }

  async getAnalyticsGrades(user: any) {
    this.requireAdminOrSecretary(user);
    const schoolId = (user as any)?.schoolId ?? null;

    const cohorts = await this.prisma.cohort.findMany({
      where: schoolId ? { OR: [{ schoolId } as any, { schoolId: null }] } : {},
      select: { id: true, name: true, grade: true, grades: true } as any,
      orderBy: [{ grade: 'asc' }, { name: 'asc' }],
    }) as any[];

    const results = await Promise.all(
      cohorts.map(async (c) => {
        const avg = await this.prisma.gradeRecord.aggregate({
          where: { assessment: { cohortId: c.id } },
          _avg: { grade: true },
        });
        return {
          cohortId: c.id,
          cohortName: c.name,
          grade: c.grade,
          grades: Array.isArray(c.grades) && c.grades.length ? c.grades : [c.grade],
          avgGrade: avg._avg.grade ? Math.round(avg._avg.grade) : null,
        };
      }),
    );

    return { ok: true, cohorts: results };
  }

  // ── Message reports ─────────────────────────────────────────────────────

  /// Lists user-filed reports on chat messages. Default returns OPEN reports
  /// (the triage queue). Pass status=RESOLVED or DISMISSED for history.
  /// Scoped to the admin's own school — admin can only see reports where
  /// either the reporter or the reported message's sender is in their school.
  async listMessageReports(adminUser: any, status?: string) {
    const schoolId = adminUser?.schoolId ?? null;
    const where: any = {};
    const s = (status ?? 'OPEN').toUpperCase();
    if (s === 'OPEN' || s === 'RESOLVED' || s === 'DISMISSED') {
      where.status = s;
    }

    // School scoping: report's reporter OR message sender must belong to this school.
    if (schoolId) {
      where.OR = [
        { reporter: { schoolId } },
        { message: { sender: { schoolId } } },
      ];
    }

    const rows = await this.prisma.dmMessageReport.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      take: 200,
      include: {
        reporter: { select: { id: true, name: true, email: true } },
        message: {
          select: {
            id: true,
            text: true,
            mediaUrl: true,
            createdAt: true,
            threadId: true,
            sender: { select: { id: true, name: true, email: true } },
          },
        },
      },
    });

    return {
      ok: true,
      items: rows.map((r) => ({
        id: r.id,
        status: r.status,
        reason: r.reason,
        createdAt: r.createdAt.toISOString(),
        resolvedAt: r.resolvedAt?.toISOString() ?? null,
        reporter: r.reporter,
        message: {
          id: r.message.id,
          threadId: r.message.threadId,
          text: r.message.text,
          mediaUrl: r.message.mediaUrl,
          createdAt: r.message.createdAt.toISOString(),
          sender: r.message.sender,
        },
      })),
    };
  }

  /// Marks a report as RESOLVED or DISMISSED. Idempotent.
  async resolveMessageReport(
    adminUser: any,
    reportId: string,
    next: 'RESOLVED' | 'DISMISSED',
  ) {
    const id = String(reportId ?? '').trim();
    if (!id) throw new BadRequestException('reportId is required');

    const adminId = adminUser?.sub ?? adminUser?.id;
    const existing = await this.prisma.dmMessageReport.findUnique({
      where: { id },
      select: { id: true },
    });
    if (!existing) throw new NotFoundException('Report not found');

    await this.prisma.dmMessageReport.update({
      where: { id },
      data: {
        status: next,
        resolvedAt: new Date(),
        resolvedBy: adminId ?? null,
      },
    });
    return { ok: true };
  }
}
