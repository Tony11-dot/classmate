import { Controller, Get, Req, Post, Body } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';

@SkipThrottle()
@Controller('auth')
export class AuthController {
  @Post('login')
  async login(@Body() body: any) {
    const { email } = body;
    // dev-only token shortcut for E2E
    return { token: 'dev-token-' + email };
  }

  @Get('me')
  me(@Req() req: any) {
    const u = req.user ?? null;
    return {
      user: u
        ? {
            id: u.id ?? null,
            email: u.email ?? null,
            role: u.role ?? null,
            cohortId: u.cohortId ?? null,
            schoolId: u.schoolId ?? null,
          }
        : null,
    };
  }
}
