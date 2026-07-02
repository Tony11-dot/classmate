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

  async myCohorts(user: any): Promise<{
    ok: true;
    cohorts: Array<{ id: string; name: string; grade: number | null }>;
  }> {
    const studentId = user.sub ?? user.id;
    if (!studentId) return { ok: true, cohorts: [] };
    const links = await this.prisma.studentCohort.findMany({
      where: { studentId },
      select: {
        cohort: { select: { id: true, name: true, grade: true } },
      },
    });
    const cohorts = links
      .map((l) => l.cohort)
      .filter((c) => c != null)
      .map((c) => ({
        id: c!.id,
        name: c!.name,
        grade: (c as any).grade ?? null,
      }));
    return { ok: true, cohorts };
  }

  async onboard(
    user: any,
    body: {
      cohortId: string;
      joinCode: string;
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

    // Also create the StudentCohort join row. Every audience read path
    // (exams / assignments / materials / meetings) resolves a student's
    // cohorts from this join table, NOT the scalar `studentProfile.cohortId`.
    // Without this, a join-code onboarded student would miss all
    // cohort-targeted content. Idempotent on the composite [studentId,cohortId].
    await this.prisma.studentCohort.upsert({
      where: {
        studentId_cohortId: { studentId, cohortId: body.cohortId },
      },
      update: {},
      create: { studentId, cohortId: body.cohortId },
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
    return this.schedule.getTodayForStudent({
      // Coerce to empty string when the source field is null — the prior
      // `String(null)` produced the literal "null", which leaked into the
      // resolver as a bogus cohort/school id.
      schoolId: String(user.schoolId ?? ''),
      studentId: String(studentId),
      cohortId: String(sp.cohortId ?? ''),
    });
  }

  async weekSchedule(user: any, weekOf?: string) {
    this.ensureStudent(user);
    const studentId = user.sub ?? user.id;
    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: studentId },
    });
    if (!sp) throw new BadRequestException('Student not onboarded');
    return this.schedule.getWeekForStudent({
      schoolId: String(user.schoolId ?? ''),
      studentId: String(studentId),
      cohortId: String(sp.cohortId ?? ''),
      weekOf,
    });
  }

  async getInsights(user: any) {
    this.ensureStudent(user);
    return this.studentInsightsService.getStudentInsights(user);
  }

  async myAssessments(user: any) {
    this.ensureStudent(user);
    const studentId = user.sub ?? user.id;

    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: studentId },
    });
    if (!sp) throw new BadRequestException('Student not onboarded');

    if (!sp.cohortId) return { ok: true, assessments: [] };

    const assessments = await this.prisma.assessment.findMany({
      // Only published grades are visible to students; drafts stay hidden until
      // the teacher publishes them. `not: false` keeps legacy/null rows visible.
      where: { cohortId: sp.cohortId, published: { not: false } },
      orderBy: [{ date: 'desc' }, { id: 'desc' }],
    });

    const grades = await this.prisma.gradeRecord.findMany({
      // Per-student publish: hide this student's grade if it was unpublished,
      // even when the assessment is published to others.
      where: {
        studentId,
        assessmentId: { in: assessments.map((a) => a.id) },
        published: { not: false },
      },
      select: { assessmentId: true, grade: true, comment: true },
    });
    const gradeMap = new Map(grades.map((g) => [g.assessmentId, g]));

    return {
      ok: true,
      assessments: assessments.map((a) => {
        const g = gradeMap.get(a.id);
        return {
          id: a.id,
          title: a.title,
          date: a.date.toISOString(),
          maxGrade: a.maxGrade,
          subject: (a as any).subject ?? null,
          cohortId: a.cohortId,
          grade: g?.grade ?? null,
          comment: g?.comment ?? null,
        };
      }),
    };
  }

  async myGrades(user: any) {
    this.ensureStudent(user);
    const studentId = user.sub ?? user.id;

    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: studentId },
    });
    if (!sp) throw new BadRequestException('Student not onboarded');

    const rows = await this.prisma.gradeRecord.findMany({
      // Per-student publish: only this student's PUBLISHED grades. `not: false`
      // keeps legacy rows (before the column existed) visible.
      where: { studentId, published: { not: false } },
      orderBy: { id: 'desc' },
      include: { assessment: true },
    });

    const grades = rows.map((r) => ({
      id: r.id,
      grade: r.grade,
      comment: r.comment,
      assessment: {
        id: r.assessment.id,
        title: r.assessment.title,
        date: r.assessment.date,
        subject: (r.assessment as any).subject ?? null,
        cohortId: r.assessment.cohortId,
      },
    }));

    // Graded teacher-assignments also belong in the grades list. The teacher
    // scores them on the submission (TeacherAssignmentSubmission.grade); surface
    // each graded one as a grade entry so it appears in the student's Grades.
    const gradedAssignments = await this.prisma.teacherAssignmentSubmission.findMany({
      where: { studentId, grade: { not: null }, status: 'GRADED' },
      orderBy: { gradedAt: 'desc' },
      include: { assignment: { select: { id: true, title: true, subject: true } } },
    });
    for (const s of gradedAssignments) {
      grades.push({
        id: `asn-${s.id}`,
        grade: s.grade as any,
        // Feedback is intentionally NOT surfaced in the Grades list — it only
        // shows inside the assignment detail. Grades shows just title + score.
        comment: null,
        assessment: {
          id: `assignment-${(s as any).assignment?.id ?? s.assignmentId}`,
          title: (s as any).assignment?.title ?? 'Assignment',
          date: (s.gradedAt ?? s.submittedAt) as any,
          subject: (s as any).assignment?.subject ?? null,
          cohortId: null as any,
        },
      });
    }

    return { ok: true, grades };
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
      include: { session: true },
      orderBy: [{ session: { date: 'desc' } }, { session: { period: 'asc' } }],
    });

    return {
      ok: true,
      student: { id: studentId, name: profile.user.name },
      cohort: profile.cohort ? { id: profile.cohort.id, name: profile.cohort.name } : null,
      from: fromYmd,
      to: toYmd,
      items: records.map((r) => ({
        date: new Intl.DateTimeFormat('en-CA', { timeZone: 'UTC' }).format(
          (r as any).session?.date,
        ),
        period: (r as any).session?.period,
        status: r.status,
        note: r.note,
        subject: null,
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

  private async ensureClassroomAccessible(_user: any, cohortId: string) {
    const cohort = await (this.prisma as any).cohort.findUnique({
      where: { id: cohortId },
      select: { id: true },
    });
    if (!cohort) throw new NotFoundException('Classroom not found');
    return cohort;
  }

  async classroomPeople(user: any, cohortId: string) {
    await this.ensureClassroomAccessible(user, cohortId);
    return { ok: true, items: [], teachers: [], students: [], server: false };
  }

  async classroomChat(user: any, cohortId: string, _q: any) {
    await this.ensureClassroomAccessible(user, cohortId);
    return { ok: true, items: [], nextCursor: null, server: false };
  }

  async classroomSendChatText(user: any, cohortId: string, dto: any) {
    await this.ensureClassroomAccessible(user, cohortId);
    const text = typeof dto?.text === 'string' ? dto.text.trim() : '';
    if (!text) throw new BadRequestException('text required');
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

  async classroomSendChatMedia(user: any, cohortId: string, dto: any) {
    await this.ensureClassroomAccessible(user, cohortId);
    return {
      ok: true,
      server: false,
      item: { id: `local-media-${Date.now()}`, createdAt: new Date().toISOString(), senderName: user?.name ?? user?.email ?? 'You', mine: true, ...dto },
    };
  }

  async classroomAssignments(user: any, cohortId: string) {
    await this.ensureClassroomAccessible(user, cohortId);
    return { ok: true, items: [], server: false };
  }

  async classroomMaterials(user: any, cohortId: string) {
    await this.ensureClassroomAccessible(user, cohortId);
    return { ok: true, items: [], server: false };
  }

  async classroomMeetings(user: any, cohortId: string) {
    await this.ensureClassroomAccessible(user, cohortId);
    return { ok: true, items: [], server: false };
  }

  async myExams(user: any) {
    this.ensureStudent(user);
    const studentId = user.sub ?? user.id;
    const schoolId = user.schoolId ?? null;

    // Get student's cohort IDs + primary grade for targeting
    const [cohortLinks, profile] = await Promise.all([
      this.prisma.studentCohort.findMany({
        where: { studentId },
        select: { cohortId: true },
      }),
      this.prisma.studentProfile.findUnique({
        where: { userId: studentId },
        select: { grade: true },
      }),
    ]);
    const cohortIds = cohortLinks.map((c) => c.cohortId);
    const grade = profile?.grade ?? null;

    const exams = await this.prisma.teacherExam.findMany({
      where: {
        published: true,
        teacher: { ...(schoolId ? { schoolId } : {}) },
        OR: [
          // Gate the broadcast clause to records with NO narrower targeting, so a
          // grade-only item (stored as EVERYONE + targetGrades) no longer leaks
          // school-wide — it is matched by the targetGrades clause instead.
          { targetType: 'EVERYONE', targetCohortIds: { isEmpty: true }, targetStudentIds: { isEmpty: true }, targetGrades: { isEmpty: true } },
          { targetStudentIds: { has: studentId } },
          ...(cohortIds.length ? [{ targetCohortIds: { hasSome: cohortIds } }] : []),
          ...(grade != null ? [{ targetGrades: { has: grade } }] : []),
        ],
      },
      orderBy: { date: 'desc' },
      include: { teacher: { select: { name: true } } },
    });

    // Find grades for each exam. A student has at most one grade per exam, so
    // rather than guess which cohort bucket the teacher's save landed in
    // (StudentProfile.cohortId vs StudentCohort, plus the cohortless null
    // bucket), just find this student's GradeRecord for ANY assessment tied to
    // the exam. This is what made saved exam grades fail to show for students.
    const items = await Promise.all(exams.map(async (exam) => {
      const grade = await this.prisma.gradeRecord.findFirst({
        where: { studentId, published: { not: false }, assessment: { is: { examId: exam.id } } },
        select: { grade: true },
      });
      return {
        id: exam.id,
        title: exam.title,
        subject: exam.subject ?? null,
        date: exam.date,
        maxGrade: exam.maxGrade ?? 100,
        grade: grade?.grade ?? null,
        graded: grade?.grade != null,
        teacherName: (exam as any).teacher?.name ?? null,
      };
    }));

    return { ok: true, items };
  }

  async myTeacherAssignments(user: any) {
    this.ensureStudent(user);
    const studentId = user.sub ?? user.id;
    const schoolId = user.schoolId ?? null;

    const [cohortLinks, profile] = await Promise.all([
      this.prisma.studentCohort.findMany({
        where: { studentId },
        select: { cohortId: true },
      }),
      this.prisma.studentProfile.findUnique({
        where: { userId: studentId },
        select: { grade: true },
      }),
    ]);
    const cohortIds = cohortLinks.map((c) => c.cohortId);
    const grade = profile?.grade ?? null;

    const assignments = await this.prisma.teacherAssignment.findMany({
      where: {
        // Use `not: false` so legacy rows where `published` was never
        // set still surface — matches the materials-feed fix in build
        // 66 that resolved the same invisibility class of bug.
        published: { not: false },
        teacher: { ...(schoolId ? { schoolId } : {}) },
        OR: [
          // Gate the broadcast clause to records with NO narrower targeting, so a
          // grade-only item (stored as EVERYONE + targetGrades) no longer leaks
          // school-wide — it is matched by the targetGrades clause instead.
          { targetType: 'EVERYONE', targetCohortIds: { isEmpty: true }, targetStudentIds: { isEmpty: true }, targetGrades: { isEmpty: true } },
          { targetStudentIds: { has: studentId } },
          ...(cohortIds.length ? [{ targetCohortIds: { hasSome: cohortIds } }] : []),
          ...(grade != null ? [{ targetGrades: { has: grade } }] : []),
        ],
      },
      orderBy: [{ dueAt: 'asc' }, { createdAt: 'desc' }],
      include: { teacher: { select: { name: true } } },
    });

    // Check submission status for each — include the full submission so the
    // detail screen can re-hydrate the student's own files + note and show
    // "already handed in" / "returned for re-solution" on re-entry.
    const items = await Promise.all(assignments.map(async (a) => {
      const sub = await this.prisma.teacherAssignmentSubmission.findFirst({
        where: { assignmentId: a.id, studentId },
        select: {
          id: true,
          submittedAt: true,
          grade: true,
          feedback: true,
          note: true,
          files: true,
          status: true,
          gradedAt: true,
        },
      });
      const status = (sub as any)?.status ?? (sub ? 'SUBMITTED' : null);
      return {
        id: a.id,
        title: a.title,
        description: a.description ?? null,
        subject: a.subject ?? null,
        dueAt: a.dueAt ?? null,
        maxGrade: a.maxGrade ?? null,
        attachments: a.attachments,
        teacherName: (a as any).teacher?.name ?? null,
        // RETURNED submissions are awaiting a fresh hand-in, so the student
        // should still see the form open — report submitted=false for those.
        submitted: !!sub && status !== 'RETURNED',
        submittedAt: sub?.submittedAt ?? null,
        grade: sub?.grade ?? null,
        feedback: sub?.feedback ?? null,
        status,
        submission: sub
          ? {
              note: sub.note ?? null,
              files: sub.files ?? [],
              grade: sub.grade ?? null,
              feedback: sub.feedback ?? null,
              status,
              submittedAt: sub.submittedAt ?? null,
              gradedAt: (sub as any).gradedAt ?? null,
            }
          : null,
      };
    }));

    return { ok: true, items };
  }

  /// Student hands in (or re-hands-in) a teacher-wide assignment. Upserts the
  /// TeacherAssignmentSubmission keyed by (assignment, student). A resubmit
  /// after a teacher "return for re-solution" clears the prior grade and
  /// flips the status back to SUBMITTED.
  async submitTeacherAssignment(user: any, assignmentId: string, body: any) {
    this.ensureStudent(user);
    const studentId = String(user.sub ?? user.id ?? '');
    if (!studentId) throw new BadRequestException('Missing student identity');

    const assignment = await this.prisma.teacherAssignment.findUnique({
      where: { id: assignmentId },
      select: {
        id: true,
        teacherId: true,
        published: true,
        targetType: true,
        targetStudentIds: true,
        targetCohortIds: true,
        targetGrades: true,
        teacher: { select: { schoolId: true } },
      },
    });
    if (!assignment) throw new NotFoundException('Assignment not found');

    // Audience check: a student may only submit to an assignment that targets
    // them (was previously unchecked — any assignment id was submittable).
    const schoolId = user.schoolId ?? null;
    if (
      schoolId &&
      assignment.teacher?.schoolId &&
      assignment.teacher.schoolId !== schoolId
    ) {
      throw new NotFoundException('Assignment not found');
    }
    if (assignment.published === false) throw new NotFoundException('Assignment not found');
    const [cohortLinks, profile] = await Promise.all([
      this.prisma.studentCohort.findMany({
        where: { studentId },
        select: { cohortId: true },
      }),
      this.prisma.studentProfile.findUnique({
        where: { userId: studentId },
        select: { grade: true, cohortId: true },
      }),
    ]);
    const cohortIds = cohortLinks.map((c) => c.cohortId);
    if (profile?.cohortId && !cohortIds.includes(profile.cohortId)) {
      cohortIds.push(profile.cohortId);
    }
    const noNarrowTargeting =
      (assignment.targetCohortIds?.length ?? 0) === 0 &&
      (assignment.targetStudentIds?.length ?? 0) === 0 &&
      (assignment.targetGrades?.length ?? 0) === 0;
    const targeted =
      (assignment.targetType === 'EVERYONE' && noNarrowTargeting) ||
      assignment.targetStudentIds?.includes(studentId) ||
      cohortIds.some((c) => assignment.targetCohortIds?.includes(c)) ||
      (profile?.grade != null && assignment.targetGrades?.includes(profile.grade));
    if (!targeted) throw new NotFoundException('Assignment not found');

    const note = body?.note != null ? String(body.note) : null;
    const files = Array.isArray(body?.files) ? body.files : [];

    const sub = await this.prisma.teacherAssignmentSubmission.upsert({
      where: { assignmentId_studentId: { assignmentId, studentId } },
      update: {
        note,
        files: files as any,
        status: 'SUBMITTED',
        grade: null,
        gradedAt: null,
        submittedAt: new Date(),
      },
      create: {
        assignmentId,
        studentId,
        note,
        files: files as any,
        status: 'SUBMITTED',
      },
    });

    // (No realtime emit here — StudentService doesn't inject RealtimeService.
    // The teacher's submissions list refreshes when they open/refresh it.)
    return { ok: true, submission: sub };
  }

  /// The student's own submission for a single teacher assignment.
  async myTeacherAssignmentSubmission(user: any, assignmentId: string) {
    this.ensureStudent(user);
    const studentId = String(user.sub ?? user.id ?? '');
    const sub = await this.prisma.teacherAssignmentSubmission.findFirst({
      where: { assignmentId, studentId },
    });
    return { ok: true, submission: sub ?? null };
  }

  async myDiplomas(user: any) {
    const userId = String(user?.sub ?? user?.id ?? '');
    if (!userId) return { ok: true, diplomas: [] };

    const diplomas = await this.prisma.teacherDiploma.findMany({
      where: { studentId: userId },
      orderBy: { issuedAt: 'desc' },
      include: { teacher: { select: { name: true } } },
    });

    return {
      ok: true,
      diplomas: diplomas.map((d) => ({
        id: d.id,
        studentName: d.studentName,
        title: d.title,
        subject: d.subject ?? '',
        grade: d.grade ?? '',
        distinction: d.distinction ?? '',
        notes: d.notes ?? '',
        issuedAt: d.issuedAt.toISOString(),
        issuedBy: (d as any).teacher?.name ?? null,
        attachments: Array.isArray((d as any).attachments) ? (d as any).attachments : [],
      })),
    };
  }
}
