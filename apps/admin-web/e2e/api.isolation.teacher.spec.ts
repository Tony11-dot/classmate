import { test, expect, request as pwRequest } from '@playwright/test';

const API_BASE = (process.env.E2E_API_BASE_URL ?? process.env.E2E_API_BASE ?? 'http://127.0.0.1:3001').replace(/\/$/, '');
const API = `${API_BASE}/api`;

async function seedAdmin() {
  const ctx = await pwRequest.newContext();
  const res = await ctx.post(`${API}/test/seed/admin-web`, { data: {} });
  expect(res.ok()).toBeTruthy();
  const json = await res.json();
  await ctx.dispose();
  return json as {
    cohortId: string;
    courseId: string;
    cohort2Id: string;
    course2Id: string;
    teacherEmail: string;
    teacher2Email: string;
    password: string;
  };
}

async function login(email: string, password: string) {
  const ctx = await pwRequest.newContext();
  const res = await ctx.post(`${API}/auth/login`, { data: { email, password } });
  expect(res.ok()).toBeTruthy();
  const { token } = await res.json();
  expect(token).toBeTruthy();
  await ctx.dispose();
  return token as string;
}

test('teacher cannot access other teacher cohort/students and course actions', async () => {
  const seed = await seedAdmin();
  const t1 = await login(seed.teacherEmail, seed.password);

  const ctx = await pwRequest.newContext();

  // Auth sanity: token must be valid for an allowed endpoint
  const okRes = await ctx.get(`${API}/teacher/schedule/today`, {
    headers: { Authorization: `Bearer ${t1}` },
  });
  expect(okRes.ok()).toBeTruthy();

  // 1) Cohort students for cohort2 should be forbidden (belongs to teacher2)
  const cohortRes = await ctx.get(`${API}/teacher/cohort/${encodeURIComponent(seed.cohort2Id)}/students`, {
    headers: { Authorization: `Bearer ${t1}` },
  });
  expect(cohortRes.status()).toBe(403);

  // 2) Create assessment on course2 should be forbidden
  const assessRes = await ctx.post(`${API}/teacher/grades/assessment`, {
    headers: { Authorization: `Bearer ${t1}` },
    data: { courseId: seed.course2Id, title: 'Should Fail', date: new Date().toISOString(), maxGrade: 100 },
  });
  expect(assessRes.status()).toBe(403);

  await ctx.dispose();
});
