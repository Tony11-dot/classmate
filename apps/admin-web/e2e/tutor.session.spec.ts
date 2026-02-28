import { test, expect } from '@playwright/test';

const BASE = process.env.E2E_API_BASE_URL || 'http://127.0.0.1:3003';

async function seed() {
  await fetch(`${BASE}/api/test/seed/admin-web`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({}),
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

test('tutor: session + message + reply + list', async () => {
  await seed();

  const student = await login('student1@classmate.app');
  // ---- profile (get + upsert) ----
  const profGet = await fetch(`${BASE}/api/tutor/me/profile`, {
    headers: { authorization: `Bearer ${student}` },
  });
  expect([200, 404]).toContain(profGet.status); // profile may not exist yet
  if (profGet.status === 200) {
    const j = await profGet.json();
    expect(j?.ok).toBeTruthy();
  }

  const profUpsert = await fetch(`${BASE}/api/tutor/me/profile`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${student}`,
    },
    body: JSON.stringify({
      targetCurriculum: 'bagrut',
      targetGrade: 12,
      preferredLanguage: 'en',
      tone: 'friendly',
      verbosity: 5,
      explainStyle: 'step-by-step',
      emojiOk: true,
      strengths: ['algebra'],
      weaknesses: ['derivatives'],
      goals: ['Improve calculus'],
      maxDepth: 3,
    }),
  });
  expect([200, 201]).toContain(profUpsert.status);
  const profUpsertJson = await profUpsert.json();
  expect(profUpsertJson?.ok).toBeTruthy();

  // ---- brain snapshot (get + rebuild) ----
  const brainGet = await fetch(`${BASE}/api/tutor/me/brain`, {
    headers: { authorization: `Bearer ${student}` },
  });
  expect(brainGet.status).toBe(200);
  const brainGetJson = await brainGet.json();
  expect(brainGetJson?.ok).toBeTruthy();

  const brainRebuild = await fetch(`${BASE}/api/tutor/me/brain/rebuild`, {
    method: 'POST',
    headers: { authorization: `Bearer ${student}` },
  });
  expect([200, 201]).toContain(brainRebuild.status);
  const brainRebuildJson = await brainRebuild.json();
  expect(brainRebuildJson?.ok).toBeTruthy();



  // ---- create session ----
  const createResp = await fetch(`${BASE}/api/tutor/sessions`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${student}`,
    },
    body: JSON.stringify({
      subject: 'MATH',
      title: 'E2E Tutor Session',
      topic: 'derivatives',
    }),
  });

  expect([200, 201]).toContain(createResp.status);
  const created = await createResp.json();
  expect(created?.ok).toBeTruthy();
  const sessionId = created?.session?.id;
  expect(sessionId).toBeTruthy();

  // ---- add message ----
  const msgResp = await fetch(`${BASE}/api/tutor/sessions/${sessionId}/messages`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${student}`,
    },
    body: JSON.stringify({
      role: 'USER',
      content: 'What is the derivative of x^2?',
    }),
  });

  expect([200, 201]).toContain(msgResp.status);
  const msgJson = await msgResp.json();
  expect(msgJson?.ok).toBeTruthy();

  // ---- reply ----
  const replyResp = await fetch(`${BASE}/api/tutor/sessions/${sessionId}/reply`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${student}`,
    },
    body: JSON.stringify({
      content: 'Explain simply.',
    }),
  });

  expect([200, 201]).toContain(replyResp.status);
  const replyJson = await replyResp.json();
  expect(replyJson?.ok).toBeTruthy();

  // ---- list sessions ----
  const listResp = await fetch(`${BASE}/api/tutor/sessions`, {
    headers: { authorization: `Bearer ${student}` },
  });

  expect(listResp.status).toBe(200);
  const listJson = await listResp.json();
  expect(listJson?.ok).toBeTruthy();
  expect(Array.isArray(listJson?.sessions)).toBeTruthy();

  // ---- get session ----
  const getResp = await fetch(`${BASE}/api/tutor/sessions/${sessionId}`, {
    headers: { authorization: `Bearer ${student}` },
  });

  expect(getResp.status).toBe(200);
  const getJson = await getResp.json();
  expect(getJson?.ok).toBeTruthy();
  expect(Array.isArray(getJson?.messages)).toBeTruthy();

  // ---- unauth protected ----
  const unauth = await fetch(`${BASE}/api/tutor/sessions`);
  expect(unauth.status).toBe(401);
});
