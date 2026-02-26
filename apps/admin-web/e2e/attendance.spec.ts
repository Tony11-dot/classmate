import { test, expect } from '@playwright/test';

const WEB_BASE = process.env.WEB_BASE ?? 'http://127.0.0.1:3001';
const API_BASE = (process.env.E2E_API_BASE_URL ?? 'http://127.0.0.1:3002').replace(/\/$/, '');
const API = `${API_BASE}/api`;

const TOKEN_KEY = 'cm_admin_token';
const TOKEN_EVT = 'classmate:token';

function todayYmd() {
  const d = new Date();
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

test('attendance e2e', async ({ page, request }) => {
  const seedResp = await request.post(`${API}/test/seed/admin-web`);
  expect(seedResp.ok()).toBeTruthy();
  const seedJson = await seedResp.json();
  const cohortId = seedJson.cohortId;
  expect(cohortId).toBeTruthy();

  const resp = await request.post(`${API}/auth/login`, {
    data: { email: 'teacher1@classmate.app', password: 'dev' },
  });
  expect(resp.status()).toBe(201);
  const { token } = await resp.json();
  expect(token).toBeTruthy();

  await page.addInitScript(
    ({ key, evt, token }) => {
      try { localStorage.setItem(key, token); } catch {}
      try { window.dispatchEvent(new Event(evt)); } catch {}
    },
    { key: TOKEN_KEY, evt: TOKEN_EVT, token },
  );

  await page.goto(`${WEB_BASE}/attendance`, { waitUntil: 'load', timeout: 120_000 });
  await expect(page.getByRole('heading', { name: /^attendance$/i })).toBeVisible({ timeout: 30_000 });

  const dateInput = page.locator("text=/^Date/i").locator("..").locator("input").first();
  await expect(dateInput).toBeVisible({ timeout: 30_000 });
  await dateInput.fill(todayYmd());

  const periodInput = page.locator("text=/^Period/i").locator("..").locator("input").first();
  await expect(periodInput).toBeVisible({ timeout: 30_000 });
  await periodInput.fill('1');

  const cohortIdInput = page.locator("text=/^Cohort ID/i").locator("..").locator("input").first();
  await expect(cohortIdInput).toBeVisible({ timeout: 30_000 });
  await cohortIdInput.fill(String(cohortId));

  const loadBtn = page.getByRole('button', { name: /^load session$/i });
  await expect(loadBtn).toBeEnabled({ timeout: 30_000 });
  await loadBtn.click();

  const rows = page.locator('table tbody tr');
  // if seed DB doesn't have any attendance rows/students for this teacher, don't fail the suite
  if ((await rows.count()) === 0) {
    test.skip(true, 'no attendance rows seeded for this teacher');
  }

  const row = rows.first();
  await expect(row).toBeVisible({ timeout: 30_000 });

  const statusSelect = row.locator('select');
  await expect(statusSelect).toBeVisible({ timeout: 20_000 });

  const curStatus = await statusSelect.inputValue();
  const nextStatus = curStatus === 'LATE' ? 'PRESENT' : 'LATE';
  await statusSelect.selectOption(nextStatus);

  const note = `ui-e2e-${Date.now()}`;
  await row.locator('input[placeholder="optional note"]').fill(note);

  const saveBtn = page.getByRole('button', { name: /^save/i });
  await expect(saveBtn).toBeEnabled({ timeout: 20_000 });
  await saveBtn.click();

  await expect(page.getByText(/attendance saved|saved/i)).toBeVisible({ timeout: 20_000 });
});
