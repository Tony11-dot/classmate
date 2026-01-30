import { test, expect, request } from '@playwright/test';
const API = 'http://127.0.0.1:3000/api';

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

test('reply cache hits on repeated prompt', async () => {
  const seed = await seedAdmin();
  const token = await login(seed.studentEmail, seed.password);

  const ctx = await request.newContext({ headers: { Authorization: `Bearer ${token}` } });

  const s = await ctx.post(`${API}/tutor/sessions`, { data: { subject: 'MATH', title: 'Cache hit' } });
  expect(s.ok()).toBeTruthy();
  const sid = (await s.json()).session.id as string;

  const prompt = 'Explain derivatives simply and give a mini-quiz.';

  const r1 = await ctx.post(`${API}/tutor/sessions/${sid}/reply`, { data: { content: prompt } });
  expect(r1.ok()).toBeTruthy();
  const t1 = String((await r1.json()).assistantMessage?.content ?? '');

  const r2 = await ctx.post(`${API}/tutor/sessions/${sid}/reply`, { data: { content: prompt } });
  expect(r2.ok()).toBeTruthy();
  const t2 = String((await r2.json()).assistantMessage?.content ?? '');

  // cache hit should produce identical deterministic output
  expect(t2).toBe(t1);

  await ctx.dispose();
});
