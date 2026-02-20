import request from 'supertest';
import { createTestApp } from './helpers/app';

describe('parent link upgrades role (e2e)', () => {
  it('e2e', async () => {
    const t = await createTestApp();
    const http = request(t.app.getHttpServer());

    const seed = await http.post('/api/test/seed/admin-web').send({});
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
