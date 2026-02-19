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
    expect(adminToken).toBeTruthy();    const jc = await http
      .post('/api/admin/cohorts/join-code')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ cohortId: seed.body.cohortId, expiresInHours: 24, length: 6 });

    expect(jc.status).toBe(201);

    const joinCode = String((jc.body && (jc.body.code ?? jc.body.joinCode ?? jc.body.value ?? jc.body.token)) ?? '');
    expect(joinCode).toBeTruthy();

    // First redemption: use SEEDED student token (seed owns canonical onboarding fixtures)
    const studentLogin = await http
      .post('/api/auth/login')
      .send({ email: seed.body.studentEmail, password: seed.body.password });

    expect(studentLogin.status).toBe(201);
    const token1 = studentLogin.body?.token;
    expect(token1).toBeTruthy();

    const first = await http
      .post('/api/student/onboard')
      .set('Authorization', `Bearer ${token1}`)
      .send({ cohortId: seed.body.cohortId, joinCode, englishLevel: 3, mathLevel: 3 });

    if (first.status !== 201) {
      // eslint-disable-next-line no-console
      console.log('JOIN1', first.status, first.body, first.text);
    }
    expect(first.status).toBe(201);

    // Second redemption: different student, same code should fail
    const secondEmail = `student2+${Date.now()}@classmate.app`;

    const reg2 = await http.post('/api/auth/register').send({
      name: 'Student Two',
      email: secondEmail,
      password: seed.body.password,
      });
    if (![201, 409].includes(reg2.status)) {
      // eslint-disable-next-line no-console
      console.log('REG2', reg2.status, reg2.body, reg2.text);
    }
    expect([201, 409]).toContain(reg2.status);

    const login2 = await http
      .post('/api/auth/login')
      .send({ email: secondEmail, password: seed.body.password });

    if (login2.status !== 201) {
      // eslint-disable-next-line no-console
      console.log('LOGIN2', login2.status, login2.body, login2.text);
    }
    expect(login2.status).toBe(201);
    const token2 = login2.body?.token;
    expect(token2).toBeTruthy();

    const second = await http
      .post('/api/student/onboard')
      .set('Authorization', `Bearer ${token2}`)
      .send({ cohortId: seed.body.cohortId, joinCode, englishLevel: 3, mathLevel: 3 });

    expect([400, 401, 403]).toContain(second.status);
  });
});
