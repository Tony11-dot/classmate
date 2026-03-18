import { Controller, Get } from '@nestjs/common';
import { metrics } from '../metrics/metrics';

@Controller('_metrics')
export class MetricsController {
  @Get()
  getMetrics() {
    return metrics.snapshot();
  }
}
