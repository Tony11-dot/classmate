import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
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

  @UseGuards(JwtAuthGuard)
  @Get('me')
  async me(@Req() req: any) {
    const u = req.user ?? null;
    if (!u) return null;

    const schoolId = u.schoolId ?? null;
    let schoolName: string | null = null;
    let schoolLogoUrl: string | null = null;

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

    return require('../contracts/auth.contract').AuthMeResponseSchema.parse({
      id: u.id ?? null,
      email: u.email ?? null,
      roles: u.roles ?? [],
      actingStudentId: u.actingStudentId ?? null,
      schoolId,
      cohortId: u.cohortId ?? null,
      schoolName,
      schoolLogoUrl,
    });
  }
}
