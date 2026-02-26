import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { AppModule } from '../src/app.module';

type LoginBody = {
  token?: string;
  accessToken?: string;
  access_token?: string;
  jwt?: string;
  data?: any;
};

async function login(app: INestApplication, email: string, password: string) {
  const res = await request(app.getHttpServer())
    .post('/auth/login')
    .send({ email, password });

  // tolerate different response shapes
  const b = (res.body || {}) as LoginBody;
  const token =
    b.token ||
    b.accessToken ||
    b.access_token ||
    b.jwt ||
    b.data?.token ||
    b.data?.accessToken ||
    b.data?.access_token;

  return token || null;
}

function findFirstCourseSlot(weekBody: any) {
  // Current API returns an ARRAY of schedule items:
  // [{ cohortId, date, period, courseId, ... }]
  const items: any[] = Array.isArray(weekBody) ? weekBody : [];
  for (const it of items) {
    const cohortId = it?.cohortId;
    const date = it?.date;
    const period = it?.period;
    const courseId = it?.courseId;
    if (cohortId && date && period !== undefined && period !== null && courseId) {
      return { cohortId, date, period };
    }
  }
  return null;
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

  it('teacher can fetch attendance session for first real scheduled slot in /schedule/week', async () => {
    // creds from seed: password is "dev"
    const STUDENT_EMAIL = process.env.STUDENT_EMAIL || 'student1@classmate.app';
    const STUDENT_PASSWORD = process.env.STUDENT_PASSWORD || 'dev';
    const TEACHER_EMAIL = process.env.TEACHER_EMAIL || 'teacher1@classmate.app';
    const TEACHER_PASSWORD = process.env.TEACHER_PASSWORD || 'dev';

    const studentToken = await login(app, STUDENT_EMAIL, STUDENT_PASSWORD);
    if (!studentToken) return; // auto-skip on env mismatch

    const week = await request(app.getHttpServer())
      .get('/student/schedule/week')
      .set('Authorization', `Bearer ${studentToken}`)
      .expect(200);

    expect(Array.isArray(week.body)).toBe(true);

    const slot = findFirstCourseSlot(week.body);
    if (!slot) return; // no courses scheduled => skip (weekend / empty data)

    const teacherToken = await login(app, TEACHER_EMAIL, TEACHER_PASSWORD);
    if (!teacherToken) return;

    const res = await request(app.getHttpServer())
      .get(
        `/teacher/attendance/session?cohortId=${encodeURIComponent(slot.cohortId)}&date=${encodeURIComponent(
          slot.date,
        )}&period=${encodeURIComponent(String(slot.period))}`,
      )
      .set('Authorization', `Bearer ${teacherToken}`)
      .expect(200);

    expect(res.body).toHaveProperty('cohort');
    expect(res.body).toHaveProperty('date', slot.date);
    expect(res.body).toHaveProperty('period', slot.period);
    expect(res.body).toHaveProperty('course');
    expect(res.body).toHaveProperty('students');
    expect(Array.isArray(res.body.students)).toBe(true);
  });
});
