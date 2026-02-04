import { Controller, Get, Patch, Query, Body, UseGuards, Req } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ParentNotificationsService } from './parent-notifications.service';
import { NotificationsQueryDto } from './dto/notifications-query.dto';
import { MarkNotificationsSeenDto } from './dto/mark-notifications-seen.dto';

@UseGuards(AuthGuard('jwt'))
@Controller('parent/notifications')
export class ParentNotificationsController {
  constructor(private readonly svc: ParentNotificationsService) {}

  @Get()
  async list(@Req() req: any, @Query() q: NotificationsQueryDto) {
    const limit = q.limit ? Number(q.limit) : 30;
    const unseenOnly = q.unseenOnly === 'true';
    return this.svc.list(req.user.sub, { limit, cursor: q.cursor, unseenOnly });
  }

  @Get('unread-count')
  async unreadCount(@Req() req: any) {
    return this.svc.unreadCount(req.user.sub);
  }

  @Patch('mark-seen')
  async markSeen(@Req() req: any, @Body() dto: MarkNotificationsSeenDto) {
    return this.svc.markSeen(req.user.sub, dto.ids ?? []);
  }
}
