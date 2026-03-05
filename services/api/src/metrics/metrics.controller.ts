import { Controller, Get, Res } from '@nestjs/common';
import { Public } from '../auth/public.decorator';
import type { Response } from 'express';
import { register } from 'prom-client';

@Controller()
export class MetricsController {
  @Public()
  @Get('metrics')
  async metrics(@Res() res: Response) {
    res.setHeader('Content-Type', register.contentType);
    res.send(await register.metrics());
  }
}
