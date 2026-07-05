import { Body, Controller, Get, Post, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { ALL_APP_ROLES } from '../auth/roles';
import { PracticeAdaptiveService } from './practice_adaptive.service';

@UseGuards(JwtAuthGuard)
@Roles(...ALL_APP_ROLES)
@Controller('practice-adaptive')
export class PracticeAdaptiveController {
  constructor(private readonly service: PracticeAdaptiveService) {}

  @Post('attempt')
  async record(@Req() req: any, @Body() body: any) {
    const userId =
      String(req?.user?.id ?? req?.user?.sub ?? req?.user?.email ?? 'dev-user');

    return this.service.recordAttempt({
      userId,
      subject: String(body?.subject ?? ''),
      topicLabel: String(body?.topicLabel ?? ''),
      mode: String(body?.mode ?? 'practice'),
      difficulty: String(body?.difficulty ?? 'medium'),
      questionId: String(body?.questionId ?? ''),
      prompt: String(body?.prompt ?? ''),
      selectedIndex:
        body?.selectedIndex == null ? null : Number(body.selectedIndex),
      correctIndex: Number(body?.correctIndex ?? 0),
      isCorrect: Boolean(body?.isCorrect),
      timeTakenMs:
        body?.timeTakenMs == null ? null : Number(body.timeTakenMs),
      usedNova: Boolean(body?.usedNova ?? false),
      source: String(body?.source ?? 'ai'),
    });
  }

  @Get('profile')
  async profile(@Req() req: any, @Query('subject') subject: string, @Query('topicLabel') topicLabel: string) {
    const userId =
      String(req?.user?.id ?? req?.user?.sub ?? req?.user?.email ?? 'dev-user');

    return this.service.getProfile(userId, String(subject ?? ''), String(topicLabel ?? ''));
  }
}
