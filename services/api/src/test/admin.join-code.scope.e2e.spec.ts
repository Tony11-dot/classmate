import { createTestApp } from './helpers/app';

describe('join-code scope (e2e)', () => {
  let app: any;
  let http: any;

  beforeAll(async () => {
    const t = await createTestApp();
    app = t.app;
    http = t.http;
  });

  afterAll(async () => {
    await app?.close?.();
  });

  it('TEACHER cannot generate join-code for foreign cohort', async () => {
    // seed
    const seed = await http.post('/api/test/seed/admin-web').send({});
    expect(seed.status).toBe(201);
    const { teacherEmail, password, cohortId } = seed.body;
    expect(teacherEmail).toBeTruthy();
    expect(password).toBeTruthy();
    expect(cohortId).toBeTruthy();

    // login teacher
    const login = await http.post('/api/auth/login').send({ email: teacherEmail, password });
    expect(login.status).toBe(201);
    const teacherToken = login.body?.token;
    expect(teacherToken).toBeTruthy();

    // create a different cohort via admin-seed (reuse seed endpoint to get an admin token by registering/logging in if available)
    // If no admin login helper exists, we just create cohort directly via prisma-backed seed assumption:
    // Use admin endpoint with the same teacher token should fail (403) anyway,
    // so instead we rely on deterministic behavior: a foreign cohort id will not have a course owned by this teacher.
    // We'll create a foreign cohort by calling seed again and taking its cohortId if it differs.
    const seed2 = await http.post('/api/test/seed/admin-web').send({});
    expect(seed2.status).toBe(201);
    const foreignCohortId = seed2.body?.cohortId;
    expect(foreignCohortId).toBeTruthy();

    // If seed is idempotent and returns same cohortId, force a bogus cohort id to simulate foreign scope.
    const targetCohortId =
      foreignCohortId !== cohortId ? foreignCohortId : '00000000-0000-0000-0000-000000000001';

    const res = await http
      .post('/api/admin/cohorts/join-code')
      .set('Authorization', `Bearer ${teacherToken}`)
      .send({ cohortId: targetCohortId, expiresInHours: 24, length: 6 });

    expect([400, 403]).toContain(res.status);
    if (res.status === 403) {
      expect(res.body?.message).toMatch(/Teacher not authorized|Admin/i);
    }
  });
});
