import { Controller, Post, Res } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import type { Response } from 'express';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';

@Controller('test/seed')
@SkipThrottle()
export class E2ESeedController {
  constructor(private readonly prisma: PrismaService) {}

  @Post('admin-web')
  async adminWeb(@Res() res: Response) {
    const prisma: any = this.prisma;

    const adminEmail = 'admin1@classmate.app';
    const password = 'dev';
    const hash = await bcrypt.hash(password, 10);

    try {
      // school (best-effort; only if model exists)
      const schoolId = 'test-school';
      await prisma.school?.upsert?.({
        where: { id: schoolId } as any,
        update: { name: 'Test School' } as any,
        create: { id: schoolId, name: 'Test School' } as any,
      } as any).catch(() => {});

      // cohort: stable + idempotent (requires name unique)
      const cohortName = 'E2E Cohort';
      const cohort = await prisma.cohort.upsert({
        where: { name: cohortName } as any,
        update: { grade: 10 } as any,
        create: { name: cohortName, grade: 10 } as any,
      } as any);
      // ================================
      // Session 10: subject defaults seed
      // ================================
      // per-grade defaults for Test School (best-effort; only if model exists)
      await prisma.schoolGradeSubjectDefault?.upsert?.({
        where: { schoolId_grade: { schoolId, grade: 10 } } as any,
        update: { subjects: ['Math','English','Chemistry','Biology','Electronics'] } as any,
        create: { schoolId, grade: 10, subjects: ['Math','English','Chemistry','Biology','Electronics'] } as any,
      } as any).catch(() => {});


      // ================================
      // === E2E ATTENDANCE FULL SEED ===
      // ================================

      // teacher1
      const teacherEmail = 'teacher1@classmate.app';
      const teacher = await prisma.user.upsert({
        where: { email: teacherEmail } as any,
        update: {
          password: hash,
          roles: { deleteMany: {}, create: [{ role: 'TEACHER' }] },
        } as any,
        create: {
          email: teacherEmail,
          name: 'Teacher 1',
          password: hash,
          roles: { create: [{ role: 'TEACHER' }] },
        } as any,
      } as any);

      // one student
      const studentUser = await prisma.user.upsert({
        where: { email: 'student1@classmate.app' } as any,
        update: {
          roles: { deleteMany: {}, create: [{ role: 'STUDENT' }] },
        } as any,
        create: {
          email: 'student1@classmate.app',
          name: 'Student 1',
          password: hash,
          roles: { create: [{ role: 'STUDENT' }] },
        } as any,
      } as any);

      await prisma.studentProfile.upsert({
        where: { userId: studentUser.id } as any,
        update: { cohortId: cohort.id, englishLevel: 4, mathLevel: 4 } as any,
        create: {
          userId: studentUser.id,
          cohortId: cohort.id,
          englishLevel: 4,
          mathLevel: 4,
        } as any,
      } as any);

      // course linked to teacher + cohort
      const course = await prisma.course.upsert({
        where: { id: 'e2e-course' } as any,
        update: {
          teacherId: teacher.id,
          cohortId: cohort.id,
        } as any,
        create: {
          id: 'e2e-course',
          name: 'E2E Electronics',
          subject: 'Electronics',
          teacherId: teacher.id,
          cohortId: cohort.id,
        } as any,
      } as any);

      // schedule slot for TODAY period 1
      const now = new Date();
      const dayOfWeek = now.getDay(); // 0-6 (matches schema)

      await prisma.scheduleSlot.upsert({
        where: {
          cohortId_dayOfWeek_period: {
            cohortId: cohort.id,
            dayOfWeek,
            period: 1,
          },
        } as any,
        update: { courseId: course.id } as any,
        create: {
          cohortId: cohort.id,
          dayOfWeek,
          period: 1,
          courseId: course.id,
        } as any,
      } as any);

      // enroll student into course
      await prisma.enrollment.upsert({
        where: {
          courseId_studentId: {
            courseId: course.id,
            studentId: studentUser.id,
          },
        } as any,
        update: {} as any,
        create: {
          courseId: course.id,
          studentId: studentUser.id,
        } as any,
      } as any);



      // admin user: idempotent
      const admin = await prisma.user.upsert({
        where: { email: adminEmail } as any,
        update: {
          password: hash,
          roles: { deleteMany: {}, create: [{ role: 'ADMIN' }] },
        } as any,
        create: {
          email: adminEmail,
          name: 'Admin 1',
          password: hash,
          roles: { create: [{ role: 'ADMIN' }] },
        } as any,
      } as any);

      // admin profile (best-effort; only if model exists)
      await prisma.adminProfile?.upsert?.({
        where: { userId: admin.id } as any,
        update: {} as any,
        create: { userId: admin.id, schoolId } as any,
      } as any).catch(() => {});

      return res.status(201).json({
        ok: true,
        adminEmail,
        password,
        adminId: admin.id,
        cohortId: cohort.id,
      });
    } catch (e: any) {


return res.status(500).json({ ok: false, error: String(e?.message ?? e) });
    }
  }
}