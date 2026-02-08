import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { E2ESeedGuard } from './e2e-seed.guard';
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

@UseGuards(E2ESeedGuard)
@Controller('/test/seed')
export class E2ESeedController {
  private prisma = new PrismaClient();

  @Post('/admin-web')
  async seedAdminWeb() {
    const passwordHash = await bcrypt.hash('dev', 10);

    const teacher = await this.prisma.user.upsert({
      where: { email: 'teacher1@classmate.app' },
      update: { password: passwordHash, name: 'Teacher One' },
      create: {
        email: 'teacher1@classmate.app',
        password: passwordHash,
        name: 'Teacher One',
        roles: { create: [{ role: 'TEACHER' }, { role: 'ADMIN' }] },
      },
      select: { id: true },
    });

    const student = await this.prisma.user.upsert({
      where: { email: 'student1@classmate.app' },
      update: { password: passwordHash, name: 'Student One' },
      create: {
        email: 'student1@classmate.app',
        password: passwordHash,
        name: 'Student One',
        roles: { create: [{ role: 'STUDENT' }] },
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

    return { teacher, student, parent };
  }
}
