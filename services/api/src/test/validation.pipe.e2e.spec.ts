import { Test } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../app.module';

describe('validation pipe (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const modRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = modRef.createNestApplication();
    app.setGlobalPrefix('api');
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('unknown fields are rejected', async () => {
    await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({ email: 'x@y.z', password: 'Passw0rd!', unknownField: true })
      .expect(400);
  });
});
