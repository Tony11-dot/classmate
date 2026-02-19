import { createTestApp } from './helpers/app';

describe('notifications (e2e)', () => {
  it('list returns cursor pagination shape', async () => {
    const { http, close } = await createTestApp();

    // register user
    const email = `n${Date.now()}@t.dev`;
    await http
      .post('/api/auth/register')
      .send({ email, name: 'NN', password: 'DevPass123!' })
      .expect(201);

    const login = await http
      .post('/api/auth/login')
      .send({ email, password: 'DevPass123!' })
      .expect(201);

    const token = login.body.token;

    const res = await http
      .get('/api/notifications?limit=5')
      .set('Authorization', `Bearer ${token}`);

    if (res.status !== 200) {
      // eslint-disable-next-line no-console
      console.log('NOTIFS', res.status, res.body, res.text);
    }

    expect(res.status).toBe(200);

    expect(res.body).toHaveProperty('items');
    expect(Array.isArray(res.body.items)).toBe(true);
    expect(res.body).toHaveProperty('nextCursor');

    await close();
  });
});
