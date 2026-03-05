import { Controller, Get, Header } from '@nestjs/common';
import { collectDefaultMetrics, register } from 'prom-client';
import { Public } from '../auth/public.decorator';

let defaultsCollected = false;

@Controller('metrics')
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
