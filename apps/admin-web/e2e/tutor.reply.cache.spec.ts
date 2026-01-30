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

test('tutor reply cache: second identical reply returns same content', async () => {
  const seed = await seedAdmin();
  const token = await login(seed.studentEmail, seed.password);

  const ctx = await request.newContext({
    headers: { Authorization: `Bearer ${token}` },
  });

  const s = await ctx.post(`${API}/tutor/sessions`, { data: { subject: 'MATH', title: 'Cache test' } });
  expect(s.ok()).toBeTruthy();
  const sj = await s.json();
  const sessionId = String(sj.session?.id ?? '');
  expect(sessionId).toBeTruthy();

  const prompt = 'Explain derivatives simply and give a mini-quiz.';
  const r1 = await ctx.post(`${API}/tutor/sessions/${sessionId}/reply`, { data: { content: prompt } });
  expect(r1.ok()).toBeTruthy();
  const j1 = await r1.json();
  const a1 = String(j1.assistantMessage?.content ?? '');
  expect(a1.length).toBeGreaterThan(20);

  const r2 = await ctx.post(`${API}/tutor/sessions/${sessionId}/reply`, { data: { content: prompt } });
  expect(r2.ok()).toBeTruthy();
  const j2 = await r2.json();
  const a2 = String(j2.assistantMessage?.content ?? '');
  expect(a2.length).toBeGreaterThan(20);

  expect(a2).toBe(a1);

  await ctx.dispose();
});
