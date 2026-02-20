import request from 'supertest';
import { createTestApp } from './helpers/app';

describe('join-code preserves leading zeros (e2e)', () => {
  it('onboard works with a leading-zero join code', async () => {
    const t = await createTestApp();
    const http = request(t.app.getHttpServer());

    try {
      const seed = await http.post('/api/test/seed/admin-web').send({});
      expect(seed.status).toBe(201);

      const cohortId = seed.body?.cohortId;
      const teacherEmail = seed.body?.teacherEmail;
      const teacherPassword = seed.body?.password;

      expect(cohortId).toBeTruthy();
      expect(teacherEmail).toBeTruthy();
      expect(teacherPassword).toBeTruthy();

      const tlogin = await http.post('/api/auth/login').send({
        email: teacherEmail,
        password: teacherPassword,
      });
      expect([200, 201]).toContain(tlogin.status);

      const teacherToken = tlogin.body?.token ?? tlogin.body?.accessToken;
      expect(teacherToken).toBeTruthy();

      let joinCode = '';
      for (let i = 0; i < 40; i++) {
        const jc = await http
          .post('/api/teacher/cohorts/join-code')
          .set('Authorization', `Bearer ${teacherToken}`)
          .send({ cohortId, expiresInHours: 24, length: 6 });

        expect(jc.status).toBe(201);

        joinCode = String(jc.body?.code ?? '').trim();
        expect(joinCode).toBeTruthy();

        if (joinCode.startsWith('0')) break;
      }

      expect(joinCode.startsWith('0')).toBe(true);

      const studentEmail = `student+${Date.now()}@classmate.app`;

      const sreg = await http.post('/api/auth/register').send({
        name: 'Student',
        email: studentEmail,
        password: 'Password123!',
      });
      expect([201, 409]).toContain(sreg.status);

      const slogin = await http.post('/api/auth/login').send({
        email: studentEmail,
        password: 'Password123!',
      });
      expect([200, 201]).toContain(slogin.status);

      const studentToken = slogin.body?.token ?? slogin.body?.accessToken;
      expect(studentToken).toBeTruthy();

      const onboard = await http
        .post('/api/student/onboard')
        .set('Authorization', `Bearer ${studentToken}`)
        .send({ cohortId, joinCode, englishLevel: 3, mathLevel: 3 });

      expect(onboard.status).toBe(201);
    } finally {
      await t.close();
    }
  });
});
