import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { json, urlencoded } from 'express';
import { join } from 'path';
import { AppModule } from './app.module';
import { JsonLogger } from './common/logging/json.logger';
import { RequestMetricsInterceptor } from './common/interceptors/request-metrics.interceptor';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule, {
    bufferLogs: true,
  });

  // Bound the payload sizes Express will accept so a malicious client
  // can't DoS us by streaming an unbounded JSON or form body. Multer
  // (used by FileInterceptor on upload routes) enforces its OWN
  // per-route `limits.fileSize`, so this only affects JSON / form data.
  // 5 MB is comfortably larger than any normal API payload we expect.
  app.use(json({ limit: '5mb' }));
  app.use(urlencoded({ extended: true, limit: '5mb' }));

  // CORS for the Flutter web build. Mobile clients don't enforce CORS,
  // so the iOS/Android apps don't care — this exists purely so that
  // the browser-served Flutter SPA (classmateapp.org/app, plus the
  // localhost:8765 preview during development) can call the API.
  //
  // CORS_ORIGINS is a comma-separated list. When unset, `origin: true`
  // reflects whatever origin made the request — fine for a not-yet-
  // public environment. Set CORS_ORIGINS in production to tighten this
  // to known surfaces only (e.g. https://classmateapp.org).
  const corsOrigins = (process.env.CORS_ORIGINS ?? '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
  app.enableCors({
    origin: corsOrigins.length === 0 ? true : corsOrigins,
    credentials: true,
  });

  const logger = app.get(JsonLogger);
  app.useLogger(logger);
  app.useStaticAssets(join(process.cwd(), 'uploads'), {
    prefix: '/uploads/',
  });
  app.useGlobalInterceptors(app.get(RequestMetricsInterceptor));

  const port = Number(process.env.PORT || 3000);
  await app.listen(port, '0.0.0.0');

  logger.log(`api_listening port=${port}`, 'Bootstrap');
}

void bootstrap();