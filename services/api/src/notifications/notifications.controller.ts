import { Body, Controller, Get, Patch, Post, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { NotificationsService } from './notifications.service';
import { ListNotificationsDto } from './dto/list-notifications.dto';
import { CreateNotificationDto } from './dto/create-notification.dto';

@UseGuards(JwtAuthGuard)
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly svc: NotificationsService) {}

  private userId(req: any) {
    return req?.user?.id ?? req?.user?.sub;
  }

  @Get()
  async list(@Req() req: any, @Query() q: ListNotificationsDto) {
    return this.svc.list(this.userId(req), q);
  }

  @Patch('seen')
  async markSeen(@Req() req: any, @Body() body: { ids: string[] }) {
    const ids = Array.isArray(body?.ids) ? body.ids : [];
    return this.svc.markSeen(this.userId(req), ids);
  }

  @Patch('seen-all')
  async markAllSeen(@Req() req: any) {
    return this.svc.markAllSeen(this.userId(req));
  }

  @Post()
  async create(@Req() req: any, @Body() dto: CreateNotificationDto) {
    return this.svc.createForUser(this.userId(req), dto);
  }
}
