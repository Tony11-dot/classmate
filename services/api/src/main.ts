import { NestFactory } from '@nestjs/core';
import helmet from 'helmet';
import compression from 'compression';
import { RequestIdMiddleware } from './common/request-id.middleware';
import { HttpLoggingInterceptor } from './common/http-logging.interceptor';
import { AppModule } from './app.module';
import { loadEnv } from './env';

async function bootstrap() {
  const env = loadEnv();
  const app = await NestFactory.create(AppModule);
  app.use(new RequestIdMiddleware().use);
  app.useGlobalInterceptors(new HttpLoggingInterceptor());

  // security + perf (safe defaults)
  app.use(
    helmet({
      contentSecurityPolicy: false,
      crossOriginEmbedderPolicy: false,
    }),
  );
  app.use(compression());

  // payload limits (avoid abuse)
  app.use(require('express').json({ limit: '1mb' }));
  app.use(require('express').urlencoded({ extended: true, limit: '1mb' }));
  app.setGlobalPrefix('api');
  await app.listen(env.PORT, '0.0.0.0');
}

bootstrap();
