import { test, expect, request as pwRequest } from '@playwright/test';

const API_BASE = (process.env.E2E_API_BASE_URL ?? process.env.E2E_API_BASE ?? 'http://127.0.0.1:3000').replace(/\/$/, '');
const API = `${API_BASE}/api`;

async function seedAndLogin() {
  const ctx = await pwRequest.newContext();
  const seed = await ctx.post(`${API}/test/seed/parent-web`, { data: {} });
  expect(seed.ok()).toBeTruthy();
  const { email, password } = await seed.json();

  const login = await ctx.post(`${API}/auth/login`, { data: { email, password } });
  expect(login.ok()).toBeTruthy();
  const { token } = await login.json();
  expect(token).toBeTruthy();

  const lookup = await ctx.get(`${API}/parent/lookup`, { headers: { Authorization: `Bearer ${token}` } });
  expect(lookup.ok()).toBeTruthy();
  const data = await lookup.json();
  const firstStudentId = data.students?.[0]?.id;
  expect(firstStudentId).toBeTruthy();

  await ctx.dispose();
  return { token, studentId: firstStudentId as string };
}

test('parent cannot query notifications for a student not linked to them', async () => {
  const a = await seedAndLogin();
  const b = await seedAndLogin();

  const ctx = await pwRequest.newContext();
  const res = await ctx.get(`${API}/parent/notifications?studentId=${encodeURIComponent(b.studentId)}&take=50`, {
    headers: { Authorization: `Bearer ${a.token}` },
  });

  // Either forbidden OR returns ok with empty list — both acceptable depending on desired API behavior.
  if (res.status() === 403) {
    expect(res.status()).toBe(403);
  } else {
    expect(res.ok()).toBeTruthy();
    const json = await res.json();
    expect(Array.isArray(json.notifications)).toBeTruthy();
    expect(json.notifications.length).toBe(0);
  }

  await ctx.dispose();
});
