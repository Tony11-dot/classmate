import { Test } from '@nestjs/testing';
import request, { Test as STTest } from 'supertest';
type Http = ReturnType<typeof request>;
import { AppModule } from '../../app.module';

export type TestApp = {
  app: any;
  http: Http;
  close: () => Promise<void>;
};

export async function createTestApp(): Promise<TestApp> {
  const modRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
  const app = modRef.createNestApplication();
  app.setGlobalPrefix('api');
  await app.init();
  const http = request(app.getHttpServer());
  const close = async () => {
    await app.close();
  };
  return { app, http, close };
}
