import { z } from 'zod';
import {
  NotificationsListResDto,
  NotificationsMarkSeenReqDto,
  NotificationsMarkSeenResDto,
  NotificationsSeenAllResDto,
  NotificationsCreateReqDto,
  NotificationsCreateResDto,
} from '../contracts/notifications.contract';
import { HttpClient } from './http-client';

export class NotificationsSdk {
  constructor(private readonly http: HttpClient) {}

  async list(input?: { limit?: number; cursor?: string; state?: 'seen' | 'unseen' }): Promise<any[]> {
    const q = new URLSearchParams();
    if (input?.limit != null) q.set('limit', String(input.limit));
    if (input?.cursor) q.set('cursor', input.cursor);
    if (input?.state) q.set('state', input.state);
    const path = `/api/notifications${q.toString() ? `?${q.toString()}` : ''}`;
    const res = await this.http.get(path, NotificationsListResDto);
    return res.items ?? [];
  }

  seen(input: z.infer<typeof NotificationsMarkSeenReqDto>) {
    return this.http.patch('/api/notifications/seen', input, NotificationsMarkSeenResDto);
  }

  seenAll() {
    return this.http.patch('/api/notifications/seen-all', {}, NotificationsSeenAllResDto);
  }

  create(input: z.infer<typeof NotificationsCreateReqDto>) {
    return this.http.post('/api/notifications', input, NotificationsCreateResDto);
  }
}
