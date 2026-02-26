import { Test } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../../src/app.module';

describe('Student schedule', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const mod = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = mod.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('GET /api/student/schedule/today requires auth', async () => {
    await request(app.getHttpServer()).get('/api/student/schedule/today').expect(401);
  });

  it('GET /api/student/schedule/week requires auth', async () => {
    await request(app.getHttpServer()).get('/api/student/schedule/week').expect(401);
  });
});
