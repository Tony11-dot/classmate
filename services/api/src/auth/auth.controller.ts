import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
import { Public } from './decorators/public.decorator';
import { SkipThrottle } from '@nestjs/throttler';
import { JwtAuthGuard } from './jwt-auth.guard';

@SkipThrottle()
@Controller('auth')
export class AuthController {
  @Public()

  @Post('login')
  async login(@Body() body: any) {
    const { email } = body;
    // dev-only token shortcut for E2E
    return { token: 'dev-token-' + email };
  }

  @UseGuards(JwtAuthGuard)
  @Get('me')
  me(@Req() req: any) {
    const u = req.user ?? null;
    if (!u) return null;

    // Return the user object (normalized/whitelisted) with roles + actingStudentId.
    return require('../contracts/auth.contract').AuthMeResponseSchema.parse({
      id: u.id ?? null,
      email: u.email ?? null,
      roles: u.roles ?? [],
      actingStudentId: u.actingStudentId ?? null,
      schoolId: u.schoolId ?? null,
      cohortId: u.cohortId ?? null,
    });
  }
}
