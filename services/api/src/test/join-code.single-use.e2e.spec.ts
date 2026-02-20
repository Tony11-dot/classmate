import request from 'supertest';
import { createTestApp } from './helpers/app';

describe('cohort join-code is single-use (e2e)', () => {
  it('e2e', async () => {
    const t = await createTestApp();
    const http = request(t.app.getHttpServer());

    const seed = await http.post('/api/test/seed/admin-web').send({});
    expect(seed.status).toBe(201);

    const adminEmail =
      seed.body?.adminEmail ??
      seed.body?.email ??
      seed.body?.admin?.email ??
      seed.body?.user?.email ??
      seed.body?.adminUser?.email ??
      '';

    const adminPassword =
      seed.body?.adminPassword ??
      seed.body?.password ??
      seed.body?.admin?.password ??
      seed.body?.adminUser?.password ??
      'Password123!';

    expect(adminEmail).toBeTruthy();
    expect(adminPassword).toBeTruthy();

    const alogin = await http.post('/api/auth/login').send({
      email: adminEmail,
      password: adminPassword,
    });
    expect([200, 201]).toContain(alogin.status);

    const adminToken = alogin.body?.accessToken ?? alogin.body?.token;
    expect(adminToken).toBeTruthy();const jc = await http
      .post('/api/admin/cohorts/join-code')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ cohortId: seed.body.cohortId, expiresInHours: 24, length: 6 });

    expect(jc.status).toBe(201);

    const joinCode = String(jc.body?.code ?? '').trim();
    expect(joinCode).toBeTruthy();

    const email1 = `student1+${Date.now()}@classmate.app`;
    const reg1 = await http.post('/api/auth/register').send({
      email: email1,
      password: 'Password123!',
    });
    expect(reg1.status).toBe(201);

    const token1 = reg1.body?.accessToken ?? reg1.body?.token;
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
      console.log('JOIN1', first.status, first.body, first.text, { joinCode });
    }
    expect(first.status).toBe(201);

    const email2 = `student2+${Date.now()}@classmate.app`;
    const reg2 = await http.post('/api/auth/register').send({
      email: email2,
      password: 'Password123!',
    });
    expect(reg2.status).toBe(201);

    const token2 = reg2.body?.accessToken ?? reg2.body?.token;
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
