import { NestFactory } from '@nestjs/core';
import { RequestIdMiddleware } from './common/request-id.middleware';
import { HttpLoggingInterceptor } from './common/http-logging.interceptor';
import { AppModule } from './app.module';
import { loadEnv } from './env';

async function bootstrap() {
  const env = loadEnv();
  const app = await NestFactory.create(AppModule);
  app.use(new RequestIdMiddleware().use);
  app.useGlobalInterceptors(new HttpLoggingInterceptor());
  app.setGlobalPrefix('api');
  await app.listen(env.PORT, '0.0.0.0');
}

bootstrap();
