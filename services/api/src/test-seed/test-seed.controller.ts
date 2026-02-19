import { Controller, Post, Res } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import type { Response } from 'express';

@Controller('api/test/seed')
export class TestSeedController {
  private prisma = new PrismaClient();

  @Post('admin-web')
  async adminWeb(@Res() res: Response) {
    // Minimal seeding for CI e2e tests:
    // - create a school
    // - create teacher1/parent1/student1 users with passwordHash='dev' (tests use /api/auth/login)
    // Use raw SQL so this compiles even if Prisma client doesn't expose some models in this service.
    const schoolId = 'test-school';
    const teacherEmail = 'teacher1@classmate.app';
    const parentEmail = 'parent1@classmate.app';
    const studentEmail = 'student1@classmate.app';
    const password = 'dev';

    try {
      await this.prisma.$executeRawUnsafe(
        `INSERT INTO "School" ("id","name","createdAt","updatedAt")
         VALUES ($1,$2,now(),now())
         ON CONFLICT ("id") DO NOTHING`,
        schoolId,
        'Test School'
      );
    } catch {}

    async function upsertUser(prisma: PrismaClient, email: string, fullName: string, role: string) {
      // assumes User has: id, email, fullName, role, schoolId, passwordHash, createdAt, updatedAt
      // if your schema differs, adjust here.
      await prisma.$executeRawUnsafe(
        `INSERT INTO "User" ("id","email","fullName","role","schoolId","passwordHash","createdAt","updatedAt")
         VALUES (gen_random_uuid()::text,$1,$2,$3,$4,$5,now(),now())
         ON CONFLICT ("email") DO UPDATE
           SET "fullName"=EXCLUDED."fullName",
               "role"=EXCLUDED."role",
               "schoolId"=EXCLUDED."schoolId",
               "passwordHash"=EXCLUDED."passwordHash",
               "updatedAt"=now()`,
        email,
        fullName,
        role,
        schoolId,
        password
      );
    }

    try {
      await upsertUser(this.prisma, teacherEmail, 'Teacher 1', 'TEACHER');
      await upsertUser(this.prisma, parentEmail, 'Parent 1', 'PARENT');
      await upsertUser(this.prisma, studentEmail, 'Student 1', 'Student 1' ? 'STUDENT' : 'STUDENT');
    } catch (e: any) {
      return res.status(500).json({ ok: false, error: String(e?.message ?? e) });
    }

    return res.status(201).json({
      ok: true,
      teacherEmail,
      parentEmail,
      studentEmail,
      password,
    });
  }
}
