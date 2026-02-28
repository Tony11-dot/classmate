import { test, expect } from '@playwright/test';

const BASE = process.env.E2E_API_BASE_URL || 'http://127.0.0.1:3003';

async function seed() {
  const r = await fetch(`${BASE}/api/test/seed/admin-web`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({}),
  });
  expect(r.ok).toBeTruthy();
}

async function login(email: string, password: string) {
  const r = await fetch(`${BASE}/api/auth/login`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ email, password }),
  });

  expect(r.ok).toBeTruthy();
  const j = await r.json();
  const token = j?.token ?? j?.accessToken ?? j?.data?.accessToken ?? '';
  expect(token.length).toBeGreaterThan(10);
  return token;
}

test('student schedule endpoints are stable', async () => {
  await seed();
  const token = await login('student1@classmate.app', 'dev');

  const endpoints = [
    '/api/student/schedule',
    '/api/student/schedule/today',
    '/api/student/schedule/week',
  ];

  for (const ep of endpoints) {
    const r = await fetch(`${BASE}${ep}`, {
      headers: { authorization: `Bearer ${token}` },
    });

    expect(r.status, `${ep} expected 200 but got ${r.status}`).toBe(200);

    const j = await r.json();
    expect(typeof j).toBe('object');
  }
});
