import { ParentNotificationsEvents } from './parent-notifications.events';
import { Observable, filter, map, merge, interval, of, startWith, switchMap } from 'rxjs';
import { Controller, Get, Patch, Query, Body, UseGuards, Req, Sse, MessageEvent, UnauthorizedException } from '@nestjs/common';

class SseJwtGuard extends AuthGuard('jwt') {
  // allow EventSource to pass token via ?token= since it can't set Authorization header
  getRequest(context: any) {
    const req = context.switchToHttp().getRequest();
    const q: any = (req.query || {});
    if (!req.headers?.authorization && q.token) {
      req.headers = req.headers || {};
      req.headers.authorization = `Bearer ${q.token}`;
    }
    return req;
  }
}

import {
 AuthGuard } from '@nestjs/passport';
import {
 ParentNotificationsService } from './parent-notifications.service';
import {
 NotificationsQueryDto } from './dto/notifications-query.dto';
import {
 MarkNotificationsSeenDto } from './dto/mark-notifications-seen.dto';

@UseGuards(AuthGuard('jwt'))
@Controller('parent/notifications')
export class ParentNotificationsController {
  constructor(private readonly svc: ParentNotificationsService,
    private readonly events: ParentNotificationsEvents) {}

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

  @UseGuards(SseJwtGuard)
  @Sse('notifications/stream')
  stream(@Req() req: any): Observable<MessageEvent> {    const parentId = req.user?.id;
    if (!parentId) throw new UnauthorizedException();
    const heartbeat$ = interval(15000).pipe(map(() => ({ data: { type: 'ping' } })));

    const events$ = this.events.events$.pipe(
      filter((e) => e.parentId === parentId),
      map((e) => ({ data: e })),
    );

    return merge(of({ data: { type: 'hello' } }), events$, heartbeat$);
  }

}
