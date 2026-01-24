import { test, expect } from '@playwright/test';

test('dashboard shows recent alerts and focus link highlights notification', async ({ page }) => {
  await page.goto('/dashboard');
  await expect(page).not.toHaveURL(/\/login/);

  await expect(page.getByText(/Recent alerts/i)).toBeVisible();

  // Click the first alert link
  const first = page.locator('a[href^="/notifications?focus="]').first();
  await expect(first).toBeVisible();

  const href = await first.getAttribute('href');
  expect(href).toBeTruthy();

  await first.click();

  // We should land on notifications with focus param
  await expect(page).toHaveURL(/\/notifications\?focus=/);

  // Extract focus id from URL
  const url = new URL(page.url());
  const focusId = url.searchParams.get('focus');
  expect(focusId).toBeTruthy();

  // Wait for the focused notification element to exist
  const focused = page.locator(`[data-notif-id="${focusId}"]`);
  await expect(focused).toBeVisible({ timeout: 10_000 });

  // Assert highlight class is applied (ring-2 expected)
  await expect(focused).toHaveClass(/ring-2/);
});
