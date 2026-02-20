import request from 'supertest';
import { TestApp } from './utils/test-app';

describe('cohort join-code is single-use (e2e)', () => {
  it('e2e', async () => {
    const t = await TestApp.init();
    const http = request(t.app.getHttpServer());

    // seed admin + teacher + cohort
    const seed = await http.post('/api/test/seed/admin-web').send({});
    expect(seed.status).toBe(201);

    const adminToken = seed.body?.adminToken;
    expect(adminToken).toBeTruthy();

    // generate join code
    const jc = await http
      .post('/api/admin/cohorts/join-code')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ cohortId: seed.body.cohortId, expiresInHours: 24, length: 6 });

    expect(jc.status).toBe(201);

    const joinCode = String(jc.body?.code ?? '').trim();
    expect(joinCode).toBeTruthy();

    // first student
    const email1 = `student1+${Date.now()}@classmate.app`;
    const reg1 = await http.post('/api/auth/register').send({
      email: email1,
      password: 'Password123!',
    });
    expect(reg1.status).toBe(201);

    const token1 = reg1.body?.accessToken;
    expect(token1).toBeTruthy();

    const first = await http
      .post('/api/student/onboard')
      .set('Authorization', `Bearer ${token1}`)
      .send({
        cohortId: seed.body.cohortId,
        joinCode,
        englishLevel: 3,
        mathLevel: 3,
      });

    expect(first.status).toBe(201);

    // second student (same code should fail)
    const email2 = `student2+${Date.now()}@classmate.app`;
    const reg2 = await http.post('/api/auth/register').send({
      email: email2,
      password: 'Password123!',
    });
    expect(reg2.status).toBe(201);

    const token2 = reg2.body?.accessToken;

    const second = await http
      .post('/api/student/onboard')
      .set('Authorization', `Bearer ${token2}`)
      .send({
        cohortId: seed.body.cohortId,
        joinCode,
        englishLevel: 3,
        mathLevel: 3,
      });

    expect(second.status).toBe(400);

    await t.close();
  });
});
