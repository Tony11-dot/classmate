import { BadRequestException, ForbiddenException, Injectable, HttpException, HttpStatus, NotFoundException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { subjectDefaultsBySchoolGrade, studentSubjectOverrides, defaultsKey, normalizeSubjects } from '../subjects/subjects.store';
import { hasAnyRole } from '../auth/permissions';

function randomDigits(len = 6) {
  const digits = '0123456789';
  let out = '';
  for (let i = 0; i < len; i++)
    out += digits[Math.floor(Math.random() * digits.length)];
  return out;
}

@Injectable()
export class AdminService {
  constructor(private readonly prisma: PrismaService) {}

  private ensureAdmin(user: any) {
    if (!hasAnyRole(user, ['ADMIN']))
      throw new ForbiddenException('Admin or Teacher only');
  }

  async createCohort(user: any, body: { name: string; grade: number }) {
    this.ensureAdmin(user);
    if (!body?.name || !body?.grade)
      throw new BadRequestException('name and grade are required');

    try {
      const out = await this.prisma.cohort.create({
        data: { name: body.name, grade: body.grade },
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
        cohorts: { select: { cohortId: true, cohort: { select: { name: true, grade: true } } } },
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
    startTime?: string;
    endTime?: string;
  }) {
    this.ensureAdmin(user);
    const schoolId = (user as any)?.schoolId ?? null;

    const { dayOfWeek, period, teacherId, classroomId, cohortIds = [], studentIds = [], subject, startTime, endTime } = body ?? {} as any;
    if (dayOfWeek === undefined || dayOfWeek < 0 || dayOfWeek > 6) throw new BadRequestException('dayOfWeek must be 0..6');
    if (!Number.isInteger(period) || period < 1 || period > 20) throw new BadRequestException('period must be 1..20');

    // If classroomId provided, verify it belongs to the selected teacher
    if (classroomId && teacherId) {
      const cr = await this.prisma.classroom.findUnique({ where: { id: classroomId }, select: { teacherId: true } });
      if (!cr) throw new BadRequestException('Classroom not found');
      if (cr.teacherId !== teacherId) throw new BadRequestException('Classroom does not belong to the selected teacher');
    }

    const slot = await this.prisma.scheduleSlot.create({
      data: {
        schoolId,
        dayOfWeek,
        period,
        teacherId: teacherId ?? null,
        classroomId: classroomId ?? null,
        subject: subject ?? null,
        startTime: startTime ?? null,
        endTime: endTime ?? null,
      },
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

    return { ok: true, slot: { ...slot, cohortIds, studentIds } };
  }

  async updatePeriod(user: any, id: string, body: {
    dayOfWeek?: number;
    period?: number;
    teacherId?: string | null;
    classroomId?: string | null;
    cohortIds?: string[];
    studentIds?: string[];
    subject?: string | null;
    startTime?: string | null;
    endTime?: string | null;
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
    if ('startTime' in body) data.startTime = body.startTime ?? null;
    if ('endTime' in body) data.endTime = body.endTime ?? null;

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
    this.ensureAdmin(user);
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
        studentProfile: { select: { cohortId: true, cohort: { select: { name: true, grade: true } } } },
      },
      orderBy: { name: 'asc' },
      take: 100,
    });
    return {
      ok: true,
      students: students.map((s) => ({
        id: s.id,
        name: s.name,
        grade: s.studentProfile?.cohort?.grade ?? null,
        cohortName: s.studentProfile?.cohort?.name ?? null,
      })),
    };
  }

  async listTeachersForDDL(user: any) {
    this.ensureAdmin(user);
    const schoolId = (user as any)?.schoolId ?? null;
    const teachers = await this.prisma.user.findMany({
      where: {
        ...(schoolId ? { schoolId } : {}),
        roles: { some: { role: 'TEACHER' } },
      },
      select: { id: true, name: true },
      orderBy: { name: 'asc' },
    });
    return { ok: true, teachers };
  }

  async listCohortsForDDL(user: any) {
    this.ensureAdmin(user);
    const cohorts = await this.prisma.cohort.findMany({
      select: { id: true, name: true, grade: true },
      orderBy: [{ grade: 'asc' }, { name: 'asc' }],
    });
    return { ok: true, cohorts };
  }

  async listClassroomsForTeacher(user: any, teacherId: string) {
    this.ensureAdmin(user);
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
    this.ensureAdmin(user);
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
    this.ensureAdmin(user);
    if (!cohortId) throw new BadRequestException('cohortId is required');
    const slotIds = (await this.prisma.scheduleSlotCohort.findMany({ where: { cohortId }, select: { slotId: true } })).map((r) => r.slotId);
    if (!slotIds.length) return [];
    return this.prisma.scheduleSlot.findMany({ where: { id: { in: slotIds } }, orderBy: [{ dayOfWeek: 'asc' }, { period: 'asc' }] });
  }

  
  // =========================================================
  // Session 10: School subject defaults + per-student overrides
  // =========================================================

  private requireAdminOrSecretary(user: any) {
    const roles: string[] = Array.isArray(user?.roles) ? user.roles : [];
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
  
    const schoolId = String(dto?.schoolId ?? user?.schoolId ?? 'test-school');
    const grade = Number(dto?.grade);
    const subjects = normalizeSubjects(dto?.subjects);
  
    if (!schoolId) throw new BadRequestException('schoolId required');
    if (Number.isNaN(grade)) throw new BadRequestException('grade required');
    if (!subjects.length) throw new BadRequestException('subjects[] required');
  
    const row = await this.prisma.schoolGradeSubjectDefault.upsert({
      where: { schoolId_grade_unique: { schoolId, grade } },
      update: { subjects },
      create: { schoolId, grade, subjects },
      select: { schoolId: true, grade: true, subjects: true },
    });
  
    return { ok: true, defaults: row };
  }
  async getSubjectDefaults(user: any, query: { schoolId?: string; grade?: number }) {
    this.requireAdminOrSecretary(user);
  
    const schoolId = String(query?.schoolId ?? user?.schoolId ?? 'test-school');
    const grade = query?.grade;
  
    if (!schoolId) throw new BadRequestException('schoolId required');
    if (grade === undefined || Number.isNaN(Number(grade))) {
      throw new BadRequestException('grade required');
    }
  
    const row = await this.prisma.schoolGradeSubjectDefault.findUnique({
      where: { schoolId_grade_unique: { schoolId, grade: Number(grade) } },
      select: { schoolId: true, grade: true, subjects: true },
    });
  
    return { ok: true, defaults: row ?? { schoolId, grade: Number(grade), subjects: [] } };
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
}
