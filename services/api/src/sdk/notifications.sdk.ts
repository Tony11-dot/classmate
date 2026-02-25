import { z } from 'zod';
import {
  NotificationsListDto,
  NotificationsSeenReqDto,
  NotificationsSeenResDto,
} from '../contracts/notifications.contract';
import { HttpClient } from './http-client';

export class NotificationsSdk {
  constructor(private readonly http: HttpClient) {}

  list() {
    return this.http.get('/api/notifications', NotificationsListDto);
  }

  seen(input: z.infer<typeof NotificationsSeenReqDto>) {
    return this.http.patch('/api/notifications/seen', input, NotificationsSeenResDto);
  }

  seenAll() {
    return this.http.patch('/api/notifications/seen-all', {}, NotificationsSeenResDto);
  }

  create(input: any) {
    return this.http.post('/api/notifications', input, z.any());
  }
}
