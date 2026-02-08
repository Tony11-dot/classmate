import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { loadEnv, parseCorsOrigins } from './env';
import { AppModule } from './app.module';

async function bootstrap() {
  
const env = loadEnv();
  const app = await NestFactory.create(AppModule);

  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));

  const isProd = env.NODE_ENV === 'production';
  const prodAllow = parseCorsOrigins(env.CORS_ORIGINS);

  app.enableCors({
    origin: (origin, cb) => {
      // allow curl/postman (no Origin)
      if (!origin) return cb(null, true);

      // Dev/test: allow local + LAN
      if (!isProd) {
        const ok =
          /^http:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin) ||
          /^http:\/\/(192\.168\.\d+\.\d+)(:\d+)?$/.test(origin);

        return cb(null, ok);
      }

      // Prod: strict allowlist
      return cb(null, prodAllow.includes(origin));
    },
    credentials: true,
    methods: ['GET', 'POST', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  });

  app.setGlobalPrefix('api');
  
  // IMPORTANT for Docker: listen on all interfaces
  await app.listen(env.PORT, '0.0.0.0');
}

bootstrap();
