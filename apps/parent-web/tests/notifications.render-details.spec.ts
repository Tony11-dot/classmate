import { test, expect } from '@playwright/test';

test('notifications render with student + course details', async ({ page }) => {
  await page.goto('/notifications');
  await expect(page).not.toHaveURL(/\/login/);

  // At least one notification card/button exists (excluding control buttons)
  const notifButtons = page.locator('button').filter({ hasNotText: 'Mark all read' });
  await expect(notifButtons.first()).toBeVisible();

  // We expect content includes a student name or course name somewhere
  await expect(page.getByText(/Student One/i).first()).toBeVisible();
  await expect(page.getByText(/Math/i).first()).toBeVisible();
});
