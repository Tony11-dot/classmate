import {
  Body,
  Controller,
  Get,
  Post,
  ServiceUnavailableException,
  UseGuards,
} from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { ALL_APP_ROLES } from '../auth/roles';
import { SupportService } from './support.service';
import { AskSupportDto } from './dto/ask-support.dto';

// The support assistant is open to every signed-in user (students, teachers,
// parents, admins, secretaries, managers) — it only knows the product and never
// touches metered NOVA spend. It still requires auth: an unauthenticated AI
// endpoint would be an open abuse/DoS surface. ALL_APP_ROLES satisfies the
// RolesGuard default-deny while keeping the route open to any logged-in role.
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(...ALL_APP_ROLES)
@Controller('support')
export class SupportController {
  constructor(private readonly support: SupportService) {}

  /// Lets the app show/hide the "Ask AI" entry point without hardcoding the
  /// provider state into the client.
  @Get('ai/status')
  status() {
    return { enabled: this.support.isEnabled() };
  }

  /// One support question (+ optional prior turns). Tightly throttled — this is
  /// help, not a chat firehose, and it fans out to a third-party model.
  @Throttle({ default: { limit: 15, ttl: 60_000 } })
  @Post('ai/ask')
  async ask(@Body() dto: AskSupportDto) {
    if (!this.support.isEnabled()) {
      // Configured off — the client falls back to the FAQ + contact card.
      throw new ServiceUnavailableException('Support assistant is not available');
    }
    try {
      return await this.support.ask(dto.question, dto.history ?? []);
    } catch {
      // Upstream/model failure — keep the message generic (no provider leak).
      throw new ServiceUnavailableException(
        'The assistant is temporarily unavailable. Please try again, or email support@classmateapp.org.',
      );
    }
  }
}
