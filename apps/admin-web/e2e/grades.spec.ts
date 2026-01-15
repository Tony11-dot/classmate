import { test, expect } from '@playwright/test';

const BASE = process.env.E2E_BASE_URL ?? 'http://localhost:3001';
const API = 'http://localhost:3000';
const TOKEN_KEY = 'classmate_token';

function todayYmd() {
  const d = new Date();
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

test('grades e2e: create assessment -> enter grade -> prefill on reopen', async ({ page, request }) => {

  // login via backend (teacher)
  const resp = await request.post(`${API}/auth/login`, {
    data: { email: 'teacher1@classmate.app', password: 'dev' },
  });
  expect(resp.status()).toBe(201);
  const { token } = await resp.json();
  expect(token).toBeTruthy();

  // set token in app storage
  // go to login first so the app is loaded, then set token + notify RequireAuth
  await page.goto(`${BASE}/login`, { waitUntil: 'domcontentloaded' });

  const failures: string[] = [];
  page.on('requestfailed', (req) => {
    const f = req.failure();
    failures.push(`REQFAILED ${req.method()} ${req.url()} :: ${f?.errorText ?? 'unknown'}`);
  });
  page.on('console', (msg) => {
    // eslint-disable-next-line no-console
    console.log('BROWSER', msg.type(), msg.text());
  });
  page.on('pageerror', (err) => {
    // eslint-disable-next-line no-console
    console.log('PAGEERROR', String(err));
  });

  await page.evaluate(({ key, token }) => {
    window.localStorage.setItem(key, token);
    window.dispatchEvent(new Event('classmate_token_change'));
  }, { key: TOKEN_KEY, token });

  // open grades page
  await page.goto(`${BASE}/grades`, { waitUntil: 'domcontentloaded' });
    // Wait for auth + client hydration (RequireAuth renders null until mounted)
  await expect(page).toHaveURL(/\/grades/i, { timeout: 20000 });
  await expect(page.getByRole('heading', { name: /grades/i })).toBeVisible({ timeout: 30000 });

  // ensure courses loaded (select exists with at least 1 option)
  const courseSelect = page.locator('select').first();
  await expect(courseSelect).toBeVisible({ timeout: 30000 });
  await expect.poll(async () => await courseSelect.locator('option').count(), { timeout: 30000 }).toBeGreaterThan(0);

  // create unique assessment
  const title = `E2E ${Date.now()}`;
  await page.getByPlaceholder('e.g. Quiz 3').fill(title);
  await page.getByPlaceholder('YYYY-MM-DD').fill(todayYmd());

  const createBtn = page.getByRole('button', { name: /^create$/i });
  await expect(createBtn).toBeEnabled({ timeout: 20000 });
  await createBtn.click();

  // find row for this assessment + open it
  const row = page.locator('tr', { hasText: title }).first();
  await expect(row).toBeVisible({ timeout: 20000 });

  await row.getByRole('button', { name: /^open$/i }).click();

  // grade entry appears + at least 1 student input
    await expect(page.getByTestId('grade-entry')).toBeVisible({ timeout: 20000 });



    const gradeRows = page.locator('table tbody tr');
  const noStudents = page.getByText(/no students loaded/i);
  await Promise.race([
    expect.poll(async () => await gradeRows.count(), { timeout: 30000 }).toBeGreaterThan(0),
    noStudents.waitFor({ timeout: 30000 }).then(() => { throw new Error('UI says: No students loaded'); }),
  ]);
  const firstInput = page.getByTestId('grades-entry-table').locator('input').first();
await expect(firstInput).toBeVisible({ timeout: 30000 });
await firstInput.fill('97');

  const saveGradesBtn = page.getByRole('button', { name: /save grades/i });
  await expect(saveGradesBtn).toBeEnabled({ timeout: 20000 });
  const seen: string[] = [];
  page.on('request', (req) => {
    const u = req.url();
    if (u.includes('grades')) seen.push(`${req.method()} ${u}`);
  });

  
  const saveError = page.getByTestId('save-error');

  const respP = page.waitForResponse((r) => {
    const u = r.url();
    return u.includes('bulk') || u.includes('/teacher/grades') || u.includes('/grades/');
  }, { timeout: 30000 });

  const failP = page.waitForEvent('requestfailed', { timeout: 30000 }).then(() => 'REQFAILED');
  const uiErrP = saveError.waitFor({ timeout: 30000 }).then(() => 'UIERROR');

  await saveGradesBtn.click();

  const winner = await Promise.race([respP, failP, uiErrP]);

  if (winner === 'REQFAILED') {
    // eslint-disable-next-line no-console
    console.log('FAILURES', failures.slice(-10));
    throw new Error('Save triggered a request failure (see FAILURES above)');
  }

  if (winner === 'UIERROR') {
    const msg = await saveError.textContent();
    throw new Error('UI displayed save error: ' + (msg ?? ''));
  }

  const saveBulkResp = winner;
  // eslint-disable-next-line no-console
  console.log('Matched response:', saveBulkResp.url(), saveBulkResp.status());
  expect(saveBulkResp.status()).toBeGreaterThanOrEqual(200);
  expect(saveBulkResp.status()).toBeLessThan(300);

  // wait a beat for save to complete (no toast currently guaranteed)
  await expect.poll(async () => await saveGradesBtn.isEnabled(), { timeout: 20000 }).toBe(true);

  // reopen same assessment and expect prefill
  await row.getByRole('button', { name: /^open$/i }).click();

    const reopenedFirstInput = page.getByTestId('grades-entry-table').locator('input').first();
  await expect.poll(async () => await reopenedFirstInput.inputValue(), { timeout: 30000 }).toBe('97');
});
