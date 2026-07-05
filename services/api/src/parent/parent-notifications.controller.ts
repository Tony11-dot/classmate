import { ParentNotificationsEvents } from './parent-notifications.events';
import { Observable, filter, map, merge, interval, of, startWith, switchMap } from 'rxjs';
import { Controller, Get, Patch, Query, Body, UseGuards, Req, Sse, MessageEvent, UnauthorizedException } from '@nestjs/common';


import { SseJwtGuard } from './sse-jwt.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import {
 ParentNotificationsService } from './parent-notifications.service';
import {
 NotificationsQueryDto } from './dto/notifications-query.dto';
import {
 MarkNotificationsSeenDto } from './dto/mark-notifications-seen.dto';

@UseGuards(SseJwtGuard)
@Roles(Role.PARENT, Role.ADMIN)
@Controller('parent/notifications')
export class ParentNotificationsController {
  constructor(private readonly svc: ParentNotificationsService,
    private readonly events: ParentNotificationsEvents) {}  @Get()
  async list(@Req() req: any, @Query() q: NotificationsQueryDto) {
    const raw: any = (req as any)?.query ?? {};

    const limitRaw =
      (q as any)?.take ??
      (q as any)?.limit ??
      raw.take ??
      raw.limit ??
      30;

    const limitNum = Number(limitRaw);
    const limit =
      Number.isFinite(limitNum) && limitNum > 0
        ? Math.min(limitNum, 100)
        : 30;

    const unseenOnly = (q as any)?.unseenOnly === true;

    const cursor =
      (q as any)?.cursor != null
        ? String((q as any).cursor)
        : raw.cursor != null
        ? String(raw.cursor)
        : undefined;

    const studentId =
      (q as any)?.studentId ??
      raw.studentId ??
      undefined;

    return this.svc.list(req.user.id, {
      limit,
      cursor,
      unseenOnly,
      studentId,
    });
  }


  @Get('unread-count')
  async unreadCount(@Req() req: any) {
    return this.svc.unreadCount(req.user.id);
  }

  @Patch('mark-seen')
  async markSeen(@Req() req: any, @Body() dto: MarkNotificationsSeenDto) {
    return this.svc.markSeen(req.user.id, dto.ids ?? []);
  }

  @UseGuards(SseJwtGuard)

  @UseGuards(SseJwtGuard)
  @Sse('stream')
  stream(@Req() req: any): Observable<MessageEvent> {    const parentId = (req as any).user?.id;
    if (!parentId) throw new UnauthorizedException();
    const heartbeat$ = interval(15000).pipe(map(() => ({ data: { type: 'ping' } })));

    const events$ = this.events.events$.pipe(
      filter((e) => e.parentId === parentId),
      map((e) => ({ data: e })),
    );

    return merge(of({ data: { type: 'hello' } }), events$, heartbeat$);
  }

}
