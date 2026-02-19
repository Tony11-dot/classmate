import request from 'supertest';
import { Test } from '@nestjs/testing';
import { AppModule } from '../app.module';

describe('parent link upgrades role (e2e)', () => {
  let t: any;

  beforeAll(async () => {
    t = await Test.createTestingModule({ imports: [AppModule] }).compile();
    t.app = t.createNestApplication();
    await t.app.init();
  });

  afterAll(async () => {
    await t.app.close();
  });

  it('link sets PARENT role so next login has PARENT', async () => {
    const http = request(t.app.getHttpServer());

    // seed fixtures (adminEmail/password/cohortId)
    const seed = await http.post('/api/test/seed/admin-web').send({});
    expect(seed.status).toBe(201);
        // admin login
    const adminLogin = await http
      .post('/api/auth/login')
      .send({ email: seed.body.adminEmail, password: seed.body.password });
    expect(adminLogin.status).toBe(201);
    const adminToken = adminLogin.body?.token;
    expect(adminToken).toBeTruthy();

    // create a join code for seeded cohort
    const jc = await http
      .post('/api/admin/cohorts/join-code')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ cohortId: seed.body.cohortId, expiresInHours: 24, length: 6 });
    expect(jc.status).toBe(201);
    const joinCode = String(jc.body?.code ?? jc.body?.joinCode ?? jc.body?.value ?? jc.body?.token ?? '');
    expect(joinCode).toBeTruthy();

    // register + login student
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

    // onboard with joinCode
    const onboard = await http
      .post('/api/student/onboard')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ cohortId: seed.body.cohortId, joinCode, englishLevel: 3, mathLevel: 3 });

    if (onboard.status != 201) {
      // eslint-disable-next-line no-console
      console.log('ONBOARD', onboard.status, onboard.body, onboard.text);
    }
    expect(onboard.status).toBe(201);

    // request parent-link code
    const plc = await http
      .post('/api/student/parent-link-code')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ expiresInHours: 24, length: 6 });

    expect(plc.status).toBe(201);
    const parentCode = plc.body?.code;
    expect(parentCode).toBeTruthy();

    // register + login parent
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

    // link parent to child (endpoint name may differ; keep existing one in repo)
    const link = await http
      .post('/api/parent/link')
      .set('Authorization', `Bearer ${parentToken}`)
      .send({ code: parentCode });

    expect([200, 201]).toContain(link.status);

    // next login should include PARENT role
    const plogin2 = await http
      .post('/api/auth/login')
      .send({ email: parentEmail, password: seed.body.password });
    expect(plogin2.status).toBe(201);
    const roles = plogin2.body?.user?.roles ?? plogin2.body?.roles ?? [];
    expect(Array.isArray(roles)).toBe(true);
    expect(roles).toContain('PARENT');
  });
});
