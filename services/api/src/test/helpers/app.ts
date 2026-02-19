import { Test } from '@nestjs/testing';
import request, { SuperTest, Test as STTest } from 'supertest';
import { AppModule } from '../../app.module';

export type TestApp = {
  app: any;
  http: SuperTest<STTest>;
};

export async function createTestApp(): Promise<TestApp> {
  const modRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
  const app = modRef.createNestApplication();
  await app.init();
  const http = request(app.getHttpServer());
  return { app, http };
}
