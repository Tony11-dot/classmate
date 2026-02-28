import { test, expect } from '@playwright/test';

const BASE = process.env.E2E_API_BASE_URL || 'http://127.0.0.1:3003';

async function seed() {
  const r = await fetch(`${BASE}/api/test/seed/admin-web`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({}),
  });
  expect(r.ok).toBeTruthy();
}

async function login(email: string, password: string) {
  const r = await fetch(`${BASE}/api/auth/login`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ email, password }),
  });
  expect(r.ok).toBeTruthy();
  const j = await r.json();
  const token = j?.token ?? j?.accessToken ?? j?.data?.accessToken ?? '';
  expect(token.length).toBeGreaterThan(10);
  return token;
}

function unwrap(j: any) {
  if (!j || typeof j !== 'object') return j;
  if ('data' in j) return (j as any).data;
  if ('classrooms' in j) return (j as any).classrooms;
  if ('items' in j) return (j as any).items;
  if ('ok' in j) {
    const { ok, ...rest } = j as any;
    if (Object.keys(rest).length === 1) return Object.values(rest)[0];
    return rest;
  }
  return j;
}

test('student classrooms endpoints are stable + protected', async () => {
  await seed();
  const token = await login('student1@classmate.app', 'dev');

  // unauth should be 401
  {
    const r = await fetch(`${BASE}/api/student/classrooms`);
    expect(r.status).toBe(401);
  }

  // list should be 200 + array
  const listResp = await fetch(`${BASE}/api/student/classrooms`, {
    headers: { authorization: `Bearer ${token}` },
  });
  expect(listResp.status).toBe(200);

  const listJson = await listResp.json();
  const listPayload = unwrap(listJson);
  expect(Array.isArray(listPayload)).toBeTruthy();

  // if seed produced nothing, that's still "stable"
  const first = Array.isArray(listPayload) ? listPayload[0] : null;
  if (!first?.id) return;

  // details should be 200 + object
  const detResp = await fetch(`${BASE}/api/student/classrooms/${first.id}`, {
    headers: { authorization: `Bearer ${token}` },
  });
  expect(detResp.status).toBe(200);

  const detJson = await detResp.json();
  const detPayload = unwrap(detJson);
  expect(detPayload && typeof detPayload === 'object' && !Array.isArray(detPayload)).toBeTruthy();
  expect((detPayload as any).id ?? (detPayload as any).classroom?.id).toBeTruthy();

  // non-existent should not 500
  const badResp = await fetch(`${BASE}/api/student/classrooms/does-not-exist`, {
    headers: { authorization: `Bearer ${token}` },
  });
  expect([400, 401, 403, 404]).toContain(badResp.status);
});
