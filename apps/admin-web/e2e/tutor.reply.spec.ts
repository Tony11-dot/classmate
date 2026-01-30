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
  expect(token).toBeTruthy();
  await ctx.dispose();
  return token as string;
}

test('tutor reply stores assistant message and sources', async () => {
  const seed = await seedAdmin();
  expect(seed.studentEmail).toBeTruthy();

  const token = await login(seed.studentEmail, seed.password);

  const ctx = await request.newContext({
    headers: { Authorization: `Bearer ${token}` },
  });

  const s = await ctx.post(`${API}/tutor/sessions`, { data: { subject: 'MATH' } });
  expect(s.ok()).toBeTruthy();
  const sj = await s.json();
  expect(sj.session?.id).toBeTruthy();

  const r = await ctx.post(`${API}/tutor/sessions/${sj.session.id}/reply`, {
    data: { content: 'What is a derivative? Explain Bagrut level.' },
  });
  expect(r.ok()).toBeTruthy();

  const rj = await r.json();
  expect(rj.assistantMessage?.id).toBeTruthy();
  expect(typeof rj.assistantMessage?.content).toBe('string');
  expect(Array.isArray(rj.assistantMessage?.sources)).toBeTruthy();

  // should usually have at least 1 source because we seeded a derivative material
  expect(rj.assistantMessage.sources.length).toBeGreaterThanOrEqual(1);

  await ctx.dispose();
});
