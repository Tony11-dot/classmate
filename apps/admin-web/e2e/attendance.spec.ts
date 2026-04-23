import { test, expect } from '@playwright/test';

const WEB_BASE = (process.env.E2E_WEB_BASE_URL ?? process.env.WEB_BASE ?? 'http://127.0.0.1:3000').replace(/\/$/, '');
const API_BASE = (process.env.E2E_API_BASE_URL ?? 'http://127.0.0.1:3001').replace(/\/$/, '');
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
  // Rewrite any hardcoded frontend API calls (ex: http://127.0.0.1:3002) to the running API on 3001
  await page.route('**/*', async (route) => {
    const url = route.request().url();
    if (url.includes('127.0.0.1:3002')) {
      return route.continue({ url: url.replace('127.0.0.1:3002', '127.0.0.1:3001') });
    }
    return route.continue();
  });


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
      // also set a few common fallback keys (in case UI reads a different one)
      try { localStorage.setItem('cm_token', token); } catch {}
      try { localStorage.setItem('cm_teacher_token', token); } catch {}
      try { localStorage.setItem('token', token); } catch {}
      try { window.dispatchEvent(new Event(evt)); } catch {}
    },
    { key: TOKEN_KEY, evt: TOKEN_EVT, token },
  );
await page.goto(`${WEB_BASE}/attendance`, { waitUntil: 'domcontentloaded', timeout: 120_000 });
  await expect(page.getByRole('heading', { name: /today\s*&\s*attendance/i })).toBeVisible({ timeout: 30_000 });

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

  // Wait for at least one attendance row (fail if none appears)
  await expect(rows.first()).toBeVisible({ timeout: 30_000 });

  const row = rows.first();

  await expect(row).toBeVisible({ timeout: 30_000 });

  const statusSelect = row.locator('select');
  await expect(statusSelect).toBeVisible({ timeout: 20_000 });

  const curStatus = await statusSelect.inputValue();
  const nextStatus = curStatus === 'LATE' ? 'PRESENT' : 'LATE';
  await statusSelect.selectOption(nextStatus);
  await expect(statusSelect).toHaveValue(nextStatus, { timeout: 10_000 });

  const note = `ui-e2e-${Date.now()}`;
  await row.locator('input[placeholder="optional note"]').fill(note);

  const saveBtn = page.getByRole('button', { name: /^save/i });
  await expect(saveBtn).toBeEnabled({ timeout: 20_000 });
  const [saveResp] = await Promise.all([
    page.waitForResponse((r) => {
      const u = r.url();
      if (!u.includes('/api/teacher/attendance/')) return false;
      const m = r.request().method();
      if (!['POST','PATCH','PUT'].includes(m)) return false;
      if (!(u.includes('/mark') || u.includes('/bulk'))) return false;
      return r.status() >= 200 && r.status() < 300;
    }, { timeout: 30_000 }),
    saveBtn.click(),
  ]);

      // Verify via API that attendance was actually saved (poll until it matches)
  let lastStatus: any = null;
  for (let i = 0; i < 20; i++) {
    const verify = await request.get(
      `${API}/teacher/attendance/session?date=${todayYmd()}&period=1&cohortId=${cohortId}`,
      { headers: { Authorization: `Bearer ${token}` } }
    );
    expect(verify.ok()).toBeTruthy();
    const verifyJson = await verify.json();
    lastStatus = verifyJson?.students?.[0]?.status ?? null;
    if (lastStatus === nextStatus) break;
    await new Promise((r) => setTimeout(r, 500));
  }
  expect(lastStatus).toBe(nextStatus);

});
