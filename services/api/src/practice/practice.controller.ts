import { Body, Controller, Get, Post, Req } from '@nestjs/common';
import { HttpException } from '@nestjs/common';
import { PracticeService } from './practice.service';
import { isPracticeHttpException } from './errors/practice-error.util';

@Controller('practice')
export class PracticeController {
  constructor(private readonly practiceService: PracticeService) {}

  @Post('generate')
  async generate(@Body() body: any) {
    return this.practiceService.generate(body ?? {});
  }

  @Get('progress-summary')
  getProgressSummary(@Req() req: any) {
    const userId = String(
      req?.user?.sub ??
        req?.user?.id ??
        req?.user?.userId ??
        'anonymous',
    );

    return this.practiceService.getProgressSummary(userId);
  }
}
