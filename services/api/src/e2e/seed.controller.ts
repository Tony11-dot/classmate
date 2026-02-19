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
    try {
      // Best-effort School (some schemas may require it)
      try {
        await prisma.school?.upsert?.({
          where: { id: 'test-school' } as any,
          update: {} as any,
          create: { id: 'test-school', name: 'Test School' } as any,
        });
      } catch {}

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

    return res.status(201).json({ ok: true, teacherEmail, parentEmail, studentEmail, password, cohortId: (res as any).locals?.cohortId });
  }
}
