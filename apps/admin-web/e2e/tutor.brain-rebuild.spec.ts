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

test('student can rebuild brain snapshot and tutor reply reflects it', async () => {
  const seed = await seedAdmin();
  expect(seed.studentEmail).toBeTruthy();

  const token = await login(seed.studentEmail, seed.password);

  const ctx = await request.newContext({
    headers: { Authorization: `Bearer ${token}` },
  });

  const rebuild = await ctx.post(`${API}/tutor/me/brain/rebuild`, { data: {} });
  expect(rebuild.ok()).toBeTruthy();
  const bj = await rebuild.json();
  expect(bj.snapshot?.id).toBeTruthy();
  expect(bj.snapshot?.metrics).toBeTruthy();

  const s = await ctx.post(`${API}/tutor/sessions`, { data: { subject: 'MATH' } });
  expect(s.ok()).toBeTruthy();
  const sj = await s.json();
  expect(sj.session?.id).toBeTruthy();

  const r = await ctx.post(`${API}/tutor/sessions/${sj.session.id}/reply`, {
    data: { content: 'Explain derivative at Bagrut level.' },
  });
  expect(r.ok()).toBeTruthy();
  const rj = await r.json();
  expect(rj.assistantMessage?.content).toContain('AI Brain:');

  await ctx.dispose();
});
