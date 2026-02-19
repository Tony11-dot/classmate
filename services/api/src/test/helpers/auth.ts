import type { SuperTest, Test as STTest } from 'supertest';

export async function loginAsTeacher(http: SuperTest<STTest>) {
  const res = await http
    .post('/api/auth/login')
    .send({ email: 'teacher1@classmate.app', password: 'dev' })
    .expect(201);

  const token = res.body?.token;
  if (!token) throw new Error('No token returned from /api/auth/login (teacher)');
  return token as string;
}
