import request from 'supertest';
import { createTestApp } from './helpers/app';

describe('parent link upgrades role (e2e)', () => {
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

    const studentEmail = `student+${Date.now()}@classmate.app`;
    const reg = await http.post('/api/auth/register').send({
      name: 'Student One',
      email,
      password: 'Password123!',
    });
    expect([201, 409]).toContain(reg.status);

    const slogin = await http.post('/api/auth/login').send({
      email,
      password: 'Password123!',
    });
    expect([200, 201]).toContain(slogin.status);
    const studentToken = slogin.body?.accessToken ?? slogin.body?.token;
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
      console.log('ONBOARD', onboard.status, onboard.body, onboard.text, { joinCode });
    }
    expect(onboard.status).toBe(201);

    const plc = await http
      .post('/api/student/parent-link-code')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({});

    expect(plc.status).toBe(201);

    const parentCode = plc.body?.code;
    expect(parentCode).toBeTruthy();

    const parentEmail = `parent+${Date.now()}@classmate.app`;
    const preg = await http.post('/api/auth/register').send({
      name: 'Parent One',
      email: parentEmail,
      password: 'Password123!',
    });
    expect([201, 409]).toContain(preg.status);

    const plogin0 = await http.post('/api/auth/login').send({
      email: parentEmail,
      password: 'Password123!',
    });
    expect([200, 201]).toContain(plogin0.status);
    const parentToken = plogin0.body?.accessToken ?? plogin0.body?.token;
    expect(parentToken).toBeTruthy();

const link = await http
      .post('/api/parent/link')
      .set('Authorization', `Bearer ${parentToken}`)
      .send({ code: parentCode });

    expect([200, 201]).toContain(link.status);

    const plogin = await http.post('/api/auth/login').send({
      email: parentEmail,
      password: 'Password123!',
    });

    expect(plogin.status).toBe(201);

    const roles = plogin.body?.user?.roles ?? plogin.body?.roles ?? [];
    expect(Array.isArray(roles)).toBe(true);
    expect(roles).toContain('PARENT');

    await t.close();
  });
});
