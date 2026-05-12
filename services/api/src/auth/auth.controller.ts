import { BadRequestException, Body, ConflictException, Controller, Get, Patch, Post, Req, UseGuards } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { Public } from './decorators/public.decorator';
import { SkipThrottle } from '@nestjs/throttler';
import { JwtAuthGuard } from './jwt-auth.guard';
import { PrismaService } from '../prisma/prisma.service';

@SkipThrottle()
@Controller('auth')
export class AuthController {
  constructor(private readonly prisma: PrismaService) {}

  @Public()
  @Post('login')
  async login(@Body() body: any) {
    const { email } = body;
    return { token: 'dev-token-' + email };
  }

  @Public()
  @Post('register')
  async register(@Body() body: any) {
    const email = String(body?.email ?? '').trim().toLowerCase();
    const name = String(body?.name ?? '').trim();
    const password = String(body?.password ?? '').trim();
    const schoolId: string | null = body?.schoolId ? String(body.schoolId).trim() : null;

    if (!email || !email.includes('@')) throw new BadRequestException('Valid email required');
    if (!name) throw new BadRequestException('Name required');
    if (!password || password.length < 3) throw new BadRequestException('Password must be at least 3 characters');

    const existing = await this.prisma.user.findUnique({ where: { email } });
    if (existing) throw new ConflictException('Email already registered');

    const hash = await bcrypt.hash(password, 10);
    await this.prisma.user.create({
      data: {
        email,
        name,
        password: hash,
        status: 'ACTIVE',
        ...(schoolId ? { schoolId } : {}),
        roles: { create: [{ role: 'STUDENT' }] },
      } as any,
    });

    // Auth system uses dev-token pattern — token = 'dev-token-{email}'
    // The DevOverrideGuard handles user provisioning on first request
    return { token: `dev-token-${email}` };
  }

  @UseGuards(JwtAuthGuard)
  @Patch('profile/name')
  async updateProfileName(@Req() req: any, @Body() body: any) {
    const userId = req.user?.sub ?? req.user?.id;
    if (!userId) return { ok: false };
    const data: any = {};
    if (body?.nameEn !== undefined) data.nameEn = body.nameEn ? String(body.nameEn).trim() : null;
    if (body?.nameAr !== undefined) data.nameAr = body.nameAr ? String(body.nameAr).trim() : null;
    if (body?.nameHe !== undefined) data.nameHe = body.nameHe ? String(body.nameHe).trim() : null;
    if (body?.nameFr !== undefined) data.nameFr = body.nameFr ? String(body.nameFr).trim() : null;
    if (body?.nameRu !== undefined) data.nameRu = body.nameRu ? String(body.nameRu).trim() : null;
    if (body?.displayNameLang !== undefined) data.displayNameLang = body.displayNameLang ? String(body.displayNameLang).trim() : null;
    if (body?.displayName !== undefined) data.displayName = body.displayName ? String(body.displayName).trim() : null;
    if (Object.keys(data).length === 0) return { ok: true };
    await this.prisma.user.update({ where: { id: userId }, data });
    return { ok: true };
  }

  @UseGuards(JwtAuthGuard)
  @Get('me')
  async me(@Req() req: any) {
    const u = req.user ?? null;
    if (!u) return null;

    const userId = u.sub ?? u.id ?? null;
    const schoolId = u.schoolId ?? null;
    let schoolName: string | null = null;
    let schoolLogoUrl: string | null = null;
    let cohortName: string | null = null;
    let fullName: string | null = null;
    let nameEn: string | null = null;
    let nameAr: string | null = null;
    let nameHe: string | null = null;
    let nameFr: string | null = null;
    let nameRu: string | null = null;
    let displayNameLang: string | null = null;
    let displayName: string | null = null;

    // Fetch up-to-date user fields from DB (the JWT only carries the claim snapshot)
    if (userId) {
      try {
        const dbUser = await this.prisma.user.findUnique({
          where: { id: userId },
          select: {
            name: true,
            displayName: true,
            legalName: true,
            nameEn: true,
            nameAr: true,
            nameHe: true,
            nameFr: true,
            nameRu: true,
            displayNameLang: true,
          },
        });
        if (dbUser) {
          fullName = dbUser.legalName ?? dbUser.displayName ?? dbUser.name ?? null;
          displayName = dbUser.displayName ?? null;
          nameEn = dbUser.nameEn ?? null;
          nameAr = dbUser.nameAr ?? null;
          nameHe = dbUser.nameHe ?? null;
          nameFr = dbUser.nameFr ?? null;
          nameRu = dbUser.nameRu ?? null;
          displayNameLang = dbUser.displayNameLang ?? null;
        }
      } catch {}
    }

    if (schoolId) {
      try {
        const school = await this.prisma.school.findUnique({
          where: { id: schoolId },
          select: { name: true, logoUrl: true },
        });
        schoolName = school?.name ?? null;
        schoolLogoUrl = school?.logoUrl ?? null;
      } catch {}
    }

    // Cohort name lookup
    const cohortId = u.cohortId ?? null;
    if (cohortId) {
      try {
        const cohort = await this.prisma.cohort.findUnique({
          where: { id: cohortId },
          select: { name: true },
        });
        cohortName = cohort?.name ?? null;
      } catch {}
    }

    return require('../contracts/auth.contract').AuthMeResponseSchema.parse({
      id: u.id ?? null,
      email: u.email ?? null,
      roles: u.roles ?? [],
      actingStudentId: u.actingStudentId ?? null,
      schoolId,
      cohortId,
      cohortName,
      schoolName,
      schoolLogoUrl,
      fullName,
      displayName,
      nameEn,
      nameAr,
      nameHe,
      nameFr,
      nameRu,
      displayNameLang,
    });
  }

  @UseGuards(JwtAuthGuard)
  @Post('me/password')
  async changePassword(@Req() req: any, @Body() body: any) {
    const userId = req.user?.sub ?? req.user?.id;
    if (!userId) throw new BadRequestException('Not authenticated');

    const currentPassword = String(body?.currentPassword ?? '').trim();
    const newPassword = String(body?.newPassword ?? '').trim();

    if (!currentPassword || !newPassword) throw new BadRequestException('Both currentPassword and newPassword are required');
    if (newPassword.length < 8) throw new BadRequestException('New password must be at least 8 characters');

    const user = await this.prisma.user.findUnique({ where: { id: userId }, select: { password: true } });
    if (!user) throw new BadRequestException('User not found');

    const isValid = await bcrypt.compare(currentPassword, user.password);
    if (!isValid) throw new BadRequestException('WRONG_PASSWORD');

    const hash = await bcrypt.hash(newPassword, 10);
    await this.prisma.user.update({ where: { id: userId }, data: { password: hash } });
    return { ok: true };
  }
}
