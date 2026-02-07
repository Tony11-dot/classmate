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
    const takeRaw = (q as any)?.take ?? (q as any)?.limit ?? 30;
    const takeNum = Number(takeRaw);
    const limit = Number.isFinite(takeNum) && takeNum > 0 ? Math.min(takeNum, 100) : 30;

    const unseenOnly = (q as any)?.unseenOnly === true;
    const cursor = (q as any)?.cursor ? String((q as any).cursor) : undefined;

    return this.svc.list(req.user.id, { limit, cursor, unseenOnly });
  }

  @Get('unread-count')
  async unreadCount(@Req() req: any) {
    return this.svc.unreadCount(req.user.id);
  }

  @Patch('mark-seen')
  async markSeen(@Req() req: any, @Body() dto: MarkNotificationsSeenDto) {
    return this.svc.markSeen(req.user.id, dto.ids ?? []);
  }
}
