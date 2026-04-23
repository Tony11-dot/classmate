import { test, expect } from '@playwright/test';

test('notifications render with student + course details', async ({ page }) => {
  await page.goto('/notifications');
  await expect(page).not.toHaveURL(/\/login/);

  // At least one notification card/button exists (excluding control buttons)
  const notifButtons = page.locator('button').filter({ hasNotText: 'Mark all read' });
  await expect(notifButtons.first()).toBeVisible();

  // Seeded notifications include student-specific titles and a rendered course detail line.
  await expect(page.getByText(/for Student /i).first()).toBeVisible();
  await expect(page.getByText(/Course:/i).first()).toBeVisible();
});
