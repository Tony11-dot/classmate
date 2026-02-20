import request from 'supertest';
import { createTestApp } from './helpers/app';

describe('parent link upgrades role (e2e)', () => {
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
    
    // create join code via ADMIN (no padStart)
    const jc = await http
      .post('/api/admin/cohorts/join-code')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ cohortId: seed.body.cohortId, expiresInHours: 24, length: 6 });

    expect(jc.status).toBe(201);

    const rawJoinCode = jc.body?.code ?? jc.body?.joinCode ?? jc.body?.value ?? jc.body?.token ?? '';
    const joinCode = String(rawJoinCode).padStart(6, '0');
    expect(joinCode).toBeTruthy();
// small delay to avoid rate-limit between tests
    await new Promise(r => setTimeout(r, 50));

const email = `student+${Date.now()}@classmate.app`;
    const reg = await http.post('/api/auth/register').send({
      name: 'Student One',
      email,
      password: seed.body.password,
    });
    expect([201, 409]).toContain(reg.status);

    const login = await http
      .post('/api/auth/login')
      .send({ email, password: seed.body.password });
    expect(login.status).toBe(201);
    const studentToken = login.body?.token;
    expect(studentToken).toBeTruthy();

    const onboard = await http
      .post('/api/student/onboard')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        cohortId: seed.body.cohortId,
        joinCode,
        englishLevel: 3,
        mathLevel: 3,
      });

    if (onboard.status !== 201) {
      // eslint-disable-next-line no-console
      console.log('ONBOARD', onboard.status, onboard.body, onboard.text);
    }
    expect(onboard.status).toBe(201);

    const plc = await http
      .post('/api/student/parent-link-code')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ expiresInHours: 24, length: 6 });

    expect(plc.status).toBe(201);
    const parentCode = plc.body?.code;
    expect(parentCode).toBeTruthy();

    const parentEmail = `parent+${Date.now()}@classmate.app`;
    const preg = await http.post('/api/auth/register').send({
      name: 'Parent One',
      email: parentEmail,
      password: seed.body.password,
    });
    expect([201, 409]).toContain(preg.status);

    const plogin = await http
      .post('/api/auth/login')
      .send({ email: parentEmail, password: seed.body.password });
    expect(plogin.status).toBe(201);
    const parentToken = plogin.body?.token;
    expect(parentToken).toBeTruthy();

    const link = await http
      .post('/api/parent/link')
      .set('Authorization', `Bearer ${parentToken}`)
      .send({ code: parentCode });

    expect([200, 201]).toContain(link.status);

    const plogin2 = await http
      .post('/api/auth/login')
      .send({ email: parentEmail, password: seed.body.password });
    expect(plogin2.status).toBe(201);
    const roles = plogin2.body?.user?.roles ?? plogin2.body?.roles ?? [];
    expect(Array.isArray(roles)).toBe(true);
    expect(roles).toContain('PARENT');

    await t.close();
  });
});
