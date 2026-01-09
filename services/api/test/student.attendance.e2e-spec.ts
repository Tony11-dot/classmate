import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { AppModule } from '../src/app.module';

async function login(app: INestApplication, email: string, password: string) {
  const res = await request(app.getHttpServer())
    .post('/auth/login')
    .send({ email, password })
    .expect(201);

  expect(res.body).toHaveProperty('token');
  return res.body.token as string;
}

describe('Student attendance (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleRef.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('student can fetch own attendance', async () => {
    const token = await login(app, 'student1@classmate.app', 'dev');

    const res = await request(app.getHttpServer())
      .get('/student/attendance')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(res.body).toHaveProperty('ok', true);
    expect(res.body).toHaveProperty('student');
    expect(res.body).toHaveProperty('cohort');
    expect(Array.isArray(res.body.items)).toBe(true);
  });
});
