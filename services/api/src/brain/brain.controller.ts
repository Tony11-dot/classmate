import { Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role, ALL_APP_ROLES } from '../auth/roles';
import { BrainService } from './brain.service';

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('brain')
export class BrainController {
  constructor(private readonly brain: BrainService) {}

  @Get('me')
  @Roles(...ALL_APP_ROLES)
  async me(@Req() req: any) {
    const userId = String(req?.user?.sub ?? req?.user?.id ?? req?.user?.userId ?? '');
    return this.brain.getBrainMe(userId);
  }

  // AI summary rebuild (metered) — students only.
  @Post('rebuild')
  @Roles(Role.STUDENT)
  async rebuild(@Req() req: any) {
    const userId = String(req?.user?.sub ?? req?.user?.id ?? req?.user?.userId ?? '');
    return this.brain.rebuildSummary(userId);
  }
}
