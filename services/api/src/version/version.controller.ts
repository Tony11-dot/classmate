import { Controller, Get } from '@nestjs/common';
import { Public } from '../auth/public.decorator';

@Public()
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
