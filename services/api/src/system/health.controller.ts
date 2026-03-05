import { Controller, Get } from '@nestjs/common';

@Controller('health')
export class HealthController {
  @Get()
  health() {
    return {
      ok: true,
      service: 'classmate-api',
      time: new Date().toISOString(),
    };
  }
}
