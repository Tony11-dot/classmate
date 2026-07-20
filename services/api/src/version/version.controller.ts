import { Controller, Get } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import { Public } from '../auth/decorators/public.decorator';

@Public()
@SkipThrottle()
@Controller()
export class VersionController {
  @Get('version')
  getVersion() {
    return {
      ok: true,
      service: 'classmate-api',
      ts: new Date().toISOString(),
    };
  }
}
