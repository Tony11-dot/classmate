import * as bcrypt from 'bcrypt';
import { BadRequestException, ForbiddenException, Injectable, HttpException, HttpStatus, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { hasAnyRole } from '../auth/permissions';
import { RealtimeService } from '../realtime/realtime.service';
import { NotificationsHubService } from '../notifications/notifications-hub.service';
import { ParentNotificationsEvents } from '../parent/parent-notifications.events';

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

  constructor(
    private readonly prisma: PrismaService,
    private readonly realtime: RealtimeService,
    private readonly hub: NotificationsHubService,
    private readonly parentEvents: ParentNotificationsEvents,
  ) {}

  /// Resolve a teacher-level audience (the targetType + targetStudentIds
  /// + targetCohortIds + targetGrades fields that almost every teacher
  /// create endpoint shares) into the de-duped list of student userIds
  /// it should notify. Wraps the hub's audience expander with the
  /// teacher's schoolId so EVERYONE resolves to "everyone in this school".
  private async _audienceUserIds(
    user: any,
    record: {
      targetType?: string | null;
      targetStudentIds?: string[];
      targetCohortIds?: string[];
      targetGrades?: number[];
    },
  ): Promise<string[]> {
    const schoolId = (user as any)?.schoolId ?? null;
    return this.hub.expandAudience({
      schoolId,
      targetType: record.targetType ?? null,
      targetStudentIds: record.targetStudentIds ?? [],
      targetCohortIds: record.targetCohortIds ?? [],
      targetGrades: record.targetGrades ?? [],
    });
  }

  private ensureTeacher(user: any) {
    if (!hasAnyRole(user, ['TEACHER','ADMIN']))
      throw new ForbiddenException('Teacher only');
  }

  /// Hardcoded fallback bell schedule. Kept in sync with the same
  /// constant in schedule.service.ts so teacher + student views always
  /// resolve identical default times.
  private static readonly PERIOD_TIME_DEFAULTS: Record<number, { start: string; end: string }> = {
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

  /// Loads the school's SchoolPeriodDefault rows once per request.
  /// Empty map when the school has no config; `_resolvePeriodTimes`
  /// then falls through to PERIOD_TIME_DEFAULTS.
  private async _loadSchoolPeriodTimes(
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
      // School period defaults are optional infra — never block schedule
      // fetch on a lookup failure.
    }
    return out;
  }

  /// Effective times for a period. Per-slot override wins; then school
  /// bell schedule; then hardcoded defaults.
  private _resolvePeriodTimes(
    period: number,
    slot: { startTime?: string | null; endTime?: string | null },
    schoolDefaults: Map<number, { start: string; end: string }>,
  ): { start: string; end: string } {
    if (slot.startTime && slot.endTime) {
      return { start: slot.startTime, end: slot.endTime };
    }
    const fromSchool = schoolDefaults.get(period);
    if (fromSchool) return fromSchool;
    return TeacherService.PERIOD_TIME_DEFAULTS[period] ?? { start: '', end: '' };
  }

  async todaySchedule(user: any) {
    this.ensureTeacher(user);

    const teacherId = user.id ?? user.sub;
    const now = new Date();
    const dayOfWeek = dayOfWeekInJerusalem(now);
    const dateYmd = ymdInJerusalem(now);
    const date = parseYmdToUtcMidnight(dateYmd);

    const slots = await this.prisma.scheduleSlot.findMany({
      where: { dayOfWeek, teacherId },
      orderBy: [{ period: 'asc' }],
      include: {
        cohorts: { include: { cohort: true } },
        classroom: { select: { id: true, name: true, subject: true } },
      },
    });

    if (slots.length === 0) return { ok: true, date: dateYmd, dayOfWeek, slots: [] };

    const out: any[] = slots.map((t) => ({
      period: t.period,
      source: 'TEMPLATE',
      subject: (t as any).subject ?? t.classroom?.subject ?? null,
      classroomId: t.classroomId,
      classroomName: t.classroom?.name ?? null,
      cohorts: t.cohorts.map((sc) => ({
        id: sc.cohort.id,
        name: sc.cohort.name,
        grade: sc.cohort.grade,
        grades: Array.isArray((sc.cohort as any).grades) && (sc.cohort as any).grades.length
          ? (sc.cohort as any).grades
          : [sc.cohort.grade],
      })),
    }));

    out.sort((a, b) => a.period - b.period);
    return { ok: true, date: dateYmd, dayOfWeek, slots: out };
  }

  async getAttendanceSession(
    user: any,
    query: { cohortId?: string; date?: string; period: number; slotId?: string },
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
    const slotIdHint = (query.slotId ?? '').trim();

    // Resolve the slot. Prefer the explicit slotId hint (lets us
    // disambiguate when a teacher has multiple slots at the same
    // day/period — e.g. one cohort vs another). Fall back to day+period
    // for older callers that don't send slotId yet.
    const slotForTeacher = slotIdHint
      ? await this.prisma.scheduleSlot.findFirst({
          where: { id: slotIdHint, teacherId },
          include: {
            cohorts: { select: { cohortId: true } },
            students: { select: { studentId: true } },
          },
        })
      : await this.prisma.scheduleSlot.findFirst({
          where: { dayOfWeek, period, teacherId },
          include: {
            cohorts: { select: { cohortId: true } },
            students: { select: { studentId: true } },
          },
        });

    if (!cohortId) {
      cohortId = slotForTeacher?.cohorts?.[0]?.cohortId ?? '';
    }

    if (slotForTeacher?.teacherId && slotForTeacher.teacherId !== teacherId) {
      throw new ForbiddenException('Not your slot');
    }

    // Key the session by cohort when there is one; otherwise by the slot
    // (periods targeted by grade or individual students have no cohort).
    const sessionSlotId = slotForTeacher?.id ?? (slotIdHint || null);
    if (!cohortId && !sessionSlotId) {
      throw new BadRequestException(
        'No teacher schedule slot found for that day/period (provide cohortId or slotId)',
      );
    }

    const session = cohortId
      ? await this.prisma.attendanceSession.upsert({
          where: { cohortId_date_period: { cohortId, date, period } },
          update: {},
          create: { cohortId, date, period },
          include: { records: true, cohort: true },
        })
      : await this.prisma.attendanceSession.upsert({
          where: { slotId_date_period: { slotId: sessionSlotId!, date, period } },
          update: {},
          create: { slotId: sessionSlotId!, date, period },
          include: { records: true, cohort: true },
        });

    // Build the roster from the slot's ACTUAL audience union — cohorts
    // attached to the slot, direct student attaches, and by-grade
    // audience. Without this, slots that include students from outside
    // the primary cohort (custom roster, by-grade, multi-cohort) would
    // silently drop the missing students.
    const cohortIdsForRoster: string[] = (slotForTeacher?.cohorts ?? [])
      .map((c: any) => c.cohortId)
      .filter((id: any) => typeof id === 'string' && id.length > 0);
    if (cohortIdsForRoster.length === 0) cohortIdsForRoster.push(cohortId);

    const directStudentIds: string[] = (slotForTeacher?.students ?? [])
      .map((s: any) => s.studentId)
      .filter((id: any) => typeof id === 'string' && id.length > 0);

    const audienceGrade = (slotForTeacher as any)?.audienceGrade ?? null;

    // Cohort union
    const cohortLinks = cohortIdsForRoster.length > 0
      ? await this.prisma.studentCohort.findMany({
          where: { cohortId: { in: cohortIdsForRoster } },
          select: { studentId: true, student: { select: { userId: true, user: { select: { name: true, displayName: true } } } } },
        })
      : [];

    // By-grade resolution — every student whose profile.cohort grade
    // matches OR direct User.grade matches, scoped to the slot's school.
    let gradeLinks: Array<{ studentId: string; student: { userId: string; user: { name: string; displayName: string | null } } }> = [];
    if (typeof audienceGrade === 'number' && (slotForTeacher as any)?.schoolId) {
      const gradeRows = await this.prisma.studentProfile.findMany({
        where: {
          user: { schoolId: (slotForTeacher as any).schoolId },
          OR: [
            { cohort: { grade: audienceGrade } },
            { user: { grade: audienceGrade } as any },
          ],
        },
        select: { userId: true, user: { select: { name: true, displayName: true } } },
      });
      gradeLinks = gradeRows.map((p) => ({
        studentId: p.userId,
        student: { userId: p.userId, user: p.user },
      }));
    }

    // Direct student attaches
    const directLinks = directStudentIds.length > 0
      ? await this.prisma.user.findMany({
          where: { id: { in: directStudentIds } },
          select: { id: true, name: true, displayName: true },
        })
      : [];

    // Union — dedupe by userId.
    const byUserId = new Map<string, { userId: string; name: string; displayName: string | null }>();
    for (const l of cohortLinks) {
      byUserId.set(l.studentId, { userId: l.studentId, name: l.student.user.name, displayName: l.student.user.displayName });
    }
    for (const l of gradeLinks) {
      byUserId.set(l.studentId, { userId: l.studentId, name: l.student.user.name, displayName: l.student.user.displayName });
    }
    for (const u of directLinks) {
      byUserId.set(u.id, { userId: u.id, name: u.name, displayName: u.displayName });
    }

    const students = [...byUserId.values()].sort((a, b) =>
      (a.name ?? '').localeCompare(b.name ?? ''),
    );

    const recordByStudent = new Map(
      session.records.map((r) => [r.studentId, r]),
    );

    return {
      cohort: session.cohort
        ? {
            id: session.cohort.id,
            name: session.cohort.name,
            grade: (session.cohort as any).grade,
          }
        : { id: '', name: '', grade: 0 },
      date: dateYmd,
      period,
      subject: (slotForTeacher as any)?.subject ?? null,
      slotId: session.slotId ?? slotForTeacher?.id ?? null,
      students: students.map((s) => {
        const r = recordByStudent.get(s.userId) as
          | AttendanceRowLite
          | undefined;
        return {
          studentId: s.userId,
          name: s.name,
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
      update: {},
      create: {
        cohortId: body.cohortId,
        date,
        period: body.period
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

              },
            })),
          });
          // Existing inline path only creates ParentNotification rows
          // — it never poked the SSE bus, so the parent's
          // /parent/notifications/stream stayed silent until next poll.
          // Ping them here so their bell badge updates in real time.
          for (const t of targets) {
            this.parentEvents.emit({ type: 'notification.created', parentId: t.parentId });
          }
        }
      }

      // Also notify the STUDENT themselves so the attendance hit shows
      // up in their own /notifications inbox. fanOutToParents: false
      // because the explicit ParentNotification path above already
      // handled parents.
      if (__newStatus === 'ABSENT' || __newStatus === 'LATE') {
        await this.hub.notify({
          recipientUserIds: [record.studentId],
          type: 'ATTENDANCE_ALERT',
          title: __newStatus === 'ABSENT' ? 'You were marked absent' : 'You were marked late',
          body: `Period ${session.period} · ${session.date.toISOString().slice(0, 10)}`,
          data: { sessionId: record.sessionId, status: __newStatus },
          severity: 'warning',
          fanOutToParents: false,
        });
      }
    } catch (_e) {
      // don't break teacher flow on notification failures
    }

    return { ok: true, sessionId: session.id, recordId: record.id };
  }

  async bulkAttendance(
    user: any,
    body: {
      cohortId?: string;
      slotId?: string;
      date?: string;
      period: number;
      records: {
        studentId: string;
        status: 'PRESENT' | 'ABSENT' | 'LATE' | 'EXCUSED';
        note?: string;
      }[];
    },
  ) {
    this.ensureTeacher(user);

    const teacherId = user.id ?? user.sub;

    const cohortId = (body?.cohortId ?? '').trim();
    const slotId = (body?.slotId ?? '').trim();
    if (!cohortId && !slotId)
      throw new BadRequestException('cohortId or slotId is required');
    if (!Number.isInteger(body?.period))
      throw new BadRequestException('period is required');
    if (!Array.isArray(body?.records) || body.records.length === 0)
      throw new BadRequestException('records[] is required');

    const dateYmd = body.date ?? ymdInJerusalem(new Date());
    const date = parseYmdToUtcMidnight(dateYmd);

    // Key by cohort when present; otherwise by slot (grade/individual-student
    // periods have no cohort).
    const session = cohortId
      ? await this.prisma.attendanceSession.upsert({
          where: { cohortId_date_period: { cohortId, date, period: body.period } },
          update: {},
          create: { cohortId, date, period: body.period },
        })
      : await this.prisma.attendanceSession.upsert({
          where: { slotId_date_period: { slotId, date, period: body.period } },
          update: {},
          create: { slotId, date, period: body.period },
        });

    const studentIds = body.records.map((r) => r.studentId);
    let okSet: Set<string>;
    if (cohortId) {
      // Allow any student enrolled in this cohort via StudentCohort (multi-cohort aware)
      const cohortLinks = await this.prisma.studentCohort.findMany({
        where: { cohortId, studentId: { in: studentIds } },
        select: { studentId: true },
      });
      okSet = new Set(cohortLinks.map((l) => l.studentId));
    } else {
      // Slot-keyed period — the roster came from getAttendanceSession (the
      // slot's grade/direct audience). Accept every sent student that is a
      // real user.
      const users = await this.prisma.user.findMany({
        where: { id: { in: studentIds } },
        select: { id: true },
      });
      okSet = new Set(users.map((u) => u.id));
    }

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
            } else {
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

                  },
                })),
              });
              for (const t of targets) {
                this.parentEvents.emit({ type: 'notification.created', parentId: t.parentId });
              }
            }
          }
        }

        // Notify the student themselves (the parents path above
        // handles parents — no need to fan out).
        if (__newStatus === 'ABSENT' || __newStatus === 'LATE') {
          await this.hub.notify({
            recipientUserIds: [__upserted.studentId],
            type: 'ATTENDANCE_ALERT',
            title: __newStatus === 'ABSENT' ? 'You were marked absent' : 'You were marked late',
            body: `Period ${session.period} · ${session.date.toISOString().slice(0, 10)}`,
            data: { sessionId: __upserted.sessionId, status: __newStatus },
            severity: 'warning',
            fanOutToParents: false,
          });
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
  async schoolStudents(user: any) {
    this.ensureTeacher(user);
    const schoolId = user.schoolId ?? null;
    const students = await this.prisma.user.findMany({
      where: {
        ...(schoolId ? { schoolId } : {}),
        roles: { some: { role: 'STUDENT' } },
      },
      select: {
        id: true,
        name: true,
        displayName: true,
        email: true,
        studentProfile: {
          select: {
            cohortId: true,
            cohort: { select: { name: true, grade: true } },
          },
        },
      },
      orderBy: { name: 'asc' },
    });
    return {
      ok: true,
      students: students.map((s) => ({
        studentId: s.id,
        name: s.displayName ?? s.name,
        email: s.email,
        cohortId: s.studentProfile?.cohortId ?? null,
        cohortName: '',
        grade: s.studentProfile?.cohort?.grade ?? null,
      })),
    };
  }

  /// Same shape as schoolStudents but for PARENT users — each parent is
  /// returned with the list of children linked via APPROVED ParentChild.
  /// Powers the announcement audience picker so authors can target an
  /// individual parent (with their kids' names shown inline for context)
  /// instead of broadcasting to every parent in the school.
  async schoolParents(user: any) {
    this.ensureTeacher(user);
    const schoolId = user.schoolId ?? null;
    const parents = await this.prisma.user.findMany({
      where: {
        ...(schoolId ? { schoolId } : {}),
        roles: { some: { role: 'PARENT' } },
      },
      select: {
        id: true,
        name: true,
        displayName: true,
        email: true,
        parentLinks: {
          where: { status: 'APPROVED' as any },
          select: {
            child: {
              select: {
                id: true,
                name: true,
                displayName: true,
                studentProfile: {
                  select: { cohort: { select: { name: true, grade: true } } },
                },
              },
            },
          },
        },
      },
      orderBy: { name: 'asc' },
    });
    return {
      ok: true,
      parents: parents.map((p) => ({
        parentId: p.id,
        name: p.displayName ?? p.name ?? p.email,
        email: p.email,
        children: p.parentLinks.map((l) => ({
          studentId: l.child.id,
          name: l.child.displayName ?? l.child.name,
          grade: l.child.studentProfile?.cohort?.grade ?? null,
          cohortName: l.child.studentProfile?.cohort?.name ?? '',
        })),
      })),
    };
  }

  async listAttendanceSessions(user: any, query: { from?: string; to?: string }) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;

    const fromDt = query.from ? new Date(`${query.from}T00:00:00.000Z`) : new Date(Date.now() - 30 * 86400000);
    const toDt = query.to ? new Date(`${query.to}T23:59:59.999Z`) : new Date(Date.now() + 30 * 86400000);

    // The teacher's own slots — used both to include slot-keyed sessions
    // (grade/individual-student periods, which have no cohort) and to label
    // them by subject in the list.
    const teacherSlots = await this.prisma.scheduleSlot.findMany({
      where: { teacherId },
      select: { id: true, subject: true },
    });
    const teacherSlotIds = teacherSlots.map((s) => s.id);
    const slotSubject = new Map(teacherSlots.map((s) => [s.id, (s as any).subject ?? '']));

    const sessions = await this.prisma.attendanceSession.findMany({
      where: {
        date: { gte: fromDt, lte: toDt },
        OR: [
          { cohort: { slotCohorts: { some: { slot: { teacherId } } } } },
          { slotId: { in: teacherSlotIds } },
        ],
      },
      include: {
        cohort: { select: { id: true, name: true, grade: true } },
        records: { select: { status: true } },
      },
      orderBy: [{ date: 'desc' }, { period: 'asc' }],
      take: 200,
    });

    return sessions.map((s) => {
      const counts = { PRESENT: 0, ABSENT: 0, LATE: 0, EXCUSED: 0 };
      for (const r of s.records) counts[String(r.status) as keyof typeof counts] = (counts[String(r.status) as keyof typeof counts] ?? 0) + 1;
      const cohortShort = (s.cohort?.name ?? '').replace(/^\d+\s*-\s*/, '') ||
          ((s as any).slotId ? (slotSubject.get((s as any).slotId) ?? '') : '');
      return {
        id: s.id,
        date: s.date.toISOString().slice(0, 10),
        period: s.period,
        courseName: cohortShort,
        subject: (s as any).subject ?? cohortShort,
        cohortId: s.cohortId,
        slotId: (s as any).slotId ?? null,
        cohortName: s.cohort?.name ?? '',
        grade: s.cohort?.grade ?? null,
        totalStudents: s.records.length,
        presentCount: counts.PRESENT,
        absentCount: counts.ABSENT,
        lateCount: counts.LATE,
        excusedCount: counts.EXCUSED,
        classNote: (s as any).classNote ?? null,
      };
    });
  }

  async teacherCohorts(user: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const slotCohorts = await this.prisma.scheduleSlotCohort.findMany({
      where: { slot: { teacherId } },
      select: { cohortId: true, cohort: { select: { id: true, name: true, grade: true } } },
      distinct: ['cohortId'],
    });
    return { ok: true, cohorts: slotCohorts.map((sc) => sc.cohort) };
  }

  async schoolCohorts(user: any) {
    this.ensureTeacher(user);
    const cohorts = await this.prisma.cohort.findMany({
      where: { name: { not: 'Dev Cohort' } },
      select: { id: true, name: true, grade: true },
      orderBy: [{ grade: 'asc' }, { name: 'asc' }],
    });
    return { ok: true, cohorts };
  }

  // ── Teacher-managed cohorts (full CRUD, scoped to the teacher's school) ──────
  // Teachers can now create and manage cohorts like admins — but only within
  // their own school, and never touching legacy/global cohorts (schoolId null).

  private teacherSchoolId(user: any): string {
    const schoolId = (user as any)?.schoolId ?? null;
    if (!schoolId) throw new BadRequestException('No school associated with this account');
    return schoolId;
  }

  private normGrades(grades: any, grade: any): number[] {
    const raw = Array.isArray(grades) && grades.length ? grades : (grade != null ? [grade] : []);
    const cleaned = raw.map((g: any) => Number(g)).filter((g: number) => Number.isInteger(g) && g > 0);
    return Array.from(new Set<number>(cleaned)).sort((a, b) => a - b);
  }

  private async assertCohortInMySchool(user: any, cohortId: string) {
    const schoolId = this.teacherSchoolId(user);
    const c = await this.prisma.cohort.findFirst({ where: { id: cohortId, schoolId }, select: { id: true } });
    if (!c) throw new ForbiddenException('That cohort is not in your school');
  }

  async teacherListCohorts(user: any) {
    this.ensureTeacher(user);
    const schoolId = this.teacherSchoolId(user);
    const cohorts = await this.prisma.cohort.findMany({
      where: { schoolId },
      select: {
        id: true, name: true, grade: true, grades: true,
        studentLinks: { select: { studentId: true } },
        students: { select: { userId: true } },
      },
      orderBy: [{ grade: 'asc' }, { name: 'asc' }],
    });
    return {
      ok: true,
      cohorts: cohorts.map((c: any) => {
        const ids = new Set<string>([
          ...(c.studentLinks ?? []).map((l: any) => l.studentId),
          ...(c.students ?? []).map((s: any) => s.userId),
        ]);
        return { id: c.id, name: c.name, grade: c.grade, grades: c.grades?.length ? c.grades : [c.grade], studentCount: ids.size };
      }),
    };
  }

  async teacherCreateCohort(user: any, body: { name: string; grade?: number; grades?: number[] }) {
    this.ensureTeacher(user);
    const schoolId = this.teacherSchoolId(user);
    if (!body?.name?.trim()) throw new BadRequestException('name is required');
    const grades = this.normGrades(body?.grades, body?.grade);
    if (!grades.length) throw new BadRequestException('grade or grades[] required');
    try {
      const out = await this.prisma.cohort.create({
        data: { name: body.name.trim(), grade: grades[0], grades, schoolId } as any,
      });
      return { ok: true, cohort: out };
    } catch (e: any) {
      if (e?.code === 'P2002') throw new HttpException('Cohort name already exists', HttpStatus.CONFLICT);
      throw e;
    }
  }

  async teacherUpdateCohort(user: any, id: string, body: any) {
    this.ensureTeacher(user);
    await this.assertCohortInMySchool(user, id);
    const data: any = {};
    if (body?.name !== undefined) data.name = String(body.name).trim();
    if (body?.grades !== undefined || body?.grade !== undefined) {
      const grades = this.normGrades(body?.grades, body?.grade);
      if (!grades.length) throw new BadRequestException('grade or grades[] required');
      data.grade = grades[0];
      data.grades = grades;
    }
    const row = await this.prisma.cohort.update({ where: { id }, data });
    return { ok: true, cohort: row };
  }

  async teacherDeleteCohort(user: any, id: string) {
    this.ensureTeacher(user);
    await this.assertCohortInMySchool(user, id);
    await this.prisma.studentCohort.deleteMany({ where: { cohortId: id } });
    await this.prisma.scheduleSlotCohort.deleteMany({ where: { cohortId: id } });
    await this.prisma.cohort.delete({ where: { id } });
    return { ok: true };
  }

  async teacherCohortRoster(user: any, cohortId: string) {
    this.ensureTeacher(user);
    await this.assertCohortInMySchool(user, cohortId);
    const links = await this.prisma.studentCohort.findMany({
      where: { cohortId },
      select: { student: { select: { user: { select: { id: true, name: true } } } } },
      orderBy: { student: { user: { name: 'asc' } } },
    });
    return { ok: true, students: links.map((l: any) => ({ id: l.student.user.id, name: l.student.user.name })) };
  }

  async teacherAddStudents(user: any, cohortId: string, body: { studentIds: string[] }) {
    this.ensureTeacher(user);
    const schoolId = this.teacherSchoolId(user);
    await this.assertCohortInMySchool(user, cohortId);
    if (!Array.isArray(body?.studentIds) || !body.studentIds.length)
      throw new BadRequestException('studentIds[] is required');
    const valid = await this.prisma.user.findMany({ where: { id: { in: body.studentIds }, schoolId }, select: { id: true } });
    const ids = valid.map((u) => u.id);
    if (!ids.length) throw new ForbiddenException('None of the specified students belong to your school');
    await this.prisma.studentCohort.createMany({ data: ids.map((sid) => ({ studentId: sid, cohortId })), skipDuplicates: true });
    return { ok: true, added: ids.length };
  }

  async teacherRemoveStudent(user: any, cohortId: string, studentId: string) {
    this.ensureTeacher(user);
    await this.assertCohortInMySchool(user, cohortId);
    await this.prisma.studentCohort.delete({ where: { studentId_cohortId: { studentId, cohortId } } });
    return { ok: true };
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

    // 2) 403 if teacher has no slot linked to this cohort
    const slotCohort = await this.prisma.scheduleSlotCohort.findFirst({
      where: { cohortId, slot: { teacherId } },
      select: { slotId: true },
    });
    if (!slotCohort) throw new ForbiddenException('Not your cohort');

    // Use StudentCohort (many-to-many) so students in multiple cohorts all appear
    const links = await this.prisma.studentCohort.findMany({
      where: { cohortId },
      select: {
        studentId: true,
        student: {
          select: {
            user: { select: { name: true, displayName: true, legalName: true, email: true } },
          },
        },
      },
      orderBy: { student: { user: { name: 'asc' } } },
    });
    const rows = links.map((l) => ({ userId: l.studentId, user: l.student.user }));

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
    body: { cohortId: string; title: string; subject?: string; date?: string; maxGrade?: number },
  ) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;

    if (!body?.cohortId) throw new BadRequestException('cohortId is required');
    if (!body?.title) throw new BadRequestException('title is required');

    const cohort = await this.prisma.cohort.findUnique({ where: { id: body.cohortId } });
    if (!cohort) throw new BadRequestException('Invalid cohortId');

    const dateYmd = body.date ?? ymdInJerusalem(new Date());
    const date = parseYmdToUtcMidnight(dateYmd);

    const assessment = await this.prisma.assessment.create({
      data: {
        cohortId: body.cohortId,
        title: body.title,
        subject: body.subject ?? undefined,
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
    });
    if (!assessment) throw new BadRequestException('Invalid assessmentId');
    if (assessment.createdBy !== teacherId)
      throw new ForbiddenException('Not your assessment');

    const cohortId = assessment.cohortId ?? null;

    // School isolation: only grade students from the teacher's school
    const schoolId = (user as any)?.schoolId;
    let studentIds = body.grades.map((g) => g.studentId);
    if (schoolId) {
      const validStudents = await this.prisma.user.findMany({
        where: { id: { in: studentIds }, schoolId },
        select: { id: true },
      });
      const validSet = new Set(validStudents.map((s) => s.id));
      body.grades = body.grades.filter((g) => validSet.has(g.studentId));
      studentIds = body.grades.map((g) => g.studentId);
    }
    // No cohort-membership guard: teachers can grade any student in their
    // school regardless of whether that student belongs to the assessment's
    // cohort. School isolation above already gates by school.
    const okSet = new Set(studentIds);
    // cohortId resolved above but no longer used as a membership filter.
    void cohortId;

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
            });

            const title = a?.title ? `New grade in ${a.title}` : 'New grade posted';

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
                },
              })),
            });
            for (const p of parents) {
              this.parentEvents.emit({ type: 'notification.created', parentId: p.parentId });
            }
          }

          // Also notify the student themselves in their /notifications
          // inbox. Hub handles persistence + SSE; fanOutToParents:false
          // because the explicit ParentNotification path above already
          // covered parents.
          await this.hub.notify({
            recipientUserIds: [__studentId],
            type: 'GRADE_POSTED',
            title: 'New grade posted',
            body: `You got ${__upserted.grade}`,
            data: {
              grade: __upserted.grade,
              assessmentId: __assessmentId,
            },
            fanOutToParents: false,
          });
        } catch (_e) {
          // don't break teacher flow on notification failures
        }

      // Real-time push to student
      this.realtime.emitToUser(g.studentId, { type: 'grade_updated', studentId: g.studentId });
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

  async listAssessments(user: any, query?: { cohortId?: string }) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;

    const cohortId = (query as any)?.cohortId as string | undefined;

    if (cohortId) {
      const cohort = await this.prisma.cohort.findUnique({ where: { id: cohortId } });
      if (!cohort) throw new BadRequestException('Invalid cohortId');

      const assessments = await this.prisma.assessment.findMany({
        where: { cohortId },
        orderBy: [{ date: 'desc' }, { id: 'desc' }],
      });

      return { ok: true, cohort, assessments };
    }

    // List assessments across all cohorts this teacher teaches
    const slotCohorts = await this.prisma.scheduleSlotCohort.findMany({
      where: { slot: { teacherId } },
      select: { cohortId: true },
    });
    const cohortIds = Array.from(new Set(slotCohorts.map((sc) => sc.cohortId)));
    if (cohortIds.length === 0) return { ok: true, cohorts: [], assessments: [] };

    const [cohorts, assessments] = await Promise.all([
      this.prisma.cohort.findMany({ where: { id: { in: cohortIds } }, select: { id: true, name: true, grade: true } }),
      this.prisma.assessment.findMany({
        where: { cohortId: { in: cohortIds } },
        orderBy: [{ date: 'desc' }, { id: 'desc' }],
      }),
    ]);

    return { ok: true, cohorts, assessments };
  }

  async assessmentGrades(user: any, assessmentId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;

    if (!assessmentId)
      throw new BadRequestException('assessmentId is required');

    const assessment = await this.prisma.assessment.findUnique({
      where: { id: assessmentId },
    });
    if (!assessment) throw new BadRequestException('Invalid assessmentId');
    if (assessment.createdBy !== teacherId)
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

    const existing = await this.prisma.assessment.findUnique({ where: { id } });
    if (!existing) throw new BadRequestException('Invalid assessment id');
    if (existing.createdBy !== teacherId)
      throw new ForbiddenException('Not your assessment');

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

    const existing = await this.prisma.assessment.findUnique({ where: { id } });
    if (!existing) throw new BadRequestException('Invalid assessment id');
    if (existing.createdBy !== teacherId)
      throw new ForbiddenException('Not your assessment');

    await this.prisma.gradeRecord.deleteMany({ where: { assessmentId: id } });
    await this.prisma.assessment.delete({ where: { id } });

    return { ok: true };
  }

  // ── Classroom management ─────────────────────────────────────────────────────

  // ── School isolation helpers ──────────────────────────────────────────────
  // Every cross-user operation must go through these to prevent data leakage.

  /** Throws 403 if targetUserId does not belong to the same school as user. */
  private async assertInSchool(user: any, targetUserId: string): Promise<void> {
    const schoolId = (user as any)?.schoolId;
    if (!schoolId) return; // no school context = dev mode
    const target = await this.prisma.user.findFirst({
      where: { id: targetUserId, schoolId },
      select: { id: true },
    });
    if (!target) throw new ForbiddenException('That user does not belong to your school');
  }

  /** Returns only the IDs from the input list that belong to user's school. */
  private async filterToSchool(user: any, userIds: string[]): Promise<string[]> {
    const schoolId = (user as any)?.schoolId;
    if (!schoolId || userIds.length === 0) return userIds;
    const valid = await this.prisma.user.findMany({
      where: { id: { in: userIds }, schoolId },
      select: { id: true },
    });
    return valid.map((u) => u.id);
  }

  private async assertTeacherOwnsClassroom(teacherId: string, classroomId: string) {
    const cr = await this.prisma.classroom.findUnique({
      where: { id: classroomId },
      select: { id: true, name: true, subject: true, teacherId: true, joinCode: true },
    });
    if (!cr) throw new NotFoundException('Classroom not found');
    if (cr.teacherId !== teacherId) throw new ForbiddenException('Not your classroom');
    return cr;
  }

  private async notifyClassroomMembers(classroomId: string, title: string, body: string, data?: any) {
    try {
      const members = await this.prisma.classroomMember.findMany({
        where: { classroomId },
        select: { studentId: true },
      });
      if (!members.length) return;
      await this.prisma.notification.createMany({
        data: members.map((m) => ({
          userId: m.studentId,
          type: 'CLASSROOM_UPDATE',
          title,
          body,
          data: data ?? {},
          severity: 'info',
        })) as any[],
        skipDuplicates: true,
      });
    } catch {}
  }

  private async emitToClassroomMembers(classroomId: string, event: Parameters<RealtimeService['emitToUsers']>[1]) {
    try {
      const members = await this.prisma.classroomMember.findMany({
        where: { classroomId },
        select: { studentId: true },
      });
      if (!members.length) return;
      this.realtime.emitToUsers(members.map((m) => m.studentId), event);
    } catch {}
  }

  private async emitToTeacherClassroomOwner(classroomId: string, event: Parameters<RealtimeService['emitToUsers']>[1]) {
    try {
      const cr = await this.prisma.classroom.findUnique({ where: { id: classroomId }, select: { teacherId: true } });
      if (cr?.teacherId) this.realtime.emitToUser(cr.teacherId, event);
    } catch {}
  }

  /// Generate a short, unique, human-typable classroom join code. Uses an
  /// unambiguous charset (no 0/O, 1/I/L) and retries on the rare collision
  /// against the unique index.
  private async generateUniqueClassroomCode(): Promise<string> {
    const charset = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    for (let attempt = 0; attempt < 20; attempt++) {
      let code = '';
      for (let i = 0; i < 6; i++) {
        code += charset[Math.floor(Math.random() * charset.length)];
      }
      const existing = await this.prisma.classroom.findUnique({
        where: { joinCode: code },
        select: { id: true },
      });
      if (!existing) return code;
    }
    // Extremely unlikely fallback — widen with a timestamp tail.
    return `C${Date.now().toString(36).toUpperCase().slice(-7)}`;
  }

  /// Returns the classroom's join code, generating + persisting a unique one
  /// if it doesn't have one yet (backfills legacy rows on first access).
  private async ensureClassroomCode(classroomId: string, current?: string | null): Promise<string> {
    if (current && current.trim()) return current.trim();
    const code = await this.generateUniqueClassroomCode();
    try {
      await this.prisma.classroom.update({
        where: { id: classroomId },
        data: { joinCode: code },
      });
    } catch (_) {
      // Lost a race — re-read whatever code won.
      const row = await this.prisma.classroom.findUnique({
        where: { id: classroomId },
        select: { joinCode: true },
      });
      return row?.joinCode ?? code;
    }
    return code;
  }

  async createClassroom(user: any, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const schoolId = user.schoolId ?? null;

    const name = String(body?.name ?? '').trim();
    const subject = String(body?.subject ?? '').trim();
    if (!name) throw new BadRequestException('name is required');
    if (!subject) throw new BadRequestException('subject is required');

    const joinCode = await this.generateUniqueClassroomCode();
    const classroom = await this.prisma.classroom.create({
      data: { name, subject, teacherId, schoolId, joinCode },
    });

    // Add students individually
    const studentIds: string[] = Array.isArray(body?.studentIds) ? body.studentIds : [];
    // Expand cohorts to their members
    const cohortIds: string[] = Array.isArray(body?.cohortIds) ? body.cohortIds : [];
    if (cohortIds.length) {
      const cohortStudents = await this.prisma.studentCohort.findMany({
        where: { cohortId: { in: cohortIds } },
        select: { studentId: true },
      });
      cohortStudents.forEach((cs) => { if (!studentIds.includes(cs.studentId)) studentIds.push(cs.studentId); });
    }

    if (studentIds.length) {
      await this.prisma.classroomMember.createMany({
        data: studentIds.map((sid) => ({ classroomId: classroom.id, studentId: sid })),
        skipDuplicates: true,
      });
    }

    return { ok: true, classroom: { ...classroom, memberCount: studentIds.length } };
  }

  async listClassrooms(user: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const classrooms = await this.prisma.classroom.findMany({
      where: { teacherId },
      orderBy: { createdAt: 'desc' },
      select: {
        id: true, name: true, subject: true, createdAt: true, joinCode: true,
        _count: { select: { members: true } },
      },
    });
    return { ok: true, classrooms: classrooms.map((c) => ({ ...c, memberCount: c._count.members })) };
  }

  async getClassroom(user: any, classroomId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const cr = await this.assertTeacherOwnsClassroom(teacherId, classroomId);

    const [assignmentCount, materialCount, meetingCount, messageCount, memberCount] = await Promise.all([
      this.prisma.classroomAssignment.count({ where: { classroomId } }),
      this.prisma.classroomMaterial.count({ where: { classroomId } }),
      this.prisma.classroomMeeting.count({ where: { classroomId } }),
      this.prisma.classroomMessage.count({ where: { classroomId } }),
      this.prisma.classroomMember.count({ where: { classroomId } }),
    ]);

    const joinCode = await this.ensureClassroomCode(cr.id, (cr as any).joinCode);

    return {
      ok: true,
      classroom: { id: cr.id, name: cr.name, subject: cr.subject, joinCode },
      stats: { assignmentCount, materialCount, meetingCount, messageCount, memberCount },
    };
  }

  async updateClassroom(user: any, classroomId: string, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsClassroom(teacherId, classroomId);
    const data: any = {};
    if (body?.name !== undefined) data.name = String(body.name).trim();
    if (body?.subject !== undefined) data.subject = String(body.subject).trim();
    const cr = await this.prisma.classroom.update({ where: { id: classroomId }, data });
    return { ok: true, classroom: cr };
  }

  async deleteClassroom(user: any, classroomId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsClassroom(teacherId, classroomId);
    await this.prisma.classroom.delete({ where: { id: classroomId } });
    return { ok: true };
  }

  async addClassroomMembers(user: any, classroomId: string, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsClassroom(teacherId, classroomId);

    const studentIds: string[] = Array.isArray(body?.studentIds) ? body.studentIds : [];
    const cohortIds: string[] = Array.isArray(body?.cohortIds) ? body.cohortIds : [];

    if (cohortIds.length) {
      const cohortStudents = await this.prisma.studentCohort.findMany({
        where: { cohortId: { in: cohortIds } },
        select: { studentId: true },
      });
      cohortStudents.forEach((cs) => { if (!studentIds.includes(cs.studentId)) studentIds.push(cs.studentId); });
    }

    if (!studentIds.length) throw new BadRequestException('No students specified');

    // School isolation: only add students from the same school
    const schoolStudentIds = await this.filterToSchool(user, studentIds);
    if (!schoolStudentIds.length) throw new ForbiddenException('None of the specified students belong to your school');

    await this.prisma.classroomMember.createMany({
      data: schoolStudentIds.map((sid) => ({ classroomId, studentId: sid })),
      skipDuplicates: true,
    });

    try {
      const classroom = await this.prisma.classroom.findUnique({
        where: { id: classroomId },
        select: { name: true, subject: true },
      });
      const subject = classroom?.subject ?? classroom?.name ?? 'a class';
      await this.hub.notify({
        recipientUserIds: schoolStudentIds,
        type: 'CLASSROOM_INVITE',
        title: `Added to ${subject}`,
        body: `You're now a member of ${classroom?.name ?? 'a new classroom'}.`,
        data: { classroomId },
      });
    } catch (e) { console.error('[teacher] classroom-add notify failed:', e); }

    return { ok: true, added: schoolStudentIds.length };
  }

  async removeClassroomMember(user: any, classroomId: string, studentId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsClassroom(teacherId, classroomId);
    await this.prisma.classroomMember.deleteMany({ where: { classroomId, studentId } });
    return { ok: true };
  }

  async listClassroomMembers(user: any, classroomId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const cr = await this.assertTeacherOwnsClassroom(teacherId, classroomId);

    const [members, teacher] = await Promise.all([
      this.prisma.classroomMember.findMany({
        where: { classroomId },
        orderBy: { joinedAt: 'asc' },
        select: {
          studentId: true,
          joinedAt: true,
          student: {
            select: {
              name: true,
              studentProfile: { select: { cohort: { select: { name: true, grade: true } } } },
            },
          },
        },
      }),
      this.prisma.user.findUnique({
        where: { id: teacherId },
        select: { id: true, name: true, displayName: true },
      }),
    ]);

    return {
      ok: true,
      teacher: {
        userId: teacherId,
        name: teacher?.displayName ?? teacher?.name ?? '',
        role: 'TEACHER',
      },
      members: members.map((m) => ({
        studentId: m.studentId,
        name: m.student?.name ?? '',
        grade: m.student?.studentProfile?.cohort?.grade ?? null,
        cohortName: m.student?.studentProfile?.cohort?.name ?? null,
        joinedAt: m.joinedAt,
      })),
    };
  }

  async getClassroomChat(user: any, classroomId: string, opts: { limit: number; cursor?: string }) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsClassroom(teacherId, classroomId);
    const take = Math.min(Math.max(opts.limit ?? 30, 1), 100);
    const rows = await this.prisma.classroomMessage.findMany({
      where: { classroomId, ...(opts.cursor ? { id: { lt: opts.cursor } } : {}) },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take,
    });
    // Resolve sender names from User.name (with displayName / nameEn
    // preferred when present). The client used to look these up via
    // classroom roster, which fell through to "Unknown" for any sender
    // who had since left the classroom — see student.classrooms.chatList
    // for the same enrichment.
    const senderIds = Array.from(new Set(rows.map((r: any) => r.senderUserId).filter(Boolean)));
    const users = senderIds.length
      ? await this.prisma.user.findMany({
          where: { id: { in: senderIds } },
          select: { id: true, name: true, displayName: true, nameEn: true } as any,
        })
      : [];
    const nameById = new Map<string, string>();
    for (const u of users as any[]) {
      const v = String(u.displayName ?? u.nameEn ?? u.name ?? '').trim();
      if (v) nameById.set(u.id, v);
    }
    const items = rows.reverse().map((r: any) => ({
      ...r,
      senderName: nameById.get(r.senderUserId) ?? null,
    }));
    return { ok: true, items };
  }

  async sendClassroomChat(user: any, classroomId: string, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsClassroom(teacherId, classroomId);
    const text = String(body?.text ?? '').trim();
    if (!text) throw new BadRequestException('text is required');
    const msg = await this.prisma.classroomMessage.create({
      data: { classroomId, senderUserId: teacherId, kind: 'TEXT' as any, text },
    });
    // Push to every classroom member so students' chat refreshes
    // immediately, matching how the student->teacher direction works.
    void this.emitToClassroomMembers(classroomId, { type: 'classroom_message', classroomId });
    return { ok: true, message: msg };
  }

  async listClassroomAssignments(user: any, classroomId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsClassroom(teacherId, classroomId);
    const items = await this.prisma.classroomAssignment.findMany({
      where: { classroomId },
      orderBy: [{ dueAt: 'asc' }, { createdAt: 'desc' }],
    });
    return { ok: true, items };
  }

  async createClassroomAssignment(user: any, classroomId: string, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const cr = await this.assertTeacherOwnsClassroom(teacherId, classroomId);
    const title = String(body?.title ?? '').trim();
    if (!title) throw new BadRequestException('title is required');
    const dueAt = body?.dueAt ? new Date(String(body.dueAt)) : null;
    const bodyText = body?.body ? String(body.body).trim() : null;
    const attachments = Array.isArray(body?.attachments) ? body.attachments : [];
    const item = await this.prisma.classroomAssignment.create({
      data: { classroomId, title, body: bodyText ?? undefined, dueAt: dueAt ?? undefined, createdBy: teacherId, attachments } as any,
    });
    const dueLabel = dueAt ? ` — due ${dueAt.toLocaleDateString()}` : '';
    await this.notifyClassroomMembers(classroomId, `New assignment: ${title}`, `${cr.name}${dueLabel}`, { type: 'NEW_ASSIGNMENT', assignmentId: item.id, classroomId });
    void this.emitToClassroomMembers(classroomId, { type: 'assignment_created', classroomId });
    return { ok: true, item };
  }

  async updateClassroomAssignment(user: any, classroomId: string, id: string, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsClassroom(teacherId, classroomId);
    const data: any = {};
    if (body?.title !== undefined) data.title = String(body.title).trim();
    if (body?.body !== undefined) data.body = body.body ? String(body.body).trim() : null;
    if (body?.dueAt !== undefined) data.dueAt = body.dueAt ? new Date(String(body.dueAt)) : null;
    const item = await this.prisma.classroomAssignment.update({ where: { id }, data });
    return { ok: true, item };
  }

  async deleteClassroomAssignment(user: any, classroomId: string, id: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsClassroom(teacherId, classroomId);
    const item = await this.prisma.classroomAssignment.findFirst({ where: { id, classroomId }, select: { teacherAssignmentId: true, title: true } });
    await this.prisma.classroomAssignment.deleteMany({ where: { id, classroomId } });
    if (item) {
      if (item.teacherAssignmentId) {
        await this.prisma.teacherAssignment.deleteMany({ where: { id: item.teacherAssignmentId, teacherId } });
      } else {
        await this.prisma.teacherAssignment.deleteMany({ where: { title: item.title, teacherId } });
      }
    }
    return { ok: true };
  }

  async listClassroomMaterials(user: any, classroomId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsClassroom(teacherId, classroomId);
    const items = await this.prisma.classroomMaterial.findMany({
      where: { classroomId },
      orderBy: [{ createdAt: 'desc' }],
    });
    return { ok: true, items };
  }

  async createClassroomMaterial(user: any, classroomId: string, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const cr = await this.assertTeacherOwnsClassroom(teacherId, classroomId);
    const title = String(body?.title ?? '').trim();
    const url = String(body?.url ?? body?.fileUrl ?? '').trim();
    if (!title) throw new BadRequestException('title is required');
    const attachments = Array.isArray(body?.attachments) ? body.attachments : [];
    // Require either a URL or at least one attachment
    const effectiveUrl = url || (attachments[0]?.url ?? '');
    if (!effectiveUrl) throw new BadRequestException('url or at least one attachment is required');
    if (url) { try { new URL(url); } catch { throw new BadRequestException('url must be a valid URL (include https://)'); } }
    const item = await this.prisma.classroomMaterial.create({
      data: { classroomId, title, url: effectiveUrl, description: body?.description ? String(body.description).trim() : undefined, mime: body?.mime ? String(body.mime).trim() : undefined, createdBy: teacherId, attachments } as any,
    });
    await this.notifyClassroomMembers(classroomId, `New material: ${title}`, cr.name, { type: 'NEW_MATERIAL', materialId: item.id, classroomId });
    void this.emitToClassroomMembers(classroomId, { type: 'material_created', classroomId });
    return { ok: true, item };
  }

  async deleteClassroomMaterial(user: any, classroomId: string, id: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsClassroom(teacherId, classroomId);
    const item = await this.prisma.classroomMaterial.findFirst({ where: { id, classroomId }, select: { teacherMaterialId: true, title: true } });
    await this.prisma.classroomMaterial.deleteMany({ where: { id, classroomId } });
    if (item) {
      if (item.teacherMaterialId) {
        await this.prisma.teacherMaterial.deleteMany({ where: { id: item.teacherMaterialId, teacherId } });
      } else {
        await this.prisma.teacherMaterial.deleteMany({ where: { title: item.title, teacherId } });
      }
    }
    return { ok: true };
  }

  async listClassroomMeetings(user: any, classroomId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsClassroom(teacherId, classroomId);
    const items = await this.prisma.classroomMeeting.findMany({
      where: { classroomId },
      orderBy: [{ startsAt: 'asc' }],
      select: { id: true, title: true, startsAt: true, endsAt: true, link: true, createdAt: true },
    });
    return { ok: true, items };
  }

  async createClassroomMeeting(user: any, classroomId: string, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const cr = await this.assertTeacherOwnsClassroom(teacherId, classroomId);
    const title = String(body?.title ?? '').trim();
    const link = String(body?.link ?? '').trim();
    const startsAt = body?.startsAt ? new Date(String(body.startsAt)) : new Date();
    if (!title || !link) throw new BadRequestException('title and link are required');
    try { new URL(link); } catch { throw new BadRequestException('link must be a valid URL (include https://)'); }
    const endsAt = body?.endsAt ? new Date(String(body.endsAt)) : null;
    const item = await this.prisma.classroomMeeting.create({
      data: { classroomId, title, link, startsAt, endsAt: endsAt ?? undefined, createdBy: teacherId },
    });
    const timeLabel = startsAt.toLocaleString('en-US', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
    await this.notifyClassroomMembers(classroomId, `Meeting: ${title}`, `${cr.name} — ${timeLabel}`, { type: 'NEW_MEETING', meetingId: item.id, classroomId });
    void this.emitToClassroomMembers(classroomId, { type: 'meeting_created', classroomId });
    return { ok: true, item };
  }

  async deleteClassroomMeeting(user: any, classroomId: string, id: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsClassroom(teacherId, classroomId);
    const item = await this.prisma.classroomMeeting.findFirst({ where: { id, classroomId }, select: { teacherMeetingId: true, title: true } });
    await this.prisma.classroomMeeting.deleteMany({ where: { id, classroomId } });
    if (item) {
      if (item.teacherMeetingId) {
        await this.prisma.teacherMeeting.deleteMany({ where: { id: item.teacherMeetingId, teacherId } });
      } else {
        await this.prisma.teacherMeeting.deleteMany({ where: { title: item.title, teacherId } });
      }
    }
    return { ok: true };
  }

  async listAssignmentSubmissions(user: any, classroomId: string, assignmentId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsClassroom(teacherId, classroomId);

    const [submissions, members] = await Promise.all([
      this.prisma.assignmentSubmission.findMany({
        where: { assignmentId },
        select: { id: true, studentId: true, note: true, files: true, submittedAt: true, student: { select: { name: true } } } as any,
        orderBy: { submittedAt: 'desc' },
      }).catch(() => []),
      this.prisma.classroomMember.findMany({
        where: { classroomId },
        select: { studentId: true, student: { select: { name: true } } },
      }),
    ]);

    const submittedIds = new Set((submissions as any[]).map((s) => s.studentId));

    return {
      ok: true,
      assignmentId,
      submissions,
      pending: members
        .filter((m) => !submittedIds.has(m.studentId))
        .map((m) => ({ studentId: m.studentId, name: m.student?.name ?? '' })),
      submittedCount: (submissions as any[]).length,
      totalCount: members.length,
    };
  }

  async resetAssignmentSubmission(user: any, assignmentId: string, studentId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertInSchool(user, studentId);
    // Verify the assignment belongs to one of teacher's classrooms
    const assignment = await this.prisma.classroomAssignment.findFirst({
      where: { id: assignmentId, classroom: { teacherId } },
      select: { id: true },
    });
    if (!assignment) throw new NotFoundException('Assignment not found or not yours');
    await this.prisma.assignmentSubmission.deleteMany({
      where: { assignmentId, studentId },
    });
    return { ok: true };
  }

  async classroomAnalytics(user: any, classroomId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const cr = await this.assertTeacherOwnsClassroom(teacherId, classroomId);

    const memberIds = (await this.prisma.classroomMember.findMany({
      where: { classroomId },
      select: { studentId: true },
    })).map((m) => m.studentId);

    const [assignments, attendance30] = await Promise.all([
      this.prisma.classroomAssignment.count({ where: { classroomId } }),
      this.prisma.attendanceRecord.findMany({
        where: { studentId: { in: memberIds }, markedAt: { gte: new Date(Date.now() - 30 * 86400000) } },
        select: { status: true },
      }),
    ]);

    const attCounts: Record<string, number> = {};
    for (const r of attendance30 as any[]) attCounts[String(r.status)] = (attCounts[String(r.status)] ?? 0) + 1;
    const total = attendance30.length;
    const present = (attCounts['PRESENT'] ?? 0) + (attCounts['LATE'] ?? 0) + (attCounts['EXCUSED'] ?? 0);

    return {
      ok: true,
      classroomId,
      classroomName: cr.name,
      subject: cr.subject,
      totalStudents: memberIds.length,
      totalAssignments: assignments,
      attendanceRate: total > 0 ? Math.round((present / total) * 100) : null,
    };
  }

  async getStudentProfile(user: any, studentId: string) {
    this.ensureTeacher(user);
    await this.assertInSchool(user, studentId);

    const [profile, recentGrades, recentAttendance, submissions] = await Promise.all([
      this.prisma.studentProfile.findUnique({
        where: { userId: studentId },
        select: { cohortId: true, user: { select: { name: true, email: true } } },
      }),
      this.prisma.gradeRecord.findMany({
        where: { studentId },
        select: {
          grade: true,
          assessment: { select: { title: true, maxGrade: true, date: true, subject: true } },
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
        subject: g.assessment?.subject ?? '',
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
    const schoolId = String((user as any)?.schoolId ?? '');

    // Anchor + week-start.  Honor the client-supplied weekOf (Mon-start
    // strings from the teacher app, Sun-start from elsewhere); fall back
    // to today's Sun-start in Jerusalem.
    const tz = 'Asia/Jerusalem';
    const now = new Date();
    let anchor: Date;
    if (weekOf && /^\d{4}-\d{2}-\d{2}$/.test(weekOf)) {
      anchor = new Date(weekOf + 'T00:00:00.000Z');
    } else {
      const todayYmd = new Intl.DateTimeFormat('en-CA', { timeZone: tz }).format(now);
      anchor = new Date(todayYmd + 'T00:00:00.000Z');
    }
    const anchorDow = new Intl.DateTimeFormat('en-US', { timeZone: tz, weekday: 'short' }).format(anchor);
    const dowMap: Record<string, number> = { Sun: 0, Mon: 1, Tue: 2, Wed: 3, Thu: 4, Fri: 5, Sat: 6 };
    const dow = dowMap[anchorDow] ?? 0;
    const weekStart = new Date(anchor);
    weekStart.setUTCDate(anchor.getUTCDate() - dow);

    // School bell schedule: per-period start/end times configured under
    // Admin → School Settings → Periods. Falls back to the hardcoded
    // PERIOD_TIME_DEFAULTS below when the school hasn't set anything,
    // and to {null,null} on lookup failure. Same resolution chain the
    // student-side resolver uses (per-slot override > school default >
    // hardcoded default).
    const schoolPeriodTimes = await this._loadSchoolPeriodTimes(schoolId);

    // All slots the teacher owns — same coverage as the student
    // resolver, just keyed on slot.teacherId. Includes the relations
    // applyOverridesForDate needs (teacher name, classroom name) and
    // the fields the day-fill filter requires (freq, startDate,
    // skipDates). studentDateSkips deliberately isn't read for the
    // teacher view — those are per-student and don't affect whether
    // the teacher teaches the class.
    // Two-stage select: try with the newest columns (caption,
    // studentDateSkips) and fall back to the conservative shape if the
    // DB hasn't caught up yet. Same Railway-deploy-resilience pattern
    // used in the student resolver.
    const baseSelect: any = {
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
      teacher: { select: { id: true, name: true } },
      classroom: { select: { id: true, name: true, subject: true } },
      cohorts: { select: { cohortId: true, cohort: { select: { id: true, name: true, grade: true } } } },
      // `student` here is a StudentProfile relation (not a User row).
      // StudentProfile keys off userId and gets the display name via
      // its nested User relation — selecting id/name directly throws
      // a Prisma error and zeros out the entire slot query.
      students: {
        select: {
          studentId: true,
          student: { select: { user: { select: { name: true } } } },
        },
      },
      // Materials attached to the slot, surfaced to the teacher tile so
      // the count pill + detail sheet have something to render. Same
      // shape as the student resolver uses.
      materials: {
        select: {
          date: true,
          material: {
            select: {
              id: true, title: true, description: true,
              url: true, attachments: true, subject: true,
            },
          },
        },
      },
    };
    let slots: any[] = [];
    try {
      slots = await this.prisma.scheduleSlot.findMany({
        where: { teacherId },
        select: { ...baseSelect, caption: true } as any,
      });
    } catch (_e) {
      try {
        slots = await this.prisma.scheduleSlot.findMany({
          where: { teacherId },
          select: baseSelect as any,
        });
      } catch (e) {
        // eslint-disable-next-line no-console
        console.error('[teacher.weekSchedule] slot fetch failed', e);
        slots = [];
      }
    }


    // Emit 7 days always — Flutter (both student and teacher) matches
    // by day.date, so missing days silently render as empty. With
    // every day present, the swipe-to-different-day flow always finds
    // a match for the selected date.
    const days: any[] = [];
    for (let i = 0; i < 7; i++) {
      const dayUtc = new Date(weekStart.getTime());
      dayUtc.setUTCDate(weekStart.getUTCDate() + i);
      const dayDow = dowMap[new Intl.DateTimeFormat('en-US', { timeZone: tz, weekday: 'short' }).format(dayUtc)] ?? 0;
      const dateYmd = new Intl.DateTimeFormat('en-CA', { timeZone: 'UTC', year: 'numeric', month: '2-digit', day: '2-digit' }).format(dayUtc);

      // Mirrors schedule.service.applyOverridesForDate's template
      // filter exactly so the teacher view honours frequencyWeeks +
      // startDate anchors + skipDates the same way the student view
      // does. Previously biweekly slots showed every week and override
      // skipDates worked partially — leading to "some periods appear,
      // others don't" in the teacher schedule.
      const dayMatches = slots.filter((s: any) => {
        if (Number(s.dayOfWeek) !== dayDow) return false;
        const freq = Number(s.frequencyWeeks ?? 1);
        const sd: string | null = typeof (s as any).startDate === 'string' &&
                /^\d{4}-\d{2}-\d{2}$/.test((s as any).startDate)
            ? (s as any).startDate
            : null;
        // Once — exactly the anchor date.
        if (freq === 0) {
          return sd !== null && sd === dateYmd;
        }
        // freq >= 2: only when the date is an integer number of `freq`
        // weeks from the anchor, AND on or after it.
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
          if (!Number.isInteger(weeksSince)) return false;
          if (weeksSince % freq !== 0) return false;
        } else if (freq === 1 && sd !== null) {
          // Weekly with an optional anchor — render only on or after sd.
          if (dateYmd < sd) return false;
        }
        // Whole-day override suppression (used by admin's Override
        // conflict resolution to replace a recurring slot for a date).
        const skipDates: string[] = Array.isArray(s.skipDates) ? s.skipDates : [];
        if (skipDates.includes(dateYmd)) return false;
        return true;
      });

      const slotsOut = dayMatches
        .sort((a: any, b: any) => Number(a.period) - Number(b.period))
        .map((s: any) => {
          // Each cohort the slot covers gets its own emitted item, so
          // teaching the same period for two cohorts shows up as two
          // tiles in the teacher's day view (previously the dedup
          // dropped one of them).
          const cohorts: any[] = Array.isArray(s.cohorts) ? s.cohorts : [];
          const students: any[] = Array.isArray(s.students) ? s.students : [];
          const audienceGrade = s.audienceGrade ?? null;
          // Resolve the single audience label the teacher tile renders
          // beneath the subject. Cohort name wins; then "Grade N" when
          // by-grade; then a list of student names when by-student.
          let audienceLabel: string | null = null;
          if (cohorts.length > 0) {
            const names = cohorts
              .map((c: any) => c?.cohort?.name)
              .filter((n: any) => typeof n === 'string' && n.length > 0);
            audienceLabel = names.length === 1
              ? names[0]
              : (names.length > 1 ? `${names[0]} +${names.length - 1}` : null);
          } else if (typeof audienceGrade === 'number') {
            audienceLabel = `Grade ${audienceGrade}`;
          } else if (students.length > 0) {
            const names = students
              .map((st: any) => st?.student?.user?.name)
              .filter((n: any) => typeof n === 'string' && n.length > 0);
            audienceLabel = names.length <= 3
              ? names.join(', ')
              : `${names.slice(0, 3).join(', ')} +${names.length - 3}`;
          }
          // Resolve effective period times: per-slot override wins, then
          // the school's configured bell schedule, then the hardcoded
          // defaults. Previously this only sent the slot's override, so
          // periods on the school's default schedule rendered with no
          // time text at all.
          const periodTimes = this._resolvePeriodTimes(
            Number(s.period),
            { startTime: s.startTime, endTime: s.endTime },
            schoolPeriodTimes,
          );
          // Flatten the slot's ScheduleSlotMaterial relation into a flat
          // list the tile can render as pills + count badge. Mirrors
          // schedule.service._materialsFromSlotRow.
          // Filter by the day being rendered so an attachment added on
          // May 24 doesn't show on the teacher's May 17 view either.
          // Legacy "" entries (pre-date-scoping) keep showing on every
          // occurrence.
          const allSlotMaterials = Array.isArray(s.materials) ? s.materials : [];
          const slotMaterials = allSlotMaterials.filter((sm: any) => {
            const d = typeof sm?.date === 'string' ? sm.date : '';
            return d === dateYmd || d === '';
          });
          const attachments = slotMaterials
            .map((sm: any) => sm?.material)
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
          const base = {
            slotId: s.id,
            period: s.period,
            subject: s.subject ?? s.classroom?.subject ?? null,
            caption: typeof s.caption === 'string' ? s.caption : null,
            startTime: periodTimes.start,
            endTime: periodTimes.end,
            classroomId: s.classroomId ?? null,
            classroomName: s.classroom?.name ?? null,
            color: s.color ?? null,
            audienceGrade,
            audienceLabel,
            attachments,
            studentNames: students
              .map((st: any) => st?.student?.user?.name)
              .filter((n: any) => typeof n === 'string' && n.length > 0),
          };
          if (cohorts.length === 0) {
            return [{ ...base, cohort: null }];
          }
          return cohorts.map((c: any) => ({
            ...base,
            cohort: c.cohort ?? null,
          }));
        })
        .flat();

      days.push({ date: dateYmd, dayOfWeek: dayDow, slots: slotsOut });
    }

    const weekOfStr = new Intl.DateTimeFormat('en-CA', {
      timeZone: 'UTC',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    }).format(weekStart);
    return { ok: true, weekOf: weekOfStr, days };
  }

  async addStudentToClassroom(user: any, classroomId: string, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsClassroom(teacherId, classroomId);

    const identifier = String(body?.email ?? body?.userId ?? '').trim();
    if (!identifier) throw new BadRequestException('email or userId required');

    const schoolId = (user as any)?.schoolId;
    const student = identifier.includes('@')
      ? await this.prisma.user.findFirst({ where: { email: identifier, ...(schoolId ? { schoolId } : {}) }, select: { id: true, name: true } })
      : await this.prisma.user.findFirst({ where: { id: identifier, ...(schoolId ? { schoolId } : {}) }, select: { id: true, name: true } });
    if (!student) throw new BadRequestException('Student not found in your school');

    await this.prisma.classroomMember.upsert({
      where: { classroomId_studentId: { classroomId, studentId: student.id } },
      update: {},
      create: { classroomId, studentId: student.id },
    });

    await this.prisma.notification.create({
      data: { userId: student.id, type: 'CLASSROOM_INVITE', title: 'You were added to a classroom', body: 'A teacher added you to a new classroom.', data: { classroomId } as any, severity: 'info' },
    });

    return { ok: true, student: { id: student.id, name: student.name } };
  }

  async removeStudentFromClassroom(user: any, classroomId: string, studentId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsClassroom(teacherId, classroomId);
    await this.prisma.classroomMember.deleteMany({ where: { classroomId, studentId } });
    return { ok: true };
  }

  async getClassroomPeople(user: any, classroomId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsClassroom(teacherId, classroomId);

    const members = await this.prisma.classroomMember.findMany({
      where: { classroomId },
      select: { studentId: true, student: { select: { name: true } } },
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
        students: members.map((m) => ({ id: m.studentId, name: m.student?.name ?? '' })),
        studentUserIds: members.map((m) => m.studentId),
      },
    };
  }

  // ---- Forms ----

  async listForms(user: any) {
    this.ensureTeacher(user);
    const teacherId = String(user?.sub ?? user?.id ?? '');
    const forms = await this.prisma.schoolForm.findMany({
      where: { createdBy: teacherId },
      orderBy: { createdAt: 'desc' },
      include: { _count: { select: { responses: true } } },
    });
    return {
      forms: forms.map((f) => ({
        id: f.id,
        title: f.title,
        description: f.description ?? '',
        subject: f.subject ?? '',
        audienceLabel: f.audienceLabel ?? 'School',
        acceptingResponses: f.acceptingResponses,
        allowMultipleResponses: f.allowMultipleResponses,
        published: f.published,
        publishedAt: f.publishedAt?.toISOString() ?? null,
        questionCount: Array.isArray(f.questions) ? (f.questions as any[]).length : 0,
        responsesCount: f._count.responses,
        createdAt: f.createdAt.toISOString(),
      })),
    };
  }

  async createForm(user: any, body: any) {
    this.ensureTeacher(user);
    const teacherId = String(user?.sub ?? user?.id ?? '');
    const u = await this.prisma.user.findUnique({ where: { id: teacherId }, select: { schoolId: true } });
    if (!u?.schoolId) throw new BadRequestException('No school');
    const form = await this.prisma.schoolForm.create({
      data: {
        schoolId: u.schoolId,
        createdBy: teacherId,
        title: String(body.title ?? 'Untitled form'),
        description: body.description ? String(body.description) : null,
        subject: body.subject ? String(body.subject) : null,
        audienceLabel: body.audienceLabel ? String(body.audienceLabel) : 'Class',
        acceptingResponses: body.acceptingResponses !== false,
        allowMultipleResponses: body.allowMultipleResponses === true,
        published: body.published === true,
        publishedAt: body.published === true ? new Date() : null,
        questions: Array.isArray(body.questions) ? body.questions : [],
        targetType: typeof body.targetType === 'string' ? body.targetType : 'EVERYONE',
        targetCohortIds: Array.isArray(body.targetCohortIds) ? body.targetCohortIds : [],
        targetStudentIds: Array.isArray(body.targetStudentIds) ? body.targetStudentIds : [],
        targetGrades: Array.isArray(body.targetGrades)
          ? body.targetGrades.map((g: any) => Number(g)).filter((n: number) => Number.isFinite(n))
          : [],
      },
    });
    if (form.published) {
      try {
        const recipients = await this._audienceUserIds(user, form);
        if (recipients.length) {
          await this.hub.notify({
            recipientUserIds: recipients,
            type: 'NEW_FORM',
            title: `New form: ${form.title}`,
            body: (form.description ?? form.subject ?? '').slice(0, 200),
            data: { formId: form.id },
          });
        }
      } catch (e) { console.error('[teacher] form notify failed:', e); }
    }
    return { ok: true, form: { id: form.id } };
  }

  async updateForm(user: any, id: string, body: any) {
    this.ensureTeacher(user);
    const teacherId = String(user?.sub ?? user?.id ?? '');
    const form = await this.prisma.schoolForm.findFirst({ where: { id, createdBy: teacherId } });
    if (!form) throw new NotFoundException('Not found');
    await this.prisma.schoolForm.update({
      where: { id },
      data: {
        ...(body.title != null && { title: String(body.title) }),
        ...(body.description != null && { description: String(body.description) }),
        ...(body.subject != null && { subject: String(body.subject) }),
        ...(body.acceptingResponses != null && { acceptingResponses: Boolean(body.acceptingResponses) }),
        ...(body.published != null && {
          published: Boolean(body.published),
          publishedAt: body.published ? new Date() : null,
        }),
        ...(body.questions != null && { questions: body.questions }),
        ...(body.targetType != null && { targetType: String(body.targetType) }),
        ...(body.targetCohortIds != null && {
          targetCohortIds: Array.isArray(body.targetCohortIds) ? body.targetCohortIds : [],
        }),
        ...(body.targetStudentIds != null && {
          targetStudentIds: Array.isArray(body.targetStudentIds) ? body.targetStudentIds : [],
        }),
        ...(body.targetGrades != null && {
          targetGrades: Array.isArray(body.targetGrades)
            ? body.targetGrades.map((g: any) => Number(g)).filter((n: number) => Number.isFinite(n))
            : [],
        }),
      },
    });
    return { ok: true };
  }

  async deleteForm(user: any, id: string) {
    this.ensureTeacher(user);
    const teacherId = String(user?.sub ?? user?.id ?? '');
    await this.prisma.schoolForm.deleteMany({ where: { id, createdBy: teacherId } });
    return { ok: true };
  }

  async formResponses(user: any, id: string) {
    this.ensureTeacher(user);
    const teacherId = String(user?.sub ?? user?.id ?? '');
    const form = await this.prisma.schoolForm.findFirst({ where: { id, createdBy: teacherId }, select: { id: true } });
    if (!form) throw new NotFoundException('Not found');
    const responses = await this.prisma.formResponse.findMany({
      where: { formId: id },
      orderBy: { submittedAt: 'desc' },
      include: { student: { select: { user: { select: { displayName: true, name: true } } } } },
    });
    return {
      responses: responses.map((r) => ({
        id: r.id,
        studentName: r.student?.user?.displayName ?? r.student?.user?.name ?? 'Student',
        answers: r.answers,
        submittedAt: r.submittedAt.toISOString(),
      })),
    };
  }

  // ---- Diplomas ----

  async listDiplomas(user: any) {
    this.ensureTeacher(user);
    const teacherId = String(user?.sub ?? user?.id ?? '');
    const diplomas = await this.prisma.teacherDiploma.findMany({
      where: { issuedBy: teacherId },
      orderBy: { issuedAt: 'desc' },
    });
    return {
      diplomas: diplomas.map((d) => ({
        id: d.id,
        studentName: d.studentName,
        studentId: d.studentId ?? null,
        title: d.title,
        subject: d.subject ?? '',
        grade: d.grade ?? '',
        distinction: d.distinction ?? '',
        notes: d.notes ?? '',
        issuedAt: d.issuedAt.toISOString(),
      })),
    };
  }

  async createDiploma(user: any, body: any) {
    this.ensureTeacher(user);
    const teacherId = String(user?.sub ?? user?.id ?? '');
    const u = await this.prisma.user.findUnique({ where: { id: teacherId }, select: { schoolId: true } });
    if (!u?.schoolId) throw new BadRequestException('No school');
    // School isolation: verify the diploma recipient belongs to the same school
    if (body?.studentId) await this.assertInSchool(user, String(body.studentId));
    const diploma = await this.prisma.teacherDiploma.create({
      data: {
        schoolId: u.schoolId,
        issuedBy: teacherId,
        studentId: body.studentId ? String(body.studentId) : null,
        studentName: String(body.studentName ?? 'Student'),
        title: String(body.title ?? 'Certificate of Achievement'),
        subject: body.subject ? String(body.subject) : null,
        grade: body.grade ? String(body.grade) : null,
        distinction: body.distinction ? String(body.distinction) : null,
        notes: body.notes ? String(body.notes) : null,
        attachments: Array.isArray(body.attachments) ? body.attachments : [],
      } as any,
    });
    // Persist + push notification (student + parents) via the hub.
    if (body.studentId) {
      try {
        await this.hub.notify({
          recipientUserIds: [String(body.studentId)],
          type: 'NEW_DIPLOMA',
          title: `You earned a certificate: ${diploma.title}`,
          body: [diploma.subject, diploma.distinction, diploma.notes].filter(Boolean).join(' · ').slice(0, 200),
          data: { diplomaId: diploma.id },
        });
      } catch (e) { console.error('[teacher] diploma notify failed:', e); }
    }
    return { ok: true, diploma: { id: diploma.id } };
  }

  async deleteDiploma(user: any, id: string) {
    this.ensureTeacher(user);
    const teacherId = String(user?.sub ?? user?.id ?? '');
    await this.prisma.teacherDiploma.deleteMany({ where: { id, issuedBy: teacherId } });
    return { ok: true };
  }

  // ── Subjects ──────────────────────────────────────────────────────────────

  async listSubjects(user: any) {
    this.ensureTeacher(user);
    const schoolId = String(user.schoolId ?? '');

    // Single source of truth: SchoolGradeSubjectDefault rows the admin
    // curated for this school. Teacher-created classroom/slot subjects
    // are NOT surfaced — those existed only as a transitional fallback,
    // but allowing them lets a teacher invent a subject and have it
    // show up in every "subject" dropdown across the app, which breaks
    // the "admin defines, everyone else picks" model.
    if (!schoolId) return { subjects: [] };

    const schoolDefaults = await this.prisma.schoolGradeSubjectDefault.findMany({
      where: { schoolId },
      select: { subjects: true, subjectsI18n: true } as any,
    });

    const set = new Set<string>();
    for (const row of schoolDefaults as any[]) {
      const i18n = Array.isArray(row.subjectsI18n) ? row.subjectsI18n : [];
      for (const s of i18n) {
        const name = typeof s === 'string'
          ? s.trim()
          : String((s as any)?.nameEn ?? '').trim();
        if (name) set.add(name);
      }
      const flat = Array.isArray(row.subjects) ? row.subjects : [];
      for (const s of flat) {
        const name = String(s ?? '').trim();
        if (name) set.add(name);
      }
    }
    return { subjects: Array.from(set).sort() };
  }

  // ── Teacher Assignments ───────────────────────────────────────────────────

  async listTeacherAssignments(user: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const [standalone, classroom] = await Promise.all([
      this.prisma.teacherAssignment.findMany({
        where: { teacherId },
        orderBy: [{ dueAt: 'asc' }, { createdAt: 'desc' }],
        include: { _count: { select: { submissions: true } } },
      }),
      this.prisma.classroomAssignment.findMany({
        where: { classroom: { teacherId } },
        orderBy: [{ dueAt: 'asc' }, { createdAt: 'desc' }],
        include: { classroom: { select: { name: true, subject: true } }, _count: { select: { submissions: true } } },
      }),
    ]);
    // Keep all TeacherAssignments (they have `published`). Only add ClassroomAssignments that have NO TeacherAssignment mirror.
    const filteredClassroom = classroom.filter(c => !c.teacherAssignmentId);
    const merged = [
      ...standalone.map(a => ({ ...a, submissionCount: a._count.submissions })),
      ...filteredClassroom.map(c => ({ ...c, _type: 'classroom', _classroomName: c.classroom?.name ?? null, submissionCount: c._count.submissions })),
    ].sort((a, b) => {
      const da = (a as any).dueAt ? new Date((a as any).dueAt).getTime() : Infinity;
      const db = (b as any).dueAt ? new Date((b as any).dueAt).getTime() : Infinity;
      return da - db;
    });
    return { assignments: merged };
  }

  async createTeacherAssignment(user: any, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const title = String(body?.title ?? '').trim();
    if (!title) throw new BadRequestException('title is required');
    const classroomId = body?.courseId ? String(body.courseId).trim() : null;
    const a = await this.prisma.teacherAssignment.create({
      data: {
        teacherId,
        title,
        description: body?.description ? String(body.description).trim() : null,
        subject: body?.subject ? String(body.subject).trim() : null,
        dueAt: body?.dueAt ? new Date(String(body.dueAt)) : null,
        maxGrade: body?.maxGrade ? Number(body.maxGrade) : null,
        targetType: body?.targetType ?? 'EVERYONE',
        targetCohortIds: Array.isArray(body?.targetCohortIds) ? body.targetCohortIds : [],
        targetStudentIds: Array.isArray(body?.targetStudentIds) ? body.targetStudentIds : [],
        targetGrades: Array.isArray(body?.targetGrades)
          ? body.targetGrades.map((g: any) => Number(g)).filter((n: number) => Number.isFinite(n))
          : [],
        published: body?.published === true,
        publishedAt: body?.published === true ? new Date() : null,
      },
    });
    if (classroomId) {
      await this.prisma.classroomAssignment.create({
        data: {
          classroomId,
          title,
          body: body?.description ? String(body.description).trim() : null,
          dueAt: body?.dueAt ? new Date(String(body.dueAt)) : null,
          createdBy: teacherId,
          teacherAssignmentId: a.id,
          attachments: Array.isArray(body?.attachments) ? body.attachments : [],
        } as any,
      }).catch(() => {});
      // Emit real-time to classroom members
      void this.emitToClassroomMembers(classroomId, { type: 'assignment_created', classroomId });
    }
    // Emit to explicitly targeted students
    if (a.published && a.targetStudentIds.length) {
      this.realtime.emitToUsers(a.targetStudentIds, { type: 'assignment_created', targetUserIds: a.targetStudentIds });
    }
    // Persist + push notifications via the hub. Covers students AND
    // their parents in one call.
    if (a.published) {
      try {
        const recipients = await this._audienceUserIds(user, a);
        if (recipients.length) {
          await this.hub.notify({
            recipientUserIds: recipients,
            type: 'NEW_ASSIGNMENT',
            title: `New assignment: ${title}`,
            body: a.subject ? `${a.subject} · ${a.description ?? ''}`.slice(0, 200) : (a.description ?? '').slice(0, 200),
            data: { assignmentId: a.id, classroomId },
          });
        }
      } catch (e) { console.error('[teacher] assignment notify failed:', e); }
    }
    return { ok: true, assignment: a };
  }

  async updateTeacherAssignment(user: any, id: string, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const data: any = {};
    if (body?.title !== undefined) data.title = String(body.title).trim();
    if (body?.description !== undefined) data.description = body.description ? String(body.description).trim() : null;
    if (body?.subject !== undefined) data.subject = body.subject ? String(body.subject).trim() : null;
    if (body?.dueAt !== undefined) data.dueAt = body.dueAt ? new Date(String(body.dueAt)) : null;
    if (body?.maxGrade !== undefined) data.maxGrade = body.maxGrade ? Number(body.maxGrade) : null;
    if (body?.targetType !== undefined) data.targetType = body.targetType;
    if (body?.targetCohortIds !== undefined) data.targetCohortIds = body.targetCohortIds;
    if (body?.targetStudentIds !== undefined) data.targetStudentIds = body.targetStudentIds;
    if (body?.targetGrades !== undefined) data.targetGrades = Array.isArray(body.targetGrades)
      ? body.targetGrades.map((g: any) => Number(g)).filter((n: number) => Number.isFinite(n))
      : [];
    if (body?.published !== undefined) { data.published = body.published; if (body.published) data.publishedAt = new Date(); }
    await this.prisma.teacherAssignment.updateMany({ where: { id, teacherId }, data });
    return { ok: true };
  }

  async deleteTeacherAssignment(user: any, id: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const ta = await this.prisma.teacherAssignment.findFirst({ where: { id, teacherId } });
    if (ta) {
      await this.prisma.teacherAssignment.deleteMany({ where: { id, teacherId } });
      // cascade: by back-ref or by matching title in teacher's classrooms
      await this.prisma.classroomAssignment.deleteMany({ where: { OR: [{ teacherAssignmentId: id }, { title: ta.title, classroom: { teacherId } }] } });
      return { ok: true };
    }
    const ca = await this.prisma.classroomAssignment.findFirst({ where: { id, classroom: { teacherId } } });
    if (ca) {
      await this.prisma.classroomAssignment.deleteMany({ where: { id } });
      if (ca.teacherAssignmentId) {
        await this.prisma.teacherAssignment.deleteMany({ where: { id: ca.teacherAssignmentId, teacherId } });
      } else {
        await this.prisma.teacherAssignment.deleteMany({ where: { title: ca.title, teacherId } });
      }
    }
    return { ok: true };
  }

  async getAssignmentSubmissions(user: any, assignmentId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;

    // Check TeacherAssignment first
    const teacherAssignment = await this.prisma.teacherAssignment.findFirst({ where: { id: assignmentId, teacherId } });
    if (teacherAssignment) {
      const submissions = await this.prisma.teacherAssignmentSubmission.findMany({
        where: { assignmentId },
        include: { student: { select: { name: true, displayName: true, email: true } } },
        orderBy: { submittedAt: 'desc' },
      });
      return {
        ok: true,
        submissions: submissions.map((s) => ({
          id: s.id,
          assignmentId: s.assignmentId,
          studentId: s.studentId,
          studentName: (s as any).student?.displayName || (s as any).student?.name || 'Student',
          note: s.note ?? null,
          files: s.files ?? [],
          grade: s.grade ?? null,
          feedback: s.feedback ?? null,
          status: (s as any).status ?? 'SUBMITTED',
          gradedAt: s.gradedAt ?? null,
          submittedAt: s.submittedAt,
          student: (s as any).student,
        })),
      };
    }

    // Fall back to ClassroomAssignment (created from classroom context)
    const classroomAssignment = await this.prisma.classroomAssignment.findFirst({
      where: { id: assignmentId, classroom: { teacherId } },
      select: { id: true, classroomId: true, title: true },
    });
    if (!classroomAssignment) throw new NotFoundException('Assignment not found');

    const submissions = await this.prisma.assignmentSubmission.findMany({
      where: { assignmentId },
      include: { student: { select: { name: true, email: true } } },
      orderBy: { submittedAt: 'desc' },
    });
    return {
      ok: true,
      submissions: submissions.map((s) => ({
        id: s.id,
        assignmentId: s.assignmentId,
        studentId: s.studentId,
        note: s.note ?? null,
        grade: null,
        feedback: null,
        submittedAt: s.submittedAt,
        student: s.student,
      })),
    };
  }

  async gradeAssignmentSubmission(user: any, assignmentId: string, studentId: string, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const schoolId = (user as any)?.schoolId;
    const assignment = await this.prisma.teacherAssignment.findFirst({ where: { id: assignmentId, teacherId } });
    if (!assignment) throw new NotFoundException('Assignment not found');
    // School isolation: reject if student belongs to a different school
    if (schoolId) {
      const student = await this.prisma.user.findFirst({ where: { id: studentId, schoolId } });
      if (!student) throw new ForbiddenException('Student does not belong to your school');
    }
    await this.prisma.teacherAssignmentSubmission.upsert({
      where: { assignmentId_studentId: { assignmentId, studentId } },
      update: { grade: body?.grade != null ? Number(body.grade) : null, feedback: body?.feedback ? String(body.feedback) : null, gradedAt: new Date(), status: 'GRADED' },
      create: { assignmentId, studentId, grade: body?.grade != null ? Number(body.grade) : null, feedback: body?.feedback ? String(body.feedback) : null, gradedAt: new Date(), status: 'GRADED' },
    });
    this.realtime.emitToUser(studentId, { type: 'grade_updated', studentId });
    return { ok: true };
  }

  /// Return a submission to the student for re-solution. Flips status to
  /// RETURNED, attaches the teacher's note as feedback, and clears any prior
  /// grade so the student's resubmission starts clean. The student's feed
  /// then reopens the hand-in form for this assignment.
  async returnAssignmentSubmission(user: any, assignmentId: string, studentId: string, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const assignment = await this.prisma.teacherAssignment.findFirst({ where: { id: assignmentId, teacherId } });
    if (!assignment) throw new NotFoundException('Assignment not found');
    const existing = await this.prisma.teacherAssignmentSubmission.findUnique({
      where: { assignmentId_studentId: { assignmentId, studentId } },
    });
    if (!existing) throw new NotFoundException('Submission not found');
    await this.prisma.teacherAssignmentSubmission.update({
      where: { assignmentId_studentId: { assignmentId, studentId } },
      data: {
        status: 'RETURNED',
        feedback: body?.feedback != null ? String(body.feedback) : existing.feedback,
        grade: null,
        gradedAt: null,
      },
    });
    this.realtime.emitToUser(studentId, { type: 'assignment_returned', assignmentId, studentId });
    return { ok: true };
  }

  // ── Teacher Materials ─────────────────────────────────────────────────────

  async listTeacherMaterials(user: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const [standalone, classroom] = await Promise.all([
      this.prisma.teacherMaterial.findMany({ where: { teacherId }, orderBy: { createdAt: 'desc' } }),
      this.prisma.classroomMaterial.findMany({
        where: { classroom: { teacherId } },
        orderBy: { createdAt: 'desc' },
        include: { classroom: { select: { name: true, subject: true } } },
      }),
    ]);
    // Deduplicate by teacherMaterialId so mirrored records don't appear twice
    const filteredClassroomMat = classroom.filter(c => !c.teacherMaterialId);
    const merged = [
      ...standalone,
      ...filteredClassroomMat.map(c => ({ ...c, _type: 'classroom', _classroomName: c.classroom?.name ?? null })),
    ].sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
    return { materials: merged };
  }

  async createTeacherMaterial(user: any, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const title = String(body?.title ?? '').trim();
    if (!title) throw new BadRequestException('title is required');
    const classroomId = body?.courseId ? String(body.courseId).trim() : null;
    const attachments = Array.isArray(body?.attachments) ? body.attachments : [];
    const primaryUrl = body?.url ? String(body.url).trim() : (attachments[0]?.url ?? null);

    const m = await this.prisma.teacherMaterial.create({
      data: {
        teacherId,
        title,
        description: body?.description ? String(body.description).trim() : null,
        url: primaryUrl,
        attachments: attachments as any,
        subject: body?.subject ? String(body.subject).trim() : null,
        targetType: body?.targetType ?? 'EVERYONE',
        targetCohortIds: Array.isArray(body?.targetCohortIds) ? body.targetCohortIds : [],
        targetStudentIds: Array.isArray(body?.targetStudentIds) ? body.targetStudentIds : [],
        targetGrades: Array.isArray(body?.targetGrades)
          ? body.targetGrades.map((g: any) => Number(g)).filter((n: number) => Number.isFinite(n))
          : [],
        published: body?.published !== false,
      },
    });
    if (classroomId) {
      await this.prisma.classroomMaterial.create({
        data: {
          classroomId,
          title,
          description: body?.description ? String(body.description).trim() : null,
          url: primaryUrl ?? '',
          attachments: attachments as any,
          mime: body?.mime ? String(body.mime).trim() : null,
          createdBy: teacherId,
          teacherMaterialId: m.id,
        },
      }).catch(() => {});
    }
    if (m.published) {
      try {
        const recipients = await this._audienceUserIds(user, m);
        if (recipients.length) {
          await this.hub.notify({
            recipientUserIds: recipients,
            type: 'NEW_MATERIAL',
            title: `New material: ${title}`,
            body: (m.subject ?? m.description ?? '').slice(0, 200),
            data: { materialId: m.id, classroomId },
          });
        }
      } catch (e) { console.error('[teacher] material notify failed:', e); }
    }
    return { ok: true, material: m };
  }

  async updateTeacherMaterial(user: any, id: string, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const data: any = {};
    if (body?.title !== undefined) data.title = String(body.title).trim();
    if (body?.description !== undefined) data.description = body.description ? String(body.description).trim() : null;
    if (body?.url !== undefined) data.url = body.url ? String(body.url).trim() : null;
    if (body?.attachments !== undefined) data.attachments = Array.isArray(body.attachments) ? body.attachments : [];
    if (body?.subject !== undefined) data.subject = body.subject ? String(body.subject).trim() : null;
    if (body?.targetType !== undefined) data.targetType = body.targetType;
    if (body?.targetCohortIds !== undefined) data.targetCohortIds = body.targetCohortIds;
    if (body?.targetStudentIds !== undefined) data.targetStudentIds = body.targetStudentIds;
    if (body?.targetGrades !== undefined) data.targetGrades = Array.isArray(body.targetGrades)
      ? body.targetGrades.map((g: any) => Number(g)).filter((n: number) => Number.isFinite(n))
      : [];
    if (body?.published !== undefined) data.published = body.published;
    await this.prisma.teacherMaterial.updateMany({ where: { id, teacherId }, data });
    return { ok: true };
  }

  async deleteTeacherMaterial(user: any, id: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    // Try TeacherMaterial first
    const tm = await this.prisma.teacherMaterial.findFirst({ where: { id, teacherId } });
    if (tm) {
      await this.prisma.teacherMaterial.deleteMany({ where: { id, teacherId } });
      await this.prisma.classroomMaterial.deleteMany({ where: { OR: [{ teacherMaterialId: id }, { title: tm.title, classroom: { teacherId } }] } });
      return { ok: true };
    }
    const cm = await this.prisma.classroomMaterial.findFirst({ where: { id, classroom: { teacherId } } });
    if (cm) {
      await this.prisma.classroomMaterial.deleteMany({ where: { id } });
      if (cm.teacherMaterialId) {
        await this.prisma.teacherMaterial.deleteMany({ where: { id: cm.teacherMaterialId, teacherId } });
      } else {
        await this.prisma.teacherMaterial.deleteMany({ where: { title: cm.title, teacherId } });
      }
    }
    return { ok: true };
  }

  // ── Slot Attachments ──────────────────────────────────────────────────────

  /// Sanitises a YYYY-MM-DD value passed from the client. Anything that
  /// doesn't match the strict format becomes "" (which the schema treats
  /// as "legacy / applies-to-every-occurrence").
  private _normalizeAttachDate(raw: any): string {
    const s = typeof raw === 'string' ? raw.trim() : '';
    if (/^\d{4}-\d{2}-\d{2}$/.test(s)) return s;
    return '';
  }

  /// Returns the materials currently attached to a teacher's schedule
  /// slot. When `date` is supplied, only attachments for that exact
  /// occurrence (plus any legacy "" entries that pre-date date-scoping)
  /// are returned. Without a date the teacher sees the full history.
  async listSlotMaterials(user: any, slotId: string, date?: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsSlot(teacherId, slotId);

    const d = this._normalizeAttachDate(date);
    const where: any = { slotId };
    if (d) where.date = { in: [d, ''] }; // include legacy permanent entries

    const rows = await this.prisma.scheduleSlotMaterial.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      include: {
        material: {
          select: {
            id: true, title: true, description: true, url: true,
            attachments: true, subject: true, createdAt: true,
          },
        },
      },
    });
    return {
      ok: true,
      attachments: rows.map((r) => ({
        ...this.materialToAttachment(r.material),
        date: (r as any).date ?? '',
      })),
    };
  }

  /// Attach a teacher-owned material to a SPECIFIC date occurrence of a
  /// slot. Idempotent — re-attaching the same material to the same
  /// (slot, date) is a no-op. When `date` is omitted or invalid, falls
  /// back to "" which means "applies to every occurrence" (the old
  /// behaviour, preserved for legacy clients).
  async attachSlotMaterial(user: any, slotId: string, teacherMaterialId: string, date?: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    if (!teacherMaterialId) throw new BadRequestException('teacherMaterialId is required');

    await this.assertTeacherOwnsSlot(teacherId, slotId);

    const material = await this.prisma.teacherMaterial.findFirst({
      where: { id: teacherMaterialId, teacherId },
    });
    if (!material) throw new NotFoundException('Material not found');

    const d = this._normalizeAttachDate(date);

    await this.prisma.scheduleSlotMaterial.upsert({
      where: { slotId_teacherMaterialId_date: { slotId, teacherMaterialId, date: d } },
      create: { slotId, teacherMaterialId, date: d },
      update: {},
    });
    // Audience auto-expand: pull every student the slot targets into the
    // material's audience so they see it in their materials feed too.
    await this.expandTeacherMaterialAudienceFromSlot(teacherMaterialId, slotId);
    return { ok: true };
  }

  /// Resolves the student IDs the given slot targets (direct studentIds +
  /// cohort members + audienceGrade matches) and merges any new ones into
  /// the teacher material's targetStudentIds.
  private async expandTeacherMaterialAudienceFromSlot(teacherMaterialId: string, slotId: string) {
    const slot = await this.prisma.scheduleSlot.findUnique({
      where: { id: slotId },
      select: {
        schoolId: true,
        audienceGrade: true,
        students: { select: { studentId: true } },
        cohorts: { select: { cohortId: true } },
      },
    });
    if (!slot) return;
    const ids = new Set<string>();
    for (const s of slot.students) ids.add(s.studentId);
    if (slot.cohorts.length) {
      const cohortIds = slot.cohorts.map((c) => c.cohortId);
      const cohortMembers = await this.prisma.studentCohort.findMany({
        where: { cohortId: { in: cohortIds } },
        select: { studentId: true },
      });
      for (const m of cohortMembers) ids.add(m.studentId);
    }
    if (slot.audienceGrade != null) {
      const gradeStudents = await this.prisma.studentProfile.findMany({
        where: {
          grade: slot.audienceGrade,
          ...(slot.schoolId ? { user: { schoolId: slot.schoolId } } : {}),
        },
        select: { userId: true },
      });
      for (const s of gradeStudents) ids.add(s.userId);
    }
    if (ids.size === 0) return;
    const cur = await this.prisma.teacherMaterial.findUnique({
      where: { id: teacherMaterialId },
      select: { targetStudentIds: true },
    });
    if (!cur) return;
    const existing = new Set(cur.targetStudentIds);
    const merged = [...cur.targetStudentIds];
    for (const id of ids) {
      if (!existing.has(id)) merged.push(id);
    }
    if (merged.length === cur.targetStudentIds.length) return;
    await this.prisma.teacherMaterial.update({
      where: { id: teacherMaterialId },
      data: { targetStudentIds: merged },
    });
  }

  async detachSlotMaterial(user: any, slotId: string, teacherMaterialId: string, date?: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.assertTeacherOwnsSlot(teacherId, slotId);
    // Date-scoped detach: when a date is provided we only remove the
    // matching occurrence's attachment (plus its sibling legacy ""
    // entry if any), so detaching from May 24 doesn't wipe May 31's
    // attachment of the same material. Omitting the date falls back to
    // the old "remove every attachment of this material from this
    // slot" behaviour for legacy callers.
    const d = this._normalizeAttachDate(date);
    if (d) {
      await this.prisma.scheduleSlotMaterial.deleteMany({
        where: { slotId, teacherMaterialId, date: d },
      });
    } else {
      await this.prisma.scheduleSlotMaterial.deleteMany({
        where: { slotId, teacherMaterialId },
      });
    }
    return { ok: true };
  }

  private async assertTeacherOwnsSlot(teacherId: string, slotId: string) {
    const slot = await this.prisma.scheduleSlot.findFirst({
      where: { id: slotId, teacherId },
      select: { id: true },
    });
    if (!slot) throw new ForbiddenException('Not your slot');
  }

  // ── Attach existing library items (material/assignment/meeting) to a
  //     classroom. The FAB in each classroom tab opens a picker showing
  //     the teacher's library; tapping an existing one calls one of
  //     these endpoints to mirror it into the classroom. Each operation
  //     is idempotent — if the item is already in the classroom (by
  //     teacherXxxId back-ref), it's a no-op success.

  async attachTeacherMaterialToClassroom(user: any, classroomId: string, teacherMaterialId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    if (!teacherMaterialId) throw new BadRequestException('teacherMaterialId is required');

    await this.assertTeacherOwnsClassroom(teacherId, classroomId);

    const material = await this.prisma.teacherMaterial.findFirst({
      where: { id: teacherMaterialId, teacherId },
    });
    if (!material) throw new NotFoundException('Material not found');

    const existing = await this.prisma.classroomMaterial.findFirst({
      where: { classroomId, teacherMaterialId },
      select: { id: true },
    });
    if (existing) return { ok: true, id: existing.id, alreadyAttached: true };

    const primaryUrl = (typeof material.url === 'string' && material.url.length > 0)
      ? material.url
      : '';
    const created = await this.prisma.classroomMaterial.create({
      data: {
        classroomId,
        title: material.title,
        description: material.description ?? null,
        url: primaryUrl,
        attachments: material.attachments as any,
        mime: null,
        createdBy: teacherId,
        teacherMaterialId: material.id,
      },
    });
    // Audience auto-expand: pull in classroom members the material doesn't
    // already target so they see the item in their materials feed too.
    await this.expandTeacherMaterialAudience(material.id, classroomId);
    return { ok: true, id: created.id };
  }

  async attachTeacherAssignmentToClassroom(user: any, classroomId: string, teacherAssignmentId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    if (!teacherAssignmentId) throw new BadRequestException('teacherAssignmentId is required');

    await this.assertTeacherOwnsClassroom(teacherId, classroomId);

    const src = await this.prisma.teacherAssignment.findFirst({
      where: { id: teacherAssignmentId, teacherId },
    });
    if (!src) throw new NotFoundException('Assignment not found');

    const existing = await this.prisma.classroomAssignment.findFirst({
      where: { classroomId, teacherAssignmentId },
      select: { id: true },
    });
    if (existing) return { ok: true, id: existing.id, alreadyAttached: true };

    const created = await this.prisma.classroomAssignment.create({
      data: {
        classroomId,
        title: src.title,
        description: src.description ?? null,
        dueAt: src.dueAt,
        maxGrade: src.maxGrade ?? null,
        attachments: src.attachments as any,
        published: src.published,
        createdBy: teacherId,
        teacherAssignmentId: src.id,
      } as any,
    });
    await this.expandTeacherAssignmentAudience(src.id, classroomId);
    return { ok: true, id: created.id };
  }

  async attachTeacherMeetingToClassroom(user: any, classroomId: string, teacherMeetingId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    if (!teacherMeetingId) throw new BadRequestException('teacherMeetingId is required');

    await this.assertTeacherOwnsClassroom(teacherId, classroomId);

    const src = await this.prisma.teacherMeeting.findFirst({
      where: { id: teacherMeetingId, teacherId },
    });
    if (!src) throw new NotFoundException('Meeting not found');

    const existing = await this.prisma.classroomMeeting.findFirst({
      where: { classroomId, teacherMeetingId },
      select: { id: true },
    });
    if (existing) return { ok: true, id: existing.id, alreadyAttached: true };

    const created = await this.prisma.classroomMeeting.create({
      data: {
        classroomId,
        title: src.title,
        startsAt: src.startsAt,
        endsAt: src.endsAt,
        link: src.link,
        createdBy: teacherId,
        teacherMeetingId: src.id,
      } as any,
    });
    await this.expandTeacherMeetingAudience(src.id, classroomId);
    return { ok: true, id: created.id };
  }

  /// Pulls every classroom member into the teacher item's targetStudentIds
  /// so they all see the item in their feed, even when the original audience
  /// didn't include them. Idempotent (skip ids already in the set).
  private async classroomMemberIds(classroomId: string): Promise<string[]> {
    const rows = await this.prisma.classroomMember.findMany({
      where: { classroomId },
      select: { studentId: true },
    });
    return rows.map((r) => r.studentId);
  }

  /// Attach a TeacherMaterial to a TeacherExam. The material's content
  /// (its `url` and each file in its `attachments` JSON) is snapshotted
  /// into the exam's `attachments` JSON with a `_sourceMaterialId`
  /// marker so the student detail screen renders it as a normal file
  /// attachment without any new client-side rendering. The material's
  /// audience is then UNIONed with the exam's audience so it reaches
  /// the wider set automatically (the user explicitly asked for this).
  async attachTeacherMaterialToExam(user: any, examId: string, materialId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    if (!materialId) throw new BadRequestException('materialId is required');

    const exam = await this.prisma.teacherExam.findFirst({
      where: { id: examId, teacherId },
    });
    if (!exam) throw new NotFoundException('Exam not found');

    const material = await this.prisma.teacherMaterial.findFirst({
      where: { id: materialId, teacherId },
    });
    if (!material) throw new NotFoundException('Material not found');

    const cur = Array.isArray(exam.attachments)
      ? (exam.attachments as any[])
      : [];
    const alreadyAttached = cur.some(
      (a) => a && typeof a === 'object' && a._sourceMaterialId === material.id,
    );
    if (!alreadyAttached) {
      const items = this._materialAttachmentSnapshot(material);
      await this.prisma.teacherExam.update({
        where: { id: exam.id },
        data: { attachments: [...cur, ...items] as any },
      });
    }

    await this._expandTeacherMaterialAudienceToTarget(material.id, {
      targetType: exam.targetType,
      targetCohortIds: exam.targetCohortIds,
      targetStudentIds: exam.targetStudentIds,
      targetGrades: exam.targetGrades,
    });

    return { ok: true, alreadyAttached };
  }

  /// Same shape as [attachTeacherMaterialToExam] but for assignments.
  async attachTeacherMaterialToAssignment(
    user: any,
    assignmentId: string,
    materialId: string,
  ) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    if (!materialId) throw new BadRequestException('materialId is required');

    const asn = await this.prisma.teacherAssignment.findFirst({
      where: { id: assignmentId, teacherId },
    });
    if (!asn) throw new NotFoundException('Assignment not found');

    const material = await this.prisma.teacherMaterial.findFirst({
      where: { id: materialId, teacherId },
    });
    if (!material) throw new NotFoundException('Material not found');

    const cur = Array.isArray(asn.attachments)
      ? (asn.attachments as any[])
      : [];
    const alreadyAttached = cur.some(
      (a) => a && typeof a === 'object' && a._sourceMaterialId === material.id,
    );
    if (!alreadyAttached) {
      const items = this._materialAttachmentSnapshot(material);
      await this.prisma.teacherAssignment.update({
        where: { id: asn.id },
        data: { attachments: [...cur, ...items] as any },
      });
    }

    await this._expandTeacherMaterialAudienceToTarget(material.id, {
      targetType: asn.targetType,
      targetCohortIds: asn.targetCohortIds,
      targetStudentIds: asn.targetStudentIds,
      targetGrades: asn.targetGrades,
    });

    return { ok: true, alreadyAttached };
  }

  /// Builds a flat list of attachment entries from a material — its
  /// primary `url` (if set) plus every file in its `attachments` JSON,
  /// each tagged with `_sourceMaterialId` so we can later identify them.
  private _materialAttachmentSnapshot(material: any): any[] {
    const out: any[] = [];
    // De-dupe by URL: a material commonly stores the SAME file both in its
    // primary `url` and in its inner `attachments[]`, which produced two
    // identical pills for one file on the student/teacher assignment view.
    const seenUrls = new Set<string>();
    const urlOf = (a: any) =>
      String(a?.url ?? a?.fileUrl ?? '').trim().toLowerCase();
    const pushUnique = (item: any) => {
      const key = urlOf(item);
      if (key) {
        if (seenUrls.has(key)) return;
        seenUrls.add(key);
      }
      out.push(item);
    };

    const primaryUrl =
      typeof material.url === 'string' && material.url.length > 0
        ? material.url
        : '';
    if (primaryUrl) {
      pushUnique({
        title: material.title,
        url: primaryUrl,
        _sourceMaterialId: material.id,
        _sourceMaterialTitle: material.title,
      });
    }
    const inner = Array.isArray(material.attachments)
      ? material.attachments
      : [];
    for (const a of inner) {
      if (a && typeof a === 'object') {
        pushUnique({
          ...a,
          _sourceMaterialId: material.id,
          _sourceMaterialTitle: material.title,
        });
      }
    }
    // Fallback: a material with neither a primary URL nor inner files
    // still needs to show up as a pill so the student knows something
    // was attached. Push a title-only entry so the client renders a
    // non-tappable "📎 Title" chip instead of leaving the section empty.
    if (out.length === 0) {
      out.push({
        title: material.title,
        _sourceMaterialId: material.id,
        _sourceMaterialTitle: material.title,
      });
    }
    return out;
  }

  /// Expands a TeacherMaterial's audience to the union of its current
  /// audience and another item's (exam, assignment, classroom roster).
  /// Used by attach-* endpoints so the same library item automatically
  /// reaches every cohort/grade/student of every container it's pulled
  /// into. EVERYONE wins — once a material is shared school-wide it
  /// stays school-wide even if other containers are narrower.
  private async _expandTeacherMaterialAudienceToTarget(
    materialId: string,
    target: {
      targetType: any;
      targetCohortIds: string[];
      targetStudentIds: string[];
      targetGrades: number[];
    },
  ) {
    const cur = await this.prisma.teacherMaterial.findUnique({
      where: { id: materialId },
      select: {
        targetType: true,
        targetCohortIds: true,
        targetStudentIds: true,
        targetGrades: true,
      },
    });
    if (!cur) return;

    const newCohorts = Array.from(
      new Set([...cur.targetCohortIds, ...target.targetCohortIds]),
    );
    const newStudents = Array.from(
      new Set([...cur.targetStudentIds, ...target.targetStudentIds]),
    );
    const newGrades = Array.from(
      new Set([...cur.targetGrades, ...target.targetGrades]),
    );
    const newType =
      cur.targetType === ('EVERYONE' as any) ||
      target.targetType === ('EVERYONE' as any)
        ? 'EVERYONE'
        : cur.targetType;

    const nothingChanged =
      newCohorts.length === cur.targetCohortIds.length &&
      newStudents.length === cur.targetStudentIds.length &&
      newGrades.length === cur.targetGrades.length &&
      newType === cur.targetType;
    if (nothingChanged) return;

    await this.prisma.teacherMaterial.update({
      where: { id: materialId },
      data: {
        targetType: newType as any,
        targetCohortIds: newCohorts,
        targetStudentIds: newStudents,
        targetGrades: newGrades,
      },
    });
  }

  private async expandTeacherMaterialAudience(teacherMaterialId: string, classroomId: string) {
    const memberIds = await this.classroomMemberIds(classroomId);
    if (!memberIds.length) return;
    const cur = await this.prisma.teacherMaterial.findUnique({
      where: { id: teacherMaterialId },
      select: { targetStudentIds: true },
    });
    if (!cur) return;
    const existing = new Set(cur.targetStudentIds);
    const merged = [...cur.targetStudentIds];
    for (const id of memberIds) {
      if (!existing.has(id)) merged.push(id);
    }
    if (merged.length === cur.targetStudentIds.length) return;
    await this.prisma.teacherMaterial.update({
      where: { id: teacherMaterialId },
      data: { targetStudentIds: merged },
    });
  }

  private async expandTeacherAssignmentAudience(teacherAssignmentId: string, classroomId: string) {
    const memberIds = await this.classroomMemberIds(classroomId);
    if (!memberIds.length) return;
    const cur = await this.prisma.teacherAssignment.findUnique({
      where: { id: teacherAssignmentId },
      select: { targetStudentIds: true },
    });
    if (!cur) return;
    const existing = new Set(cur.targetStudentIds);
    const merged = [...cur.targetStudentIds];
    for (const id of memberIds) {
      if (!existing.has(id)) merged.push(id);
    }
    if (merged.length === cur.targetStudentIds.length) return;
    await this.prisma.teacherAssignment.update({
      where: { id: teacherAssignmentId },
      data: { targetStudentIds: merged },
    });
  }

  private async expandTeacherMeetingAudience(teacherMeetingId: string, classroomId: string) {
    const memberIds = await this.classroomMemberIds(classroomId);
    if (!memberIds.length) return;
    const cur = await this.prisma.teacherMeeting.findUnique({
      where: { id: teacherMeetingId },
      select: { targetStudentIds: true },
    });
    if (!cur) return;
    const existing = new Set(cur.targetStudentIds);
    const merged = [...cur.targetStudentIds];
    for (const id of memberIds) {
      if (!existing.has(id)) merged.push(id);
    }
    if (merged.length === cur.targetStudentIds.length) return;
    await this.prisma.teacherMeeting.update({
      where: { id: teacherMeetingId },
      data: { targetStudentIds: merged },
    });
  }

  /// Normalises a TeacherMaterial row into a flat pill-friendly shape.
  /// Inlines the first attachment's URL+mime when the row itself has no
  /// top-level URL, so the student tile can always render a tappable pill.
  private materialToAttachment(m: any) {
    const list = Array.isArray(m?.attachments) ? m.attachments : [];
    const first = list.find((a: any) => a && typeof a === 'object') ?? null;
    const url = (typeof m?.url === 'string' && m.url.length > 0)
      ? m.url
      : (first && typeof first.url === 'string' ? first.url : '');
    const mime = first && typeof first.mime === 'string' ? first.mime : '';
    return {
      id: m.id,
      title: m.title ?? 'Material',
      description: m.description ?? null,
      url,
      mime,
      subject: m.subject ?? null,
      attachments: list,
    };
  }

  // ── Teacher Meetings ──────────────────────────────────────────────────────

  async listTeacherMeetings(user: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;

    const [standalone, classroom] = await Promise.all([
      this.prisma.teacherMeeting.findMany({
        where: { teacherId },
        orderBy: [{ startsAt: 'asc' }],
      }),
      this.prisma.classroomMeeting.findMany({
        where: { classroom: { teacherId } },
        orderBy: [{ startsAt: 'asc' }],
        select: { id: true, title: true, startsAt: true, endsAt: true, link: true, createdAt: true, updatedAt: true, classroomId: true, teacherMeetingId: true, classroom: { select: { name: true, subject: true } } },
      }),
    ]);

    const filteredClassroomMtg = classroom.filter(c => !c.teacherMeetingId);

    const classroomNorm = filteredClassroomMtg.map((m) => ({
      id: m.id, teacherId, title: m.title, description: null, link: m.link,
      startsAt: m.startsAt, endsAt: m.endsAt ?? null,
      subject: m.classroom?.subject ?? null, targetType: 'EVERYONE',
      targetCohortIds: [] as string[], targetStudentIds: [] as string[],
      createdAt: m.createdAt, updatedAt: m.updatedAt,
      classroomId: m.classroomId, courseName: m.classroom?.name ?? null, _type: 'classroom',
    }));

    const all = [...standalone, ...classroomNorm].sort(
      (a, b) => new Date(a.startsAt).getTime() - new Date(b.startsAt).getTime(),
    );
    return { meetings: all };
  }

  /// Readable date/time for notification bodies (e.g. "08:15 · Jun 2, 2026")
  /// instead of a raw ISO timestamp. Uses the stored wall-clock components.
  private _friendlyDateTime(d: Date): string {
    try {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      const hh = String(d.getUTCHours()).padStart(2, '0');
      const mm = String(d.getUTCMinutes()).padStart(2, '0');
      return `${hh}:${mm} · ${months[d.getUTCMonth()]} ${d.getUTCDate()}, ${d.getUTCFullYear()}`;
    } catch {
      return d.toISOString();
    }
  }

  async createTeacherMeeting(user: any, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const title = String(body?.title ?? '').trim();
    const link = String(body?.link ?? '').trim();
    if (!title || !link) throw new BadRequestException('title and link are required');
    const classroomId = body?.courseId ? String(body.courseId).trim() : null;
    const startsAt = body?.startsAt ? new Date(String(body.startsAt)) : new Date();
    const endsAt = body?.endsAt ? new Date(String(body.endsAt)) : null;
    const m = await this.prisma.teacherMeeting.create({
      data: {
        teacherId,
        title,
        description: body?.description ? String(body.description).trim() : null,
        link,
        startsAt,
        endsAt,
        subject: body?.subject ? String(body.subject).trim() : null,
        targetType: body?.targetType ?? 'EVERYONE',
        targetCohortIds: Array.isArray(body?.targetCohortIds) ? body.targetCohortIds : [],
        targetStudentIds: Array.isArray(body?.targetStudentIds) ? body.targetStudentIds : [],
        targetGrades: Array.isArray(body?.targetGrades)
          ? body.targetGrades.map((g: any) => Number(g)).filter((n: number) => Number.isFinite(n))
          : [],
      },
    });
    if (classroomId) {
      await this.prisma.classroomMeeting.create({
        data: {
          classroomId,
          title,
          link,
          startsAt,
          endsAt: endsAt ?? undefined,
          createdBy: teacherId,
          teacherMeetingId: m.id,
        },
      }).catch(() => {});
    }
    try {
      const recipients = await this._audienceUserIds(user, m);
      if (recipients.length) {
        const teacherName =
          (user?.displayName || user?.name || user?.fullName || 'Your teacher')
            .toString()
            .trim();
        await this.hub.notify({
          recipientUserIds: recipients,
          type: 'NEW_MEETING',
          title: title,
          body: `New meeting scheduled by ${teacherName} at ${this._friendlyDateTime(startsAt)}`,
          data: { meetingId: m.id, classroomId },
        });
      }
    } catch (e) { console.error('[teacher] meeting notify failed:', e); }
    return { ok: true, meeting: m };
  }

  async updateTeacherMeeting(user: any, id: string, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const data: any = {};
    if (body?.title !== undefined) data.title = String(body.title).trim();
    if (body?.link !== undefined) data.link = String(body.link).trim();
    if (body?.startsAt !== undefined) data.startsAt = body.startsAt ? new Date(String(body.startsAt)) : new Date();
    if (body?.endsAt !== undefined) data.endsAt = body.endsAt ? new Date(String(body.endsAt)) : null;
    if (body?.subject !== undefined) data.subject = body.subject ? String(body.subject).trim() : null;
    if (body?.targetType !== undefined) data.targetType = body.targetType;
    if (body?.targetCohortIds !== undefined) data.targetCohortIds = body.targetCohortIds;
    if (body?.targetStudentIds !== undefined) data.targetStudentIds = body.targetStudentIds;
    if (body?.targetGrades !== undefined) data.targetGrades = Array.isArray(body.targetGrades)
      ? body.targetGrades.map((g: any) => Number(g)).filter((n: number) => Number.isFinite(n))
      : [];
    await this.prisma.teacherMeeting.updateMany({ where: { id, teacherId }, data });
    return { ok: true };
  }

  async deleteTeacherMeeting(user: any, id: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const tm = await this.prisma.teacherMeeting.findFirst({ where: { id, teacherId } });
    if (tm) {
      await this.prisma.teacherMeeting.deleteMany({ where: { id, teacherId } });
      await this.prisma.classroomMeeting.deleteMany({ where: { OR: [{ teacherMeetingId: id }, { title: tm.title, classroom: { teacherId } }] } });
      return { ok: true };
    }
    const cm = await this.prisma.classroomMeeting.findFirst({ where: { id, classroom: { teacherId } } });
    if (cm) {
      await this.prisma.classroomMeeting.deleteMany({ where: { id } });
      if (cm.teacherMeetingId) {
        await this.prisma.teacherMeeting.deleteMany({ where: { id: cm.teacherMeetingId, teacherId } });
      } else {
        await this.prisma.teacherMeeting.deleteMany({ where: { title: cm.title, teacherId } });
      }
    }
    return { ok: true };
  }

  // ── Teacher Exams ─────────────────────────────────────────────────────────

  async listTeacherExams(user: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const exams = await this.prisma.teacherExam.findMany({
      where: { teacherId },
      orderBy: [{ date: 'desc' }],
    });
    return { exams };
  }

  async createTeacherExam(user: any, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const title = String(body?.title ?? '').trim();
    if (!title) throw new BadRequestException('title is required');
    const e = await this.prisma.teacherExam.create({
      data: {
        teacherId,
        title,
        subject: body?.subject ? String(body.subject).trim() : null,
        date: body?.date ? new Date(String(body.date)) : new Date(),
        maxGrade: body?.maxGrade ? Number(body.maxGrade) : null,
        published: body?.published === true,
        targetType: body?.targetType ?? 'EVERYONE',
        targetCohortIds: Array.isArray(body?.targetCohortIds) ? body.targetCohortIds : [],
        targetStudentIds: Array.isArray(body?.targetStudentIds) ? body.targetStudentIds : [],
        targetGrades: Array.isArray(body?.targetGrades)
          ? body.targetGrades.map((g: any) => Number(g)).filter((n: number) => Number.isFinite(n))
          : [],
        // Inline attachments (URLs the teacher pasted in or files they
        // uploaded outside the material library). The library-picker
        // path goes through attachMaterialToExam afterwards and APPENDs
        // its own snapshots — both flows now coexist.
        attachments: Array.isArray(body?.attachments) ? (body.attachments as any) : [],
      },
    });
    if (e.published) {
      try {
        const recipients = await this._audienceUserIds(user, e);
        if (recipients.length) {
          await this.hub.notify({
            recipientUserIds: recipients,
            type: 'NEW_EXAM',
            title: `New exam: ${title}`,
            body: e.subject ? `${e.subject} · ${e.date.toISOString().slice(0, 10)}` : e.date.toISOString().slice(0, 10),
            data: { examId: e.id },
          });
        }
      } catch (err) { console.error('[teacher] exam notify failed:', err); }
    }
    return { ok: true, exam: e };
  }

  /// Partial-update for an existing exam. Every field is optional;
  /// the absence of a key on `body` means "leave it alone". The
  /// teacher_create_exam_screen.dart sends a full payload when editing
  /// so audience + attachments stay in sync, but other call sites may
  /// PATCH a single field. Attachments are REPLACED when present so
  /// the teacher can remove inline files; library-picker materials
  /// continue to flow through attachMaterialToExam afterwards.
  async updateTeacherExam(user: any, id: string, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const existing = await this.prisma.teacherExam.findFirst({
      where: { id, teacherId },
    });
    if (!existing) throw new NotFoundException('Exam not found');

    const data: any = {};
    if (body?.title !== undefined) {
      const t = String(body.title).trim();
      if (!t) throw new BadRequestException('title cannot be empty');
      data.title = t;
    }
    if (body?.subject !== undefined) {
      data.subject = body.subject ? String(body.subject).trim() : null;
    }
    if (body?.date !== undefined) {
      data.date = body.date ? new Date(String(body.date)) : new Date();
    }
    if (body?.maxGrade !== undefined) {
      data.maxGrade = body.maxGrade ? Number(body.maxGrade) : null;
    }
    if (body?.published !== undefined) {
      data.published = body.published === true;
    }
    if (body?.targetType !== undefined) {
      data.targetType = String(body.targetType);
    }
    if (body?.targetCohortIds !== undefined) {
      data.targetCohortIds = Array.isArray(body.targetCohortIds) ? body.targetCohortIds : [];
    }
    if (body?.targetStudentIds !== undefined) {
      data.targetStudentIds = Array.isArray(body.targetStudentIds) ? body.targetStudentIds : [];
    }
    if (body?.targetGrades !== undefined) {
      data.targetGrades = Array.isArray(body.targetGrades)
        ? body.targetGrades.map((g: any) => Number(g)).filter((n: number) => Number.isFinite(n))
        : [];
    }
    if (body?.attachments !== undefined) {
      data.attachments = Array.isArray(body.attachments) ? (body.attachments as any) : [];
    }

    const updated = await this.prisma.teacherExam.update({
      where: { id },
      data,
    });
    return { ok: true, exam: updated };
  }

  async getExamGrades(user: any, examId: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const exam = await this.prisma.teacherExam.findFirst({
      where: { id: examId, teacherId },
      select: { id: true, title: true, subject: true, maxGrade: true, targetType: true, targetCohortIds: true, targetStudentIds: true },
    });
    if (!exam) throw new NotFoundException('Exam not found');

    // Resolve target students via school-wide list or targeted selection
    const schoolId = user.schoolId ?? null;
    let students: { id: string; name: string }[] = [];
    if ((exam.targetType as string) === 'EVERYONE') {
      students = await this.prisma.user.findMany({
        where: { ...(schoolId ? { schoolId } : {}), roles: { some: { role: 'STUDENT' } } },
        select: { id: true, name: true },
      });
    } else {
      const cohortStudents = exam.targetCohortIds?.length
        ? await this.prisma.studentCohort.findMany({ where: { cohortId: { in: exam.targetCohortIds } }, select: { studentId: true } })
        : [];
      const ids = Array.from(new Set([...(exam.targetStudentIds ?? []), ...cohortStudents.map((r) => r.studentId)]));
      students = await this.prisma.user.findMany({ where: { id: { in: ids } }, select: { id: true, name: true } });
    }

    // Find all assessments linked to this exam
    const assessments = await this.prisma.assessment.findMany({ where: { examId }, select: { id: true } });
    const assessmentIds = assessments.map((a) => a.id);
    const grades = assessmentIds.length
      ? await this.prisma.gradeRecord.findMany({ where: { assessmentId: { in: assessmentIds } }, select: { studentId: true, grade: true, comment: true } })
      : [];
    const gradeByStudent = new Map(grades.map((g) => [g.studentId, g]));

    return {
      ok: true,
      exam,
      students: students.map((s) => ({
        studentId: s.id,
        name: s.name,
        grade: gradeByStudent.get(s.id)?.grade ?? null,
        comment: gradeByStudent.get(s.id)?.comment ?? null,
      })),
    };
  }

  async saveExamGrades(user: any, examId: string, body: any) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    const exam = await this.prisma.teacherExam.findFirst({ where: { id: examId, teacherId } });
    if (!exam) throw new NotFoundException('Exam not found');

    let grades: { studentId: string; grade: number }[] = Array.isArray(body?.grades) ? body.grades : [];
    if (!grades.length) return { ok: true, saved: 0 };

    // School isolation: only grade students from the teacher's school
    const allowedIds = new Set(await this.filterToSchool(user, grades.map((g) => g.studentId)));
    grades = grades.filter((g) => allowedIds.has(g.studentId));
    if (!grades.length) return { ok: true, saved: 0 };

    // Group grades by student's cohort so each assessment is cohort-scoped.
    // Students without a cohort fall back to the exam's first target cohort
    // (when the exam was cohort-targeted) so individually-targeted students
    // and cohortless edge cases still get graded instead of silently dropped.
    const studentIds = grades.map((g) => g.studentId);
    const profiles = await this.prisma.studentProfile.findMany({
      where: { userId: { in: studentIds } },
      select: { userId: true, cohortId: true },
    });
    const cohortByStudent = new Map(profiles.map((p) => [p.userId, p.cohortId ?? '']));
    const fallbackCohortId = (exam.targetCohortIds ?? [])[0] ?? '';

    const byCohort = new Map<string, { studentId: string; grade: number }[]>();
    const dropped: string[] = [];
    for (const g of grades) {
      const cohortId = cohortByStudent.get(g.studentId) || fallbackCohortId;
      if (!cohortId) {
        dropped.push(g.studentId);
        continue;
      }
      byCohort.set(cohortId, [...(byCohort.get(cohortId) ?? []), g]);
    }

    let saved = 0;
    for (const [cohortId, cohortGrades] of byCohort.entries()) {
      let assessment = await this.prisma.assessment.findFirst({ where: { examId, cohortId } });
      if (!assessment) {
        assessment = await this.prisma.assessment.create({
          data: {
            createdBy: teacherId,
            title: exam.title,
            subject: exam.subject ?? null,
            cohortId,
            date: exam.date,
            maxGrade: exam.maxGrade ?? 100,
            examId,
            published: true,
          },
        });
      }
      for (const g of cohortGrades) {
        await this.prisma.gradeRecord.upsert({
          where: { assessmentId_studentId: { assessmentId: assessment.id, studentId: g.studentId } },
          update: { grade: Number(g.grade) },
          create: { assessmentId: assessment.id, studentId: g.studentId, grade: Number(g.grade) },
        });
        saved++;
        this.realtime.emitToUser(g.studentId, { type: 'grade_updated', studentId: g.studentId });
      }
    }
    return { ok: true, saved, requested: grades.length, dropped };
  }

  async deleteTeacherExam(user: any, id: string) {
    this.ensureTeacher(user);
    const teacherId = user.id ?? user.sub;
    await this.prisma.teacherExam.deleteMany({ where: { id, teacherId } });
    return { ok: true };
  }
}
