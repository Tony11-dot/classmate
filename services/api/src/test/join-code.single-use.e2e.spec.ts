import request from 'supertest';
import { createTestApp } from './helpers/app';

describe('cohort join-code is single-use (e2e)', () => {
  it('second redemption fails', async () => {
    const t = await createTestApp();
    const http = request(t.app.getHttpServer());

        const seed = await http.post('/api/test/seed/admin-web').send({});
    expect([200,201]).toContain(seed.status);

    const cohortId = seed.body.cohortId;
    expect(cohortId).toBeTruthy();

    const teacherEmail =
      seed.body?.teacherEmail ??
      seed.body?.teacher?.email ??
      seed.body?.teacherUser?.email ??
      seed.body?.teacher_account?.email ??
      seed.body?.emailTeacher ??
      '';

    const teacherPassword =
      seed.body?.teacherPassword ??
      seed.body?.teacher?.password ??
      seed.body?.teacherUser?.password ??
      seed.body?.teacher_account?.password ??
      seed.body?.passwordTeacher ??
      seed.body?.password ??
      'Password123!';

    expect(teacherEmail).toBeTruthy();
    expect(teacherPassword).toBeTruthy();

    const tlogin = await http.post('/api/auth/login').send({
      email: teacherEmail,
      password: teacherPassword,
    });

    expect([200, 201]).toContain(tlogin.status);

    const tkn = tlogin.body?.accessToken ?? tlogin.body?.token;
    expect(tkn).toBeTruthy();
  



    // Generate join-code
    const jc = await http
          .post('/api/teacher/cohorts/join-code')
          .set('Authorization', `Bearer ${tkn}`)
          .send({ cohortId, expiresInHours: 24, length: 6 });
    
        expect([200, 201]).toContain(jc.status);
const joinCode = String(jc.body?.code ?? '').trim();
        expect(joinCode).toBeTruthy();
    
const jc = await http
      .post('/api/teacher/cohorts/join-code')
      .set('Authorization', `Bearer ${tkn}`)
      .send({ cohortId, expiresInHours: 24, length: 6 });

    expect([200, 201]).toContain(jc.status);

    const joinCode = String(jc.body?.code ?? '').trim();
    expect(joinCode).toBeTruthy();
// Register + login student
    const email1 = `student1+${Date.now()}@classmate.app`;

    await http.post('/api/auth/register').send({
      name: 'Student One',
      email: email1,
      password: 'Password123!',
    });

    const login1 = await http.post('/api/auth/login').send({
      email: email1,
      password: 'Password123!',
    });

    const token1 = login1.body?.accessToken ?? login1.body?.token;

    // Onboard FIRST time
    const first = await http.post('/api/student/onboard')
      .set('Authorization', `Bearer ${token1}`)
      .send({ cohortId, joinCode, englishLevel: 3, mathLevel: 3 });
    expect(first.status).toBe(201);

    // Second student attempt
    const email2 = `student2+${Date.now()}@classmate.app`;

    await http.post('/api/auth/register').send({
      name: 'Student Two',
      email: email2,
      password: 'Password123!',
    });

    const login2 = await http.post('/api/auth/login').send({
      email: email2,
      password: 'Password123!',
    });

    const token2 = login2.body?.accessToken ?? login2.body?.token;

    const second = await http.post('/api/student/onboard')
      .set('Authorization', `Bearer ${token2}`)
      .send({ cohortId, joinCode, englishLevel: 3, mathLevel: 3 });

    expect([400,401,403]).toContain(second.status);

    await t.close();
  });
});
