import { test, expect } from '@playwright/test';

test('notifications page loads and does not show legacy type', async ({ page }) => {
  await page.goto('/notifications');

  // If auth failed, you'd be on /login
  await expect(page).not.toHaveURL(/\/login/);

  // header exists
  await expect(page.getByRole('heading', { name: /Notifications/i })).toBeVisible();

  // should not render legacy entries
  await expect(page.locator('text=ATTENDANCE_MARKED')).toHaveCount(0);

  // Either "No notifications" is visible OR we have at least one notification item button.
  const no = page.getByText('No notifications');

  // Exclude control buttons
  const notifButtons = page.locator('button').filter({ hasNotText: 'Mark all read' });

  if (await no.isVisible()) {
    await expect(no).toBeVisible();
  } else {
    await expect(notifButtons.first()).toBeVisible();
  }
});
