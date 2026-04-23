import { Body, Controller, Get, Patch, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { NotificationsService } from './notifications.service';
import { ListNotificationsDto } from './dto/list-notifications.dto';

@Controller('notifications')
@UseGuards(JwtAuthGuard)
export class NotificationsController {
  constructor(private readonly notifications: NotificationsService) {}

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
