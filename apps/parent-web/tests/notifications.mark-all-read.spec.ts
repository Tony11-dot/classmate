import { test, expect, request } from '@playwright/test';

const API_BASE = process.env.API_BASE || 'http://127.0.0.1:3000';
const TOKEN_KEY = 'parent_token';

test('mark all read clears unread count', async ({ page }) => {
  await page.goto('/notifications');
  await expect(page).not.toHaveURL(/\/login/);

  // Click "Mark all read" if present
  const markAll = page.getByRole('button', { name: /Mark all read/i });
  await expect(markAll).toBeVisible();
  await markAll.click();

  // Grab token from localStorage (should exist thanks to storageState)
  const token = await page.evaluate((k) => localStorage.getItem(k), TOKEN_KEY);
  expect(token, 'parent_token should exist in localStorage').toBeTruthy();

  // Verify unread count via API
  const ctx = await request.newContext({
    baseURL: API_BASE,
    extraHTTPHeaders: { Authorization: `Bearer ${token}` },
  });

  const res = await ctx.get('/api/parent/notifications/unread-count');
  expect(res.ok()).toBeTruthy();

  const json = await res.json();
  expect(json.ok).toBeTruthy();
  let last = json;
  for (let i = 0; i < 10; i++) {
    // re-apply mark-all-read (idempotent)
    await ctx.post('/api/parent/notifications/mark-seen', { data: {} });

    const res2 = await ctx.get('/api/parent/notifications/unread-count');
    expect(res2.ok()).toBeTruthy();

    last = await res2.json();
    if (last.unread === 0) break;

    await new Promise((r) => setTimeout(r, 200));
  }
  expect(last.unread).toBe(0);

  await ctx.dispose();
});
