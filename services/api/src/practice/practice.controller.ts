import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
import { HttpException } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { PracticeService } from './practice.service';
import { isPracticeHttpException } from './errors/practice-error.util';

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.STUDENT)
@SkipThrottle()
@Controller('practice')
export class PracticeController {
  constructor(private readonly practiceService: PracticeService) {}

  // AI generation (metered) — re-enable the default throttle that the
  // class-level @SkipThrottle() turns off for the lightweight read routes.
  @Post('generate')
  @SkipThrottle({ default: false })
  async generate(@Req() req: any, @Body() body: any) {
    const userId = String(
      req?.user?.sub ?? req?.user?.id ?? req?.user?.userId ?? '',
    ).trim();
    return this.practiceService.generate({ ...(body ?? {}), userId });
  }

  @Get('progress-summary')
  async getProgressSummary(@Req() req: any) {
    const userId = String(
      req?.user?.sub ??
        req?.user?.id ??
        req?.user?.userId ??
        'anonymous',
    );

    return this.practiceService.getProgressSummary(userId);
  }

  @Get('insights-summary')
  async getAiInsightsSummary(@Req() req: any) {
    const userId = String(
      req?.user?.sub ??
        req?.user?.id ??
        req?.user?.userId ??
        'anonymous',
    );

    return this.practiceService.getAiInsightsSummary(userId);
  }
}
