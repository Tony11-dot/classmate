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
  if ('items' in j) return (j as any).items;
  if ('ok' in j) {
    const { ok, ...rest } = j as any;
    if (Object.keys(rest).length === 1) return Object.values(rest)[0];
    return rest;
  }
  return j;
}

test('announcements + notifications are protected + stable', async () => {
  await seed();

  const student = await login('student1@classmate.app', 'dev');
  const admin = await login('admin1@classmate.app', 'dev');

  // announcements feed must be 401 without token
  {
    const r = await fetch(`${BASE}/api/announcements/feed`);
    expect(r.status).toBe(401);
  }

  // notifications must be 401 without token
  {
    const r = await fetch(`${BASE}/api/notifications`);
    expect(r.status).toBe(401);
  }

  // student feed should be 200 + array/object
  {
    const r = await fetch(`${BASE}/api/announcements/feed`, {
      headers: { authorization: `Bearer ${student}` },
    });
    expect(r.status).toBe(200);
    const j = unwrap(await r.json());
    const ok = Array.isArray(j) || (j && typeof j === 'object');
    expect(ok).toBeTruthy();
  }

  // student unread-count should be 200 + object/number
  {
    const r = await fetch(`${BASE}/api/announcements/unread-count`, {
      headers: { authorization: `Bearer ${student}` },
    });
    expect(r.status).toBe(200);
    const j = unwrap(await r.json());
    const ok = typeof j === 'number' || (j && typeof j === 'object');
    expect(ok).toBeTruthy();
  }

  // notifications list should be 200 + array/object
  {
    const r = await fetch(`${BASE}/api/notifications`, {
      headers: { authorization: `Bearer ${student}` },
    });
    expect(r.status).toBe(200);
    const j = unwrap(await r.json());
    const ok = Array.isArray(j) || (j && typeof j === 'object');
    expect(ok).toBeTruthy();
  }

  // admin can POST announcement (should not 401/500)
  {
    const r = await fetch(`${BASE}/api/announcements`, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        authorization: `Bearer ${admin}`,
      },
      body: JSON.stringify({
        title: 'E2E Announcement',
        body: 'hello from e2e',
        targets: [{ role: "STUDENT" }],
      }),
    });

    // accept 201 or 200; if DTO differs we allow 400 (but never 500)
    expect([200, 201]).toContain(r.status);
    const j = await r.json().catch(() => null);
    expect(j).not.toBeNull();
  }
});
