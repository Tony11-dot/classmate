import {
  BadRequestException,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';

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
    if (!user?.roles?.includes('ADMIN'))
      throw new ForbiddenException('Admin only');
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
    this.ensureAdmin(user);
    if (!body?.cohortId) throw new BadRequestException('cohortId is required');

    const cohort = await this.prisma.cohort.findUnique({
      where: { id: body.cohortId },
    });
    if (!cohort) throw new BadRequestException('Invalid cohortId');

    const len =
      body.length && body.length >= 4 && body.length <= 10 ? body.length : 6;
    const code = randomDigits(len);
    const codeHash = await bcrypt.hash(code, 10);

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
        codeHash,
        expiresAt: expiresAt ?? undefined,
      },
    });

    return { cohortId: body.cohortId, code, expiresAt };
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
}
