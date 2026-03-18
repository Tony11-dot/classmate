import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { JsonLogger } from './common/logging/json.logger';
import { RequestMetricsInterceptor } from './common/interceptors/request-metrics.interceptor';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { bufferLogs: true });

  const logger = app.get(JsonLogger);
  app.useLogger(logger);
  app.useGlobalInterceptors(app.get(RequestMetricsInterceptor));

  const port = Number(process.env.PORT || 3000);
  await app.listen(port, '0.0.0.0');

  logger.log(`api_listening port=${port}`, 'Bootstrap');
}

void bootstrap();
