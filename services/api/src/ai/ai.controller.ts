import {
  Body,
  Controller,
  Post,
  Res,
  ServiceUnavailableException,
  UseGuards,
} from '@nestjs/common';
import type { Response as ExpressResponse } from 'express';
import { SkipThrottle, Throttle } from '@nestjs/throttler';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { ALL_APP_ROLES } from '../auth/roles';
import { AiService } from './ai.service';

/**
 * `/ai/chat/completions` — the OpenAI-compatible NOVA proxy the ClassNotes app
 * points at in proxy mode. JWT-gated (any signed-in role), streams SSE back.
 * The route lives under `/ai/...` so the app's base URL is `<host>/ai`.
 */
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(...ALL_APP_ROLES)
@Controller('ai')
export class AiController {
  constructor(private readonly ai: AiService) {}

  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @SkipThrottle({ default: false })
  @Post('chat/completions')
  async chat(@Body() body: any, @Res() res: ExpressResponse): Promise<void> {
    if (!this.ai.isEnabled()) {
      throw new ServiceUnavailableException('NOVA is not available right now.');
    }

    let upstream: Awaited<ReturnType<AiService['streamChat']>>;
    try {
      upstream = await this.ai.streamChat(body);
    } catch {
      throw new ServiceUnavailableException('NOVA is temporarily unavailable.');
    }

    if (!upstream.ok || !upstream.body) {
      res.status(502).json({ error: 'nova_upstream_error' });
      return;
    }

    res.setHeader('Content-Type', 'text/event-stream; charset=utf-8');
    res.setHeader('Cache-Control', 'no-cache, no-transform');
    res.setHeader('Connection', 'keep-alive');
    res.setHeader('X-Accel-Buffering', 'no');
    res.flushHeaders?.();

    // Pipe the upstream web ReadableStream straight to the Express response.
    const reader = upstream.body.getReader();
    const decoder = new TextDecoder();
    try {
      for (;;) {
        const { done, value } = await reader.read();
        if (done) break;
        res.write(decoder.decode(value, { stream: true }));
      }
    } catch {
      // Client disconnected or upstream broke mid-stream — just end cleanly.
    } finally {
      res.end();
    }
  }
}
