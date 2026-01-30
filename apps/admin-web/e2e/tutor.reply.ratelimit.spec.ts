import { test, expect, request } from '@playwright/test';
const API = 'http://127.0.0.1:3000/api';

async function seed() {
  const ctx = await request.newContext();
  const r = await ctx.post(`${API}/test/seed/admin-web`, { data: {} });
  const j = await r.json();
  await ctx.dispose();
  return j;
}
async function login(email: string, password: string) {
  const ctx = await request.newContext();
  const r = await ctx.post(`${API}/auth/login`, { data: { email, password } });
  const { token } = await r.json();
  await ctx.dispose();
  return token as string;
}

test('tutor reply rate-limit kicks in', async () => {
  const s = await seed();
  const token = await login(s.studentEmail, s.password);
  const ctx = await request.newContext({ headers: { Authorization: `Bearer ${token}` } });

  const sess = await ctx.post(`${API}/tutor/sessions`, { data: { subject: 'MATH', title: 'RL' } });
  const id = (await sess.json()).session.id;

  let lastOk = true;
  for (let i=0;i<20;i++) {
    const r = await ctx.post(`${API}/tutor/sessions/${id}/reply`, { data: { content: 'hi' } });
    lastOk = r.ok();
    if (!lastOk) break;
  }
  expect(lastOk).toBeFalsy();
  await ctx.dispose();
});
