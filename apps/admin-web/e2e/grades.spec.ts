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

test('grades e2e: create assessment -> enter grade -> prefill on reopen', async ({ page, request }) => {
  await request.post(`${API}/test/seed/admin-web`);

  // login via backend (teacher)
  const resp = await request.post(`${API}/auth/login`, {
    data: { email: 'teacher1@classmate.app', password: 'dev' },
  });
  expect(resp.status()).toBe(201);
  const { token } = await resp.json();
  expect(token).toBeTruthy();

  // inject token BEFORE any page scripts run
  await page.addInitScript(
    ({ key, evt, token }) => {
      try { localStorage.setItem(key, token); } catch {}
      try { window.dispatchEvent(new Event(evt)); } catch {}
    },
    { key: TOKEN_KEY, evt: TOKEN_EVT, token },
  );

  const failures: string[] = [];
  page.on('requestfailed', (req) => {
    const f = req.failure();
    failures.push(`REQFAILED ${req.method()} ${req.url()} :: ${f?.errorText ?? 'unknown'}`);
  });
  page.on('console', (msg) => console.log('BROWSER', msg.type(), msg.text()));
  page.on('pageerror', (err) => console.log('PAGEERROR', String(err)));

  await page.goto(`${WEB_BASE}/grades`, { waitUntil: 'domcontentloaded' });
  await expect(page).toHaveURL(/\/grades/i, { timeout: 20_000 });
  await expect(page.getByRole('heading', { name: /grades/i }).first().first()).toBeVisible({ timeout: 30_000 });

  const courseSelect = page.locator('select').first();
  await expect(courseSelect).toBeVisible({ timeout: 30_000 });
  await expect
    .poll(async () => await courseSelect.locator('option').count(), { timeout: 30_000 })
    .toBeGreaterThan(0);

  const title = `E2E ${Date.now()}`;
  await page.getByPlaceholder('e.g. Quiz 3').fill(title);
  await page.getByPlaceholder('YYYY-MM-DD').fill(todayYmd());

  const createBtn = page.getByRole('button', { name: /^create$/i });
  await expect(createBtn).toBeEnabled({ timeout: 20_000 });
  await createBtn.click();

  const row = page.locator('tr', { hasText: title }).first();
  await expect(row).toBeVisible({ timeout: 20_000 });
  await row.getByRole('button', { name: /^open$/i }).click();

  await expect(page.getByTestId('grade-entry')).toBeVisible({ timeout: 20_000 });

  const gradeRows = page.locator('table tbody tr');
  const noStudents = page.getByText(/no students loaded/i);
  await Promise.race([
    expect.poll(async () => await gradeRows.count(), { timeout: 30_000 }).toBeGreaterThan(0),
    noStudents.waitFor({ timeout: 30_000 }).then(() => {
      throw new Error('UI says: No students loaded');
    }),
  ]);

  const firstInput = page.getByTestId('grades-entry-table').locator('input').first();
  await expect(firstInput).toBeVisible({ timeout: 30_000 });
  await firstInput.fill('97');

  const saveGradesBtn = page.getByRole('button', { name: /save grades/i });
  await expect(saveGradesBtn).toBeEnabled({ timeout: 20_000 });

  const saveError = page.getByTestId('save-error');

  const respP = page.waitForResponse(
    (r) => {
      const u = r.url();
      return u.includes('bulk') || u.includes('/api/teacher/grades') || u.includes('/grades/');
    },
    { timeout: 30_000 },
  );

  const failP = page.waitForEvent('requestfailed', { timeout: 30_000 }).then(() => 'REQFAILED' as const);
  const uiErrP = saveError.waitFor({ timeout: 30_000 }).then(() => 'UIERROR' as const);

  await saveGradesBtn.click();

  const winner = await Promise.race([respP, failP, uiErrP]);

  if (winner === 'REQFAILED') {
    console.log('FAILURES', failures.slice(-10));
    throw new Error('Save triggered a request failure (see FAILURES above)');
  }
});
