import { test, expect } from '@playwright/test';

test('dashboard unread badge updates after mark all read', async ({ page }) => {
  await page.goto('/dashboard');
  await expect(page).not.toHaveURL(/\/login/);

  const notifLink = page.getByRole('link', { name: /Notifications/i });
  await expect(notifLink).toBeVisible();

  // Go notifications and mark all read
  await page.goto('/notifications');
  const markAll = page.getByRole('button', { name: /Mark all read/i });
  await expect(markAll).toBeVisible();
  await markAll.click();

  // Back to dashboard
  await page.goto('/dashboard');
  await expect(notifLink).toBeVisible();

  // Badge is typically a small element containing just digits next to "Notifications".
  // Assert there is NO digits-only element inside the Notifications link.
  const badge = notifLink.locator('span,div').filter({ hasText: /^\d+$/ });
  await expect(badge).toHaveCount(0, { timeout: 5000 });
});
