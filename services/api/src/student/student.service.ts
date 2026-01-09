import {
  BadRequestException,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { ScheduleService } from '../schedule/schedule.service';

@Injectable()
export class StudentService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly schedule: ScheduleService,
  ) {}

  private ensureStudent(user: any) {
    if (!user?.roles?.includes('STUDENT'))
      throw new ForbiddenException('Student only');
  }

  async onboard(
    user: any,
    body: {
      cohortId: string;
      joinCode: string;
      displayName?: string;
      phone?: string;
      englishLevel: number;
      mathLevel: number;
    },
  ) {
    this.ensureStudent(user);

    if (!body?.cohortId) throw new BadRequestException('cohortId is required');
    if (!body?.joinCode) throw new BadRequestException('joinCode is required');

    const cohort = await this.prisma.cohort.findUnique({
      where: { id: body.cohortId },
    });
    if (!cohort) throw new BadRequestException('Invalid cohortId');

    const codes = await this.prisma.cohortJoinCode.findMany({
      where: { cohortId: body.cohortId },
      orderBy: { createdAt: 'desc' },
      take: 5,
    });

    const now = new Date();
    let ok = false;
    for (const c of codes) {
      if (c.expiresAt && c.expiresAt < now) continue;
      if (await bcrypt.compare(body.joinCode, c.codeHash)) {
        ok = true;
        break;
      }
    }
    if (!ok) throw new BadRequestException('Invalid join code');

    const studentId = user.sub ?? user.id;

    await this.prisma.studentProfile.upsert({
      where: { userId: studentId },
      update: {
        cohortId: body.cohortId,
        englishLevel: Math.round(Number(body.englishLevel)),
        mathLevel: Math.round(Number(body.mathLevel)),
      },
      create: {
        userId: studentId,
        cohortId: body.cohortId,
        englishLevel: Math.round(Number(body.englishLevel)),
        mathLevel: Math.round(Number(body.mathLevel)),
      },
    });

    return { ok: true };
  }

  async todaySchedule(user: any) {
    this.ensureStudent(user);
    const studentId = user.sub ?? user.id;
    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: studentId },
    });
    if (!sp) throw new BadRequestException('Student not onboarded');
    return this.schedule.getTodayForCohort(sp.cohortId);
  }

  async weekSchedule(user: any) {
    this.ensureStudent(user);
    const studentId = user.sub ?? user.id;
    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: studentId },
    });
    if (!sp) throw new BadRequestException('Student not onboarded');
    return this.schedule.getWeekForCohort(sp.cohortId);
  }

  async myGrades(user: any) {
    this.ensureStudent(user);
    const studentId = user.sub ?? user.id;

    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: studentId },
    });
    if (!sp) throw new BadRequestException('Student not onboarded');

    const rows = await this.prisma.gradeRecord.findMany({
      where: { studentId },
      orderBy: { id: 'desc' },
      include: {
        assessment: {
          include: {
            course: true,
          },
        },
      },
    });

    return {
      ok: true,
      grades: rows.map((r) => ({
        id: r.id,
        grade: r.grade,
        comment: r.comment,
        assessment: {
          id: r.assessment.id,
          title: (r.assessment as any).title,
          date: r.assessment.date,
        },
        course: {
          id: r.assessment.course.id,
          name: r.assessment.course.name,
          subject: r.assessment.course.subject,
        },
      })),
    };
  }

  async generateParentLinkCode(
    user: any,
    body: { expiresInHours?: number; length?: number },
  ) {
    this.ensureStudent(user);
    const childId = user.sub ?? user.id;

    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: childId },
    });
    if (!sp) throw new BadRequestException('Student not onboarded');

    const len =
      body?.length && body.length >= 4 && body.length <= 8
        ? Math.floor(body.length)
        : 6;
    const hours =
      body?.expiresInHours && body.expiresInHours > 0
        ? Math.floor(body.expiresInHours)
        : 72;

    const digits = '0123456789';
    let code = '';
    for (let i = 0; i < len; i++)
      code += digits[Math.floor(Math.random() * digits.length)];

    const codeHash = await bcrypt.hash(code, 10);

    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + hours);

    // keep only one active code per child (anti-chaos)
    await this.prisma.parentLinkCode.deleteMany({ where: { childId } });

    await this.prisma.parentLinkCode.create({
      data: { childId, codeHash, expiresAt },
    });

    return { ok: true, code, expiresAt: expiresAt.toISOString() };
  }

  async getMyAttendance(user: any, q: { from?: string; to?: string }) {
    // allow ADMIN for testing
    if (!user?.roles?.includes('STUDENT') && !user?.roles?.includes('ADMIN')) {
      throw new ForbiddenException('Student only');
    }

    const studentId = user.sub ?? user.id;

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

    const profile = await this.prisma.studentProfile.findUnique({
      where: { userId: studentId },
      include: { cohort: true, user: true },
    });

    if (!profile) {
      throw new BadRequestException('Student profile not found');
    }

    const records = await this.prisma.attendanceRecord.findMany({
      where: {
        studentId,
        session: { date: { gte: from, lt: toPlus } },
      },
      include: { session: { include: { course: true } } },
      orderBy: [{ session: { date: 'desc' } }, { session: { period: 'asc' } }],
    });

    return {
      ok: true,
      student: { id: studentId, name: profile.user.name },
      cohort: { id: profile.cohort.id, name: profile.cohort.name },
      from: fromYmd,
      to: toYmd,
      items: records.map((r) => ({
        date: new Intl.DateTimeFormat('en-CA', { timeZone: 'UTC' }).format(
          r.session.date,
        ),
        period: r.session.period,
        status: r.status,
        note: r.note,
        course: r.session.course
          ? {
              id: r.session.course.id,
              name: r.session.course.name,
              subject: r.session.course.subject,
            }
          : null,
      })),
    };
  }
}
