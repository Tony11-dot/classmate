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

test('student can create tutor session and send message', async () => {
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

  const m = await ctx.post(`${API}/tutor/sessions/${sj.session.id}/messages`, {
    data: { role: 'USER', content: 'What is a derivative?' },
  });
  expect(m.ok()).toBeTruthy();

  const get = await ctx.get(`${API}/tutor/sessions/${sj.session.id}`);
  expect(get.ok()).toBeTruthy();
  const json = await get.json();
  expect(Array.isArray(json.messages)).toBeTruthy();
  expect(json.messages.length).toBe(1);

  await ctx.dispose();
});
