import request from 'supertest';
import { createTestApp } from './helpers/app';

describe('cohort join-code is single-use (e2e)', () => {
  it('e2e', async () => {
    const t = await createTestApp();
    const http = request(t.app.getHttpServer());


    const seed = await http.post('/api/test/seed/admin-web').send({});
    expect(seed.status).toBe(201);

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
    const rawJoinCode = jc.body?.code ?? jc.body?.joinCode ?? jc.body?.value ?? jc.body?.token ?? '';
    const joinCode = String(rawJoinCode).padStart(6, '0');
    expect(joinCode).toBeTruthy();
const firstEmail = `student1+${Date.now()}@classmate.app`;
    const reg1 = await http.post('/api/auth/register').send({
      name: 'Student One',
      email: firstEmail,
      password: seed.body.password,
    });
    expect([201, 409]).toContain(reg1.status);

    const login1 = await http
      .post('/api/auth/login')
      .send({ email: firstEmail, password: seed.body.password });
    expect(login1.status).toBe(201);
    const token1 = login1.body?.token;
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

    if (first.status !== 201) {
      // eslint-disable-next-line no-console
      console.log('JOIN1', first.status, first.body, first.text);
    }
    expect(first.status).toBe(201);

    const secondEmail = `student2+${Date.now()}@classmate.app`;
    const reg2 = await http.post('/api/auth/register').send({
      name: 'Student Two',
      email: secondEmail,
      password: seed.body.password,
    });
    expect([201, 409]).toContain(reg2.status);

    const login2 = await http
      .post('/api/auth/login')
      .send({ email: secondEmail, password: seed.body.password });
    expect(login2.status).toBe(201);
    const token2 = login2.body?.token;
    expect(token2).toBeTruthy();

    const second = await http
      .post('/api/student/onboard')
      .set('Authorization', `Bearer ${token2}`)
      .send({
        cohortId: seed.body.cohortId,
        joinCode,
        englishLevel: 3,
        mathLevel: 3,
      });

    expect([400, 401, 403]).toContain(second.status);

    await t.close();
  });
});
