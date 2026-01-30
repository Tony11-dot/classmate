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

test('tutor reply adapts using brain/profile and includes mini-quiz', async () => {
  const seed = await seedAdmin();
  const token = await login(seed.studentEmail, seed.password);

  const ctx = await request.newContext({
    headers: { Authorization: `Bearer ${token}` },
  });

  // Create a session (auto-picks character if needed)
  const s = await ctx.post(`${API}/tutor/sessions`, { data: { subject: 'MATH', title: 'Adaptive test' } });
  expect(s.ok()).toBeTruthy();
  const sj = await s.json();
  const sessionId = sj.session?.id;
  expect(sessionId).toBeTruthy();

  // Ask something that should trigger “derivatives”
  const r = await ctx.post(`${API}/tutor/sessions/${sessionId}/reply`, {
    data: { content: 'Explain derivatives in a simple way. Then give me practice.' },
  });
  expect(r.ok()).toBeTruthy();
  const json = await r.json();

  const assistant = String(json.assistantMessage?.content ?? '');
  expect(assistant.length).toBeGreaterThan(20);

  // Must mention bagrut-level + have mini-quiz bullets
  expect(assistant.toLowerCase()).toContain('bagrut');
  expect(assistant.toLowerCase()).toContain('mini');
  expect(assistant).toContain('- Mini');

  await ctx.dispose();
});
