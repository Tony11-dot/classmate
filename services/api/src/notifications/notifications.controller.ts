import { Body, Controller, Get, Patch, Query, Req, UseGuards } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { ALL_APP_ROLES } from '../auth/roles';
import { NotificationsService } from './notifications.service';
import { ListNotificationsDto } from './dto/list-notifications.dto';

@Controller('notifications')
@UseGuards(JwtAuthGuard)
@Roles(...ALL_APP_ROLES)
export class NotificationsController {
  constructor(private readonly notifications: NotificationsService) {}

  // Polled on every screen open and on SSE reconnect — exempt from the
  // default bucket so a parent flipping tabs can't trip it.
  @SkipThrottle()
  @Get()
  list(@Req() req: any, @Query() query: ListNotificationsDto) {
    return this.notifications.list(req.user, query);
  }

  @Patch('seen')
  seen(@Req() req: any, @Body() body: any) {
    return this.notifications.seen(req.user, body?.ids);
  }

  @Patch('seen-all')
  seenAll(@Req() req: any) {
    return this.notifications.seenAll(req.user);
  }
}
