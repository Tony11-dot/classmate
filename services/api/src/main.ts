import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { loadEnv } from './env';

async function bootstrap() {
  const env = loadEnv();
  const app = await NestFactory.create(AppModule);
  app.setGlobalPrefix('api');
  await app.listen(env.PORT, '0.0.0.0');
}

bootstrap();
