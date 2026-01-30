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

test('POST /tutor/sessions/:id/reply returns stable contract', async () => {
  const seed = await seedAdmin();
  const token = await login(seed.studentEmail, seed.password);

  const ctx = await request.newContext({
    headers: { Authorization: `Bearer ${token}` },
  });

  const s = await ctx.post(`${API}/tutor/sessions`, { data: { subject: 'MATH', title: 'Contract test' } });
  expect(s.ok()).toBeTruthy();
  const sj = await s.json();
  const sessionId = String(sj.session?.id ?? '');
  expect(sessionId).toBeTruthy();

  const r = await ctx.post(`${API}/tutor/sessions/${sessionId}/reply`, {
    data: { content: 'Explain derivatives simply and give a mini quiz.' },
  });
  expect(r.ok()).toBeTruthy();
  const json = await r.json();

  // top-level
  expect(json.ok).toBeTruthy();

  // message objects exist
  expect(json.userMessage?.id).toBeTruthy();
  expect(json.userMessage?.role).toBe('USER');
  expect(String(json.userMessage?.content ?? '').length).toBeGreaterThan(0);

  expect(json.assistantMessage?.id).toBeTruthy();
  expect(json.assistantMessage?.role).toBe('ASSISTANT');
  expect(String(json.assistantMessage?.content ?? '').length).toBeGreaterThan(20);

  // stable conventions in content
  const content = String(json.assistantMessage?.content ?? '').toLowerCase();
  expect(content).toContain('bagrut');
  expect(content).toContain('mini-quiz');

  await ctx.dispose();
});
