import { Controller, Get, Req, Res, UseGuards } from '@nestjs/common';
import type { Response, Request } from 'express';
import { RealtimeService } from './realtime.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { ALL_APP_ROLES } from '../auth/roles';
import { SkipThrottle } from '@nestjs/throttler';

@SkipThrottle()
@Controller('realtime')
@UseGuards(JwtAuthGuard)
@Roles(...ALL_APP_ROLES)
export class RealtimeController {
  constructor(private readonly realtime: RealtimeService) {}

  @Get('stream')
  stream(@Req() req: Request, @Res() res: Response) {
    const userId = (req as any).user?.sub ?? (req as any).user?.id;
    if (!userId) {
      res.status(401).end();
      return;
    }

    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache, no-transform');
    res.setHeader('X-Accel-Buffering', 'no');
    res.setHeader('Connection', 'keep-alive');
    res.flushHeaders();

    // Send initial connected event
    res.write(`data: ${JSON.stringify({ type: 'connected', userId })}\n\n`);

    const unsubscribe = this.realtime.subscribe(userId, res);

    req.on('close', () => {
      unsubscribe();
      res.end();
    });
  }
}
