import { Controller, Get, Header } from '@nestjs/common';
import { collectDefaultMetrics, register } from 'prom-client';
import { Public } from '../auth/public.decorator';

let defaultsCollected = false;

@Controller('api')
export class MetricsController {
  constructor() {
    if (!defaultsCollected) {
      collectDefaultMetrics();
      defaultsCollected = true;
    }
  }

  @Public()
  @Get('metrics')
  @Header('Content-Type', register.contentType)
  async metrics() {
    return await register.metrics();
  }
}
