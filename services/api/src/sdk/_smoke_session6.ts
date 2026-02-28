import { HttpClient } from './http-client';
import { AuthSdk } from './auth.sdk';
import { AnnouncementsSdk } from './announcements.sdk';
import { NotificationsSdk } from './notifications.sdk';

const BASE = process.env.SDK_BASE ?? process.env.API ?? 'http://127.0.0.1:3001';

let token = '';
const http = new HttpClient({ baseUrl: BASE, getToken: () => token });

const auth = new AuthSdk(http);
const announcements = new AnnouncementsSdk(http);
const notifications = new NotificationsSdk(http);

(async () => {
  const login: any = await auth.login({ email: 'student1@classmate.app', password: 'dev' });

  token =
    String(
      login?.accessToken ??
        login?.token ??
        login?.jwt ??
        login?.data?.accessToken ??
        login?.data?.token ??
        '',
    ) || '';

  if (!token) {
    console.error('login response:', login);
    throw new Error('No token returned from auth.login (expected accessToken/token)');
  }

  const feed = await announcements.feed();
  const unread = await announcements.unreadCount();
  const list: any[] = await notifications.list({ limit: 30 });

  console.log('announcements.feed:', feed.length);
  console.log('announcements.unread:', unread.unread);
  console.log('notifications.list:', list.length);

  await notifications.seenAll();
  console.log('notifications.seenAll: ok');
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
