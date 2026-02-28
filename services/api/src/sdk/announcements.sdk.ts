import { z } from 'zod';
import {
  AnnouncementFeedResDto,
  AnnouncementUnreadCountResDto,
  AnnouncementMarkSeenReqDto,
  AnnouncementMarkSeenResDto,
} from '../contracts/announcements.contract';
import { HttpClient } from './http-client';

export class AnnouncementsSdk {
  constructor(private readonly http: HttpClient) {}

  async feed(): Promise<any[]> {
    const res = await this.http.get('/api/announcements/feed', AnnouncementFeedResDto);
    return res.announcements ?? [];
  }

  unreadCount() {
    return this.http.get('/api/announcements/unread-count', AnnouncementUnreadCountResDto);
  }

  markSeen(input: z.infer<typeof AnnouncementMarkSeenReqDto>) {
    return this.http.post('/api/announcements/mark-seen', input, AnnouncementMarkSeenResDto);
  }

  targets() {
    return this.http.get('/api/announcements/targets', z.any());
  }
}
