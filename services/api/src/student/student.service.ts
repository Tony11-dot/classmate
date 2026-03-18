import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { ScheduleService } from '../schedule/schedule.service';
import { StudentInsightsService } from './student-insights.service';
import {
  subjectDefaultsBySchoolGrade,
  studentSubjectOverrides,
  defaultsKey,
} from '../subjects/subjects.store';

@Injectable()
export class StudentService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly schedule: ScheduleService,
    private readonly studentInsightsService: StudentInsightsService,
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
      where: {
        cohortId: body.cohortId,
        active: true,
        OR: [{ expiresAt: null }, { expiresAt: { gt: new Date() } }],
      },
      orderBy: { createdAt: 'desc' },
      take: 10,
    });

    const now = new Date();
    let matchedId: string | null = null;

    const joinCode = String(body.joinCode ?? '').trim();
    for (const c of codes) {
      if (c.expiresAt && c.expiresAt < now) continue;
      if (await bcrypt.compare(joinCode, c.codeHash)) {
        matchedId = c.id;
        break;
      }
    }

    if (!matchedId) throw new BadRequestException('Invalid join code');

    // 🔐 single-use: deactivate matched code
    const used = await this.prisma.cohortJoinCode.updateMany({
      where: { id: matchedId, active: true },
      data: { active: false },
    });

    if (used.count !== 1) throw new BadRequestException('Invalid join code');

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

    // Session 5: auto-enroll student into cohort courses (from schedule template)
    const courseIds = await this.prisma.scheduleSlot.findMany({
      where: { cohortId: body.cohortId, courseId: { not: null } },
      select: { courseId: true },
      distinct: ['courseId'],
    });

    const uniqueCourseIds = Array.from(
      new Set(courseIds.map((r) => String(r.courseId)).filter(Boolean)),
    );

    if (uniqueCourseIds.length) {
      await this.prisma.enrollment.createMany({
        data: uniqueCourseIds.map((courseId) => ({ studentId, courseId })),
        skipDuplicates: true,
      });
    }

    return { ok: true };
  }

  async todaySchedule(user: any) {
    this.ensureStudent(user);
    const studentId = user.sub ?? user.id;
    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: studentId },
    });
    if (!sp) throw new BadRequestException('Student not onboarded');
    return this.schedule.getTodayForStudent({
      schoolId: String(user.schoolId),
      studentId: String(studentId),
      cohortId: String(sp.cohortId),
    });
  }

  async weekSchedule(user: any) {
    this.ensureStudent(user);
    const studentId = user.sub ?? user.id;
    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: studentId },
    });
    if (!sp) throw new BadRequestException('Student not onboarded');
    return this.schedule.getWeekForStudent({
      schoolId: String(user.schoolId),
      studentId: String(studentId),
      cohortId: String(sp.cohortId),
    });
  }

  async getInsights(user: any) {
    this.ensureStudent(user);
    return this.studentInsightsService.getStudentInsights(user);
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

  // ---- Session 10: Effective subjects for student (defaults + override) ----
  // ---- Session 10: Effective subjects for student (defaults + override) ----
  async mySubjects(user: any) {
    if (!user?.roles?.includes('STUDENT') && !user?.roles?.includes('ADMIN')) {
      throw new ForbiddenException('Student only');
    }

    const studentId = user.sub ?? user.id;
    if (!studentId) throw new ForbiddenException('Not authenticated');

    let schoolId = String(user?.schoolId ?? 'test-school');

    const __h = (user as any)?.__headers ?? null;
    const __devSchoolRaw =
      __h?.['x-dev-school-id'] ?? __h?.['X-DEV-SCHOOL-ID'] ?? null;
    if (__devSchoolRaw) schoolId = String(__devSchoolRaw);

    // best-effort grade from cohort
    let grade: number | null = null;

    const sp = await (this.prisma as any).studentProfile?.findUnique?.({
      where: { userId: studentId } as any,
      select: { cohortId: true } as any,
    });

    if (sp?.cohortId) {
      const c = await (this.prisma as any).cohort?.findUnique?.({
        where: { id: sp.cohortId } as any,
        select: { grade: true } as any,
      });
      if (c?.grade !== undefined && c?.grade !== null) grade = Number(c.grade);
    }

    // DEV HELPERS: allow overriding grade via headers when using dev auth headers
    const __h2 = (user as any)?.__headers ?? null;
    const __devGradeRaw =
      __h2?.['x-dev-grade'] ?? __h2?.['X-DEV-GRADE'] ?? null;
    const __devGrade =
      __devGradeRaw !== null && __devGradeRaw !== undefined
        ? Number(__devGradeRaw)
        : null;
    if (
      (grade === null || grade === undefined) &&
      __devGrade !== null &&
      !Number.isNaN(Number(__devGrade))
    ) {
      grade = Number(__devGrade);
    }

    const defaultsRow =
      grade !== null && !Number.isNaN(Number(grade))
        ? await this.prisma.schoolGradeSubjectDefault.findUnique({
            where: {
              schoolId_grade_unique: { schoolId, grade: Number(grade) },
            },
          })
        : null;

    const defaults = defaultsRow?.subjects ?? [];

    const ovRow = await this.prisma.studentSubjectOverride.findUnique({
      where: { userId: String(studentId) },
      select: { userId: true, enabled: true, subjects: true },
    });

    const override = ovRow
      ? {
          userId: ovRow.userId,
          enabled: ovRow.enabled,
          subjects: ovRow.subjects,
        }
      : null;

    const effective =
      override?.enabled &&
      Array.isArray(override?.subjects) &&
      override.subjects.length
        ? override.subjects
        : defaults;

    return {
      ok: true,
      schoolId,
      grade,
      defaults,
      override,
      effective,
    };
  }

  private async ensureClassroomAccessible(_user: any, courseId: string) {
    const course = await this.prisma.course.findUnique({
      where: { id: courseId },
      select: { id: true },
    });

    if (!course) {
      throw new NotFoundException('Classroom not found');
    }

    return course;
  }

  async classroomPeople(user: any, courseId: string) {
    await this.ensureClassroomAccessible(user, courseId);

    return {
      ok: true,
      items: [],
      teachers: [],
      students: [],
      server: false,
    };
  }

  async classroomChat(user: any, courseId: string, _q: any) {
    await this.ensureClassroomAccessible(user, courseId);

    return {
      ok: true,
      items: [],
      nextCursor: null,
      server: false,
    };
  }

  async classroomSendChatText(user: any, courseId: string, dto: any) {
    await this.ensureClassroomAccessible(user, courseId);

    const text = typeof dto?.text === 'string' ? dto.text.trim() : '';
    if (!text) {
      throw new BadRequestException('text required');
    }

    return {
      ok: true,
      server: false,
      message: {
        id: `local-${Date.now()}`,
        text,
        body: text,
        createdAt: new Date().toISOString(),
        senderName: user?.name ?? user?.email ?? 'You',
        mine: true,
      },
    };
  }

  async classroomSendChatMedia(user: any, courseId: string, dto: any) {
    await this.ensureClassroomAccessible(user, courseId);

    return {
      ok: true,
      server: false,
      item: {
        id: `local-media-${Date.now()}`,
        createdAt: new Date().toISOString(),
        senderName: user?.name ?? user?.email ?? 'You',
        mine: true,
        ...dto,
      },
    };
  }

  async classroomAssignments(user: any, courseId: string) {
    await this.ensureClassroomAccessible(user, courseId);

    return {
      ok: true,
      items: [],
      server: false,
    };
  }

  async classroomMaterials(user: any, courseId: string) {
    await this.ensureClassroomAccessible(user, courseId);

    return {
      ok: true,
      items: [],
      server: false,
    };
  }

  async classroomMeetings(user: any, courseId: string) {
    await this.ensureClassroomAccessible(user, courseId);

    return {
      ok: true,
      items: [],
      server: false,
    };
  }
}
