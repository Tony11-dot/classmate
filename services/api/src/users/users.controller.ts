import { Controller, Get, Param, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { ALL_APP_ROLES } from '../auth/roles';
import { UsersService } from './users.service';

@UseGuards(JwtAuthGuard)
@Roles(...ALL_APP_ROLES)
@Controller('users')
export class UsersController {
  constructor(private readonly users: UsersService) {}

  /// Lightweight public-ish profile used when tapping a name in a chat
  /// thread, member list, or @mention. Returns role + grade (students)
  /// + children (parents). Same-school enforced inside the service so a
  /// crafted id from another school 403s instead of leaking data.
  @Get(':id/profile')
  async profile(@Req() req: any, @Param('id') id: string) {
    const viewerId = String(req?.user?.sub ?? req?.user?.id ?? '');
    const profile = await this.users.getProfile(viewerId, id);
    return { ok: true, profile };
  }
}
