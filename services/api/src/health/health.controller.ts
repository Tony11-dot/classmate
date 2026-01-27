import { Controller, Get } from '@nestjs/common';

@Controller('health')
export class HealthController {
  @Get()
  health() {
    return {
      ok: true,
      env: process.env.NODE_ENV ?? 'development',
    };
  }
}
