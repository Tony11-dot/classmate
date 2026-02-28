import { test, expect } from '@playwright/test';

const BASE = process.env.E2E_API_BASE_URL || 'http://127.0.0.1:3003';

async function seed() {
  await fetch(`${BASE}/api/test/seed/admin-web`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({
      subject: "Math",
      sourceType: "BOOK",
      sourceName: `E2E Book ${Date.now()}`,
      page: 1,
      questionNumber: "1",
      body: "hello world",
    }),
  });

}

async function login(email: string) {
  const r = await fetch(`${BASE}/api/auth/login`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ email, password: 'dev' }),
  });
  const j = await r.json();
  return j.token;
}

function unwrap(j: any) {
  if (!j || typeof j !== 'object') return j;
  if ('data' in j) return j.data;
  if ('items' in j) return j;
  return j;
}

test('solutions feed: create + list + pagination + image', async () => {
  await seed();

  const student = await login('student1@classmate.app');
  const teacher = await login('teacher1@classmate.app');

  // ---- create solution ----
  const createResp = await fetch(`${BASE}/api/solutions`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${teacher}`,
    },
    body: JSON.stringify({
      subject: "Math",
      sourceType: "BOOK",
      sourceName: `E2E Book ${Date.now()}`,
      page: 1,
      questionNumber: "1",
      body: "hello world",
    }),
  });
  const created = await createResp.json().catch(() => null);
  expect([200, 201]).toContain(createResp.status);
  expect(created).not.toBeNull();
  const solutionId =
    created?.id ?? created?.solution?.id ?? created?.data?.id ?? null;

  expect(solutionId).toBeTruthy();

  // ---- add image ----
  const imgResp = await fetch(`${BASE}/api/solutions/${solutionId}/images`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${teacher}`,
    },
    body: JSON.stringify({
      url: 'https://example.com/test.png',
    }),
  });

  expect([200, 201, 400]).toContain(imgResp.status);
  expect(imgResp.status).not.toBe(500);

  // ---- list feed ----
  const listResp = await fetch(`${BASE}/api/solutions?limit=5`, {
    headers: { authorization: `Bearer ${student}` },
  });

  expect(listResp.status).toBe(200);

  const listJson = unwrap(await listResp.json());
  expect(listJson && typeof listJson === 'object').toBeTruthy();
  expect(Array.isArray(listJson.items)).toBeTruthy();
  expect('nextCursor' in listJson).toBeTruthy();

  // ---- pagination ----
  const nextCursor = listJson.nextCursor;
  if (nextCursor) {
    const page2 = await fetch(
      `${BASE}/api/solutions?limit=5&cursor=${encodeURIComponent(nextCursor)}`,
      { headers: { authorization: `Bearer ${student}` } }
    );
    expect(page2.status).toBe(200);
  }

  // ---- unauth protected ----
  const unauth = await fetch(`${BASE}/api/solutions`);
  expect(unauth.status).toBe(401);
});
