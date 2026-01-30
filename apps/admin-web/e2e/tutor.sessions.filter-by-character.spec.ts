import { test, expect, request } from '@playwright/test';

const API = process.env.E2E_API ?? 'http://127.0.0.1:3000/api';

async function seedAdmin() {
  const ctx = await request.newContext();
  const res = await ctx.post(`${API}/test/seed/admin-web`, { data: {} });
  expect(res.ok()).toBeTruthy();
  const json = await res.json();
  await ctx.dispose();
  return json as any;
}

async function login(email: string, password: string) {
  const ctx = await request.newContext();
  const res = await ctx.post(`${API}/auth/login`, { data: { email, password } });
  expect(res.ok()).toBeTruthy();
  const { token } = await res.json();
  expect(token).toBeTruthy();
  await ctx.dispose();
  return token as string;
}

test('GET /tutor/sessions can filter by characterId', async () => {
  const seed = await seedAdmin();
  const token = await login(seed.studentEmail, seed.password);

  expect(seed.mathTutorId).toBeTruthy();
  expect(seed.physicsTutorId).toBeTruthy();

  const ctx = await request.newContext({
    headers: { Authorization: `Bearer ${token}` },
  });

  // Create two sessions with explicit characters (deterministic)
  const s1 = await ctx.post(`${API}/tutor/sessions`, {
    data: { characterId: seed.mathTutorId, title: 'Math session' },
  });
  expect(s1.ok()).toBeTruthy();
  const s1j = await s1.json();
  expect(s1j.session?.id).toBeTruthy();
  expect(s1j.session?.characterId).toBe(seed.mathTutorId);

  const s2 = await ctx.post(`${API}/tutor/sessions`, {
    data: { characterId: seed.physicsTutorId, title: 'Physics session' },
  });
  expect(s2.ok()).toBeTruthy();
  const s2j = await s2.json();
  expect(s2j.session?.id).toBeTruthy();
  expect(s2j.session?.characterId).toBe(seed.physicsTutorId);

  // Filter by math tutor id
  const res = await ctx.get(`${API}/tutor/sessions?characterId=${encodeURIComponent(seed.mathTutorId)}`);
  expect(res.ok()).toBeTruthy();
  const json = await res.json();

  expect(Array.isArray(json.sessions)).toBeTruthy();
  expect(json.sessions.length).toBeGreaterThan(0);

  // All returned sessions must match the filter
  for (const row of json.sessions) {
    expect(row.characterId).toBe(seed.mathTutorId);
  }

  await ctx.dispose();
});
