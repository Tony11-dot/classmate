import { Controller, Post, Res, Get, Param } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import type { Response } from 'express';
import * as bcrypt from 'bcrypt';

@Controller('test/seed')
export class E2ESeedController {
  constructor(private readonly prisma: PrismaService) {}

  @Get('db-check/:email')
  async dbCheck(@Res() res: Response, @Param('email') email: string) {
    const prisma: any = this.prisma;
    try {
      const u = await prisma.user.findUnique({
        where: { email } as any,
        select: { id: true, email: true, roles: { select: { role: true } } },
      });
      const sp = u?.id
        ? await prisma.studentProfile?.findFirst?.({
            where: { userId: u.id } as any,
            select: { userId: true, cohortId: true, englishLevel: true, mathLevel: true },
          })
        : null;
      const enroll = u?.id
        ? await prisma.enrollment?.findMany?.({
            where: { studentId: u.id } as any,
            select: { courseId: true, studentId: true },
          })
        : [];
      
      const courseIds = (enroll || []).map((e: any) => e.courseId).filter(Boolean);
      const coursesForStudent = courseIds.length
        ? await prisma.course?.findMany?.({
            where: { id: { in: courseIds } } as any,
            select: { id: true, name: true, subject: true, teacherId: true, cohortId: true } as any,
          })
        : [];
return res.status(200).json({
        ok: true,
        file: 'services/api/src/e2e/seed.controller.ts',
        dbUrl: process.env.DATABASE_URL || null,
        user: u || null,
        studentProfile: sp || null,
        enrollments: enroll || [],
        coursesForStudent: coursesForStudent || [],
      });
    } catch (e: any) {
      return res.status(500).json({ ok: false, error: String(e?.message ?? e) });
    }
  }




  @Post('clear-tutor-characters')
  async clearTutorCharacters(@Res() res: Response) {
    const prisma: any = this.prisma;
    try {
      await prisma.tutorMessage?.deleteMany?.({} as any).catch(() => {});
      await prisma.tutorSession?.deleteMany?.({} as any).catch(() => {});
      await prisma.tutorReplyCache?.deleteMany?.({} as any).catch(() => {});
      await prisma.tutorCharacter?.deleteMany?.({} as any).catch(() => {});
      return res.status(200).json({ ok: true });
    } catch (e: any) {
      return res.status(500).json({ ok: false, error: String(e?.message ?? e) });
    }
  }

  @Post('admin-web')
  async adminWeb(@Res() res: Response) {
    const adminEmail = 'admin1@classmate.app';
    const teacherEmail = 'teacher1@classmate.app';
    const teacher2Email = 'teacher2@classmate.app';
    const parentEmail = 'parent1@classmate.app';
    const studentEmail = 'student1@classmate.app';
    const password = 'dev';

    const hash = await bcrypt.hash(password, 10);
    const prisma: any = this.prisma;

    let cohortId: any = undefined;
    let cohort2Id: any = undefined;
    let courseId: any = undefined;
    let course2Id: any = undefined;
    let mathTutorId: any = undefined;
    let physicsTutorId: any = undefined;

    const cohortDebug: any[] = [];

    try {
      await prisma.school
        ?.upsert?.({
          where: { id: 'test-school' } as any,
          update: {} as any,
          create: { id: 'test-school', name: 'Test School' } as any,
        })
        .catch(() => {});

      try {
        const models = Object.keys((prisma as any) ?? {});
        cohortDebug.push({
          models: models.filter((k) => !k.startsWith('$')).slice(0, 200),
        });
      } catch (e) {
        cohortDebug.push({ modelsErr: String((e as any)?.message ?? e) });
      }

      const COHORT1 = `Test Cohort`;
      const COHORT2 = `Test Cohort 2`;

      try {
        const created = await prisma.cohort.upsert({
          where: { name: COHORT1 } as any,
          update: { grade: 10 } as any,
          create: { name: COHORT1, grade: 10 } as any,
        } as any);
        cohortId = created?.id;
      } catch {
        const created2 = await prisma.cohort.create({
          data: { name: `${COHORT1} ${Date.now()}`, grade: 10 } as any,
        } as any);
        cohortId = created2?.id;
      }

      try {
        const created = await prisma.cohort.upsert({
          where: { name: COHORT2 } as any,
          update: { grade: 10 } as any,
          create: { name: COHORT2, grade: 10 } as any,
        } as any);
        cohort2Id = created?.id;
      } catch {
        const created2 = await prisma.cohort.create({
          data: { name: `${COHORT2} ${Date.now()}`, grade: 10 } as any,
        } as any);
        cohort2Id = created2?.id;
      }

      if (!cohortId || !cohort2Id) {
        return res
          .status(500)
          .json({ ok: false, error: 'FAILED_TO_CREATE_COHORTS', cohortDebug });
      }

      await prisma.user.upsert({
        where: { email: adminEmail } as any,
        update: {
          name: 'Admin 1',
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

      await prisma.user.upsert({
        where: { email: teacherEmail } as any,
        update: {
          name: 'Teacher 1',
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

      await prisma.user.upsert({
        where: { email: teacher2Email } as any,
        update: {
          name: 'Teacher 2',
          password: hash,
          roles: { deleteMany: {}, create: [{ role: 'TEACHER' }] },
        } as any,
        create: {
          email: teacher2Email,
          name: 'Teacher 2',
          password: hash,
          roles: { create: [{ role: 'TEACHER' }] },
        } as any,
      } as any);

      await prisma.user.upsert({
        where: { email: parentEmail } as any,
        update: {
          name: 'Parent 1',
          password: hash,
          roles: { deleteMany: {}, create: [{ role: 'PARENT' }] },
        } as any,
        create: {
          email: parentEmail,
          name: 'Parent 1',
          password: hash,
          roles: { create: [{ role: 'PARENT' }] },
        } as any,
      } as any);

      await prisma.user.upsert({
        where: { email: studentEmail } as any,
        update: {
          name: 'Student 1',
          password: hash,
          roles: { deleteMany: {}, create: [{ role: 'STUDENT' }] },
        } as any,
        create: {
          email: studentEmail,
          name: 'Student 1',
          password: hash,
          roles: { create: [{ role: 'STUDENT' }] },
        } as any,
      } as any);

      const t1 = await prisma.user.findUnique({
        where: { email: teacherEmail } as any,
      });
      const t2 = await prisma.user.findUnique({
        where: { email: teacher2Email } as any,
      });
      const st = await prisma.user.findUnique({
        where: { email: studentEmail } as any,
      });
// CM_SEED_PROFILE_LINKS_START
      const parent = await prisma.user.findUnique({
        where: { email: parentEmail } as any,
      });

      // ✅ StudentProfile must exist (ClassroomsService requires it by userId)
      if (st?.id) {
        await prisma.studentProfile.upsert({
          where: { userId: st.id } as any,
          update: {
            cohortId,
            englishLevel: 3,
            mathLevel: 3,
          } as any,
          create: {
            userId: st.id,
            cohortId,
            englishLevel: 3,
            mathLevel: 3,
          } as any,
        } as any);
      }

      // ✅ Parent must be linked to student for /parent/classrooms
      if (parent?.id && st?.id) {
        await prisma.parentChild.upsert({
          where: { parentId_childId: { parentId: parent.id, childId: st.id } } as any,
          update: { status: 'APPROVED' } as any,
          create: { parentId: parent.id, childId: st.id, status: 'APPROVED' } as any,
        } as any);
      }
      // CM_SEED_PROFILE_LINKS_END

      if (t1?.id)
        await prisma.teacher
          ?.upsert?.({
            where: { userId: t1.id } as any,
            update: {} as any,
            create: { userId: t1.id } as any,
          })
          .catch(() => {});
      if (t2?.id)
        await prisma.teacher
          ?.upsert?.({
            where: { userId: t2.id } as any,
            update: {} as any,
            create: { userId: t2.id } as any,
          })
          .catch(() => {});
      if (st?.id)
        await prisma.student
          ?.upsert?.({
            where: { userId: st.id } as any,
            update: {} as any,
            create: { userId: st.id } as any,
          })
          .catch(() => {});

      const c1 = await prisma.course.upsert({
        where: { id: 'test-course-teacher1-cohort1' } as any,
        update: {
          name: 'Test Course 1',
          subject: 'TEST',
          teacherId: t1?.id,
          cohortId,
        } as any,
        create: {
          id: 'test-course-teacher1-cohort1',
          name: 'Test Course 1',
          subject: 'TEST',
          teacherId: t1?.id,
          cohortId,
        } as any,
      } as any);
      courseId = c1?.id;

      // ✅ Ensure enrollment for student -> course1
      if (st?.id && c1?.id) {
        await prisma.enrollment.upsert({
          where: { courseId_studentId: { courseId: c1.id, studentId: st.id } } as any,
          update: {} as any,
          create: { courseId: c1.id, studentId: st.id, source: 'AUTO' } as any,
        } as any);
      }


      // ✅ Ensure enrollment exists so /student/classrooms can list memberships
      if (st?.id && c1?.id) {
        await prisma.enrollment.upsert({
          where: { courseId_studentId: { courseId: c1.id, studentId: st.id } } as any,
          update: {} as any,
          create: { courseId: c1.id, studentId: st.id, source: 'AUTO' } as any,
        } as any);
      }




      // ensure attendance template slot exists (scheduleSlot) + today override + at least 1 studentProfile
      try {
        // compute dateYmd + dayOfWeek in Asia/Jerusalem
        const now = new Date();
        const dateYmd = new Intl.DateTimeFormat('en-CA', {
          timeZone: 'Asia/Jerusalem',
          year: 'numeric',
          month: '2-digit',
          day: '2-digit',
        }).format(now);

        const wk = new Intl.DateTimeFormat('en-US', {
          timeZone: 'Asia/Jerusalem',
          weekday: 'short',
        }).format(now);
        const map = { Sun: 0, Mon: 1, Tue: 2, Wed: 3, Thu: 4, Fri: 5, Sat: 6 };
        const dayOfWeek = map[wk] ?? 0;

        const period = 1;

        // IMPORTANT: TeacherService expects override.date as DateTime at UTC midnight
        const date = new Date(`${dateYmd}T00:00:00.000Z`);

        // 1) scheduleSlot (weekly template)
        if (prisma.scheduleSlot?.upsert) {
          await prisma.scheduleSlot.upsert({
            where: { cohortId_dayOfWeek_period: { cohortId, dayOfWeek, period } },
            update: { courseId },
            create: { cohortId, dayOfWeek, period, courseId },
          });
        } else if (prisma.scheduleSlot?.create) {
          await prisma.scheduleSlot.deleteMany?.({ where: { cohortId, dayOfWeek, period } }).catch(() => {});
          await prisma.scheduleSlot.create({ data: { cohortId, dayOfWeek, period, courseId } });
        }

        // 2) scheduleOverride (today)
        if (prisma.scheduleOverride?.upsert) {
          await prisma.scheduleOverride.upsert({
            where: { cohortId_date_period: { cohortId, date, period } },
            update: { courseId },
            create: { cohortId, date, period, courseId },
          });
        } else if (prisma.scheduleOverride?.create) {
          await prisma.scheduleOverride.deleteMany?.({ where: { cohortId, date, period } }).catch(() => {});
          await prisma.scheduleOverride.create({ data: { cohortId, date, period, courseId } });
        }

        // 3) ensure at least 1 studentProfile exists in cohortId (UI table needs rows)
        // st is the user row for studentEmail; student row is keyed by userId in this seed.
        let studentRow: any = null;
        try {
          if (prisma.student?.findUnique) {
            studentRow = await prisma.student.findUnique({ where: { userId: st?.id } });
          }
        } catch {}

        const studentId = (studentRow && studentRow.id) ? studentRow.id : null;

        // Try common schemas:
        // - studentProfile unique on studentId
        // - studentProfile unique on userId
        if (prisma.studentProfile?.upsert) {
          if (studentId) {
            try {
              await prisma.studentProfile.upsert({
                where: { studentId },
                update: { cohortId },
                create: { studentId, cohortId, name: 'Student 1' },
              });
            } catch {
              await prisma.studentProfile.upsert({
                where: { userId: st?.id },
                update: { cohortId },
                create: { userId: st?.id, cohortId, name: 'Student 1' },
              });
            }
          } else {
            // studentId missing -> fall back to userId schema
            await prisma.studentProfile.upsert({
              where: { userId: st?.id },
              update: { cohortId },
              create: { userId: st?.id, cohortId, name: 'Student 1' },
            });
          }
        } else if (prisma.studentProfile?.create) {
          // last-resort create (best-effort idempotent)
          if (studentId) {
            await prisma.studentProfile.deleteMany?.({ where: { studentId } }).catch(() => {});
            try {
              await prisma.studentProfile.create({
                data: { studentId, cohortId, name: 'Student 1' },
              });
            } catch {
              await prisma.studentProfile.deleteMany?.({ where: { userId: st?.id } }).catch(() => {});
              await prisma.studentProfile.create({
                data: { userId: st?.id, cohortId, name: 'Student 1' },
              });
            }
          } else {
            await prisma.studentProfile.deleteMany?.({ where: { userId: st?.id } }).catch(() => {});
            await prisma.studentProfile.create({
              data: { userId: st?.id, cohortId, name: 'Student 1' },
            });
          }
        }

      } catch {}

      const c2 = await prisma.course.upsert({
        where: { id: 'test-course-teacher2-cohort2' } as any,
        update: {
          name: 'Test Course 2',
          subject: 'TEST',
          teacherId: t2?.id,
          cohortId: cohort2Id,
        } as any,
        create: {
          id: 'test-course-teacher2-cohort2',
          name: 'Test Course 2',
          subject: 'TEST',
          teacherId: t2?.id,
          cohortId: cohort2Id,
        } as any,
      } as any);
      course2Id = c2?.id;

      // ✅ Ensure enrollment for student -> course2
      if (st?.id && c2?.id) {
        await prisma.enrollment.upsert({
          where: { courseId_studentId: { courseId: c2.id, studentId: st.id } } as any,
          update: {} as any,
          create: { courseId: c2.id, studentId: st.id, source: 'AUTO' } as any,
        } as any);
      }


      try {
        const math = await prisma.tutorCharacter?.upsert?.({
          where: { id: 'e2e-math' } as any,
          update: {
            name: 'Math Tutor',
            subject: 'MATH',
            language: 'EN',
            maxGrade: 12,
          } as any,
          create: {
            id: 'e2e-math',
            name: 'Math Tutor',
            subject: 'MATH',
            language: 'EN',
            maxGrade: 12,
          } as any,
        });
        mathTutorId = math?.id ?? 'e2e-math';
      } catch {}

      try {
        const phys = await prisma.tutorCharacter?.upsert?.({
          where: { id: 'e2e-physics' } as any,
          update: {
            name: 'Physics Tutor',
            subject: 'PHYSICS',
            language: 'EN',
            maxGrade: 12,
          } as any,
          create: {
            id: 'e2e-physics',
            name: 'Physics Tutor',
            subject: 'PHYSICS',
            language: 'EN',
            maxGrade: 12,
          } as any,
        });
        physicsTutorId = phys?.id ?? 'e2e-physics';
      } catch {}

      return res.status(201).json({
        ok: true,
        adminEmail,
        teacherEmail,
        teacher2Email,
        parentEmail,
        studentEmail,
        password,
        cohortId,
        cohort2Id,
        courseId,
        course2Id,
        mathTutorId,
        physicsTutorId,
        cohortDebug,
      });
    } catch (e: any) {
      return res.status(500).json({
        ok: false,
        error: String(e?.message ?? e),
        cohortDebug,
      });
    }
  }
}
