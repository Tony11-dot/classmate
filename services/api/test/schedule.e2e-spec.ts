import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { AppModule } from '../src/app.module';

const request = require('supertest');

describe('Schedule (e2e)', () => {
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

  function pickToken(body: any) {
    return (
      body?.access_token ||
      body?.accessToken ||
      body?.token ||
      body?.jwt ||
      body?.data?.access_token ||
      body?.data?.accessToken
    );
  }

  async function getToken(kind: 'STUDENT' | 'PARENT' | 'ADMIN') {
    const direct = process.env[`${kind}_TOKEN`];
    if (direct && !direct.startsWith('PASTE_')) return direct;

    const email = process.env[`${kind}_EMAIL`];
    const password = process.env[`${kind}_PASSWORD`];
    if (!email || !password) return null;

    const res = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email, password });

    // tolerate various login behaviors
    if (res.status !== 200 && res.status !== 201) return null;
    if (res.body?.error) return null;

    const token = pickToken(res.body);
    if (!token) return null;

    return token;
  }

  it('student: /schedule/week returns week-grid shape (no cohortId needed)', async () => {
    const token =
      (await getToken('STUDENT')) || process.env.STUDENT_TOKEN || null;
    if (!token) return;

    const res = await request(app.getHttpServer())
      .get('/schedule/week')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(res.body).toHaveProperty('ok', true);
    expect(res.body).toHaveProperty('cohort');
    expect(res.body).toHaveProperty('days');
    expect(Array.isArray(res.body.days)).toBe(true);
  });

  it('student: /schedule/week and /schedule/week-grid are identical (alias)', async () => {
    const token =
      (await getToken('STUDENT')) || process.env.STUDENT_TOKEN || null;
    if (!token) return;

    const [a, b] = await Promise.all([
      request(app.getHttpServer())
        .get('/schedule/week')
        .set('Authorization', `Bearer ${token}`)
        .expect(200),
      request(app.getHttpServer())
        .get('/schedule/week-grid')
        .set('Authorization', `Bearer ${token}`)
        .expect(200),
    ]);

    expect(a.body.ok).toBe(true);
    expect(b.body.ok).toBe(true);
    expect(a.body.cohort?.id).toEqual(b.body.cohort?.id);
    expect(a.body.maxPeriod).toEqual(b.body.maxPeriod);
    expect(JSON.stringify(a.body.days)).toEqual(JSON.stringify(b.body.days));
  });

  it('parent: /schedule/week requires childId and returns week-grid shape', async () => {
    const token = await getToken('PARENT');
    const childId = process.env.CHILD_ID || null;
    if (!token || !childId) return;

    const res = await request(app.getHttpServer())
      .get(`/schedule/week?childId=${encodeURIComponent(childId)}`)
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(res.body).toHaveProperty('ok', true);
    expect(res.body).toHaveProperty('cohort');
  });

  it('admin: /schedule/week requires cohortId and returns week-grid shape', async () => {
    const token = await getToken('ADMIN');
    const cohortId = process.env.COHORT_ID || null;
    if (!token || !cohortId) return;

    const res = await request(app.getHttpServer())
      .get(`/schedule/week?cohortId=${encodeURIComponent(cohortId)}`)
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(res.body).toHaveProperty('ok', true);
    expect(res.body).toHaveProperty('cohort');
  });

  it('parent: missing childId => 400 (when authenticated)', async () => {
    const token = await getToken('PARENT');
    if (!token) return;

    await request(app.getHttpServer())
      .get('/schedule/week')
      .set('Authorization', `Bearer ${token}`)
      .expect(400);
  });

  it('admin: missing cohortId => 400 (when authenticated)', async () => {
    const token = await getToken('ADMIN');
    if (!token) return;

    await request(app.getHttpServer())
      .get('/schedule/week')
      .set('Authorization', `Bearer ${token}`)
      .expect(400);
  });
  it('student: /schedule/today returns ok + day payload', async () => {
    const token = await getToken('STUDENT');
    if (!token) return;

    const res = await request(app.getHttpServer())
      .get('/schedule/today')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(res.body).toHaveProperty('ok', true);
    // be flexible about exact payload fields, but enforce the important ones
    // usually today returns { date, dayOfWeek, slots } (or similar)
    // if your service returns something else, tweak these 2 lines.
    expect(res.body).toHaveProperty('date');
    expect(res.body).toHaveProperty('dayOfWeek');
    expect(res.body).toHaveProperty('slots');
    expect(Array.isArray(res.body.slots)).toBe(true);
  });

  it('parent: /schedule/today requires childId (when authenticated)', async () => {
    const token = await getToken('PARENT');
    const childId = process.env.CHILD_ID || null;
    if (!token || !childId) return;

    const res = await request(app.getHttpServer())
      .get(`/schedule/today?childId=${encodeURIComponent(childId)}`)
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(res.body).toHaveProperty('ok', true);
    expect(res.body).toHaveProperty('date');
    expect(res.body).toHaveProperty('dayOfWeek');
    expect(res.body).toHaveProperty('slots');
    expect(Array.isArray(res.body.slots)).toBe(true);
  });

  it('admin: /schedule/today requires cohortId (when authenticated)', async () => {
    const token = await getToken('ADMIN');
    const cohortId = process.env.COHORT_ID || null;
    if (!token || !cohortId) return;

    const res = await request(app.getHttpServer())
      .get(`/schedule/today?cohortId=${encodeURIComponent(cohortId)}`)
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(res.body).toHaveProperty('ok', true);
    expect(res.body).toHaveProperty('date');
    expect(res.body).toHaveProperty('dayOfWeek');
    expect(res.body).toHaveProperty('slots');
    expect(Array.isArray(res.body.slots)).toBe(true);
  });
});
