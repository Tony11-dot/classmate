import { test, expect, request } from '@playwright/test';

const API_BASE = (process.env.API_BASE || process.env.NEXT_PUBLIC_API_BASE_URL || 'http://127.0.0.1:3001').replace(/\/api\/?$/, '');

test('notifications API returns createdAt + seenAt', async ({ page }) => {
  await page.goto('/notifications');
  const token = await page.evaluate(() => localStorage.getItem('parent_token'));
  expect(token).toBeTruthy();

  const ctx = await request.newContext({
    baseURL: API_BASE,
    extraHTTPHeaders: { Authorization: `Bearer ${token}` },
  });

  const res = await ctx.get('/parent/notifications?take=10');
  expect(res.ok()).toBeTruthy();
  const json = await res.json();


  // Strict contract: no legacy keys like "at"
  const EXPECTED_KEYS = ['createdAt','data','id','message','parentId','seenAt','studentId','title','type'];

  expect(Array.isArray(json.notifications)).toBeTruthy();
  expect(json.notifications.length).toBeGreaterThan(0);

  const keys0 = Object.keys(json.notifications[0]).sort();
  expect(keys0).toEqual(EXPECTED_KEYS);

  expect(json.notifications[0].createdAt).toBeTruthy();
  expect(new Date(json.notifications[0].createdAt).toString()).not.toBe('Invalid Date');

  for (const n of json.notifications) {
    expect(typeof n.createdAt).toBe('string');
    expect(n.seenAt === null || typeof n.seenAt === 'string').toBeTruthy();
  }

  await ctx.dispose();
});
