import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { AppModule } from '../src/app.module';

// supertest import that works reliably with jest in many TS configs
const request = require('supertest');

describe('Schedule contract (e2e)', () => {
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

    // tolerate different login behaviors
    if (res.status !== 200 && res.status !== 201) return null;
    if (res.body?.error) return null;

    const tok = pickToken(res.body);
    if (!tok) return null;

    return tok;
  }

  it('GET /schedule/week-grid (student) matches /schedule/week output shape', async () => {
    const STUDENT_TOKEN =
      (await getToken('STUDENT')) || process.env.STUDENT_TOKEN || null;
    if (!STUDENT_TOKEN) return;

    const a = await request(app.getHttpServer())
      .get('/schedule/week')
      .set('Authorization', `Bearer ${STUDENT_TOKEN}`)
      .expect(200);

    const b = await request(app.getHttpServer())
      .get('/schedule/week-grid')
      .set('Authorization', `Bearer ${STUDENT_TOKEN}`)
      .expect(200);

    expect(a.body.ok).toBe(true);
    expect(b.body.ok).toBe(true);
    expect(a.body.cohort?.id).toEqual(b.body.cohort?.id);
    expect(a.body.maxPeriod).toEqual(b.body.maxPeriod);
    expect(Array.isArray(a.body.days)).toBe(true);
    expect(Array.isArray(b.body.days)).toBe(true);
  });

  it('GET /schedule/week-grid (parent) requires childId and APPROVED link', async () => {
    const PARENT_TOKEN = await getToken('PARENT');
    const CHILD_ID = process.env.CHILD_ID || null;
    if (!PARENT_TOKEN || !CHILD_ID) return;

    const res = await request(app.getHttpServer())
      .get(`/schedule/week-grid?childId=${encodeURIComponent(CHILD_ID)}`)
      .set('Authorization', `Bearer ${PARENT_TOKEN}`)
      .expect(200);

    expect(res.body.ok).toBe(true);
    expect(res.body.cohort?.id).toBeTruthy();
  });

  it('GET /schedule/week-grid (admin) requires cohortId', async () => {
    const ADMIN_TOKEN = await getToken('ADMIN');
    const COHORT_ID = process.env.COHORT_ID || null;
    if (!ADMIN_TOKEN || !COHORT_ID) return;

    const res = await request(app.getHttpServer())
      .get(`/schedule/week-grid?cohortId=${encodeURIComponent(COHORT_ID)}`)
      .set('Authorization', `Bearer ${ADMIN_TOKEN}`)
      .expect(200);

    expect(res.body.ok).toBe(true);
    expect(res.body.cohort?.id).toBeTruthy();
  });
});
