import { test, expect } from '@playwright/test';
import { loginAsTeacher } from './helpers/auth';

const BASE = 'http://localhost:3001';
const API = 'http://localhost:3000';
const TOKEN_KEY = 'classmate_token';

test('attendance e2e', async ({ page, request }) => {
  const resp = await request.post(`${API}/api/auth/login`, {
    data: { email: 'teacher1@classmate.app', password: 'dev' },
  });
  expect(resp.status()).toBe(201);
  const { token } = await resp.json();
  expect(token).toBeTruthy();

  await page.addInitScript(({ key, token }) => {
    window.localStorage.setItem(key, token);
  }, { key: TOKEN_KEY, token });

  await page.goto(`${BASE}/attendance`, { waitUntil: 'domcontentloaded' });

  await expect(page.getByText(/today sessions/i)).toBeVisible({ timeout: 20000 });

  const firstSlot = page.getByRole('button', { name: /period\s+\d+/i }).first();
  await expect(firstSlot).toBeVisible({ timeout: 20000 });
  await firstSlot.click();

  const loadBtn = page.getByRole('button', { name: /^load session$/i });
  await expect(loadBtn).toBeVisible({ timeout: 20000 });
  await loadBtn.click();

  const row = page.locator('table tbody tr').first();
  await expect(row).toBeVisible({ timeout: 30000 });

  const statusSelect = row.locator('select');
  const curStatus = await statusSelect.inputValue();
  const nextStatus = curStatus === 'LATE' ? 'PRESENT' : 'LATE';
  await statusSelect.selectOption(nextStatus);

  const note = `ui-e2e-${Date.now()}`;
  await row.locator('input[placeholder="optional note"]').fill(note);

  const saveBtn = page.getByRole('button', { name: /^save/i });
  await expect.poll(async () => await saveBtn.innerText(), { timeout: 20000 })
    .toMatch(/Save\s*\(([1-9]\d*)\)/);

  await expect(saveBtn).toBeEnabled({ timeout: 20000 });
  await saveBtn.click();

  await expect(page.getByText(/saved|attendance saved/i)).toBeVisible({ timeout: 20000 });
});
