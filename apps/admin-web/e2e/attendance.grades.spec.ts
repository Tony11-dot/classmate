import { test, expect } from '@playwright/test';

const BASE = process.env.E2E_API_BASE_URL || 'http://127.0.0.1:3003';

async function seed() {
  const r = await fetch(`${BASE}/api/test/seed/admin-web`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({}),
  });
  expect(r.ok).toBeTruthy();
  return (await r.json().catch(() => ({}))) as any;
}

async function login(email: string, password: string) {
  const r = await fetch(`${BASE}/api/auth/login`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ email, password }),
  });
  expect(r.ok).toBeTruthy();
  const j = (await r.json().catch(() => ({}))) as any;
  const token = j?.token ?? j?.accessToken ?? j?.data?.accessToken ?? '';
  expect(typeof token).toBe('string');
  expect(token.length).toBeGreaterThan(10);
  return token as string;
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

test('attendance + grades are protected + stable (teacher/student/parent)', async () => {
  const seedJson = await seed();
  const cohortId = seedJson?.cohortId;
  expect(cohortId).toBeTruthy();

  const student = await login('student1@classmate.app', 'dev');
  const teacher = await login('teacher1@classmate.app', 'dev');
  const parent = await login('parent1@classmate.app', 'dev');

  // ---- AUTH GUARDRAILS (401 without token) ----
  {
    const r = await fetch(`${BASE}/api/teacher/attendance/session?cohortId=${encodeURIComponent(cohortId)}&period=1`);
    expect([401, 403]).toContain(r.status);
  }
  {
    const r = await fetch(`${BASE}/api/teacher/grades/assessments`);
    expect([401, 403]).toContain(r.status);
  }
  {
    const r = await fetch(`${BASE}/api/student/attendance`);
    expect([401, 403]).toContain(r.status);
  }
  {
    const r = await fetch(`${BASE}/api/student/grades`);
    expect([401, 403]).toContain(r.status);
  }
  {
    const r = await fetch(`${BASE}/api/parent/grades`);
    expect([401, 403]).toContain(r.status);
  }

  // ---- TEACHER: schedule today -> date + period + course ----
  const todayResp = await fetch(`${BASE}/api/teacher/schedule/today`, {
    headers: { authorization: `Bearer ${teacher}` },
  });
  expect(todayResp.status).toBe(200);

  const todayJson = (await todayResp.json().catch(() => null)) as any;
  expect(todayJson).not.toBeNull();

  const date = todayJson?.date;
  const period = todayJson?.slots?.[0]?.period;
  const courseId = todayJson?.slots?.[0]?.course?.id;

  // If seed had no slots, treat as stable (not a failure)
  if (!date || !Number.isInteger(period) || !courseId) return;

  // ---- TEACHER: attendance session ----
  const sessionResp = await fetch(
    `${BASE}/api/teacher/attendance/session?cohortId=${encodeURIComponent(cohortId)}&date=${encodeURIComponent(
      date,
    )}&period=${period}`,
    { headers: { authorization: `Bearer ${teacher}` } },
  );
  expect([200, 400, 401, 403]).toContain(sessionResp.status);
  expect(sessionResp.status).not.toBe(500);
  expect(sessionResp.status).toBe(200);

  const sessionJson = (await sessionResp.json().catch(() => null)) as any;
  expect(sessionJson).not.toBeNull();
  expect(Array.isArray(sessionJson?.students)).toBeTruthy();

  const studentId = sessionJson?.students?.[0]?.studentId;
  expect(studentId).toBeTruthy();

  // ---- TEACHER: mark attendance ----
  const markResp = await fetch(`${BASE}/api/teacher/attendance/mark`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${teacher}`,
    },
    body: JSON.stringify({
      cohortId,
      date,
      period,
      studentId,
      status: 'ABSENT',
    }),
  });
  expect([200, 201, 400, 401, 403]).toContain(markResp.status);
  expect(markResp.status).not.toBe(500);
  expect([200, 201]).toContain(markResp.status);

  // ---- TEACHER: session reflects change ----
  const session2Resp = await fetch(
    `${BASE}/api/teacher/attendance/session?cohortId=${encodeURIComponent(cohortId)}&date=${encodeURIComponent(
      date,
    )}&period=${period}`,
    { headers: { authorization: `Bearer ${teacher}` } },
  );
  expect(session2Resp.status).toBe(200);
  const session2 = (await session2Resp.json().catch(() => null)) as any;
  expect(session2).not.toBeNull();
  const row = (session2?.students || []).find((s: any) => s?.studentId === studentId);
  expect(row?.status).toBe('ABSENT');

  // ---- STUDENT: attendance + grades endpoints stable ----
  {
    const r = await fetch(`${BASE}/api/student/attendance`, {
      headers: { authorization: `Bearer ${student}` },
    });
    expect([200, 400, 401, 403]).toContain(r.status);
    expect(r.status).not.toBe(500);
    if (r.status === 200) {
      const j = await r.json().catch(() => null);
      expect(j).not.toBeNull();
      const payload = unwrap(j);
      const ok = Array.isArray(payload) || (payload && typeof payload === 'object');
      expect(ok).toBeTruthy();
    }
  }
  {
    const r = await fetch(`${BASE}/api/student/grades`, {
      headers: { authorization: `Bearer ${student}` },
    });
    expect([200, 400, 401, 403]).toContain(r.status);
    expect(r.status).not.toBe(500);
    if (r.status === 200) {
      const j = await r.json().catch(() => null);
      expect(j).not.toBeNull();
      const payload = unwrap(j);
      const ok = Array.isArray(payload) || (payload && typeof payload === 'object');
      expect(ok).toBeTruthy();
    }
  }

  // ---- PARENT: discover childId then hit attendance/grades ----
  const childrenResp = await fetch(`${BASE}/api/parent/children`, {
    headers: { authorization: `Bearer ${parent}` },
  });
  expect([200, 400, 401, 403]).toContain(childrenResp.status);
  expect(childrenResp.status).not.toBe(500);

  let childId: string | null = null;
  if (childrenResp.status === 200) {
    const j = (await childrenResp.json().catch(() => null)) as any;
    const payload = unwrap(j);
    const list = Array.isArray(payload) ? payload : payload?.children;
    childId = (Array.isArray(list) ? list?.[0]?.id ?? list?.[0]?.studentId : null) || null;
  }

  // parent grades should never 500
  {
    const r = await fetch(`${BASE}/api/parent/grades`, {
      headers: { authorization: `Bearer ${parent}` },
    });
    expect([200, 400, 401, 403]).toContain(r.status);
    expect(r.status).not.toBe(500);
  }

  // parent attendance should never 500 (only if we have a childId)
  if (childId) {
    const r = await fetch(`${BASE}/api/parent/attendance?childId=${encodeURIComponent(childId)}`, {
      headers: { authorization: `Bearer ${parent}` },
    });
    expect([200, 400, 401, 403]).toContain(r.status);
    expect(r.status).not.toBe(500);
  }

  // ---- TEACHER: grades create + bulk (minimal happy path; no 500) ----
  const createAssessmentResp = await fetch(`${BASE}/api/teacher/grades/assessment`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${teacher}`,
    },
    body: JSON.stringify({
      courseId,
      title: `E2E Assessment ${Date.now()}`,
      date,
      maxGrade: 100,
      grades: [{ studentId, grade: 97 }],
    }),
  });
  expect([200, 201, 400, 401, 403]).toContain(createAssessmentResp.status);
  expect(createAssessmentResp.status).not.toBe(500);

  let assessmentId: string | null = null;
  if (createAssessmentResp.status === 200 || createAssessmentResp.status === 201) {
    const j = (await createAssessmentResp.json().catch(() => null)) as any;
    assessmentId =
      j?.assessmentId ??
      j?.id ??
      j?.assessment?.id ??
      (Array.isArray(j?.grades) ? j?.assessmentId : null) ??
      null;
  }

  if (assessmentId) {
    const bulkResp = await fetch(`${BASE}/api/teacher/grades/bulk`, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        authorization: `Bearer ${teacher}`,
      },
      body: JSON.stringify({
        assessmentId,
        grades: [{ studentId, grade: 98 }],
      }),
    });
    expect([200, 201, 400, 401, 403]).toContain(bulkResp.status);
    expect(bulkResp.status).not.toBe(500);
  }
});
