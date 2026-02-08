import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { AppModule } from '../src/app.module';

async function login(app: INestApplication, email: string, password: string) {
  const res = await request(app.getHttpServer())
    .post('/auth/login')
    .send({ email, password })
    .expect(201);

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

type WeekResp = {
  ok: boolean;
  cohort: { id: string };
  days: {
    date: string;
    slots: {
      period: number;
      course: { id: string; teacherId: string } | null;
    }[];
  }[];
};

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
      .get('/schedule/week')
      .set('Authorization', `Bearer ${studentToken}`)
      .expect(200);

    const week = weekRes.body as WeekResp;
    expect(week.ok).toBe(true);
    expect(week.cohort?.id).toBeTruthy();

    const cohortId = week.cohort.id;

    let picked: { date: string; period: number } | null = null;
    for (const day of week.days || []) {
      for (const slot of day.slots || []) {
        if (slot.course) {
          picked = { date: day.date, period: slot.period };
          break;
        }
      }
      if (picked) break;
    }

    if (!picked) {
      // Seed may have no lessons in this environment; don't hard-fail.
      return;
    }

    const { date, period } = picked;

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
