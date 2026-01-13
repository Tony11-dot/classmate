import {
  BadRequestException,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

function ymdInJerusalem(date = new Date()): string {
  return new Intl.DateTimeFormat('en-CA', {
    timeZone: 'Asia/Jerusalem',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(date);
}

function parseYmdToUtcMidnight(ymd: string): Date {
  const dt = new Date(`${ymd}T00:00:00.000Z`);
  if (Number.isNaN(dt.getTime()))
    throw new BadRequestException('Invalid date (YYYY-MM-DD)');
  return dt;
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

@Injectable()
export class TeacherService {
  constructor(private readonly prisma: PrismaService) {}

  private ensureTeacher(user: any) {
    if (!user?.roles?.includes('TEACHER') && !user?.roles?.includes('ADMIN'))
      throw new ForbiddenException('Teacher only');
  }

  async todaySchedule(user: any) {
    this.ensureTeacher(user);

    const teacherId = user.sub ?? user.id;
    const now = new Date();
    const dayOfWeek = dayOfWeekInJerusalem(now);
    const dateYmd = ymdInJerusalem(now);
    const date = parseYmdToUtcMidnight(dateYmd);

    // template lessons for this teacher today
    const template = await this.prisma.scheduleSlot.findMany({
      where: { dayOfWeek, course: { teacherId } },
      orderBy: [{ period: 'asc' }],
      include: { cohort: true, course: true },
    });

    if (template.length === 0) {
      return { ok: true, date: dateYmd, dayOfWeek, slots: [] };
    }

    const cohortIds = Array.from(new Set(template.map((t) => t.cohortId)));

    // one-time overrides for today for those cohorts
    const overrides = await this.prisma.scheduleOverride.findMany({
      where: {
        cohortId: { in: cohortIds },
        date,
      },
      include: { course: true },
    });

    const overrideKey = (cohortId: string, period: number) =>
      `${cohortId}::${period}`;
    const overrideByKey = new Map(
      overrides.map((o) => [overrideKey(o.cohortId, o.period), o]),
    );

    const out: any[] = [];

    for (const t of template) {
      const o = overrideByKey.get(overrideKey(t.cohortId, t.period));

      if (o) {
        // override exists
        if (!o.courseId) {
          out.push({
            period: t.period,
            source: 'OVERRIDE',
            cohort: {
              id: t.cohort.id,
              name: t.cohort.name,
              grade: (t.cohort as any).grade,
            },
            course: null,
          });
          continue;
        }

        // override course belongs to someone else -> not your slot anymore
        if (o.course?.teacherId && o.course.teacherId !== teacherId) {
          continue;
        }

        out.push({
          period: t.period,
          source: 'OVERRIDE',
          cohort: {
            id: t.cohort.id,
            name: t.cohort.name,
            grade: (t.cohort as any).grade,
          },
          course: o.course
            ? {
                id: o.course.id,
                name: o.course.name,
                subject: o.course.subject,
              }
            : null,
        });
        continue;
      }

      // template slot
      out.push({
        period: t.period,
        source: 'TEMPLATE',
        cohort: {
          id: t.cohort.id,
          name: t.cohort.name,
          grade: (t.cohort as any).grade,
        },
        course: t.course
          ? { id: t.course.id, name: t.course.name, subject: t.course.subject }
          : null,
      });
    }

    out.sort((a, b) => a.period - b.period);

    return { ok: true, date: dateYmd, dayOfWeek, slots: out };
  }

  async getAttendanceSession(
    user: any,
    query: { cohortId: string; date?: string; period: number },
  ) {
    this.ensureTeacher(user);

    const teacherId = user.sub ?? user.id;
    const cohortId = query.cohortId;
    const period = Number(query.period);

    if (!cohortId) throw new BadRequestException('cohortId is required');
    if (!Number.isInteger(period))
      throw new BadRequestException('period is required');

    const dateYmd = query.date ?? ymdInJerusalem(new Date());
    const date = parseYmdToUtcMidnight(dateYmd);

    const dayOfWeek = dayOfWeekInJerusalem(
      new Date(`${dateYmd}T12:00:00.000Z`),
    );

    const template = await this.prisma.scheduleSlot.findUnique({
      where: { cohortId_dayOfWeek_period: { cohortId, dayOfWeek, period } },
      include: { course: true, cohort: true },
    });

    const override = await this.prisma.scheduleOverride.findUnique({
      where: { cohortId_date_period: { cohortId, date, period } },
      include: { course: true },
    });

    const course = override?.course ?? template?.course ?? null;

    if (!course)
      throw new BadRequestException('No course scheduled for this slot');
    if (course.teacherId !== teacherId)
      throw new ForbiddenException('Not your course');

    const session = await this.prisma.attendanceSession.upsert({
      where: { cohortId_date_period: { cohortId, date, period } },
      update: { courseId: course.id },
      create: { cohortId, date, period, courseId: course.id },
      include: { records: true, cohort: true },
    });

    const students = await this.prisma.studentProfile.findMany({
      where: { cohortId },
      include: { user: true },
      orderBy: { user: { name: 'asc' } },
    });

    const recordByStudent = new Map(
      session.records.map((r) => [r.studentId, r]),
    );

    return {
      cohort: {
        id: session.cohort.id,
        name: session.cohort.name,
        grade: (session.cohort as any).grade,
      },
      date: dateYmd,
      period,
      course: { id: course.id, name: course.name, subject: course.subject },
      students: students.map((s) => {
        const r = recordByStudent.get(s.userId);
        return {
          studentId: s.userId,
          name: s.user.name,
          status: r?.status ?? 'PRESENT',
          note: r?.note ?? null,
        };
      }),
    };
  }

  async markAttendance(
    user: any,
    body: {
      cohortId: string;
      date?: string;
      period: number;
      courseId?: string | null;
      studentId: string;
      status: 'PRESENT' | 'ABSENT' | 'LATE' | 'EXCUSED';
      note?: string;
    },
  ) {
    this.ensureTeacher(user);

    const teacherId = user.sub ?? user.id;

    if (!body?.cohortId) throw new BadRequestException('cohortId is required');
    if (!Number.isInteger(body?.period))
      throw new BadRequestException('period is required');
    if (!body?.studentId)
      throw new BadRequestException('studentId is required');
    if (!body?.status) throw new BadRequestException('status is required');

    const dateYmd = body.date ?? ymdInJerusalem(new Date());
    const date = parseYmdToUtcMidnight(dateYmd);

    if (body.courseId) {
      const c = await this.prisma.course.findUnique({
        where: { id: body.courseId },
      });
      if (!c) throw new BadRequestException('Invalid courseId');
      if (c.teacherId !== teacherId)
        throw new ForbiddenException('Not your course');
    }

    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: body.studentId },
    });
    if (!sp || sp.cohortId !== body.cohortId)
      throw new BadRequestException('Student not in cohort');

    const session = await this.prisma.attendanceSession.upsert({
      where: {
        cohortId_date_period: {
          cohortId: body.cohortId,
          date,
          period: body.period,
        },
      },
      update: { courseId: body.courseId ?? undefined },
      create: {
        cohortId: body.cohortId,
        date,
        period: body.period,
        courseId: body.courseId ?? undefined,
      },
    });

    const record = await this.prisma.attendanceRecord.upsert({
      where: {
        sessionId_studentId: {
          sessionId: session.id,
          studentId: body.studentId,
        },
      },
      update: { status: body.status as any, note: body.note ?? null },
      create: {
        sessionId: session.id,
        studentId: body.studentId,
        status: body.status as any,
        note: body.note ?? null,
      },
    });

    return { ok: true, sessionId: session.id, recordId: record.id };
  }

  async bulkAttendance(
    user: any,
    body: {
      cohortId: string;
      date?: string;
      period: number;
      courseId?: string | null;
      records: {
        studentId: string;
        status: 'PRESENT' | 'ABSENT' | 'LATE' | 'EXCUSED';
        note?: string;
      }[];
    },
  ) {
    this.ensureTeacher(user);

    const teacherId = user.sub ?? user.id;

    if (!body?.cohortId) throw new BadRequestException('cohortId is required');
    if (!Number.isInteger(body?.period))
      throw new BadRequestException('period is required');
    if (!Array.isArray(body?.records) || body.records.length === 0)
      throw new BadRequestException('records[] is required');

    const dateYmd = body.date ?? ymdInJerusalem(new Date());
    const date = parseYmdToUtcMidnight(dateYmd);

    if (body.courseId) {
      const c = await this.prisma.course.findUnique({
        where: { id: body.courseId },
      });
      if (!c) throw new BadRequestException('Invalid courseId');
      if (c.teacherId !== teacherId)
        throw new ForbiddenException('Not your course');
    }

    const session = await this.prisma.attendanceSession.upsert({
      where: {
        cohortId_date_period: {
          cohortId: body.cohortId,
          date,
          period: body.period,
        },
      },
      update: { courseId: body.courseId ?? undefined },
      create: {
        cohortId: body.cohortId,
        date,
        period: body.period,
        courseId: body.courseId ?? undefined,
      },
    });

    const studentIds = body.records.map((r) => r.studentId);
    const profiles = await this.prisma.studentProfile.findMany({
      where: { userId: { in: studentIds } },
      select: { userId: true, cohortId: true },
    });
    const okSet = new Set(
      profiles.filter((p) => p.cohortId === body.cohortId).map((p) => p.userId),
    );

    let written = 0;
    for (const r of body.records) {
      if (!okSet.has(r.studentId)) continue;
      await this.prisma.attendanceRecord.upsert({
        where: {
          sessionId_studentId: {
            sessionId: session.id,
            studentId: r.studentId,
          },
        },
        update: { status: r.status as any, note: r.note ?? null },
        create: {
          sessionId: session.id,
          studentId: r.studentId,
          status: r.status as any,
          note: r.note ?? null,
        },
      });
      written++;
    }

    return {
      ok: true,
      sessionId: session.id,
      written,
      skipped: body.records.length - written,
    };
  }


  async cohortStudents(user: any, cohortId: string) {
    this.ensureTeacher(user);
    const teacherId = user.sub ?? user.id;

    if (!cohortId) throw new BadRequestException('cohortId is required');

    // ensure teacher owns at least one course in this cohort (authorization)
    const owns = await this.prisma.course.findFirst({
      where: { teacherId, cohortId },
      select: { id: true },
    });
    if (!owns) throw new ForbiddenException('Not your cohort');

    const rows = await this.prisma.studentProfile.findMany({
      where: { cohortId },
      select: { userId: true },
      orderBy: [{ userId: 'asc' }],
    });

    return {
      ok: true,
      cohortId,
      students: rows.map((r) => ({
        studentId: r.userId,
        name: r.userId, // TODO: enrich with real name/email once we confirm Prisma relations
      })),
    };
  }

  async createAssessment(
    user: any,
    body: { courseId: string; title: string; date?: string },
  ) {
    this.ensureTeacher(user);
    const teacherId = user.sub ?? user.id;

    if (!body?.courseId) throw new BadRequestException('courseId is required');
    if (!body?.title) throw new BadRequestException('title is required');

    const course = await this.prisma.course.findUnique({
      where: { id: body.courseId },
    });
    if (!course) throw new BadRequestException('Invalid courseId');
    if (course.teacherId !== teacherId)
      throw new ForbiddenException('Not your course');

    const dateYmd = body.date ?? ymdInJerusalem(new Date());
    const date = parseYmdToUtcMidnight(dateYmd);

    const assessment = await this.prisma.assessment.create({
      data: {
        courseId: body.courseId,
        title: body.title,
        date,
        createdBy: teacherId,
      },
    });

    return { ok: true, assessment };
  }

  async bulkGrades(
    user: any,
    body: {
      assessmentId: string;
      grades: { studentId: string; grade: number; comment?: string }[];
    },
  ) {
    this.ensureTeacher(user);
    const teacherId = user.sub ?? user.id;

    if (!body?.assessmentId)
      throw new BadRequestException('assessmentId is required');
    if (!Array.isArray(body?.grades) || body.grades.length === 0)
      throw new BadRequestException('grades[] is required');

    const assessment = await this.prisma.assessment.findUnique({
      where: { id: body.assessmentId },
      include: { course: true },
    });
    if (!assessment) throw new BadRequestException('Invalid assessmentId');
    if (assessment.course.teacherId !== teacherId)
      throw new ForbiddenException('Not your assessment');

    const cohortId = assessment.course.cohortId ?? null;

    const studentIds = body.grades.map((g) => g.studentId);
    const profiles = await this.prisma.studentProfile.findMany({
      where: { userId: { in: studentIds } },
      select: { userId: true, cohortId: true },
    });

    const okSet = new Set(
      profiles
        .filter((p) => (cohortId ? p.cohortId === cohortId : true))
        .map((p) => p.userId),
    );

    let written = 0;
    for (const g of body.grades) {
      if (!okSet.has(g.studentId)) continue;
      const grade = Math.round(Number(g.grade));
      if (!Number.isFinite(grade)) continue;

      await this.prisma.gradeRecord.upsert({
        where: {
          assessmentId_studentId: {
            assessmentId: assessment.id,
            studentId: g.studentId,
          },
        },
        update: { grade, comment: g.comment ?? null },
        create: {
          assessmentId: assessment.id,
          studentId: g.studentId,
          grade,
          comment: g.comment ?? null,
        },
      });
      written++;
    }

    return {
      ok: true,
      assessmentId: assessment.id,
      written,
      skipped: body.grades.length - written,
    };
  }
  // ---- Assessments (list/update/delete) ----

  async listAssessments(user: any, query?: { courseId?: string }) {
    this.ensureTeacher(user);
    const teacherId = user.sub ?? user.id;

    const courseId = query?.courseId;

    // If courseId is provided: validate ownership and list assessments for that course
    if (courseId) {
      const course = await this.prisma.course.findUnique({
        where: { id: courseId },
      });
      if (!course) throw new BadRequestException('Invalid courseId');
      if (course.teacherId !== teacherId)
        throw new ForbiddenException('Not your course');

      const assessments = await this.prisma.assessment.findMany({
        where: { courseId: course.id },
        orderBy: [{ date: 'desc' }, { id: 'desc' }],
      });

      return { ok: true, course, assessments };
    }

    // Otherwise: list all assessments for all courses owned by this teacher
    const courses = await this.prisma.course.findMany({
      where: { teacherId },
      select: { id: true, name: true, subject: true, cohortId: true },
      orderBy: { name: 'asc' },
    });

    const courseIds = courses.map((c) => c.id);
    if (courseIds.length === 0)
      return { ok: true, courses: [], assessments: [] };

    const assessments = await this.prisma.assessment.findMany({
      where: { courseId: { in: courseIds } },
      orderBy: [{ date: 'desc' }, { id: 'desc' }],
      include: { course: true },
    });

    return { ok: true, courses, assessments };
  }

  async updateAssessment(
    user: any,
    id: string,
    body: { title?: string; date?: string | null },
  ) {
    this.ensureTeacher(user);
    const teacherId = user.sub ?? user.id;

    if (!id) throw new BadRequestException('id is required');
    if (!body || (body.title === undefined && body.date === undefined))
      throw new BadRequestException('Nothing to update');

    const existing = await this.prisma.assessment.findUnique({
      where: { id },
      include: { course: true },
    });
    if (!existing) throw new BadRequestException('Invalid assessment id');
    if (existing.course.teacherId !== teacherId)
      throw new ForbiddenException('Not your course');

    const data: any = {};
    if (body.title !== undefined) {
      const t = String(body.title).trim();
      if (!t) throw new BadRequestException('title cannot be empty');
      data.title = t;
    }

    if (body.date !== undefined) {
      if (body.date === null || String(body.date).trim() === '') {
        // Keep strict: assessment.date is probably required. If you DO want nullable, update Prisma schema.
        throw new BadRequestException('date cannot be null/empty');
      } else {
        const dateYmd = String(body.date);
        const dt = parseYmdToUtcMidnight(dateYmd);
        data.date = dt;
      }
    }

    const updated = await this.prisma.assessment.update({
      where: { id },
      data,
    });

    return { ok: true, assessment: updated };
  }

  async deleteAssessment(user: any, id: string) {
    this.ensureTeacher(user);
    const teacherId = user.sub ?? user.id;

    if (!id) throw new BadRequestException('id is required');

    const existing = await this.prisma.assessment.findUnique({
      where: { id },
      include: { course: true },
    });
    if (!existing) throw new BadRequestException('Invalid assessment id');
    if (existing.course.teacherId !== teacherId)
      throw new ForbiddenException('Not your course');

    // If Prisma schema doesn't cascade grade records, delete them first
    await this.prisma.gradeRecord.deleteMany({ where: { assessmentId: id } });

    await this.prisma.assessment.delete({ where: { id } });

    return { ok: true };
  }
}
