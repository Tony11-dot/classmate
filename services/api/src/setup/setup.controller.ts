/**
 * One-time platform bootstrap endpoint.
 * Only the platform owner (Tony) can call this.
 * Protected by SETUP_SECRET env variable — never expose this to the public.
 *
 * Usage:
 *   POST /setup/school
 *   Headers: { "x-setup-secret": "<SETUP_SECRET value>" }
 *   Body: { "schoolName": "Demo School", "adminEmail": "admin@classmate.app" }
 */

import {
  BadRequestException,
  Body,
  Controller,
  ForbiddenException,
  Post,
  Headers,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { Public } from '../auth/decorators/public.decorator';
import { PrismaService } from '../prisma/prisma.service';

@Controller('setup')
export class SetupController {
  constructor(private readonly prisma: PrismaService) {}

  @Public()
  @Post('school')
  async bootstrapSchool(
    @Headers('x-setup-secret') secret: string,
    @Body() body: { schoolName: string; adminEmail: string },
  ) {
    const expected = process.env.SETUP_SECRET;
    if (!expected || expected.length < 8) {
      throw new ForbiddenException('Setup endpoint is disabled (SETUP_SECRET not configured)');
    }
    if (secret !== expected) {
      throw new ForbiddenException('Invalid setup secret');
    }

    const schoolName = String(body?.schoolName ?? '').trim();
    const adminEmail = String(body?.adminEmail ?? '').trim().toLowerCase();
    if (!schoolName) throw new BadRequestException('schoolName is required');
    if (!adminEmail) throw new BadRequestException('adminEmail is required');

    // Create school (or find existing)
    let school = await this.prisma.school.findFirst({ where: { name: schoolName } });
    if (!school) {
      school = await this.prisma.school.create({ data: { name: schoolName } });
    }

    // Find or create the admin user
    let adminUser = await this.prisma.user.findFirst({ where: { email: adminEmail } });
    const tempPassword = `Classmate${Math.floor(100000 + Math.random() * 900000)}!`;

    if (!adminUser) {
      const hash = await bcrypt.hash(tempPassword, 10);
      adminUser = await this.prisma.user.create({
        data: {
          email: adminEmail,
          name: adminEmail.split('@')[0],
          password: hash,
          schoolId: school.id,
          status: 'ACTIVE',
          roles: { create: [{ role: 'ADMIN' }] },
        } as any,
      });
    } else {
      // Link existing user to this school
      await this.prisma.user.update({
        where: { id: adminUser.id },
        data: { schoolId: school.id } as any,
      });
      // Ensure ADMIN role exists
      await this.prisma.userRole.upsert({
        where: { userId_role: { userId: adminUser.id, role: 'ADMIN' as any } },
        update: {},
        create: { userId: adminUser.id, role: 'ADMIN' as any },
      });
    }

    return {
      ok: true,
      school: { id: school.id, name: school.name },
      admin: { id: adminUser.id, email: adminUser.email },
      tempPassword: adminUser ? '(existing user — password unchanged)' : tempPassword,
      note: 'School linked to admin. You can now log in and manage the school.',
    };
  }
}
