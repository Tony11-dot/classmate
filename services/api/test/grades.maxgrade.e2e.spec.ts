import request from 'supertest';

const BASE = process.env.E2E_API_BASE_URL ?? 'http://localhost:3000';

async function loginTeacher() {
  const res = await request(BASE)
    .post('/auth/login')
    .send({ email: 'teacher1@classmate.app', password: 'dev' })
    .expect(201);

  const token = res.body?.token;
  expect(token).toBeTruthy();
  return token as string;
}

describe('grades: maxGrade enforcement', () => {
  it('allows grade <= maxGrade and rejects grade > maxGrade', async () => {
    const token = await loginTeacher();

    // list courses + assessments
    const list = await request(BASE)
      .get('/teacher/grades/assessments')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(list.body.ok).toBe(true);
    expect(Array.isArray(list.body.courses)).toBe(true);
    expect(list.body.courses.length).toBeGreaterThan(0);

    const course = list.body.courses[0];
    expect(course.id).toBeTruthy();
    expect(course.cohortId).toBeTruthy();

    // create assessment with maxGrade 120
    const created = await request(BASE)
      .post('/teacher/grades/assessment')
      .set('Authorization', `Bearer ${token}`)
      .send({ courseId: course.id, title: `E2E MaxGrade ${Date.now()}`, maxGrade: 120 })
      .expect(201);

    expect(created.body.ok).toBe(true);
    const assessmentId = created.body.assessment?.id;
    expect(assessmentId).toBeTruthy();

    // load cohort students
    const studentsRes = await request(BASE)
      .get(`/teacher/cohort/${course.cohortId}/students`)
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(studentsRes.body.ok).toBe(true);
    expect(Array.isArray(studentsRes.body.students)).toBe(true);
    expect(studentsRes.body.students.length).toBeGreaterThan(0);

    const studentId = studentsRes.body.students[0].studentId;
    expect(studentId).toBeTruthy();

    // PASS: 120
    await request(BASE)
      .post('/teacher/grades/bulk')
      .set('Authorization', `Bearer ${token}`)
      .send({ assessmentId, grades: [{ studentId, grade: 120 }] })
      .expect(201);

    // FAIL: 121
    const bad = await request(BASE)
      .post('/teacher/grades/bulk')
      .set('Authorization', `Bearer ${token}`)
      .send({ assessmentId, grades: [{ studentId, grade: 121 }] })
      .expect(400);

    expect(String(bad.body?.message ?? '')).toMatch(/exceeds maxGrade/i);
  });
});
