import { Test } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../app.module';

describe('health/ready endpoints (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const modRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = modRef.createNestApplication();
    app.setGlobalPrefix('api');
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('GET /api/health returns ok', async () => {
    await request(app.getHttpServer()).get('/api/health').expect(200);
  });

  it('GET /api/ready returns ok', async () => {
    await request(app.getHttpServer()).get('/api/ready').expect(200);
  });
});
