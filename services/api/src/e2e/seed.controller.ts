import { Body, Controller, Post } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

@Controller('/test/seed')
export class E2ESeedController {
  private prisma = new PrismaClient();

  @Post('/admin-web')
  async seedAdminWeb() {
    const now = Date.now();
    const passwordHash = await bcrypt.hash('dev', 10);

    // --- Tutor characters (Day 2) ---
    const mathTutor = await this.prisma.tutorCharacter.create({
      data: {
        subject: 'MATH',
        name: 'Math Tutor',
        curriculum: 'bagrut',
        maxGrade: 12,
        language: 'en',
        tone: 'friendly',
        verbosity: 6,
        explainStyle: 'step-by-step',
        systemNotes: 'Answer only in Bagrut level. Avoid university-level depth.',
      } as any,
      select: { id: true },
    });

    const physicsTutor = await this.prisma.tutorCharacter.create({
      data: {
        subject: 'PHYSICS',
        name: 'Physics Tutor',
        curriculum: 'bagrut',
        maxGrade: 12,
        language: 'en',
        tone: 'coach',
        verbosity: 6,
        explainStyle: 'examples',
        systemNotes: 'Use Bagrut physics style, constant acceleration assumptions unless asked otherwise.',
      } as any,
      select: { id: true },
    });

    const csTutor = await this.prisma.tutorCharacter.create({
      data: {
        subject: 'CS',
        name: 'CS Tutor',
        curriculum: 'bagrut',
        maxGrade: 12,
        language: 'en',
        tone: 'friendly',
        verbosity: 5,
        explainStyle: 'step-by-step',
        systemNotes: 'Keep it high-school level, avoid advanced CS theory unless requested.',
      } as any,
      select: { id: true },
    });


    const teacher = await this.prisma.user.upsert({
      where: { email: 'teacher1@classmate.app' },
      update: { password: passwordHash, name: 'Teacher One' },
      create: {
        email: 'teacher1@classmate.app',
        password: passwordHash,
        name: 'Teacher One',
        roles: { create: [{ role: 'TEACHER' }] },
      },
      select: { id: true },
    });

    await this.prisma.userRole.upsert({
      where: { userId_role: { userId: teacher.id, role: 'TEACHER' } },
      update: {},
      create: { userId: teacher.id, role: 'TEACHER' },
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
              assessment: { id: 'e2e-assessment', title: 'E2E Assessment', date: today.toISOString() },
              course: { id: course.id, name: course.name, subject: course.subject },
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
    };
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
    const mk = (minsAgo: number) => new Date(nowDt.getTime() - minsAgo * 60_000);

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
