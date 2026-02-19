import { Controller, NotFoundException, Post, Res } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import type { Response } from 'express';
import * as bcrypt from 'bcrypt';
@Controller('test/seed')

export class E2ESeedController {  constructor(private readonly prisma: PrismaService) {}
@Post('admin-web')
  async adminWeb(@Res() res: Response) {
    const teacherEmail = 'teacher1@classmate.app';
    const parentEmail = 'parent1@classmate.app';
    const studentEmail = 'student1@classmate.app';
    const password = 'dev';

    const hash = await bcrypt.hash(password, 10);
const prisma: any = this.prisma;
    let cohortId: any = undefined;
      const cohortDebug: any[] = [];
  try {

      // Best-effort School (some schemas may require it)
      try {
        await prisma.school?.upsert?.({
          where: { id: 'test-school' } as any,
          update: {} as any,
          create: { id: 'test-school', name: 'Test School' } as any,
        });
      } catch {}

      // Best-effort Cohort/Classroom for parent-link tests
      // parent-link tests REQUIRE a Cohort id.
      // Cohort model requires: name (String) + grade (Int). name is UNIQUE.
      try {
        const models = Object.keys((prisma as any) ?? {});
        cohortDebug.push({ models: models.filter((k) => !k.startsWith('$')).slice(0, 120) });
      } catch (e) {
        cohortDebug.push({ modelsErr: String((e as any)?.message ?? e) });
      }

      const COHORT_NAME = `Test Cohort`; // stable unique key for upsert

      try {
        const created = await prisma.cohort.upsert({
          where: { name: COHORT_NAME } as any,
          update: { grade: 10 } as any,
          create: { name: COHORT_NAME, grade: 10 } as any,
        } as any);
        cohortId = (created as any)?.id;
        cohortDebug.push({ ok: true, modelName: 'cohort.upsert', cohortId });
      } catch (e1: any) {
        cohortDebug.push({ ok: false, modelName: 'cohort.upsert', err: String(e1?.message ?? e1) });
        // fallback: unique name per run (in case name isn't the unique in some env)
        const fallbackName = `Test Cohort ${Date.now()}`;
        try {
          const created2 = await prisma.cohort.create({
            data: { name: fallbackName, grade: 10 } as any,
          } as any);
          cohortId = (created2 as any)?.id;
          cohortDebug.push({ ok: true, modelName: 'cohort.create.fallback', cohortId, name: fallbackName });
        } catch (e2: any) {
          cohortDebug.push({ ok: false, modelName: 'cohort.create.fallback', err: String(e2?.message ?? e2) });
        }
      }

      if (!cohortId) {
        return res.status(500).json({ ok: false, error: 'FAILED_TO_CREATE_COHORT', cohortDebug });
      }


      // Users with plaintext password for e2e (auth service currently tolerates plaintext compare)
      
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
      });

      
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
      });

      
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
      });

      // Best-effort teacher/student rows (if your schema expects them)
      try {
        const teacherUser = await prisma.user.findUnique({ where: { email: teacherEmail } as any });
        if (teacherUser?.id) {
          await prisma.teacher?.upsert?.({
            where: { userId: teacherUser.id } as any,
            update: {} as any,
            create: { userId: teacherUser.id } as any,
          });
        }
      } catch {}

      try {
        const studentUser = await prisma.user.findUnique({ where: { email: studentEmail } as any });
        if (studentUser?.id) {
          await prisma.student?.upsert?.({
            where: { userId: studentUser.id } as any,
            update: {} as any,
            create: { userId: studentUser.id } as any,
          });
        }
      } catch {}
    } catch (e: any) {
      return res.status(500).json({ ok: false, error: String(e?.message ?? e) });
    }

    return res.status(201).json({ ok: true, teacherEmail, parentEmail, studentEmail, password, cohortId, cohortDebug });
  }
}
