import request from 'supertest';
import { createTestApp } from './helpers/app';

describe('parent link upgrades role (e2e)', () => {
  let app: any;
  let http: any;

  beforeAll(async () => {
    const t = await createTestApp();
    app = t.app;
    http = t.http;
  });

  afterAll(async () => {
    await app?.close?.();
  });

it('link sets PARENT role so next login has PARENT', async () => {
    // seed admin-web (returns teacherEmail+password+cohortId etc)
    const seed = await http
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
    const tLogin = await http
      .post('/api/auth/login')
      .send({ email: teacherEmail, password })
      .expect(201);

    const teacherToken = tLogin.body?.token;
    expect(teacherToken).toBeTruthy();

    // create join code

    // student register + login + onboard + generate parent link code
    const stuEmail = `student_${Date.now()}@classmate.app`;

    await http
      .post('/api/auth/register')
      .send({ email: stuEmail, name: 'Student', password: 'DevPass123!' })
      .expect(201);

    const sLogin = await http
      .post('/api/auth/login')
      .send({ email: stuEmail, password: 'DevPass123!' })
      .expect(201);

    const studentToken = sLogin.body?.token;
    expect(studentToken).toBeTruthy();

    const jc = await http
      .post('/api/admin/cohorts/join-code')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ cohortId: seed.body.cohortId, expiresInHours: 24, length: 6 });

    expect(jc.status).toBe(201);
    joinCode = String(jc.body?.code ?? jc.body?.joinCode ?? jc.body?.value ?? jc.body?.token ?? '');
    expect(joinCode).toBeTruthy();

const onboard = await http
      .post('/api/student/onboard')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ cohortId: seed.body.cohortId, joinCode, englishLevel: 3, mathLevel: 3 });

    if (onboard.status !== 201) {
      // eslint-disable-next-line no-console
      console.log('ONBOARD', onboard.status, onboard.body, onboard.text);
    }

    expect(onboard.status).toBe(201);

    const plc = await http
      .post('/api/student/parent-link-code')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ expiresInHours: 24, length: 6 })
      .expect(201);

    const code = plc.body?.code;
    expect(code).toBeTruthy();

    // parent register + login (starts as STUDENT)
    const parentEmail = `parent_${Date.now()}@classmate.app`;

    await http
      .post('/api/auth/register')
      .send({ email: parentEmail, name: 'Parent', password: 'DevPass123!' })
      .expect(201);

    const pLogin1 = await http
      .post('/api/auth/login')
      .send({ email: parentEmail, password: 'DevPass123!' })
      .expect(201);

    const parentToken1 = pLogin1.body?.token;
    expect(parentToken1).toBeTruthy();

    // link using ONLY code
    await http
      .post('/api/parent/link')
      .set('Authorization', `Bearer ${parentToken1}`)
      .send({ code })
      .expect(201);

    // login again -> token should include PARENT
    const pLogin2 = await http
      .post('/api/auth/login')
      .send({ email: parentEmail, password: 'DevPass123!' })
      .expect(201);

    const payload = JSON.parse(
      Buffer.from(pLogin2.body.token.split('.')[1], 'base64').toString('utf8'),
    );

    expect(payload.roles).toContain('PARENT');
  });
});
