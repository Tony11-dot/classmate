import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { AppModule } from '../src/app.module';

async function login(app: INestApplication, email: string, password: string) {
  const res = await request(app.getHttpServer())
    .post('/auth/login')
    .send({ email, password })
    .expect(201);

  expect(res.body).toHaveProperty('token');
  return res.body.token as string;
}

describe('Parent attendance (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleRef.createNestApplication();
    await app.init();

    await request(app.getHttpServer())
      .post('/test/seed/admin-web')
      .expect(201);

  });

  afterAll(async () => {
    await app.close();
  });

  it('parent can fetch child attendance (approved link)', async () => {
    const token = await login(app, 'parent1@classmate.app', 'dev');

    const childId = '6c56edbc-d612-4c91-9073-bfe9986df4d0';

    const res = await request(app.getHttpServer())
      .get(`/parents/attendance?childId=${encodeURIComponent(childId)}`)
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(res.body).toHaveProperty('ok', true);
    expect(Array.isArray(res.body.items)).toBe(true);
  });

  it('parent can fetch child attendance with from/to filters', async () => {
    const token = await login(app, 'parent1@classmate.app', 'dev');

    const childId = '6c56edbc-d612-4c91-9073-bfe9986df4d0';

    const res = await request(app.getHttpServer())
      .get(
        `/parents/attendance?childId=${encodeURIComponent(
          childId,
        )}&from=2026-01-01&to=2026-01-09`,
      )
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(res.body).toHaveProperty('ok', true);
    expect(res.body.from).toBe('2026-01-01');
    expect(res.body.to).toBe('2026-01-09');
    expect(Array.isArray(res.body.items)).toBe(true);
  });
});
