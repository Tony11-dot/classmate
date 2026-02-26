import { request, expect, APIRequestContext } from '@playwright/test';

export const API = `${(process.env.E2E_API_BASE_URL ?? 'http://127.0.0.1:3002').replace(/\/$/,'')}/api`;

async function seedAdminWithRetry(retries = 6): Promise<any> {
  const ctx = await request.newContext();
  let lastText = '';

  for (let i = 0; i < retries; i++) {
    const res = await ctx.post(`${API}/test/seed/admin-web`, { data: {} });
    lastText = await res.text();

    if (res.ok()) {
      await ctx.dispose();
      return JSON.parse(lastText);
    }

    await new Promise((r) => setTimeout(r, 150 * (i + 1)));
  }

  await ctx.dispose();
  throw new Error(`seed failed after retries. last=${lastText}`);
}

async function login(email: string, password: string): Promise<string> {
  const ctx = await request.newContext();
  const res = await ctx.post(`${API}/auth/login`, { data: { email, password } });
  const text = await res.text();
  await ctx.dispose();

  if (!res.ok()) throw new Error(`login failed ${res.status()}: ${text}`);
  const j = JSON.parse(text);
  const token = j?.token ?? j?.accessToken ?? j?.data?.accessToken;
  if (!token) throw new Error(`login response missing token: ${text}`);
  return token;
}

export async function seededStudentApi(): Promise<{ seed: any; ctx: APIRequestContext }> {
  const seed = await seedAdminWithRetry();

  const studentEmail =
    seed?.studentEmail ??
    seed?.student?.email ??
    'student1@classmate.app';

  const password =
    seed?.password ??
    seed?.studentPassword ??
    seed?.student?.password ??
    'dev';

  expect(studentEmail).toBeTruthy();
  expect(password).toBeTruthy();

  const token = await login(studentEmail, password);

  const ctx = await request.newContext({
    extraHTTPHeaders: { 'X-E2E-BYPASS-THROTTLE': '1', Authorization: `Bearer ${token}` },

  });

  return { seed, ctx };
}
