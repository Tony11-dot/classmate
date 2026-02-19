import request from 'supertest';
import { createTestApp } from './helpers/app';

describe('teacher join-code route (e2e)', () => {
  it('TEACHER can generate join-code via /teacher route (scoped)', async () => {
    const t = await createTestApp();
    const http = request(t.app.getHttpServer());

    const seed = await http.post('/api/test/seed/admin-web').send({});
    expect(seed.status).toBe(201);
    const cohortId = seed.body?.cohortId;

    const login = await http
      .post('/api/auth/login')
      .send({ email: seed.body.teacherEmail, password: seed.body.password });

    expect(login.status).toBe(201);
    const teacherToken = login.body?.token;
    expect(teacherToken).toBeTruthy();

    const jc = await http
      .post('/api/teacher/cohorts/join-code')
      .set('Authorization', `Bearer ${teacherToken}`)
      .send({ cohortId, expiresInHours: 24, length: 6 });

    expect(jc.status).toBe(201);
    expect(jc.body?.code).toBeTruthy();
  });
});
