import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { E2ESeedGuard } from './e2e-seed.guard';
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

@UseGuards(E2ESeedGuard)
@Controller('/test/seed')
export class E2ESeedController {
  private prisma = new PrismaClient();

  @Post('/admin-web')
  async seedAdminWeb() {
    const now = Date.now();
    const passwordHash = await bcrypt.hash('dev', 10);

    const teacher = await this.prisma.user.upsert({
      where: { email: 'teacher1@classmate.app' },
      update: { password: passwordHash, name: 'Teacher One' },
      create: {
        email: 'teacher1@classmate.app',
        password: passwordHash,
        name: 'Teacher One',
        roles: { create: [{ role: 'TEACHER' }, { role: 'ADMIN' }] },
      },
      select: { id: true },
    });

    await this.prisma.userRole.upsert({
      where: { userId_role: { userId: teacher.id, role: 'TEACHER' } },
      update: {},
      create: { userId: teacher.id, role: 'TEACHER' },
    });

    await this.prisma.userRole.upsert({
      where: { userId_role: { userId: teacher.id, role: 'ADMIN' } },
      update: {},
      create: { userId: teacher.id, role: 'ADMIN' },
    });

    const teacher2 = await this.prisma.user.upsert({
      where: { email: 'teacher2@classmate.app' },
      update: { password: passwordHash, name: 'Teacher Two' },
      create: {
        email: 'teacher2@classmate.app',
        password: passwordHash,
        name: 'Teacher Two',
        roles: { create: [{ role: 'TEACHER' }] },
      },
      select: { id: true },
    });

    await this.prisma.userRole.upsert({
      where: { userId_role: { userId: teacher2.id, role: 'TEACHER' } },
      update: {},
      create: { userId: teacher2.id, role: 'TEACHER' },
    });

    const cohort = await this.prisma.cohort.create({
      data: { name: `e2e-cohort-${now}`, grade: 10 },
      select: { id: true },
    });

    // Tutor seed: default characters (cohort scope)
    const subjects = [
      'GENERAL',
      'MATH',
      'PHYSICS',
      'CS',
      'ENGLISH',
      'HEBREW',
      'ARABIC',
    ] as const;
    const createdBySubject: Record<string, any> = {};

    for (const subj of subjects) {
      const created = await this.prisma.tutorCharacter.create({
        data: {
          cohortId: cohort.id,
          subject: subj as any,
          name:
            subj === 'MATH'
              ? 'Math Tutor'
              : subj === 'PHYSICS'
                ? 'Physics Tutor'
                : subj === 'CS'
                  ? 'CS Tutor'
                  : subj === 'ENGLISH'
                    ? 'English Tutor'
                    : subj === 'HEBREW'
                      ? 'Hebrew Tutor'
                      : subj === 'ARABIC'
                        ? 'Arabic Tutor'
                        : 'General Tutor',
          curriculum: 'bagrut',
          maxGrade: 12,
          language: 'en',
          tone: subj === 'PHYSICS' ? 'coach' : 'friendly',
          verbosity: 5,
          explainStyle: subj === 'PHYSICS' ? 'examples' : 'step-by-step',
          systemNotes:
            'Bagrut level only. Adapt to learning profile and AI brain. Ask mini-quiz.',
        } as any,
        select: { id: true, subject: true, name: true },
      });
      createdBySubject[String(subj)] = created;
    }

    const mathTutor = createdBySubject.MATH;
    const physicsTutor = createdBySubject.PHYSICS;
    const csTutor = createdBySubject.CS;

    const course = await this.prisma.course.create({
      data: {
        name: `e2e-course-${now}`,
        subject: 'MATH',
        teacher: { connect: { id: teacher.id } },
        cohort: { connect: { id: cohort.id } },
      },
      select: { id: true, name: true, subject: true },
    });

    // --- extra teacher/cohort/course for isolation tests ---
    const cohort2 = await this.prisma.cohort.create({
      data: { name: `e2e-cohort2-${now}`, grade: 10 },
      select: { id: true },
    });

    const course2 = await this.prisma.course.create({
      data: {
        name: `e2e-course2-${now}`,
        subject: 'MATH',
        teacher: { connect: { id: teacher2.id } },
        cohort: { connect: { id: cohort2.id } },
      },
      select: { id: true, name: true, subject: true },
    });

    await this.prisma.scheduleSlot.create({
      data: {
        cohortId: cohort2.id,
        courseId: course2.id,
        dayOfWeek: new Date().getDay(),
        period: 2,
      },
    });

    await this.prisma.scheduleSlot.create({
      data: {
        cohortId: cohort.id,
        courseId: course.id,
        dayOfWeek: new Date().getDay(),
        period: 1,
      },
    });

    const student = await this.prisma.user.create({
      data: {
        email: `student1+e2e-${now}@classmate.app`,
        password: passwordHash,
        name: 'Student One',
        roles: { create: [{ role: 'STUDENT' }] },
        studentProfile: {
          create: {
            cohort: { connect: { id: cohort.id } },
            englishLevel: 3,
            mathLevel: 3,
          },
        },
      },
      select: { id: true, email: true },
    });
    // Tutor seed: one Bagrut material + brain snapshot
    await this.prisma.material.create({
      data: {
        title: `Bagrut: Derivative basics (${now})`,
        subject: 'MATH',
        grade: 11,
        language: 'en',
        source: 'BAGrut',
        content:
          'Derivative definition: slope of tangent. Basic rules: power rule, sum rule. Example: d/dx(x^2)=2x.',
        tags: ['derivative', 'calculus', 'bagrut'],
      } as any,
    });

    await this.prisma.studentBrainSnapshot.create({
      data: {
        userId: student.id,
        cohortId: cohort.id,
        metrics: {
          subjects: {
            MATH: {
              avg: 78,
              trend: 'up',
              weak: ['derivatives'],
              strong: ['algebra'],
            },
          },
          note: 'Prefers step-by-step and short quizzes.',
        },
      } as any,
    });

    const parent = await this.prisma.user.upsert({
      where: { email: 'parent1@classmate.app' },
      update: { password: passwordHash, name: 'Parent One' },
      create: {
        email: 'parent1@classmate.app',
        password: passwordHash,
        name: 'Parent One',
        roles: { create: [{ role: 'PARENT' }] },
      },
      select: { id: true },
    });

    await this.prisma.userRole.upsert({
      where: { userId_role: { userId: parent.id, role: 'PARENT' } },
      update: {},
      create: { userId: parent.id, role: 'PARENT' },
    });

    // Link parent <-> child (student)
    await this.prisma.parentChild.upsert({
      where: { parentId_childId: { parentId: parent.id, childId: student.id } },
      update: { status: 'APPROVED' },
      create: { parentId: parent.id, childId: student.id, status: 'APPROVED' },
    });

    await this.prisma.enrollment.create({
      data: {
        courseId: course.id,
        studentId: student.id,
      },
    });

    const today = new Date();

    today.setHours(12, 0, 0, 0);

    const session = await this.prisma.attendanceSession.create({
      data: {
        cohortId: cohort.id,

        date: today,

        period: 1,

        courseId: course.id,
      },

      select: { id: true },
    });

    await this.prisma.attendanceRecord.create({
      data: {
        sessionId: session.id,

        studentId: student.id,

        status: 'PRESENT',
      },
    });

    // E2E: create deterministic parent notifications (safe + matches TeacherService payload)
    try {
      await this.prisma.parentNotification.createMany({
        data: [
          {
            parentId: parent.id,
            studentId: student.id,
            type: 'ATTENDANCE_RECORDED',
            title: 'Absence recorded',
            message: null,
            data: {
              status: 'ABSENT',
              sessionId: session.id,
              cohortId: cohort.id,
              date: today.toISOString(),
              period: 1,
              courseId: course.id,
            },
            createdAt: new Date(),
          },
          {
            parentId: parent.id,
            studentId: student.id,
            type: 'GRADE_POSTED',
            title: `New grade in ${course.name}`,
            message: null,
            data: {
              grade: 95,
              comment: null,
              assessment: {
                id: 'e2e-assessment',
                title: 'E2E Assessment',
                date: today.toISOString(),
              },
              course: {
                id: course.id,
                name: course.name,
                subject: course.subject,
              },
            },
            createdAt: new Date(),
          },
        ],
      });
    } catch (_e) {
      // don't break seed on notification failures
    }

    return {
      ok: true,
      cohortId: cohort.id,
      courseId: course.id,
      cohort2Id: cohort2.id,
      course2Id: course2.id,
      teacherEmail: 'teacher1@classmate.app',
      studentEmail: student.email,
      teacher2Email: 'teacher2@classmate.app',
      parentEmail: 'parent1@classmate.app',
      password: 'dev',
      mathTutorId: mathTutor.id,
      physicsTutorId: physicsTutor.id,
      csTutorId: csTutor.id,
      characterIds: (
        await this.prisma.tutorCharacter.findMany({
          select: { id: true, subject: true, name: true },
        })
      ).map((x) => x),
    };
  }
  @Post('clear-tutor-characters')
  async clearTutorCharacters(@Body() body: any) {
    const cohortId = body?.cohortId ? String(body.cohortId) : null;

    if (!cohortId) {
      return { ok: false, message: 'cohortId required' };
    }

    const deleted = await this.prisma.tutorCharacter.deleteMany({
      where: { cohortId },
    });

    return { ok: true, deletedCount: deleted.count, cohortId };
  }

  @Post('parent-web')
  async seedParentWeb(@Body() body: { runId?: string }) {
    const now = Date.now();
    const runId =
      (body?.runId && String(body.runId).trim()) ||
      `${now}-${Math.random().toString(16).slice(2)}`;

    const passwordHash = await bcrypt.hash('dev', 10);

    // create a fresh cohort/course/student/parent per run (isolated)
    const cohort = await this.prisma.cohort.create({
      data: { name: `pw-cohort-${runId}`, grade: 10 as any },
      select: { id: true },
    });

    const student = await this.prisma.user.create({
      data: {
        email: `student+pw-${runId}@classmate.app`,
        password: passwordHash,
        name: `Student ${runId.slice(0, 6)}`,
        roles: { create: [{ role: 'STUDENT' }] },
        studentProfile: {
          create: {
            cohort: { connect: { id: cohort.id } },
            englishLevel: 3,
            mathLevel: 3,
          },
        },
      } as any,
      select: { id: true },
    });

    const parent = await this.prisma.user.create({
      data: {
        email: `parent+pw-${runId}@classmate.app`,
        password: passwordHash,
        name: `Parent ${runId.slice(0, 6)}`,
        roles: { create: [{ role: 'PARENT' }] },
      } as any,
      select: { id: true, email: true },
    });

    await this.prisma.parentChild.upsert({
      where: { parentId_childId: { parentId: parent.id, childId: student.id } },
      update: { status: 'APPROVED' },
      create: { parentId: parent.id, childId: student.id, status: 'APPROVED' },
    });

    // minimal course so parent-web can enrich (courseId present)
    const course = await this.prisma.course.create({
      data: {
        name: `pw-course-${runId}`,
        subject: 'MATH',
        cohort: { connect: { id: cohort.id } },
      } as any,
      select: { id: true, name: true },
    });

    const nowDt = new Date();
    const mk = (minsAgo: number) =>
      new Date(nowDt.getTime() - minsAgo * 60_000);

    await this.prisma.parentNotification.createMany({
      data: [
        {
          parentId: parent.id,
          studentId: student.id,
          type: 'ATTENDANCE_RECORDED',
          title: 'Absence recorded',
          message: null,
          data: { courseId: course.id },
          createdAt: mk(5),
          seenAt: null,
        },
        {
          parentId: parent.id,
          studentId: student.id,
          type: 'GRADE_POSTED',
          title: `New grade in ${course.name}`,
          message: null,
          data: { courseId: course.id },
          createdAt: mk(20),
          seenAt: mk(10),
        },
      ] as any,
    });

    return { ok: true, runId, email: parent.email, password: 'dev' };
  }
}
