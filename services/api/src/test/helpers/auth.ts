import request from 'supertest';

const BASE = process.env.E2E_API_BASE_URL ?? 'http://localhost:3000';

export async function loginAsTeacher() {
  const res = await request(BASE)
    .post('/api/auth/login')
    .send({ email: 'teacher1@classmate.app', password: 'dev' })
    .expect(201);

  const token = res.body?.token;
  if (!token) throw new Error('No token returned from /api/auth/login (teacher)');
  return token as string;
}

export async function loginAsAdmin() {
  const res = await request(BASE)
    .post('/api/auth/login')
    .send({ email: 'admin@classmate.app', password: 'dev' })
    .expect(201);

  const token = res.body?.token;
  if (!token) throw new Error('No token returned from /api/auth/login (admin)');
  return token as string;
}
