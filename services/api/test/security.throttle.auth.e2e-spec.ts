import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { AppModule } from '../src/app.module';

describe('security: auth throttling (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = moduleRef.createNestApplication();
    await app.init();

    await request(app.getHttpServer()).post('/test/seed/admin-web').expect(201);
  });

  afterAll(async () => {
    await app.close();
  });

  it('login gets throttled under repeated attempts', async () => {
    const http = request(app.getHttpServer());
    let got429 = false;

    // 60 attempts should be enough even with generous limits
    for (let i = 0; i < 60; i++) {
      const res = await http.post('/auth/login').send({ email: 'student1@classmate.app', password: 'wrong' });
      if (res.status === 429) {
        got429 = true;
        break;
      }
    }

    expect(got429).toBe(true);
  });
});
