import { Controller, Get, Header } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import { collectDefaultMetrics, register } from 'prom-client';
import { Public } from '../auth/public.decorator';

let defaultsCollected = false;

@Controller('metrics')
@SkipThrottle({ global: true, auth: true })
export class MetricsController {
  constructor() {
    if (!defaultsCollected) {
      collectDefaultMetrics();
      defaultsCollected = true;
    }
  }

  @Public()
  @Get()
  @Header('Content-Type', register.contentType)
  async metrics() {
    return await register.metrics();
  }
}
