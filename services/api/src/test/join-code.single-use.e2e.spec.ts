import request from 'supertest';
import { Test } from '@nestjs/testing';
import { AppModule } from '../app.module';

describe('cohort join-code is single-use (e2e)', () => {
  let t: any;

  beforeAll(async () => {
    t = await Test.createTestingModule({ imports: [AppModule] }).compile();
    t.app = t.createNestApplication();
    await t.app.init();
  });

  afterAll(async () => {
    await t.app.close();
  });

  it('second redemption with same code (different student) fails', async () => {
    const http = request(t.app.getHttpServer());

    const seed = await http.post('/api/test/seed').send({});
    expect(seed.status).toBe(201);

    // admin login
    const adminLogin = await http
      .post('/api/auth/login')
      .send({ email: seed.body.adminEmail, password: seed.body.password });
    expect(adminLogin.status).toBe(201);
    const adminToken = adminLogin.body?.token;
    expect(adminToken).toBeTruthy();

    // create join code
    const jc = await http
      .post('/api/admin/cohorts/join-code')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ cohortId: seed.body.cohortId, expiresInHours: 24, length: 6 });
    expect(jc.status).toBe(201);
    const joinCode = String(jc.body?.code ?? jc.body?.joinCode ?? jc.body?.value ?? jc.body?.token ?? '');
    expect(joinCode).toBeTruthy();

    // Student1 register + login
    const firstEmail = `student1+${Date.now()}@classmate.app`;
    const reg1 = await http.post('/api/auth/register').send({
      name: 'Student One',
      email: firstEmail,
      password: seed.body.password,
    });
    expect([201, 409]).toContain(reg1.status);

    const login1 = await http
      .post('/api/auth/login')
      .send({ email: firstEmail, password: seed.body.password });
    expect(login1.status).toBe(201);
    const token1 = login1.body?.token;
    expect(token1).toBeTruthy();

    // First redemption should succeed
    const first = await http
      .post('/api/student/onboard')
      .set('Authorization', `Bearer ${token1}`)
      .send({
        cohortId: seed.body.cohortId,
        joinCode,
        englishLevel: 3,
        mathLevel: 3,
      });

    if (first.status !== 201) {
      // eslint-disable-next-line no-console
      console.log('JOIN1', first.status, first.body, first.text);
    }
    expect(first.status).toBe(201);

    // Student2 register + login
    const secondEmail = `student2+${Date.now()}@classmate.app`;
    const reg2 = await http.post('/api/auth/register').send({
      name: 'Student Two',
      email: secondEmail,
      password: seed.body.password,
    });
    expect([201, 409]).toContain(reg2.status);

    const login2 = await http
      .post('/api/auth/login')
      .send({ email: secondEmail, password: seed.body.password });
    expect(login2.status).toBe(201);
    const token2 = login2.body?.token;
    expect(token2).toBeTruthy();

    // Second redemption should fail (code is single-use)
    const second = await http
      .post('/api/student/onboard')
      .set('Authorization', `Bearer ${token2}`)
      .send({
        cohortId: seed.body.cohortId,
        joinCode,
        englishLevel: 3,
        mathLevel: 3,
      });

    expect([400, 401, 403]).toContain(second.status);
  });
});
