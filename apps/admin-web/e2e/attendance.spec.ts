import { test, expect } from '@playwright/test';

const BASE = 'http://localhost:3001';
const API = 'http://127.0.0.1:3001';
const TOKEN_KEY = 'classmate_token';

function todayYmd() {
  const d = new Date();
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

test('attendance e2e', async ({ page, request }) => {
  // seed stable teacher/cohort/course/student + TODAY attendance session
  const seedResp = await request.post(`${API}/test/seed/admin-web`);
  expect(seedResp.ok()).toBeTruthy();
  const seedJson = await seedResp.json();
  const cohortId = seedJson.cohortId;
  expect(cohortId).toBeTruthy();


  // login via backend
  const resp = await request.post(`${API}/api/auth/login`, {
    data: { email: 'teacher1@classmate.app', password: 'dev' },
  });
  expect(resp.status()).toBe(201);
  const { token } = await resp.json();
  expect(token).toBeTruthy();

  // set token then go attendance
  await page.goto(`${BASE}/login`, { waitUntil: 'domcontentloaded' });
  await page.evaluate(({ key, token }) => {
    window.localStorage.setItem(key, token);
    window.dispatchEvent(new Event('classmate_token_change'));
  }, { key: TOKEN_KEY, token });

  await page.goto(`${BASE}/attendance`, { waitUntil: 'domcontentloaded' });
  await expect(page.getByRole('heading', { name: /^attendance$/i })).toBeVisible({ timeout: 30000 });

  const dateInput = page.locator("text=/^Date/i").locator("..").locator("input").first();
  await expect(dateInput).toBeVisible({ timeout: 30000 });
  await dateInput.fill(todayYmd());

  const periodInput = page.locator("text=/^Period/i").locator("..").locator("input").first();
  await expect(periodInput).toBeVisible({ timeout: 30000 });
  await periodInput.fill("1");

  const loadBtn = page.getByRole('button', { name: /^load session$/i });

  const cohortIdInput = page.locator("text=/^Cohort ID/i").locator("..").locator("input").first();
  await expect(cohortIdInput).toBeVisible({ timeout: 30000 });
  await cohortIdInput.fill(String(cohortId));


  await expect(loadBtn).toBeEnabled({ timeout: 30000 });
  await loadBtn.click();
  await page.waitForTimeout(500);
  const msg = await page.locator('body').innerText();


  // now table rows should appear
  const row = page.locator('table tbody tr').first();
  await expect(row).toBeVisible({ timeout: 30000 });

  const statusSelect = row.locator('select');
  await expect(statusSelect).toBeVisible({ timeout: 20000 });

  const curStatus = await statusSelect.inputValue();
  const nextStatus = curStatus === 'LATE' ? 'PRESENT' : 'LATE';
  await statusSelect.selectOption(nextStatus);

  const note = `ui-e2e-${Date.now()}`;
  await row.locator('input[placeholder="optional note"]').fill(note);

  const saveBtn = page.getByRole('button', { name: /^save/i });
  await expect(saveBtn).toBeEnabled({ timeout: 20000 });
  await saveBtn.click();

  await expect(page.getByText(/attendance saved|saved/i)).toBeVisible({ timeout: 20000 });
});
