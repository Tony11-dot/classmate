import { BadRequestException, ForbiddenException, Injectable, HttpException, HttpStatus } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
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

    return this.prisma.cohort.create({
      data: { name: body.name, grade: body.grade },
    });
  }

  async generateJoinCode(
    user: any,
    body: { cohortId: string; expiresInHours?: number; length?: number },
  ) {
    // allow TEACHER for join-code (e2e expects this)

    if (!hasAnyRole(user, ['ADMIN', 'TEACHER'])) throw new ForbiddenException('Admin or Teacher only');
if (!body?.cohortId) throw new BadRequestException('cohortId is required');
    // TEACHER cohort-scope: must own a course in this cohort
    const roles: string[] = Array.isArray((user as any)?.roles) ? (user as any).roles : [];
    const teacherId = (user as any)?.sub ?? (user as any)?.id;

    if (roles.includes('TEACHER') && !roles.includes('ADMIN')) {
      const owns = await this.prisma.course.findFirst({
        where: { teacherId, cohortId: body.cohortId },
        select: { id: true },
      });
      if (!owns) throw new ForbiddenException('Teacher not authorized for this cohort');
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

  async getCohortSchedule(user: any, cohortId: string) {
    this.ensureAdmin(user);
    if (!cohortId) throw new BadRequestException('cohortId is required');

    return this.prisma.scheduleSlot.findMany({
      where: { cohortId },
      orderBy: [{ dayOfWeek: 'asc' }, { period: 'asc' }],
      include: { course: true },
    });
  }

  async setScheduleSlot(
    user: any,
    body: {
      cohortId: string;
      dayOfWeek: number;
      period: number;
      courseId?: string | null;
    },
  ) {
    this.ensureAdmin(user);

    const { cohortId, dayOfWeek, period, courseId } = body ?? ({} as any);
    if (!cohortId) throw new BadRequestException('cohortId is required');
    if (dayOfWeek === undefined || dayOfWeek < 0 || dayOfWeek > 6)
      throw new BadRequestException('dayOfWeek must be 0..6 (Sunday=0)');
    if (!Number.isInteger(period) || period < 1 || period > 20)
      throw new BadRequestException('period must be 1..20');

    if (courseId) {
      const course = await this.prisma.course.findUnique({
        where: { id: courseId },
      });
      if (!course) throw new BadRequestException('Invalid courseId');
    }

    return this.prisma.scheduleSlot.upsert({
      where: { cohortId_dayOfWeek_period: { cohortId, dayOfWeek, period } },
      update: { courseId: courseId ?? null },
      create: { cohortId, dayOfWeek, period, courseId: courseId ?? null },
    });
  }

  async setScheduleBulk(
    user: any,
    body: {
      cohortId: string;
      slots: { dayOfWeek: number; period: number; courseId?: string | null }[];
    },
  ) {
    this.ensureAdmin(user);

    const { cohortId, slots } = body ?? ({} as any);
    if (!cohortId) throw new BadRequestException('cohortId is required');
    if (!Array.isArray(slots) || slots.length === 0)
      throw new BadRequestException('slots[] is required');

    for (const s of slots) {
      if (s.dayOfWeek === undefined || s.dayOfWeek < 0 || s.dayOfWeek > 6)
        throw new BadRequestException('dayOfWeek must be 0..6');
      if (!Number.isInteger(s.period) || s.period < 1 || s.period > 20)
        throw new BadRequestException('period must be 1..20');
    }

    let count = 0;
    for (const s of slots) {
      await this.prisma.scheduleSlot.upsert({
        where: {
          cohortId_dayOfWeek_period: {
            cohortId,
            dayOfWeek: s.dayOfWeek,
            period: s.period,
          },
        },
        update: { courseId: s.courseId ?? null },
        create: {
          cohortId,
          dayOfWeek: s.dayOfWeek,
          period: s.period,
          courseId: s.courseId ?? null,
        },
      });
      count++;
    }

    return { ok: true, count };
  }

  async setScheduleOverride(
    user: any,
    body: {
      cohortId: string;
      date: string;
      period: number;
      courseId?: string | null;
    },
  ) {
    this.ensureAdmin(user);

    const { cohortId, date, period, courseId } = body ?? ({} as any);
    if (!cohortId) throw new BadRequestException('cohortId is required');
    if (!date) throw new BadRequestException('date is required (YYYY-MM-DD)');
    if (!Number.isInteger(period) || period < 1 || period > 20)
      throw new BadRequestException('period must be 1..20');

    const dt = new Date(`${date}T00:00:00.000Z`);
    if (Number.isNaN(dt.getTime()))
      throw new BadRequestException('Invalid date format');

    if (courseId) {
      const course = await this.prisma.course.findUnique({
        where: { id: courseId },
      });
      if (!course) throw new BadRequestException('Invalid courseId');
    }

    return this.prisma.scheduleOverride.upsert({
      where: { cohortId_date_period: { cohortId, date: dt, period } },
      update: { courseId: courseId ?? null },
      create: { cohortId, date: dt, period, courseId: courseId ?? null },
    });
  }

  async upsertScheduleTemplate(body: {
    cohortId: string;
    slots: { dayOfWeek: number; period: number; courseId?: string | null }[];
  }) {
    const { cohortId, slots } = body;

    if (!cohortId) return { ok: false, error: 'cohortId is required' };
    if (!Array.isArray(slots))
      return { ok: false, error: 'slots must be an array' };

    const cleaned = slots.map((s) => ({
      cohortId,
      dayOfWeek: Number(s.dayOfWeek),
      period: Number(s.period),
      courseId: s.courseId ?? null,
    }));

    // upsert each slot (simple + reliable MVP)
    for (const s of cleaned) {
      await this.prisma.scheduleSlot.upsert({
        where: {
          cohortId_dayOfWeek_period: {
            cohortId: s.cohortId,
            dayOfWeek: s.dayOfWeek,
            period: s.period,
          },
        },
        create: {
          cohortId: s.cohortId,
          dayOfWeek: s.dayOfWeek,
          period: s.period,
          courseId: s.courseId,
        },
        update: { courseId: s.courseId },
      });
    }

    return { ok: true, upserted: cleaned.length };
  }

  // ---- Courses ----

  async listCourses(user: any, query: { cohortId?: string }) {
    this.ensureAdmin(user);

    const cohortId = query?.cohortId || undefined;

    const rows = await this.prisma.course.findMany({
      where: cohortId ? { cohortId } : {},
      orderBy: [{ subject: 'asc' }, { name: 'asc' }],
      include: {
        cohort: true,
        teacher: { select: { id: true, email: true, name: true } },
      },
      take: 500,
    });

    return {
      ok: true,
      courses: rows.map((c) => ({
        id: c.id,
        name: c.name,
        subject: c.subject,
        teacherId: c.teacherId,
        cohortId: c.cohortId,
        groupTag: c.groupTag ?? null,
        cohort: c.cohort
          ? {
              id: c.cohort.id,
              name: c.cohort.name,
              grade: (c.cohort as any).grade,
            }
          : null,
        teacher: c.teacher
          ? { id: c.teacher.id, email: c.teacher.email, name: c.teacher.name }
          : null,
      })),
    };
  }

  async createCourse(
    user: any,
    body: {
      name: string;
      subject: string;
      teacherId?: string | null;
      cohortId?: string | null;
      groupTag?: string | null;
    },
  ) {
    this.ensureAdmin(user);

    const name = (body?.name ?? '').trim();
    const subject = (body?.subject ?? '').trim();
    const teacherId = body?.teacherId ?? null;
    const cohortId = body?.cohortId ?? null;
    const groupTag = body?.groupTag ?? null;

    if (!name) throw new BadRequestException('name is required');
    if (!subject) throw new BadRequestException('subject is required');

    if (teacherId) {
      const t = await this.prisma.user.findUnique({ where: { id: teacherId } });
      if (!t) throw new BadRequestException('Invalid teacherId');
    }

    if (cohortId) {
      const c = await this.prisma.cohort.findUnique({
        where: { id: cohortId },
      });
      if (!c) throw new BadRequestException('Invalid cohortId');
    }

    const course = await this.prisma.course.create({
      data: {
        name,
        subject,
        teacherId,
        cohortId,
        groupTag,
      },
    });

    return { ok: true, course };
  }

  async updateCourse(
    user: any,
    id: string,
    body: {
      name?: string;
      subject?: string;
      teacherId?: string | null;
      cohortId?: string | null;
      groupTag?: string | null;
    },
  ) {
    this.ensureAdmin(user);
    if (!id) throw new BadRequestException('id is required');

    const exists = await this.prisma.course.findUnique({ where: { id } });
    if (!exists) throw new BadRequestException('Course not found');

    const data: any = {};

    if (body?.name !== undefined) {
      const v = body.name.trim();
      if (!v) throw new BadRequestException('name cannot be empty');
      data.name = v;
    }

    if (body?.subject !== undefined) {
      const v = body.subject.trim();
      if (!v) throw new BadRequestException('subject cannot be empty');
      data.subject = v;
    }

    if (body?.teacherId !== undefined) {
      if (body.teacherId) {
        const t = await this.prisma.user.findUnique({
          where: { id: body.teacherId },
        });
        if (!t) throw new BadRequestException('Invalid teacherId');
      }
      data.teacherId = body.teacherId;
    }

    if (body?.cohortId !== undefined) {
      if (body.cohortId) {
        const c = await this.prisma.cohort.findUnique({
          where: { id: body.cohortId },
        });
        if (!c) throw new BadRequestException('Invalid cohortId');
      }
      data.cohortId = body.cohortId;
    }

    if (body?.groupTag !== undefined) {
      data.groupTag = body.groupTag;
    }

    const course = await this.prisma.course.update({
      where: { id },
      data,
    });

    return { ok: true, course };
  }

  async deleteCourse(user: any, id: string) {
    this.ensureAdmin(user);
    if (!id) throw new BadRequestException('id is required');

    // will cascade where relations use onDelete; otherwise Prisma will throw and we surface it
    await this.prisma.course.delete({ where: { id } });
    return { ok: true };
  }

  // ---- Schedule admin helpers ----

  async clearScheduleTemplate(user: any, cohortId: string) {
    this.ensureAdmin(user);
    if (!cohortId) throw new BadRequestException('cohortId is required');

    const res = await this.prisma.scheduleSlot.deleteMany({
      where: { cohortId },
    });
    return { ok: true, deleted: res.count };
  }

  async clearSchedulePeriodAcrossWeek(
    user: any,
    body: { cohortId: string; period: number },
  ) {
    this.ensureAdmin(user);

    const cohortId = body?.cohortId;
    const period = Number(body?.period);

    if (!cohortId) throw new BadRequestException('cohortId is required');
    if (!Number.isInteger(period) || period < 1 || period > 20)
      throw new BadRequestException('period must be 1..20');

    const res = await this.prisma.scheduleSlot.updateMany({
      where: { cohortId, period },
      data: { courseId: null },
    });

    return { ok: true, updated: res.count };
  }

  async listScheduleOverrides(
    user: any,
    query: { cohortId: string; from: string; to: string },
  ) {
    this.ensureAdmin(user);

    const cohortId = query?.cohortId;
    const from = query?.from;
    const to = query?.to;

    if (!cohortId) throw new BadRequestException('cohortId is required');
    if (!from) throw new BadRequestException('from is required (YYYY-MM-DD)');
    if (!to) throw new BadRequestException('to is required (YYYY-MM-DD)');

    const fromDt = new Date(`${from}T00:00:00.000Z`);
    const toDt = new Date(`${to}T00:00:00.000Z`);
    if (Number.isNaN(fromDt.getTime()) || Number.isNaN(toDt.getTime()))
      throw new BadRequestException('Invalid date format');

    // inclusive range: [from, to+1day)
    const end = new Date(toDt.getTime());
    end.setUTCDate(end.getUTCDate() + 1);

    const rows = await this.prisma.scheduleOverride.findMany({
      where: { cohortId, date: { gte: fromDt, lt: end } },
      orderBy: [{ date: 'asc' }, { period: 'asc' }],
      include: { course: true },
      take: 2000,
    });

    return {
      ok: true,
      overrides: rows.map((o) => ({
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
        courseId: o.courseId ?? null,
      })),
    };
  }

  async deleteScheduleOverride(
    user: any,
    body: { cohortId: string; date: string; period: number },
  ) {
    this.ensureAdmin(user);

    const cohortId = body?.cohortId;
    const date = body?.date;
    const period = Number(body?.period);

    if (!cohortId) throw new BadRequestException('cohortId is required');
    if (!date) throw new BadRequestException('date is required (YYYY-MM-DD)');
    if (!Number.isInteger(period) || period < 1 || period > 20)
      throw new BadRequestException('period must be 1..20');

    const dt = new Date(`${date}T00:00:00.000Z`);
    if (Number.isNaN(dt.getTime()))
      throw new BadRequestException('Invalid date format');

    await this.prisma.scheduleOverride.delete({
      where: { cohortId_date_period: { cohortId, date: dt, period } },
    });

    return { ok: true };
  }
}
