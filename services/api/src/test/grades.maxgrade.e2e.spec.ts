import request from 'supertest';
import { createTestApp } from './helpers/app';
import { loginAsTeacher } from './helpers/auth';
import { seedTeacherWithCourse } from './helpers/seed';


describe('grades: maxGrade enforcement', () => {
  let app: any;
  let http: any;

  beforeAll(async () => {
    const t = await createTestApp();
    app = t.app;
    http = t.http;
  });

  afterAll(async () => {
    await app?.close?.();
  });

it('allows grade <= maxGrade and rejects grade > maxGrade', async () => {
    const token = await loginAsTeacher(http);

    const seeded = await seedTeacherWithCourse('teacher1@classmate.app');

    const courseId = seeded.courseId;
    const cohortId = seeded.cohortId;

    // create assessment with maxGrade 120
    const created = await http
      .post('/api/teacher/grades/assessment')
      .set('Authorization', `Bearer ${token}`)
      .send({
        courseId: courseId,
        title: `E2E MaxGrade ${Date.now()}`,
        maxGrade: 120,
      })
      .expect(201);

    expect(created.body.ok).toBe(true);
    const assessmentId = created.body.assessment?.id;
    expect(assessmentId).toBeTruthy();

    // load cohort students
    const studentsRes = await http
      .get(`/api/teacher/cohort/${cohortId}/students`)
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(studentsRes.body.ok).toBe(true);
    expect(Array.isArray(studentsRes.body.students)).toBe(true);
    expect(studentsRes.body.students.length).toBeGreaterThan(0);

    const studentId = studentsRes.body.students[0].studentId;
    expect(studentId).toBeTruthy();

    // PASS: 120
    await http
      .post('/api/teacher/grades/bulk')
      .set('Authorization', `Bearer ${token}`)
      .send({ assessmentId, grades: [{ studentId, grade: 120 }] })
      .expect(201);

    // FAIL: 121
    const bad = await http
      .post('/api/teacher/grades/bulk')
      .set('Authorization', `Bearer ${token}`)
      .send({ assessmentId, grades: [{ studentId, grade: 121 }] })
      .expect(400);

    expect(String(bad.body?.message ?? '')).toMatch(/exceeds maxGrade/i);
  });
});
