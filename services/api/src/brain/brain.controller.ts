import { Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { BrainService } from './brain.service';

@UseGuards(JwtAuthGuard)
@Controller('brain')
export class BrainController {
  constructor(private readonly brain: BrainService) {}

  @Get('me')
  async me(@Req() req: any) {
    const userId = String(req?.user?.sub ?? req?.user?.id ?? req?.user?.userId ?? '');
    return this.brain.getBrainMe(userId);
  }

  // dev helper endpoint (keep simple; you can wrap with env guard later)
  @Post('rebuild')
  async rebuild(@Req() req: any) {
    const userId = String(req?.user?.sub ?? req?.user?.id ?? req?.user?.userId ?? '');
    return this.brain.rebuildSummary(userId);
  }
}
