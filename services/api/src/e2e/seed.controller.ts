import { Controller, Post } from '@nestjs/common';
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
      select: { id: true },
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

    // E2E: create deterministic parent notifications
    // Seed uses Prisma directly (doesn't hit TeacherService), so we create ParentNotification rows here.
    const at = new Date();

    await this.prisma.parentNotification.createMany({
      data: [
        {
          // attendance
          parentId: parent.id,
          studentId: student.id,
          type: 'ATTENDANCE_RECORDED' as any,
          title: 'Absence recorded',
          at,
          data: { courseId: course.id, status: 'ABSENT', period: 1, date: today } as any,
        },
        {
          // grade
          parentId: parent.id,
          studentId: student.id,
          type: 'GRADE_POSTED' as any,
          title: 'New grade in Math',
          at,
          data: { courseId: course.id, grade: 95 } as any,
        },
      ],
      skipDuplicates: true,
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

    return {
      ok: true,
      cohortId: cohort.id,
      courseId: course.id,
      teacherEmail: 'teacher1@classmate.app',
      parentEmail: 'parent1@classmate.app',
      password: 'dev',
    };
  }
}
