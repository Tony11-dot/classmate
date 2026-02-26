import { Controller, Get, Req } from '@nestjs/common';

@Controller('auth')
export class AuthController {
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
