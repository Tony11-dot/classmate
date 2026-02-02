import request from 'supertest';

const BASE = process.env.E2E_API_BASE_URL ?? 'http://localhost:3000';

describe('parent link upgrades role (e2e)', () => {
  it('link sets PARENT role so next login has PARENT', async () => {
    // seed admin-web (returns teacherEmail+password+cohortId etc)
    const seed = await request(BASE)
      .post('/api/test/seed/admin-web')
      .send({})
      .expect(201);

    const teacherEmail = seed.body?.teacherEmail;
    const password = seed.body?.password;
    const cohortId = seed.body?.cohortId;

    expect(teacherEmail).toBeTruthy();
    expect(password).toBeTruthy();
    expect(cohortId).toBeTruthy();

    // teacher login
    const tLogin = await request(BASE)
      .post('/api/auth/login')
      .send({ email: teacherEmail, password })
      .expect(201);

    const teacherToken = tLogin.body?.token;
    expect(teacherToken).toBeTruthy();

    // create join code
    const jc = await request(BASE)
      .post('/api/admin/cohorts/join-code')
      .set('Authorization', `Bearer ${teacherToken}`)
      .send({ cohortId, expiresInHours: 24, length: 6 })
      .expect(201);

    const joinCode = jc.body?.code;
    expect(joinCode).toBeTruthy();

    // student register + login + onboard + generate parent link code
    const stuEmail = `student_${Date.now()}@classmate.app`;

    await request(BASE)
      .post('/api/auth/register')
      .send({ email: stuEmail, name: 'Student', password: 'dev' })
      .expect(201);

    const sLogin = await request(BASE)
      .post('/api/auth/login')
      .send({ email: stuEmail, password: 'dev' })
      .expect(201);

    const studentToken = sLogin.body?.token;
    expect(studentToken).toBeTruthy();

    await request(BASE)
      .post('/api/student/onboard')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ cohortId, joinCode, englishLevel: 3, mathLevel: 3 })
      .expect(201);

    const plc = await request(BASE)
      .post('/api/student/parent-link-code')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ expiresInHours: 24, length: 6 })
      .expect(201);

    const code = plc.body?.code;
    expect(code).toBeTruthy();

    // parent register + login (starts as STUDENT)
    const parentEmail = `parent_${Date.now()}@classmate.app`;

    await request(BASE)
      .post('/api/auth/register')
      .send({ email: parentEmail, name: 'Parent', password: 'dev' })
      .expect(201);

    const pLogin1 = await request(BASE)
      .post('/api/auth/login')
      .send({ email: parentEmail, password: 'dev' })
      .expect(201);

    const parentToken1 = pLogin1.body?.token;
    expect(parentToken1).toBeTruthy();

    // link using ONLY code
    await request(BASE)
      .post('/api/parent/link')
      .set('Authorization', `Bearer ${parentToken1}`)
      .send({ code })
      .expect(201);

    // login again -> token should include PARENT
    const pLogin2 = await request(BASE)
      .post('/api/auth/login')
      .send({ email: parentEmail, password: 'dev' })
      .expect(201);

    const payload = JSON.parse(
      Buffer.from(pLogin2.body.token.split('.')[1], 'base64').toString('utf8'),
    );

    expect(payload.roles).toContain('PARENT');
  });
});
