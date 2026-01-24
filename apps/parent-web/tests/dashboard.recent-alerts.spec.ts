import { test, expect } from '@playwright/test';

test('dashboard shows recent alerts and focus link highlights notification', async ({ page }) => {
  await page.goto('/dashboard');
  await expect(page).not.toHaveURL(/\/login/);

  await expect(page.getByText(/Recent alerts/i)).toBeVisible();

  // Click the first alert
  const first = page.locator('a[href^="/notifications?focus="]').first();
  await expect(first).toBeVisible();
  const href = await first.getAttribute('href');
  expect(href).toBeTruthy();

  await first.click();

  // We should land on notifications and see a highlighted item
  await expect(page).toHaveURL(/\/notifications\?focus=/);
  await expect(page.locator('[data-notif-id].ring-2')).toHaveCount(1);
});
