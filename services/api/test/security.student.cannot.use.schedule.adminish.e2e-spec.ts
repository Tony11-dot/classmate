import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { AppModule } from '../src/app.module';

async function login(app: INestApplication, email: string, password: string) {
  const res = await request(app.getHttpServer())
    .post('/auth/login')
    .send({ email, password })
    .expect(201);
  return res.body.token as string;
}

describe('security: student cannot call /schedule with cohortId (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = moduleRef.createNestApplication();
    await app.init();

    await request(app.getHttpServer()).post('/test/seed/admin-web').expect(201);
  });

  afterAll(async () => {
    await app.close();
  });

  it('student GET /api/student/schedule/today?cohortId=... -> 403/400 (not allowed)', async () => {
    const token = await login(app, 'student1@classmate.app', 'dev');

    const res = await request(app.getHttpServer())
      .get('/api/student/schedule/today?cohortId=bogus')
      .set('Authorization', `Bearer ${token}`);

    expect([400, 403, 404]).toContain(res.status);
  });

  it('student GET /api/student/schedule/week?cohortId=... -> 403/400 (not allowed)', async () => {
    const token = await login(app, 'student1@classmate.app', 'dev');

    const res = await request(app.getHttpServer())
      .get('/api/student/schedule/week?cohortId=bogus')
      .set('Authorization', `Bearer ${token}`);

    expect([400, 403, 404]).toContain(res.status);
  });
});
