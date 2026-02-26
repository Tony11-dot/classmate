import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { AppModule } from '../src/app.module';

async function login(app: INestApplication, email: string, password: string) {
  const res = await request(app.getHttpServer())
    .post('/auth/login')
    .send({ email, password });

  if (res.status !== 200 && res.status !== 201) {
    throw new Error(`Login failed: status ${res.status}`);
  }

  const token =
    res.body?.token ||
    res.body?.accessToken ||
    res.body?.access_token ||
    res.body?.jwt ||
    res.body?.data?.token ||
    res.body?.data?.accessToken ||
    res.body?.data?.access_token;

  if (!token) throw new Error('Login failed: no token in response');
  return token as string;
}


describe('Teacher attendance mark/bulk (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const modRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = modRef.createNestApplication();
    await app.init();

    
await request(app.getHttpServer())
      .post('/test/seed/admin-web')
      .expect(201);

  });

  afterAll(async () => {
    await app.close();
  });

  it('teacher can mark attendance then bulk update and verify via session', async () => {
    const TEACHER_EMAIL = process.env.TEACHER_EMAIL || 'teacher1@classmate.app';
    const TEACHER_PASSWORD = process.env.TEACHER_PASSWORD || 'dev';
    const STUDENT_EMAIL = process.env.STUDENT_EMAIL || 'student1@classmate.app';
    const STUDENT_PASSWORD = process.env.STUDENT_PASSWORD || 'dev';

    const teacherToken = await login(app, TEACHER_EMAIL, TEACHER_PASSWORD);
    const studentToken = await login(app, STUDENT_EMAIL, STUDENT_PASSWORD);

    // Derive a real cohortId/date/period from the student's schedule
    const weekRes = await request(app.getHttpServer())
      .get('/student/schedule/week')
      .set('Authorization', `Bearer ${studentToken}`)
      .expect(200);

    const items = (Array.isArray(weekRes.body) ? weekRes.body : []) as WeekItem[];
    if (!items.length) return;

    const picked = items.find((x) => !!x?.courseId) || items[0];
    if (!picked?.cohortId || !picked?.date || picked?.period === undefined || picked?.period === null) return;

    const cohortId = picked.cohortId;
    const date = picked.date;
    const period = picked.period;

// 1) Fetch attendance session (should also verify teacher owns the course)
    const session1 = await request(app.getHttpServer())
      .get(
        `/teacher/attendance/session?cohortId=${encodeURIComponent(
          cohortId,
        )}&date=${encodeURIComponent(date)}&period=${period}`,
      )
      .set('Authorization', `Bearer ${teacherToken}`)
      .expect(200);

    expect(session1.body).toHaveProperty('cohort');
    expect(session1.body).toHaveProperty('date', date);
    expect(session1.body).toHaveProperty('period', period);
    expect(Array.isArray(session1.body.students)).toBe(true);

    const studentId = session1.body.students?.[0]?.studentId;
    if (!studentId) return;

    // 2) Mark attendance (single)
    const mark = await request(app.getHttpServer())
      .post('/teacher/attendance/mark')
      .set('Authorization', `Bearer ${teacherToken}`)
      .send({
        cohortId,
        date,
        period,
        studentId,
        status: 'LATE',
        note: 'e2e',
      })
      .expect(201);

    expect(mark.body).toHaveProperty('ok', true);

    // 3) Verify via session
    const session2 = await request(app.getHttpServer())
      .get(
        `/teacher/attendance/session?cohortId=${encodeURIComponent(
          cohortId,
        )}&date=${encodeURIComponent(date)}&period=${period}`,
      )
      .set('Authorization', `Bearer ${teacherToken}`)
      .expect(200);

    const s2 = (session2.body.students || []).find(
      (x: any) => x.studentId === studentId,
    );
    expect(s2?.status).toBe('LATE');
    expect(s2?.note).toBe('e2e');

    // 4) Bulk update
    const bulk = await request(app.getHttpServer())
      .post('/teacher/attendance/bulk')
      .set('Authorization', `Bearer ${teacherToken}`)
      .send({
        cohortId,
        date,
        period,
        records: [{ studentId, status: 'PRESENT', note: 'bulk' }],
      })
      .expect(201);

    expect(bulk.body).toHaveProperty('ok', true);
    expect(bulk.body).toHaveProperty('written');
    expect(bulk.body.written).toBeGreaterThanOrEqual(1);

    // 5) Verify bulk took effect
    const session3 = await request(app.getHttpServer())
      .get(
        `/teacher/attendance/session?cohortId=${encodeURIComponent(
          cohortId,
        )}&date=${encodeURIComponent(date)}&period=${period}`,
      )
      .set('Authorization', `Bearer ${teacherToken}`)
      .expect(200);

    const s3 = (session3.body.students || []).find(
      (x: any) => x.studentId === studentId,
    );
    expect(s3?.status).toBe('PRESENT');
    expect(s3?.note).toBe('bulk');
  });
});
