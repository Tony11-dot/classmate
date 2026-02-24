import { NestFactory } from '@nestjs/core';
import { corsOrigins, env } from './config/env';
import helmet from 'helmet';
import compression from 'compression';
import { RequestIdMiddleware } from './common/request-id.middleware';
import { HttpLoggingInterceptor } from './common/http-logging.interceptor';
import { AppModule } from './app.module';
import { loadEnv } from './env';

async function bootstrap() {
  const env = loadEnv();
  const app = await NestFactory.create(AppModule);

  // ✅ CORS for admin-web dev + e2e
  // allow:
  // - explicit localhost/127.0.0.1:3001
  // - your LAN ip:3001 (any 192.168.x.x:3001)
  // - tools/no-origin requests (curl/postman)
  app.enableCors({
    origin: (origin, cb) => {
      if (!origin) return cb(null, true);
      const ok =
        origin === 'http://127.0.0.1:3001' ||
        origin === 'http://localhost:3001' ||
        /^http:\/\/192\.168\.\d+\.\d+:3001$/.test(origin);
      return cb(null, ok);
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
}

bootstrap();
