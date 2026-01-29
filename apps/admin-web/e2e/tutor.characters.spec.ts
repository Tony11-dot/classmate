import { test, expect, request } from '@playwright/test';

const API = (process.env.E2E_API_BASE ?? 'http://127.0.0.1:3000') + '/api';

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
  await ctx.dispose();
  return token as string;
}

test('student can open multiple tutor chats across characters', async () => {
  const seed = await seedAdmin();
  expect(seed.studentEmail).toBeTruthy();
  expect(seed.mathTutorId).toBeTruthy();
  expect(seed.physicsTutorId).toBeTruthy();

  const token = await login(seed.studentEmail, seed.password);

  const ctx = await request.newContext({
    headers: { Authorization: `Bearer ${token}` },
  });

  const s1 = await ctx.post(`${API}/tutor/sessions`, { data: { subject: 'MATH', characterId: seed.mathTutorId } });
  expect(s1.ok()).toBeTruthy();
  const j1 = await s1.json();

  const s2 = await ctx.post(`${API}/tutor/sessions`, { data: { subject: 'PHYSICS', characterId: seed.physicsTutorId } });
  expect(s2.ok()).toBeTruthy();
  const j2 = await s2.json();

  const list = await ctx.get(`${API}/tutor/sessions`);
  expect(list.ok()).toBeTruthy();
  const lj = await list.json();
  expect(lj.sessions.length).toBeGreaterThanOrEqual(2);

  expect(j1.session.characterId).toBe(seed.mathTutorId);
  expect(j2.session.characterId).toBe(seed.physicsTutorId);

  await ctx.dispose();
});
