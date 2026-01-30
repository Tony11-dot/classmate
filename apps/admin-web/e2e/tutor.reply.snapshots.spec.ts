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

async function makeReply(token: string, subject: string, prompt: string) {
  const ctx = await request.newContext({ headers: { Authorization: `Bearer ${token}` } });

  const s = await ctx.post(`${API}/tutor/sessions`, { data: { subject, title: `Snap ${subject}` } });
  expect(s.ok()).toBeTruthy();
  const sj = await s.json();
  const sessionId = String(sj.session?.id ?? '');
  expect(sessionId).toBeTruthy();

  const r = await ctx.post(`${API}/tutor/sessions/${sessionId}/reply`, { data: { content: prompt } });
  expect(r.ok()).toBeTruthy();
  const json = await r.json();
  await ctx.dispose();

  return String(json.assistantMessage?.content ?? '');
}

test('snapshot: math derivatives reply', async () => {
  const seed = await seedAdmin();
  const token = await login(seed.studentEmail, seed.password);

  const text = await makeReply(token, 'MATH', 'Explain derivatives simply. Then give a mini-quiz.');
  expect(text).toMatchSnapshot('tutor.reply.math.derivatives.txt');
});

test('snapshot: physics kinematics reply', async () => {
  const seed = await seedAdmin();
  const token = await login(seed.studentEmail, seed.password);

  const text = await makeReply(token, 'PHYSICS', 'Explain constant acceleration and give a mini-quiz.');
  expect(text).toMatchSnapshot('tutor.reply.physics.kinematics.txt');
});
