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
    const joinCode = jc.body?.code;
    expect(joinCode).toBeTruthy();

    // login as STUDENT (seeded) to onboard
    const studentLogin = await http
      .post('/api/auth/login')
      .send({ email: seed.body.studentEmail, password: seed.body.password });

    expect(studentLogin.status).toBe(201);
    const studentToken = studentLogin.body?.token;
    expect(studentToken).toBeTruthy();

    const first = await http
      .post('/api/student/onboard')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        cohortId: seed.body.cohortId,
        joinCode,
        englishLevel: 3,
        mathLevel: 3,
      });

    expect(first.status).toBe(201);

    // attempt to reuse same code for a DIFFERENT student
    const secondEmail = `student2+${Date.now()}@classmate.app`;
    const second = await http.post('/api/student/onboard').send({
      email: secondEmail,
      password: seed.body.password,
      cohortId: seed.body.cohortId,
      joinCode,
      englishLevel: 3,
      mathLevel: 3,
    });

    expect([400, 401, 403]).toContain(second.status);
  });
});
