import { Body, Controller, Get, Patch, Post, Query, Req } from '@nestjs/common';
import { NotificationsService } from './notifications.service';
import { ListNotificationsDto } from './dto/list-notifications.dto';
import { CreateNotificationDto } from './dto/create-notification.dto';

@Controller('notifications')
export class NotificationsController {
  constructor(private svc: NotificationsService) {}

  // NOTE: auth guard already used elsewhere; rely on existing global auth pattern in app.
  private userId(req: any) {
    return req?.user?.id ?? req?.user?.sub; // tolerate either
  }

  @Get()
  async list(@Req() req: any, @Query() q: ListNotificationsDto) {
    const userId = this.userId(req);
    return this.svc.list(userId, q);
  }

  @Patch('seen')
  async markSeen(@Req() req: any, @Body() body: { ids: string[] }) {
    // NOTIFICATIONS_WRITE_RETURNS_OK
  const userId = this.userId(req);
  const ids = Array.isArray(body?.ids) ? body.ids : [];
  return this.svc.markSeen(userId, ids);
    await this.svc.markSeen(userId, ids);
    return { ok: true } as any;
  }
@Patch('seen-all')
  async markAllSeen(@Req() req: any) {
    // NOTIFICATIONS_WRITE_RETURNS_OK
  const userId = this.userId(req);
  return this.svc.markAllSeen(userId);
    await this.svc.markAllSeen(userId);
    return { ok: true } as any;
  }
// Internal endpoint for now (admin/system); keep for wiring later
  @Post()
  async create(@Req() req: any, @Body() dto: CreateNotificationDto) {
    const userId = this.userId(req);
    return this.svc.createForUser(userId, dto);
  }
}
