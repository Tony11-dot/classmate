import {
  BadRequestException,
  Controller,
  Get,
  Query,
  Res,
  ServiceUnavailableException,
} from '@nestjs/common';
import type { Response } from 'express';
import { Throttle } from '@nestjs/throttler';

import { Public } from '../decorators/public.decorator';
import { MoeSsoService } from './moe-sso.service';

/**
 * Ministry of Education SSO endpoints. Public (pre-login) by nature — a user
 * signs in THROUGH the Ministry here. Every route no-ops with 503 until the
 * integration is enabled + configured, so this is safe to ship un-provisioned.
 */
@Public()
@Controller('auth/moe')
export class MoeSsoController {
  constructor(private readonly sso: MoeSsoService) {}

  /** Lets the app decide whether to show a "Sign in with the Ministry" button. */
  @Get('status')
  status() {
    return { enabled: this.sso.isEnabled() };
  }

  /** Kicks off the flow: redirect the browser to the Ministry authorize URL. */
  @Throttle({ auth: { limit: 30, ttl: 15 * 60_000 } })
  @Get('login')
  login(@Res() res: Response) {
    if (!this.sso.isEnabled()) {
      throw new ServiceUnavailableException('Ministry sign-in is not enabled');
    }
    return res.redirect(this.sso.buildAuthorizeUrl());
  }

  /** The Ministry redirects back here with ?code & ?state. */
  @Throttle({ auth: { limit: 30, ttl: 15 * 60_000 } })
  @Get('callback')
  async callback(
    @Res() res: Response,
    @Query('code') code?: string,
    @Query('state') state?: string,
    @Query('error') error?: string,
  ) {
    if (!this.sso.isEnabled()) {
      throw new ServiceUnavailableException('Ministry sign-in is not enabled');
    }
    if (error) throw new BadRequestException(`Ministry sign-in error: ${error}`);
    if (!code || !state) throw new BadRequestException('Missing code or state');

    const token = await this.sso.handleCallback(String(code), String(state));

    // Hand the session token to the app. If a post-login URL is configured we
    // bounce the browser there with the token in the fragment (kept out of
    // server logs / Referer); otherwise return it as JSON for API clients.
    const redirect = this.sso.config().postLoginRedirect;
    if (redirect) {
      const sep = redirect.includes('#') ? '&' : '#';
      return res.redirect(`${redirect}${sep}token=${encodeURIComponent(token)}`);
    }
    return res.json({ token });
  }
}
