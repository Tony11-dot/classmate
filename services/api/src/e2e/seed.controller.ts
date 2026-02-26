import { Controller, Post, Res } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import type { Response } from 'express';
import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcrypt';

@Controller('test/seed')
@SkipThrottle()
export class E2ESeedController {
  constructor(private readonly prisma: PrismaService) {}

  @Post('admin-web')
  async adminWeb(@Res() res: Response) {
    try {
          const prisma: any = this.prisma;
      
          const adminEmail = 'admin1@classmate.app';
          const password = 'dev';
          const hash = await bcrypt.hash(password, 10);
      
          try {
            // create minimal cohort (or reuse)
            const cohort = await prisma.cohort.create({
              data: { name: `E2E Cohort ${Date.now()}`, grade: 10 } as any,
            } as any);
      
            // create admin user (or reuse)
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
      
            // ensure admin has a profile link if your schema expects it (best-effort)
            await prisma.adminProfile?.upsert?.({
              where: { userId: admin.id } as any,
              update: {} as any,
              create: { userId: admin.id, schoolId: 'test-school' } as any,
            } as any).catch(() => {});
      
            // also ensure school exists (best-effort)
            await prisma.school?.upsert?.({
              where: { id: 'test-school' } as any,
              update: {} as any,
              create: { id: 'test-school', name: 'Test School' } as any,
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
    } catch (e: any) {
      // idempotent seed: ignore duplicate/unique constraint errors
      if (e?.code === 'P2002' || String(e?.message || '').toLowerCase().includes('unique')) {
        return { ok: true, alreadySeeded: true };
      }
      throw e;
    }
  }
}
