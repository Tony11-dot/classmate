// MUST be the first import — initialises Sentry before Nest and the modules
// it instruments are loaded. No-op unless SENTRY_DSN is set.
import './instrument';

import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import helmet from 'helmet';
import { json, urlencoded } from 'express';
import { join } from 'path';
import { AppModule } from './app.module';
import { JsonLogger } from './common/logging/json.logger';
import { setUploadSafetyHeaders } from './common/upload-safety';
import { RequestMetricsInterceptor } from './common/interceptors/request-metrics.interceptor';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule, {
    bufferLogs: true,
  });

  // Railway terminates TLS at its edge proxy. Without this, Express reports
  // the PROXY's IP for every request, so the per-IP throttler collapses into
  // one shared bucket — the strict 5/15min auth limit would lock out a whole
  // school after five total login attempts. `1` trusts exactly one hop: the
  // client IP is taken from the X-Forwarded-For entry Railway itself
  // appended, so a client can't spoof its way out by sending its own header.
  app.set('trust proxy', 1);

  // Security headers (HSTS, X-Content-Type-Options: nosniff, X-Frame-Options:
  // DENY, Referrer-Policy, etc.). CSP is disabled — this is a JSON API, not an
  // HTML app, and a strict CSP would serve no purpose here while risking
  // breakage. crossOriginResourcePolicy is relaxed to 'cross-origin' so the
  // Flutter web SPA (different origin) and the mobile apps can still load
  // uploaded images served from /uploads/.
  app.use(
    helmet({
      contentSecurityPolicy: false,
      crossOriginResourcePolicy: { policy: 'cross-origin' },
    }),
  );

  // Bound the payload sizes Express will accept so a malicious client
  // can't DoS us by streaming an unbounded JSON or form body. Multer
  // (used by FileInterceptor on upload routes) enforces its OWN
  // per-route `limits.fileSize`, so this only affects JSON / form data.
  // 25 MB accommodates the ClassNotes page-content sync (a notebook can carry
  // a dozen+ base64 PNG data URLs at a few hundred KB each) while still
  // failing closed on a truly unbounded body.
  app.use(json({ limit: '25mb' }));
  app.use(urlencoded({ extended: true, limit: '25mb' }));

  // CORS for the Flutter web build. Mobile clients don't enforce CORS,
  // so the iOS/Android apps don't care — this exists purely so that
  // the browser-served Flutter SPA (classmateapp.org/app, plus the
  // localhost:8765 preview during development) can call the API.
  //
  // CORS_ORIGINS is a comma-separated allowlist. In production it MUST be set
  // (fail closed) — reflecting an arbitrary origin together with
  // credentials: true is exactly what a security review flags. Outside
  // production, an empty list reflects the request origin for local dev.
  const corsOrigins = (process.env.CORS_ORIGINS ?? '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
  const isProd = (process.env.NODE_ENV ?? '') === 'production';
  if (isProd && corsOrigins.length === 0) {
    // A sane built-in allowlist so a missing env var can't silently open CORS
    // to the world. Extend via CORS_ORIGINS.
    corsOrigins.push(
      'https://classmateapp.org',
      'https://classmate-f17d6.web.app',
    );
  }
  app.enableCors({
    origin: corsOrigins.length === 0 ? true : corsOrigins,
    credentials: true,
  });

  const logger = app.get(JsonLogger);
  app.useLogger(logger);
  app.useStaticAssets(join(process.cwd(), 'uploads'), {
    prefix: '/uploads/',
    // Force-download + neuter anything script-capable (SVG/HTML) — uploaded
    // content must never execute on the API origin. See upload-safety.ts.
    setHeaders: setUploadSafetyHeaders,
  });
  app.useGlobalInterceptors(app.get(RequestMetricsInterceptor));

  const port = Number(process.env.PORT || 3000);
  await app.listen(port, '0.0.0.0');

  logger.log(`api_listening port=${port}`, 'Bootstrap');
}

void bootstrap();