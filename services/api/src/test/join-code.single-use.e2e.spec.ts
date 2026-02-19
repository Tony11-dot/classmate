import request from 'supertest';
import { createTestApp } from './helpers/app';

describe('cohort join-code is single-use (e2e)', () => {
  it('second redemption with same code (different student) fails', async () => {
    const t = await createTestApp();
    const http = request(t.app.getHttpServer());

    const seed = await http.post('/api/test/seed/admin-web').send({});
    expect(seed.status).toBe(201);

    // login as ADMIN to create join-code
    const adminLogin = await http
      .post('/api/auth/login')
      .send({ email: seed.body.adminEmail, password: seed.body.password });

    expect(adminLogin.status).toBe(201);
    const adminToken = adminLogin.body?.token;
    expect(adminToken).toBeTruthy();

    const jc = await http
      .post('/api/admin/cohorts/join-code')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ cohortId: seed.body.cohortId, expiresInHours: 24, length: 6 });

    expect(jc.status).toBe(201);

    const joinCode = String(
      (jc.body && (jc.body.code ?? jc.body.joinCode ?? jc.body.value ?? jc.body.token)) ??
        '',
    );
    expect(joinCode).toBeTruthy();

    // First redemption: onboard a fresh student (public flow)
    const firstEmail = `student1+${Date.now()}@classmate.app`;
    const first = await http.post('/api/student/onboard').send({
      email: firstEmail,
      password: seed.body.password,
      cohortId: seed.body.cohortId,
      joinCode,
      code: joinCode,
      englishLevel: 3,
      mathLevel: 3,
    });

    if (first.status !== 201) {
      // eslint-disable-next-line no-console
      console.log('JOIN1', first.status, first.body, first.text);
    }
    expect(first.status).toBe(201);

    // attempt to reuse same code for a DIFFERENT student
    const secondEmail = `student2+${Date.now()}@classmate.app`;
    const second = await http.post('/api/student/onboard').send({
      email: secondEmail,
      password: seed.body.password,
      cohortId: seed.body.cohortId,
      joinCode,
      code: joinCode,
      englishLevel: 3,
      mathLevel: 3,
    });

    expect([400, 401, 403]).toContain(second.status);
  });
});
