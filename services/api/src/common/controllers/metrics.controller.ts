import { Controller, Get } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import { Public } from '../../auth/public.decorator';
import { metrics } from '../metrics/metrics';

@Public()
@SkipThrottle()
@Controller('_metrics')
export class MetricsController {
  @Get()
  getMetrics() {
    return metrics.snapshot();
  }
}
