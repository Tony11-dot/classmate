import { Controller, Get, Req, Post, Body, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
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

  @UseGuards(AuthGuard('jwt'))
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
