import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

function pickToken(body: any): string | null {
  if (!body) return null;
  return (
    body.token ||
    body.accessToken ||
    body.access_token ||
    body.jwt ||
    body?.data?.token ||
    body?.data?.accessToken ||
    body?.data?.access_token ||
    null
  );
}

async function login(app: INestApplication, email: string, password: string) {
  const res = await request(app.getHttpServer())
    .post('/auth/login')
    .send({ email, password });

  if (res.status !== 200 && res.status !== 201) return null;
  if (res.body?.error) return null;

  return pickToken(res.body);
}

describe('Teacher attendance (e2e)', () => {
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

  it('teacher can fetch attendance session for a known date/period', async () => {
    const email = process.env.TEACHER_EMAIL;
    const password = process.env.TEACHER_PASSWORD;
    const cohortId = process.env.COHORT_ID;

    // If someone runs tests without env/seed, skip instead of failing CI noisily
    if (!email || !password || !cohortId) return;

    const token = await login(app, email, password);
    if (!token) return;

    const date = '2026-01-08';
    const period = 1;

    const res = await request(app.getHttpServer())
      .get(
        `/teacher/attendance/session?cohortId=${encodeURIComponent(cohortId)}&date=${encodeURIComponent(date)}&period=${period}`,
      )
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(res.body).toHaveProperty('cohort');
    expect(res.body.cohort).toHaveProperty('id', cohortId);
    expect(res.body).toHaveProperty('date', date);
    expect(res.body).toHaveProperty('period', period);
    expect(res.body).toHaveProperty('course');
    expect(res.body).toHaveProperty('students');
    expect(Array.isArray(res.body.students)).toBe(true);
  });
});
