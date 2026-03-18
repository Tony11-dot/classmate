import { Controller, Get } from '@nestjs/common';
import { metrics } from '../metrics/metrics';
import { Public } from '../../auth/public.decorator';

@Public()
@Controller('_metrics')
export class MetricsController {
  @Get()
  getMetrics() {
    return metrics.snapshot();
  }
}
