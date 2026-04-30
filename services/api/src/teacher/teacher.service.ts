import * as bcrypt from 'bcrypt';
import { BadRequestException, ForbiddenException, Injectable, HttpException, HttpStatus, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { hasAnyRole } from '../auth/permissions';

function randomDigits(len = 6) {
  const digits = '0123456789';
  let out = '';
  for (let i = 0; i < len; i++) out += digits[Math.floor(Math.random() * digits.length)];
  return out;
}


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

type CourseLite = {
  id: string;
  name: string;
  subject: string | null;
  teacherId?: string | null;
};
type AttendanceRowLite = {
  studentId: string;
  status?: string;
  note?: string | null;
};

@Injectable()
export class TeacherService {

  async generateJoinCode(
    user: any,
    body: { cohortId: string; expiresInHours?: number; length?: number },
  ) {
    if (!hasAnyRole(user, ['ADMIN', 'TEACHER']))
      throw new ForbiddenException('Admin or Teacher only');
    if (!body?.cohortId) throw new BadRequestException('cohortId is required');

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

    const len = body.length && body.length >= 4 && body.length <= 10 ? body.length : 6;
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

  constructor(private readonly prisma: PrismaService) {}

  private ensureTeacher(user: any) {
    if (!hasAnyRole(user, ['TEACHER','ADMIN']))
      throw new ForbiddenException('Teacher only');
  }

  async todaySchedule(user: any) {
    this.ensureTeacher(user);

    const teacherId = user.id ?? user.sub;
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
        if (!(o as any).courseId) {
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
        if (
          (o as any).course?.teacherId &&
          (o as any).course.teacherId !== teacherId
        ) {
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
          course: (o as any).course
            ? {
                id: (o as any).course.id,
                name: (o as any).course.name,
                subject: (o as any).course.subject,
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
    query: { cohortId?: string; date?: string; period: number },
  ) {
    this.ensureTeacher(user);

    const teacherId = user.id ?? user.sub;
    const period = Number(query.period);

    if (!Number.isInteger(period))
      throw new BadRequestException('period is required');

    const dateYmd = query.date ?? ymdInJerusalem(new Date());
    const date = parseYmdToUtcMidnight(dateYmd);

    const dayOfWeek = dayOfWeekInJerusalem(
      new Date(`${dateYmd}T12:00:00.000Z`),
    );

    let cohortId = (query.cohortId ?? '').trim();

    if (!cohortId) {
      const slot = await this.prisma.scheduleSlot.findFirst({
        where: {
          dayOfWeek,
          period,
          course: { is: { teacherId } },
        } as any,
        select: { cohortId: true },
        orderBy: [{ cohortId: 'asc' }],
      });

      if (!slot?.cohortId) {
        throw new BadRequestException(
          'No teacher schedule slot found for that day/period (provide cohortId)',
        );
      }

      cohortId = slot.cohortId;
    }

    const template = await this.prisma.scheduleSlot.findUnique({
      where: { cohortId_dayOfWeek_period: { cohortId, dayOfWeek, period } },
      include: { course: true, cohort: true },
    });

    const override = await this.prisma.scheduleOverride.findUnique({
      where: { cohortId_date_period: { cohortId, date, period } },
      include: { course: true },
    });

    const course: any = override?.course ?? template?.course ?? null;

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
        const r = recordByStudent.get(s.userId) as
          | AttendanceRowLite
          | undefined;
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

    const teacherId = user.id ?? user.sub;

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

    const __existing = await this.prisma.attendanceRecord.findUnique({
      where: {
        sessionId_studentId: {
          sessionId: session.id,
          studentId: body.studentId,
        },
      },
      select: { id: true, status: true },
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

    // 🔔 Notify parents: attendance marked (ONLY first time ABSENT/LATE for this session)
    try {
      const __newStatus = record.status;
      const __shouldNotify =
        (__newStatus === 'ABSENT' || __newStatus === 'LATE') &&
        (!__existing || __existing.status === 'PRESENT');

      if (__shouldNotify) {
        const parents = await this.prisma.parentChild.findMany({
          where: { childId: record.studentId, status: 'APPROVED' as any },
          select: { parentId: true },
        });

        if (parents.length) {
          const title =
            __newStatus === 'ABSENT'
              ? 'Absence recorded'
              : 'Late arrival recorded';

          // dedupe: one notification per parent+student+session+type
          const existingNotifs = await this.prisma.parentNotification.findMany({
            where: {
              parentId: { in: parents.map((p) => p.parentId) },
              studentId: record.studentId,
              type: 'ATTENDANCE_RECORDED' as any,
              data: { path: ['sessionId'], equals: record.sessionId },
            },
            select: { parentId: true },
          });
          const already = new Set(existingNotifs.map((x) => x.parentId));
          const targets = parents.filter((p) => !already.has(p.parentId));

          if (!targets.length) return;

          await this.prisma.parentNotification.createMany({
            data: targets.map((p) => ({
              parentId: p.parentId,
              studentId: record.studentId,
              type: 'ATTENDANCE_RECORDED',
              title,
              message: null,
              data: {
                status: __newStatus,
                sessionId: record.sessionId,
                cohortId: session.cohortId,
                date: session.date.toISOString(),
                period: session.period,
                courseId: session.courseId ?? null,
              },
            })),
          });
        }
      }
    } catch (_e) {
      // don't break teacher flow on notification failures
    }

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

    const teacherId = user.id ?? user.sub;

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
      const __existing = await this.prisma.attendanceRecord.findUnique({
        where: {
          sessionId_studentId: {
            sessionId: session.id,
            studentId: r.studentId,
          },
        },
        select: { id: true, status: true },
      });

      const __upserted = await this.prisma.attendanceRecord.upsert({
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

      // 🔔 Notify parents: attendance marked (ONLY first time ABSENT/LATE for this session)
      try {
        const __newStatus = __upserted.status;
        const __shouldNotify =
          (__newStatus === 'ABSENT' || __newStatus === 'LATE') &&
          (!__existing || __existing.status === 'PRESENT');

        if (__shouldNotify) {
          const parents = await this.prisma.parentChild.findMany({
            where: { childId: __upserted.studentId, status: 'APPROVED' as any },
            select: { parentId: true },
          });

          if (parents.length) {
            const title =
              __newStatus === 'ABSENT'
                ? 'Absence recorded'
                : 'Late arrival recorded';

            // dedupe: one notification per parent+student+session+type
            const existingNotifs =
              await this.prisma.parentNotification.findMany({
                where: {
                  parentId: { in: parents.map((p) => p.parentId) },
                  studentId: __upserted.studentId,
                  type: 'ATTENDANCE_RECORDED' as any,
                  data: { path: ['sessionId'], equals: __upserted.sessionId },
                },
                select: { parentId: true },
              });
            const already = new Set(existingNotifs.map((x) => x.parentId));
            const targets = parents.filter((p) => !already.has(p.parentId));

            if (!targets.length) {
              /* no-op */
            } else
              await this.prisma.parentNotification.createMany({
                data: targets.map((p) => ({
                  parentId: p.parentId,
                  studentId: __upserted.studentId,
                  type: 'ATTENDANCE_RECORDED',
                  title,
                  message: null,
                  data: {
                    status: __newStatus,
                    sessionId: __upserted.sessionId,
                    cohortId: session.cohortId,
                    date: session.date.toISOString(),
                    period: session.period,
                    courseId: session.courseId ?? null,
                  },
                })),
              });
          }
        }
      } catch (_e) {
        // don't break teacher flow on notification failures
      }

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
    const teacherId = user.id ?? user.sub;

    if (!cohortId) throw new BadRequestException('cohortId is required');

    // 1) 404 if cohort doesn't exist (true not-found)
    const cohort = await this.prisma.cohort.findUnique({
      where: { id: cohortId },
      select: { id: true },
    });
    if (!cohort) throw new NotFoundException('Cohort not found');

    // 2) 403 if cohort exists but not owned by teacher (authorization)
    const owns = await this.prisma.course.findFirst({
      where: { teacherId, cohortId },
      select: { id: true },
    });
    if (!owns) throw new ForbiddenException('Not your cohort');

    const rows = await this.prisma.studentProfile.findMany({
      where: { cohortId },
      select: {
        userId: true,
        user: {
          select: {
            name: true,
            displayName: true,
            legalName: true,
            email: true,
          },
        },
      },
      orderBy: [{ user: { name: 'asc' } }, { userId: 'asc' }],
    });

    return {
      ok: true,
      cohortId,
      students: rows.map((r) => ({
        studentId: r.userId,
        name:
          r.user.displayName ||
          r.user.legalName ||
          r.user.name ||
          r.user.email ||
          r.userId,
      })),
    };
  }


  async createAssessment(
    user: any,
    body: { courseId: string; title: string; date?: string; maxGrade?: number },
  ) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;

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
        maxGrade: body.maxGrade ?? undefined,
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
    const teacherId = user.id ?? user.sub;

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

      if (
        assessment.maxGrade !== null &&
        assessment.maxGrade !== undefined &&
        grade > assessment.maxGrade
      ) {
        throw new BadRequestException(
          `Grade ${grade} exceeds maxGrade ${assessment.maxGrade}`,
        );
      }
      if (grade < 0) {
        throw new BadRequestException('Grade cannot be negative');
      }

      if (!Number.isFinite(grade)) continue;

      const __existing = await this.prisma.gradeRecord.findUnique({
        where: {
          assessmentId_studentId: {
            assessmentId: assessment.id,
            studentId: g.studentId,
          },
        },
        select: { id: true },
      });
      const __upserted = await this.prisma.gradeRecord.upsert({
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

      // 🔔 Notify parents: grade posted (only on first create)
      if (!__existing)
        try {
          const __studentId = g.studentId;
          const __assessmentId = assessment.id;

          const parents = await this.prisma.parentChild.findMany({
            where: { childId: __studentId, status: 'APPROVED' },
            select: { parentId: true },
          });

          if (parents.length) {
            const a = await this.prisma.assessment.findUnique({
              where: { id: __assessmentId },
              include: {
                course: { select: { id: true, name: true, subject: true } },
              },
            });

            const title = a?.course?.name
              ? `New grade in ${a.course.name}`
              : 'New grade posted';

            await this.prisma.parentNotification.createMany({
              data: parents.map((p) => ({
                parentId: p.parentId,
                studentId: __studentId,
                type: 'GRADE_POSTED',
                title,
                message: null,
                data: {
                  grade: __upserted.grade,
                  comment: __upserted.comment ?? null,
                  assessment: a
                    ? { id: a.id, title: a.title, date: a.date.toISOString() }
                    : { id: __assessmentId },
                  course: a?.course
                    ? {
                        id: a.course.id,
                        name: a.course.name,
                        subject: a.course.subject,
                      }
                    : null,
                },
              })),
            });
          }
        } catch (_e) {
          // don't break teacher flow on notification failures
        }

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
    const teacherId = user.id ?? user.sub;

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

  async assessmentGrades(user: any, assessmentId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;

    if (!assessmentId)
      throw new BadRequestException('assessmentId is required');

    const assessment = await this.prisma.assessment.findUnique({
      where: { id: assessmentId },
      include: { course: true },
    });
    if (!assessment) throw new BadRequestException('Invalid assessmentId');
    if (assessment.course.teacherId !== teacherId)
      throw new ForbiddenException('Not your assessment');

    const rows = await this.prisma.gradeRecord.findMany({
      where: { assessmentId },
      select: { studentId: true, grade: true, comment: true },
      orderBy: [{ studentId: 'asc' }],
    });

    return { ok: true, assessmentId, grades: rows };
  }

  async updateAssessment(
    user: any,
    id: string,
    body: { title?: string; date?: string | null },
  ) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;

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
    const teacherId = user.id ?? user.sub;

    if (!id) throw new BadRequestException('id is required');

    const existing = await this.prisma.assessment.findUnique({
      where: { id },
      include: { course: true },
    });
    if (!existing) throw new BadRequestException('Invalid assessment id');
    if (existing.course.teacherId !== teacherId)
      throw new ForbiddenException('Not your course');

    await this.prisma.gradeRecord.deleteMany({ where: { assessmentId: id } });
    await this.prisma.assessment.delete({ where: { id } });

    return { ok: true };
  }

  // ---- Classroom management ----

  private async assertTeacherOwnsCourse(teacherId: string, courseId: string) {
    const course = await this.prisma.course.findUnique({
      where: { id: courseId },
      select: { id: true, teacherId: true, name: true, subject: true, cohortId: true, cohort: { select: { id: true, name: true, grade: true } } },
    });
    if (!course) throw new NotFoundException('Course not found');
    if (course.teacherId !== teacherId) throw new ForbiddenException('Not your course');
    return course;
  }

  private async notifyCohortStudents(cohortId: string | null | undefined, title: string, body: string, data?: any) {
    if (!cohortId) return;
    try {
      const enrollments = await this.prisma.studentProfile.findMany({
        where: { cohortId },
        select: { userId: true },
      });
      const notifications = enrollments.map((e) => ({
        userId: e.userId,
        type: 'CLASSROOM_UPDATE',
        title,
        body,
        data: data ?? {},
        severity: 'info',
      }));
      if (notifications.length) {
        await this.prisma.notification.createMany({ data: notifications as any[], skipDuplicates: true });
      }
    } catch {}
  }

  async listClassrooms(user: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const courses = await this.prisma.course.findMany({
      where: { teacherId },
      select: {
        id: true, name: true, subject: true, cohortId: true,
        cohort: { select: { id: true, name: true, grade: true } },
      },
      orderBy: [{ cohortId: 'asc' }, { name: 'asc' }],
    });
    return { ok: true, classrooms: courses };
  }

  async getClassroom(user: any, courseId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const course = await this.assertTeacherOwnsCourse(teacherId, courseId);

    const [assignmentCount, materialCount, meetingCount, messageCount] = await Promise.all([
      this.prisma.classroomAssignment.count({ where: { courseId } }),
      this.prisma.classroomMaterial.count({ where: { courseId } }),
      this.prisma.classroomMeeting.count({ where: { courseId } }),
      this.prisma.classroomMessage.count({ where: { courseId } }),
    ]);

    return {
      ok: true,
      course: {
        id: course.id,
        name: course.name,
        subject: course.subject,
        cohortId: course.cohortId,
        cohort: course.cohort,
      },
      stats: { assignmentCount, materialCount, meetingCount, messageCount },
    };
  }

  async getClassroomChat(user: any, courseId: string, opts: { limit: number; cursor?: string }) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsCourse(teacherId, courseId);

    const take = Math.min(Math.max(opts.limit ?? 30, 1), 100);
    const rows = await this.prisma.classroomMessage.findMany({
      where: {
        courseId,
        ...(opts.cursor ? { id: { lt: opts.cursor } } : {}),
      },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take,
    });

    return { ok: true, items: rows.reverse() };
  }

  async sendClassroomChat(user: any, courseId: string, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsCourse(teacherId, courseId);

    const text = String(body?.text ?? '').trim();
    if (!text) throw new BadRequestException('text is required');

    const msg = await this.prisma.classroomMessage.create({
      data: {
        courseId,
        senderUserId: teacherId,
        kind: 'TEXT' as any,
        text,
      },
    });

    return { ok: true, message: msg };
  }

  async listClassroomAssignments(user: any, courseId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsCourse(teacherId, courseId);

    const items = await this.prisma.classroomAssignment.findMany({
      where: { courseId },
      orderBy: [{ dueAt: 'asc' }, { createdAt: 'desc' }],
    });

    return { ok: true, items };
  }

  async createClassroomAssignment(user: any, courseId: string, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const course = await this.assertTeacherOwnsCourse(teacherId, courseId);

    const title = String(body?.title ?? '').trim();
    if (!title) throw new BadRequestException('title is required');

    const dueAt = body?.dueAt ? new Date(String(body.dueAt)) : null;
    const bodyText = body?.body ? String(body.body).trim() : null;

    const item = await this.prisma.classroomAssignment.create({
      data: { courseId, title, body: bodyText ?? undefined, dueAt: dueAt ?? undefined, createdBy: teacherId },
    });

    const dueLabel = dueAt ? ` — due ${dueAt.toLocaleDateString()}` : '';
    await this.notifyCohortStudents(
      course.cohortId,
      `New assignment: ${title}`,
      `${course.name}${dueLabel}`,
      { type: 'NEW_ASSIGNMENT', assignmentId: item.id, courseId },
    );

    return { ok: true, item };
  }

  async updateClassroomAssignment(user: any, courseId: string, id: string, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsCourse(teacherId, courseId);

    const data: any = {};
    if (body?.title !== undefined) data.title = String(body.title).trim();
    if (body?.body !== undefined) data.body = body.body ? String(body.body).trim() : null;
    if (body?.dueAt !== undefined) data.dueAt = body.dueAt ? new Date(String(body.dueAt)) : null;

    const item = await this.prisma.classroomAssignment.update({ where: { id }, data });
    return { ok: true, item };
  }

  async deleteClassroomAssignment(user: any, courseId: string, id: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsCourse(teacherId, courseId);
    await this.prisma.classroomAssignment.delete({ where: { id } });
    return { ok: true };
  }

  async listClassroomMaterials(user: any, courseId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsCourse(teacherId, courseId);

    const items = await this.prisma.classroomMaterial.findMany({
      where: { courseId },
      orderBy: [{ createdAt: 'desc' }],
    });

    return { ok: true, items };
  }

  async createClassroomMaterial(user: any, courseId: string, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const course = await this.assertTeacherOwnsCourse(teacherId, courseId);

    const title = String(body?.title ?? '').trim();
    const url = String(body?.url ?? '').trim();
    if (!title || !url) throw new BadRequestException('title and url are required');

    const item = await this.prisma.classroomMaterial.create({
      data: {
        courseId,
        title,
        url,
        description: body?.description ? String(body.description).trim() : undefined,
        mime: body?.mime ? String(body.mime).trim() : undefined,
        createdBy: teacherId,
      },
    });

    await this.notifyCohortStudents(
      course.cohortId,
      `New material: ${title}`,
      course.name,
      { type: 'NEW_MATERIAL', materialId: item.id, courseId },
    );

    return { ok: true, item };
  }

  async deleteClassroomMaterial(user: any, courseId: string, id: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsCourse(teacherId, courseId);
    await this.prisma.classroomMaterial.delete({ where: { id } });
    return { ok: true };
  }

  async listClassroomMeetings(user: any, courseId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsCourse(teacherId, courseId);

    const items = await this.prisma.classroomMeeting.findMany({
      where: { courseId },
      orderBy: [{ startsAt: 'asc' }],
      select: { id: true, title: true, startsAt: true, endsAt: true, link: true, createdAt: true },
    });

    return { ok: true, items };
  }

  async createClassroomMeeting(user: any, courseId: string, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const course = await this.assertTeacherOwnsCourse(teacherId, courseId);

    const title = String(body?.title ?? '').trim();
    const link = String(body?.link ?? '').trim();
    const startsAt = body?.startsAt ? new Date(String(body.startsAt)) : new Date();
    if (!title || !link) throw new BadRequestException('title and link are required');

    const endsAt = body?.endsAt ? new Date(String(body.endsAt)) : null;

    const item = await this.prisma.classroomMeeting.create({
      data: {
        courseId,
        title,
        link,
        startsAt,
        endsAt: endsAt ?? undefined,
        createdBy: teacherId,
      },
    });

    const timeLabel = startsAt.toLocaleString('en-US', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
    await this.notifyCohortStudents(
      course.cohortId,
      `Meeting scheduled: ${title}`,
      `${course.name} — ${timeLabel}`,
      { type: 'NEW_MEETING', meetingId: item.id, courseId },
    );

    return { ok: true, item };
  }

  async deleteClassroomMeeting(user: any, courseId: string, id: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsCourse(teacherId, courseId);
    await this.prisma.classroomMeeting.delete({ where: { id } });
    return { ok: true };
  }

  async listAssignmentSubmissions(user: any, courseId: string, assignmentId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsCourse(teacherId, courseId);

    const submissions = await this.prisma.assignmentSubmission.findMany({
      where: { assignmentId },
      select: {
        id: true,
        studentId: true,
        note: true,
        submittedAt: true,
        student: { select: { name: true } },
      },
      orderBy: { submittedAt: 'desc' },
    }).catch((err: any) => {
      console.error('[teacher.submissions] query failed — schema may need migration', { assignmentId, error: err?.message });
      return [];
    });

    const students = await this.prisma.classroomAssignment.findUnique({
      where: { id: assignmentId },
      select: { courseId: true, course: { select: { cohortId: true } } },
    });

    const cohortId = students?.course?.cohortId;
    const roster = cohortId
      ? await this.prisma.studentProfile.findMany({
          where: { cohortId },
          select: { userId: true, user: { select: { name: true } } },
        })
      : [];

    const submittedIds = new Set(submissions.map((s: any) => s.studentId));

    return {
      ok: true,
      assignmentId,
      submissions,
      pending: roster
        .filter((r) => !submittedIds.has(r.userId))
        .map((r) => ({ studentId: r.userId, name: r.user?.name ?? '' })),
      submittedCount: submissions.length,
      totalCount: roster.length,
    };
  }

  async classroomAnalytics(user: any, courseId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const course = await this.assertTeacherOwnsCourse(teacherId, courseId);
    const cohortId = course.cohortId;

    const [assignments, assessments, attendance30, students] = await Promise.all([
      this.prisma.classroomAssignment.count({ where: { courseId } }),
      this.prisma.assessment.findMany({
        where: { courseId },
        select: { id: true, title: true, maxGrade: true, date: true },
        orderBy: { date: 'desc' },
        take: 10,
      }),
      cohortId ? this.prisma.attendanceRecord.findMany({
        where: {
          session: { courseId, date: { gte: new Date(Date.now() - 30 * 86400000) } },
        },
        select: { status: true },
      }) : Promise.resolve([]),
      cohortId ? this.prisma.studentProfile.count({ where: { cohortId } }) : Promise.resolve(0),
    ]);

    // Grade averages per assessment
    const gradeStats: any[] = [];
    for (const a of assessments) {
      const grades = await this.prisma.gradeRecord.findMany({
        where: { assessmentId: a.id },
        select: { grade: true },
      });
      const max = a.maxGrade ?? 100;
      const pcts = grades.map((g) => Math.round((Number(g.grade) / max) * 100));
      const avg = pcts.length ? Math.round(pcts.reduce((s, v) => s + v, 0) / pcts.length) : null;
      const below60 = pcts.filter((v) => v < 60).length;
      gradeStats.push({
        assessmentId: a.id,
        title: a.title,
        date: a.date,
        gradedCount: grades.length,
        totalStudents: students,
        avg,
        below60,
        distribution: {
          '0-39': pcts.filter((v) => v < 40).length,
          '40-59': pcts.filter((v) => v >= 40 && v < 60).length,
          '60-79': pcts.filter((v) => v >= 60 && v < 80).length,
          '80-100': pcts.filter((v) => v >= 80).length,
        },
      });
    }

    // Attendance summary last 30 days
    const attCounts: Record<string, number> = {};
    for (const r of attendance30 as any[]) {
      attCounts[String(r.status)] = (attCounts[String(r.status)] ?? 0) + 1;
    }
    const total = (attendance30 as any[]).length;
    const present = (attCounts['PRESENT'] ?? 0) + (attCounts['LATE'] ?? 0) + (attCounts['EXCUSED'] ?? 0);
    const attendanceRate = total > 0 ? Math.round((present / total) * 100) : null;

    return {
      ok: true,
      courseId,
      courseName: course.name,
      subject: course.subject,
      totalStudents: students,
      totalAssignments: assignments,
      attendanceRate,
      gradeStats,
    };
  }

  async getStudentProfile(user: any, studentId: string) {
    this.ensureTeacher(user);

    const [profile, recentGrades, recentAttendance, submissions] = await Promise.all([
      this.prisma.studentProfile.findUnique({
        where: { userId: studentId },
        select: { cohortId: true, user: { select: { name: true, email: true } } },
      }),
      this.prisma.gradeRecord.findMany({
        where: { studentId },
        select: {
          grade: true,
          assessment: { select: { title: true, maxGrade: true, date: true, course: { select: { name: true, subject: true } } } },
        },
        orderBy: { assessment: { date: 'desc' } },
        take: 20,
      }),
      this.prisma.attendanceRecord.findMany({
        where: { studentId, markedAt: { gte: new Date(Date.now() - 30 * 86400000) } },
        select: { status: true },
      }),
      this.prisma.assignmentSubmission.findMany({
        where: { studentId },
        select: { assignmentId: true, submittedAt: true },
      }).catch(() => []),
    ]);

    const normGrades = recentGrades.map((g) => {
      const max = g.assessment?.maxGrade ?? 100;
      return {
        title: g.assessment?.title ?? '',
        subject: g.assessment?.course?.subject ?? '',
        courseName: g.assessment?.course?.name ?? '',
        date: g.assessment?.date ?? null,
        pct: Math.round((Number(g.grade) / max) * 100),
        raw: Number(g.grade),
        max,
      };
    });
    const avg = normGrades.length
      ? Math.round(normGrades.reduce((s, g) => s + g.pct, 0) / normGrades.length)
      : null;

    const attCounts: Record<string, number> = {};
    for (const r of recentAttendance) attCounts[String(r.status)] = (attCounts[String(r.status)] ?? 0) + 1;
    const total = recentAttendance.length;
    const present = (attCounts['PRESENT'] ?? 0) + (attCounts['LATE'] ?? 0) + (attCounts['EXCUSED'] ?? 0);
    const attRate = total > 0 ? Math.round((present / total) * 100) : null;

    return {
      ok: true,
      student: { id: studentId, name: profile?.user?.name ?? '', email: profile?.user?.email ?? '', cohortId: profile?.cohortId ?? null },
      grades: normGrades,
      gradeAverage: avg,
      attendanceRate: attRate,
      attendanceBreakdown: attCounts,
      submissionsCount: (submissions as any[]).length,
    };
  }

  async weekSchedule(user: any, weekOf?: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;

    const tz = 'Asia/Jerusalem';
    const now = new Date();
    let anchor: Date;
    if (weekOf) {
      anchor = new Date(weekOf + 'T00:00:00');
    } else {
      anchor = new Date(now.toLocaleDateString('en-CA', { timeZone: tz }) + 'T00:00:00');
    }

    const dow = anchor.getDay();
    // Week starts Sunday
    const weekStart = new Date(anchor);
    weekStart.setDate(anchor.getDate() - dow);

    const days: any[] = [];
    for (let d = 0; d < 7; d++) {
      const day = new Date(weekStart);
      day.setDate(weekStart.getDate() + d);
      const dayOfWeek = day.getDay();
      const dateStr = day.toLocaleDateString('en-CA');

      const slots = await this.prisma.scheduleSlot.findMany({
        where: {
          dayOfWeek,
          course: { teacherId },
        },
        select: {
          period: true,
          cohort: { select: { id: true, name: true, grade: true } },
          course: { select: { id: true, name: true, subject: true } },
        },
        orderBy: { period: 'asc' },
      });

      if (slots.length > 0) {
        days.push({ date: dateStr, dayOfWeek, slots });
      }
    }

    return { ok: true, weekOf: weekStart.toLocaleDateString('en-CA'), days };
  }

  async addStudentToClassroom(user: any, courseId: string, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsCourse(teacherId, courseId);

    const identifier = String(body?.email ?? body?.userId ?? '').trim();
    if (!identifier) throw new BadRequestException('email or userId required');

    // Find the student by email or userId
    const student = identifier.includes('@')
      ? await this.prisma.user.findUnique({ where: { email: identifier }, select: { id: true, name: true } })
      : await this.prisma.user.findUnique({ where: { id: identifier }, select: { id: true, name: true } });
    if (!student) throw new BadRequestException('Student not found');

    // Ensure student has a profile
    const sp = await this.prisma.studentProfile.findUnique({ where: { userId: student.id }, select: { userId: true, cohortId: true } });
    if (!sp) throw new BadRequestException('User has no student profile');

    await this.prisma.enrollment.upsert({
      where: { courseId_studentId: { courseId, studentId: student.id } },
      update: {},
      create: { courseId, studentId: student.id, source: 'MANUAL' as any },
    });

    // Notify the student
    await this.prisma.notification.create({
      data: {
        userId: student.id,
        type: 'CLASSROOM_INVITE',
        title: 'You were added to a classroom',
        body: `A teacher added you to a new classroom.`,
        data: { courseId } as any,
        severity: 'info',
      },
    });

    return { ok: true, student: { id: student.id, name: student.name } };
  }

  async removeStudentFromClassroom(user: any, courseId: string, studentId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsCourse(teacherId, courseId);

    await this.prisma.enrollment.deleteMany({ where: { courseId, studentId } });
    return { ok: true };
  }

  async getClassroomPeople(user: any, courseId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const course = await this.assertTeacherOwnsCourse(teacherId, courseId);

    const cohortId = course.cohortId;
    if (!cohortId) return { ok: true, items: { teacherUserId: teacherId, students: [], teacher: null } };

    const students = await this.prisma.studentProfile.findMany({
      where: { cohortId },
      select: { userId: true, user: { select: { name: true } } },
    });

    const teacher = await this.prisma.user.findUnique({
      where: { id: teacherId },
      select: { id: true, name: true },
    });

    return {
      ok: true,
      items: {
        teacherUserId: teacherId,
        teacher: teacher ? { id: teacher.id, name: teacher.name } : null,
        students: students.map((s) => ({ id: s.userId, name: s.user?.name ?? '' })),
        studentUserIds: students.map((s) => s.userId),
      },
    };
  }
}
