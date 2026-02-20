import request from 'supertest';
import { TestApp } from './utils/test-app';

describe('parent link upgrades role (e2e)', () => {
  it('e2e', async () => {
    const t = await TestApp.init();
    const http = request(t.app.getHttpServer());

    // seed
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

    // student register
    const email = `student+${Date.now()}@classmate.app`;
    const reg = await http.post('/api/auth/register').send({
      email,
      password: 'Password123!',
    });
    expect(reg.status).toBe(201);

    const studentToken = reg.body?.accessToken;
    expect(studentToken).toBeTruthy();

    // onboard
    const onboard = await http
      .post('/api/student/onboard')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        cohortId: seed.body.cohortId,
        joinCode,
        englishLevel: 3,
        mathLevel: 3,
      });

    expect(onboard.status).toBe(201);

    // generate parent link code
    const plc = await http
      .post('/api/student/parent-link-code')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({});

    expect(plc.status).toBe(201);

    const parentCode = plc.body?.code;
    expect(parentCode).toBeTruthy();

    // parent register
    const parentEmail = `parent+${Date.now()}@classmate.app`;
    const preg = await http.post('/api/auth/register').send({
      email: parentEmail,
      password: 'Password123!',
    });
    expect(preg.status).toBe(201);

    const parentToken = preg.body?.accessToken;

    // parent link
    const link = await http
      .post('/api/parent/link')
      .set('Authorization', `Bearer ${parentToken}`)
      .send({ code: parentCode });

    expect(link.status).toBe(201);

    // login again to verify role
    const plogin = await http.post('/api/auth/login').send({
      email: parentEmail,
      password: 'Password123!',
    });

    expect(plogin.status).toBe(201);

    const roles = plogin.body?.user?.roles ?? [];
    expect(Array.isArray(roles)).toBe(true);
    expect(roles).toContain('PARENT');

    await t.close();
  });
});
