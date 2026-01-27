import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { loadEnv, parseCorsOrigins } from './env';
import { AppModule } from './app.module';

async function bootstrap() {
  const env = loadEnv();

  const app = await NestFactory.create(AppModule);


  app.enableCors({
    origin: (origin, cb) => {
      // allow curl/postman (no Origin)
      if (!origin) return cb(null, true);

      // Dev/test: allow local + LAN
      if (env.NODE_ENV !== 'production') {
        const ok =
          /^http:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin) ||
          /^http:\/\/(192\.168\.\d+\.\d+)(:\d+)?$/.test(origin);

        return cb(null, ok);
      }

      // Prod: strict allowlist
      const allow = parseCorsOrigins(env.CORS_ORIGINS);
      return cb(null, allow.includes(origin));
    },
    credentials: true,
    methods: ['GET', 'POST', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  });

  app.setGlobalPrefix('api');
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));

  await app.listen(env.PORT);
}

bootstrap();
