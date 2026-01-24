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
      select: { id: true },
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
      teacherEmail: 'teacher1@classmate.app',
      parentEmail: 'parent1@classmate.app',
      password: 'dev',
    };
  }
  @Post('parent-web')
  async seedParentWeb(@Body() body: { runId?: string }) {
    // local/dev only convenience seed
    const runId =
      (body?.runId && String(body.runId).trim()) ||
      `${Date.now()}-${Math.random().toString(16).slice(2)}`;

    const email = `parent+${runId}@classmate.app`;
    const password = 'dev';

    // ---- ensure a cohort exists ----
    const cohort =
      (await this.prisma.cohort.findFirst({ orderBy: { id: 'desc' } })) ||
      (await this.prisma.cohort.create({
        data: {
          name: 'Cohort A',
          grade: 10 as any,
        } as any,
      }));

    // ---- ensure a student exists (reuse newest or create one) ----
    const student =
      (await this.prisma.user.findFirst({
        where: { roles: { some: { role: 'STUDENT' as any } } },
        orderBy: { id: 'desc' },
      })) ||
      (await this.prisma.user.create({
        data: {
          email: `student+${runId}@classmate.app`,
          name: `Student ${runId.slice(0, 6)}`,
          roles: ['STUDENT'] as any,
          cohortId: (cohort as any).id,
        } as any,
      }));

    // ---- ensure a course exists in this cohort ----
    const course =
      (await this.prisma.course.findFirst({
        where: { cohortId: (cohort as any).id },
        orderBy: { id: 'desc' },
      })) ||
      (await this.prisma.course.create({
        data: {
          cohortId: (cohort as any).id,
          name: 'Math',
          subject: 'MATH',
        } as any,
      }));

    // ---- create the parent user (unique per run) ----
    // If your user table has passwordHash, we set it; otherwise we just create and rely on existing auth mechanisms.
    // IMPORTANT: We do NOT try to mint a JWT here; we return email/password and globalSetup logs in via /api/auth/login.
    // use existing bcrypt import (bcrypt)

    const passwordHash = await bcrypt.hash(password, 10);

    const parent = await this.prisma.user.create({
      data: {
        email,
        name: `Parent ${runId.slice(0, 6)}`,
        roles: ['PARENT'] as any,
        passwordHash: passwordHash as any,
      } as any,
    });

    // ---- link parent<->child ----
    await this.prisma.parentChild.create({
      data: {
        parentId: (parent as any).id,
        childId: (student as any).id,
        status: 'APPROVED' as any,
      } as any,
    });

    // ---- seed a few notifications (some unread) ----
    const now = new Date();
    const mk = (minsAgo: number) => new Date(now.getTime() - minsAgo * 60_000);

    await this.prisma.parentNotification.createMany({
      data: [
        {
          parentId: (parent as any).id,
          studentId: (student as any).id,
          type: 'GRADE_POSTED',
          title: 'New grade posted',
          message: 'A new grade was posted.',
          data: { courseId: (course as any).id },
          createdAt: mk(5),
          seenAt: null,
        },
        {
          parentId: (parent as any).id,
          studentId: (student as any).id,
          type: 'ANNOUNCEMENT',
          title: 'New announcement',
          message: 'Please check today’s announcement.',
          data: { courseId: (course as any).id },
          createdAt: mk(20),
          seenAt: mk(10),
        },
        {
          parentId: (parent as any).id,
          studentId: (student as any).id,
          type: 'ATTENDANCE',
          title: 'Attendance updated',
          message: 'Attendance was updated.',
          data: { courseId: (course as any).id },
          createdAt: mk(60),
          seenAt: null,
        },
      ] as any,
    });

    return { ok: true, runId, email, password };
  }


}
