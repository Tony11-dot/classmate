import request from 'supertest';
import { createTestApp } from './helpers/app';

describe('admin join-code legacy route headers (e2e)', () => {
  it('returns Deprecation/Sunset/Link headers', async () => {
    const t = await createTestApp();
    const http = request(t.app.getHttpServer());

    const seed = await http.post('/api/test/seed/admin-web').send({});
    expect(seed.status).toBe(201);

    const login = await http
      .post('/api/auth/login')
      .send({ email: seed.body.adminEmail, password: seed.body.password });

    expect(login.status).toBe(201);
    const token = login.body?.token;
    expect(token).toBeTruthy();

    const res = await http
      .post('/api/admin/cohorts/join-code')
      .set('Authorization', `Bearer ${token}`)
      .send({ cohortId: seed.body.cohortId, expiresInHours: 24, length: 6 });

    expect(res.status).toBe(201);

    const dep = res.header['deprecation'];
    const sunset = res.header['sunset'];
    const link = res.header['link'];

    expect(dep).toBe('true');
    expect(sunset).toBe('2026-03-31');
    expect(typeof link).toBe('string');
    expect(link).toContain('/api/teacher/cohorts/join-code');
    expect(link).toContain('rel="successor-version"');
  });
});
