import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
const request = require('supertest');
import { AppModule } from '../src/app.module';

const env = (k: string) => process.env[k] ?? '';

describe('Schedule (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  const getAuth = (token: string) => ({
    Authorization: `Bearer ${token}`,
  });

  const shouldRun = (keys: string[]) => keys.every((k) => !!env(k));

  it('student: /schedule/week returns week-grid shape (no cohortId needed)', async () => {
    if (!shouldRun(['STUDENT_TOKEN'])) return;

    const res = await request(app.getHttpServer())
      .get('/schedule/week')
      .set(getAuth(env('STUDENT_TOKEN')))
      .expect(200);

    expect(res.body).toHaveProperty('ok', true);
    expect(res.body).toHaveProperty('cohort');
    expect(res.body.cohort).toHaveProperty('id');
    expect(res.body).toHaveProperty('days');
    expect(Array.isArray(res.body.days)).toBe(true);
  });

  it('student: /schedule/week and /schedule/week-grid are identical (alias)', async () => {
    if (!shouldRun(['STUDENT_TOKEN'])) return;

    const [a, b] = await Promise.all([
      request(app.getHttpServer())
        .get('/schedule/week')
        .set(getAuth(env('STUDENT_TOKEN')))
        .expect(200),
      request(app.getHttpServer())
        .get('/schedule/week-grid')
        .set(getAuth(env('STUDENT_TOKEN')))
        .expect(200),
    ]);

    expect(a.body).toEqual(b.body);
  });

  it('parent: /schedule/week requires childId and returns week-grid shape', async () => {
    if (!shouldRun(['PARENT_TOKEN', 'CHILD_ID'])) return;

    const res = await request(app.getHttpServer())
      .get(`/schedule/week?childId=${encodeURIComponent(env('CHILD_ID'))}`)
      .set(getAuth(env('PARENT_TOKEN')))
      .expect(200);

    expect(res.body).toHaveProperty('ok', true);
    expect(res.body).toHaveProperty('cohort');
    expect(res.body).toHaveProperty('days');
  });

  it('admin: /schedule/week requires cohortId and returns week-grid shape', async () => {
    if (!shouldRun(['ADMIN_TOKEN', 'COHORT_ID'])) return;

    const res = await request(app.getHttpServer())
      .get(`/schedule/week?cohortId=${encodeURIComponent(env('COHORT_ID'))}`)
      .set(getAuth(env('ADMIN_TOKEN')))
      .expect(200);

    expect(res.body).toHaveProperty('ok', true);
    expect(res.body).toHaveProperty('cohort');
    expect(res.body.cohort).toHaveProperty('id', env('COHORT_ID'));
  });

  it('parent: missing childId => 400', async () => {
    if (!shouldRun(['PARENT_TOKEN'])) return;

    await request(app.getHttpServer())
      .get('/schedule/week')
      .set(getAuth(env('PARENT_TOKEN')))
      .expect(400);
  });

  it('admin: missing cohortId => 400', async () => {
    if (!shouldRun(['ADMIN_TOKEN'])) return;

    await request(app.getHttpServer())
      .get('/schedule/week')
      .set(getAuth(env('ADMIN_TOKEN')))
      .expect(400);
  });
});
