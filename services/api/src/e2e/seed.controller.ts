import { Controller, NotFoundException, Post, Res } from '@nestjs/common';
import type { Response } from 'express';
import { PrismaClient } from '@prisma/client';

@Controller('test/seed')

export class E2ESeedController {
  private prisma = new PrismaClient();

  @Post('admin-web')
  async adminWeb(@Res() res: Response) {
    const teacherEmail = 'teacher1@classmate.app';
    const parentEmail = 'parent1@classmate.app';
    const studentEmail = 'student1@classmate.app';
    const password = 'dev';

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
        update: { role: 'TEACHER' as any, password, passwordHash: password } as any,
        create: { email: teacherEmail, fullName: 'Teacher 1', role: 'TEACHER' as any, password, passwordHash: password } as any,
      });

      await prisma.user.upsert({
        where: { email: parentEmail } as any,
        update: { role: 'PARENT' as any, password, passwordHash: password } as any,
        create: { email: parentEmail, fullName: 'Parent 1', role: 'PARENT' as any, password, passwordHash: password } as any,
      });

      await prisma.user.upsert({
        where: { email: studentEmail } as any,
        update: { role: 'STUDENT' as any, password, passwordHash: password } as any,
        create: { email: studentEmail, fullName: 'Student 1', role: 'STUDENT' as any, password, passwordHash: password } as any,
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

    return res.status(201).json({ ok: true, teacherEmail, parentEmail, studentEmail, password });
  }
}
