import { z } from 'zod';
import {
  AnnouncementFeedDto,
  AnnouncementUnreadCountDto,
  AnnouncementMarkSeenReqDto,
  AnnouncementMarkSeenResDto,
} from '../contracts/announcements.contract';
import { HttpClient } from './http-client';

export class AnnouncementsSdk {
  constructor(private readonly http: HttpClient) {}

  feed() {
    return this.http.get('/api/announcements/feed', AnnouncementFeedDto);
  }

  unreadCount() {
    return this.http.get('/api/announcements/unread-count', AnnouncementUnreadCountDto);
  }

  markSeen(input: z.infer<typeof AnnouncementMarkSeenReqDto>) {
    return this.http.post('/api/announcements/mark-seen', input, AnnouncementMarkSeenResDto);
  }

  targets() {
    return this.http.get('/api/announcements/targets', z.any());
  }
}
