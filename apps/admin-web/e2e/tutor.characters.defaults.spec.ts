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

test('createSession auto-creates global default tutor characters when none exist', async () => {
  const seed = await seedAdmin();
  const token = await login(seed.studentEmail, seed.password);

  // wipe characters (test-only)
  const wipeCtx = await request.newContext();
  const wipe = await wipeCtx.post(`${API}/test/seed/clear-tutor-characters`, { data: {} });
  expect(wipe.ok()).toBeTruthy();
  await wipeCtx.dispose();

  const ctx = await request.newContext({
    headers: { Authorization: `Bearer ${token}` },
  });

  const s = await ctx.post(`${API}/tutor/sessions`, { data: { subject: 'MATH' } });
  expect(s.ok()).toBeTruthy();
  const sj = await s.json();

  expect(sj.session?.id).toBeTruthy();
  expect(sj.session?.characterId).toBeTruthy(); // proves runtime recreated defaults

  await ctx.dispose();
});
