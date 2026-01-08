import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
const request = require('supertest');
import { AppModule } from '../src/app.module';

describe('Schedule contract (e2e)', () => {
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

  function requireEnv(name: string) {
    const v = process.env[name];
    if (!v)
      throw new Error(
        `Missing env var ${name}. Export it or copy token setup from schedule.e2e-spec.ts`,
      );
    return v;
  }

  /**
   * IMPORTANT:
   * Your existing test/schedule.e2e-spec.ts already passes and likely has helpers
   * to obtain STUDENT_TOKEN / PARENT_TOKEN / ADMIN_TOKEN and a CHILD_ID / COHORT_ID.
   *
   * The best next move is:
   * 1) Copy the token setup from schedule.e2e-spec.ts into this file
   * 2) Remove `.skip` to enforce the contract permanently
   */

  it.skip('GET /schedule/today (student) -> { ok: true, date, dayOfWeek, slots[] }', async () => {
    const STUDENT_TOKEN = requireEnv('STUDENT_TOKEN');
    const res = await request(app.getHttpServer())
      .get('/schedule/today')
      .set('Authorization', `Bearer ${STUDENT_TOKEN}`)
      .expect(200);

    expect(res.body.ok).toBe(true);
    expect(typeof res.body.dayOfWeek).toBe('number');
    expect(typeof res.body.date).toBe('string');
    expect(Array.isArray(res.body.slots)).toBe(true);
  });

  it.skip('GET /schedule/week (student) -> week-grid shape', async () => {
    const STUDENT_TOKEN = requireEnv('STUDENT_TOKEN');
    const res = await request(app.getHttpServer())
      .get('/schedule/week')
      .set('Authorization', `Bearer ${STUDENT_TOKEN}`)
      .expect(200);

    expect(res.body.ok).toBe(true);
    expect(res.body.cohort?.id).toBeTruthy();
    expect(typeof res.body.maxPeriod).toBe('number');
    expect(Array.isArray(res.body.days)).toBe(true);
  });

  it('GET /schedule/week-grid (student) matches /schedule/week output shape', async () => {
    const STUDENT_TOKEN = requireEnv('STUDENT_TOKEN');
    const a = await request(app.getHttpServer())
      .get('/schedule/week')
      .set('Authorization', `Bearer ${STUDENT_TOKEN}`)
      .expect(200);

    const b = await request(app.getHttpServer())
      .get('/schedule/week-grid')
      .set('Authorization', `Bearer ${STUDENT_TOKEN}`)
      .expect(200);

    // Contract check: both endpoints should be the same shape and broadly equivalent
    expect(a.body.ok).toBe(true);
    expect(b.body.ok).toBe(true);
    expect(a.body.cohort?.id).toEqual(b.body.cohort?.id);
    expect(a.body.maxPeriod).toEqual(b.body.maxPeriod);
    expect(Array.isArray(a.body.days)).toBe(true);
    expect(Array.isArray(b.body.days)).toBe(true);
  });

  it.skip('GET /schedule/week-grid (parent) requires childId and APPROVED link', async () => {
    const PARENT_TOKEN = process.env.PARENT_TOKEN!;
    const CHILD_ID = process.env.CHILD_ID!;
    const res = await request(app.getHttpServer())
      .get(`/schedule/week-grid?childId=${CHILD_ID}`)
      .set('Authorization', `Bearer ${PARENT_TOKEN}`)
      .expect(200);

    expect(res.body.ok).toBe(true);
    expect(res.body.cohort?.id).toBeTruthy();
  });

  it.skip('GET /schedule/week-grid (admin) requires cohortId', async () => {
    const ADMIN_TOKEN = process.env.ADMIN_TOKEN!;
    const COHORT_ID = process.env.COHORT_ID!;
    const res = await request(app.getHttpServer())
      .get(`/schedule/week-grid?cohortId=${COHORT_ID}`)
      .set('Authorization', `Bearer ${ADMIN_TOKEN}`)
      .expect(200);

    expect(res.body.ok).toBe(true);
    expect(res.body.cohort?.id).toEqual(COHORT_ID); // (or remove if cohort.id != cohortId param in your model)
  });
});
