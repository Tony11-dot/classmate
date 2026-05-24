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