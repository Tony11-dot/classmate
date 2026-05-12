import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
import { HttpException } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { PracticeService } from './practice.service';
import { isPracticeHttpException } from './errors/practice-error.util';

@UseGuards(JwtAuthGuard)
@Controller('practice')
export class PracticeController {
  constructor(private readonly practiceService: PracticeService) {}

  @Post('generate')
  async generate(@Body() body: any) {
    return this.practiceService.generate(body ?? {});
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
