import { NestFactory } from '@nestjs/core';
import helmet from 'helmet';
import compression from 'compression';
import { RequestIdMiddleware } from './common/request-id.middleware';
import { HttpLoggingInterceptor } from './common/http-logging.interceptor';
import { AppModule } from './app.module';
import { loadEnv, parseCorsOrigins } from './env';

async function bootstrap() {
  const env = loadEnv();
  const app = await NestFactory.create(AppModule);

  const corsList = parseCorsOrigins(env.CORS_ORIGINS);

  app.enableCors({
    origin: (origin, cb) => {
      if (!origin) return cb(null, true); // curl/postman
      if (corsList.length === 0) return cb(null, true);
      return cb(null, corsList.includes(origin));
    },
    credentials: true,
    methods: ['GET','HEAD','PUT','PATCH','POST','DELETE','OPTIONS'],
    allowedHeaders: ['Content-Type','Authorization'],
  });

  app.use(new RequestIdMiddleware().use);
  app.useGlobalInterceptors(new HttpLoggingInterceptor());

  app.use(
    helmet({
      contentSecurityPolicy: false,
      crossOriginEmbedderPolicy: false,
    }),
  );
  app.use(compression());

  app.use(require('express').json({ limit: '1mb' }));
  app.use(require('express').urlencoded({ extended: true, limit: '1mb' }));

  app.setGlobalPrefix('api');

  await app.listen(env.PORT, '0.0.0.0');
  // eslint-disable-next-line no-console
  console.log(`🚀 API running on http://0.0.0.0:${env.PORT}/api`);
}

bootstrap();
