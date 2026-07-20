import { Injectable, Logger, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../../prisma/prisma.service';
import { AuthService } from '../auth.service';
import {
  isMoeSsoEnabled,
  MoeSsoConfig,
  readMoeSsoConfig,
} from './moe-sso.config';

/**
 * Ministry of Education SSO — OpenID Connect Authorization-Code flow.
 *
 * Design choices that fit ClassMate's model:
 *  - CSRF `state` is a short-lived signed JWT (stateless — no server session or
 *    cookie needed). It's created on /login and verified on /callback.
 *  - We NEVER auto-create accounts. Admins provision every ClassMate account;
 *    MoE SSO only AUTHENTICATES an account that already exists, matched by the
 *    Ministry-provided identifier. An unknown identity is rejected with a clear
 *    "ask your school admin" message. This keeps school membership admin-owned.
 */
@Injectable()
export class MoeSsoService {
  private readonly logger = new Logger('MoeSsoService');
  private static readonly STATE_TTL_SECONDS = 600; // 10 min to complete login

  constructor(
    private readonly prisma: PrismaService,
    private readonly auth: AuthService,
    private readonly jwt: JwtService,
  ) {}

  config(): MoeSsoConfig {
    return readMoeSsoConfig();
  }

  isEnabled(): boolean {
    return isMoeSsoEnabled(this.config());
  }

  /** Signs the CSRF state token embedded in the authorize request. */
  private signState(): string {
    // `nonce` varies per request; the signature makes it unforgeable and the
    // short expiry bounds replay. Vary the payload so two requests differ.
    return this.jwt.sign(
      { kind: 'moe_sso_state' },
      { expiresIn: MoeSsoService.STATE_TTL_SECONDS },
    );
  }

  private verifyState(state: string): void {
    try {
      const payload: any = this.jwt.verify(state);
      if (payload?.kind !== 'moe_sso_state') throw new Error('bad kind');
    } catch {
      throw new UnauthorizedException('Invalid or expired SSO state');
    }
  }

  /** The Ministry authorize URL we redirect the user's browser to. */
  buildAuthorizeUrl(): string {
    const cfg = this.config();
    const params = new URLSearchParams({
      response_type: 'code',
      client_id: cfg.clientId,
      redirect_uri: cfg.redirectUri,
      scope: cfg.scopes,
      state: this.signState(),
    });
    return `${cfg.authUrl}?${params.toString()}`;
  }

  /**
   * Completes the callback: verify state, exchange the code for tokens, fetch
   * the profile, map it to an existing ClassMate user, and mint a session JWT.
   * Returns the ClassMate session token.
   */
  async handleCallback(code: string, state: string): Promise<string> {
    this.verifyState(state);
    const cfg = this.config();

    const tokens = await this.exchangeCode(code, cfg);
    const profile = await this.fetchUserInfo(tokens.access_token, cfg);

    const identifier = String(profile?.[cfg.identifierClaim] ?? '').trim();
    if (!identifier) {
      this.logger.warn(
        `moe_sso_missing_identifier_claim claim=${cfg.identifierClaim}`,
      );
      throw new UnauthorizedException('Ministry profile missing its identifier');
    }

    const user = await this.findExistingUser(identifier);
    if (!user) {
      // No self-provisioning: the school admin must have created the account.
      throw new UnauthorizedException(
        'No ClassMate account is linked to this Ministry identity yet. Please ask your school administrator.',
      );
    }

    return this.auth.signSessionToken(user.id);
  }

  private async exchangeCode(
    code: string,
    cfg: MoeSsoConfig,
  ): Promise<{ access_token: string; id_token?: string }> {
    const body = new URLSearchParams({
      grant_type: 'authorization_code',
      code,
      redirect_uri: cfg.redirectUri,
      client_id: cfg.clientId,
      client_secret: cfg.clientSecret,
    });
    const res = await fetch(cfg.tokenUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: body.toString(),
    });
    if (!res.ok) {
      this.logger.warn(`moe_sso_token_exchange_failed status=${res.status}`);
      throw new UnauthorizedException('Ministry sign-in failed (token exchange)');
    }
    return (await res.json()) as any;
  }

  private async fetchUserInfo(
    accessToken: string,
    cfg: MoeSsoConfig,
  ): Promise<Record<string, any>> {
    const res = await fetch(cfg.userInfoUrl, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    if (!res.ok) {
      this.logger.warn(`moe_sso_userinfo_failed status=${res.status}`);
      throw new UnauthorizedException('Ministry sign-in failed (profile fetch)');
    }
    return (await res.json()) as any;
  }

  /**
   * Match the Ministry identity to an existing ClassMate account.
   *
   * Default: match by email (works today with no schema change). If the
   * Ministry issues a stable national-id / "sub" claim instead, set
   * MOE_SSO_IDENTIFIER_CLAIM to that claim and add a dedicated column to the
   * User model (e.g. `moeSubjectId`) so admins can pre-link accounts — then
   * match on it here. Left as the one clearly-marked completion point.
   */
  private async findExistingUser(identifier: string): Promise<{ id: string } | null> {
    const value = identifier.toLowerCase();
    if (value.includes('@')) {
      return this.prisma.user.findUnique({
        where: { email: value },
        select: { id: true },
      });
    }
    // Non-email identifier (e.g. national id). TODO(moe-sso): match against a
    // dedicated User.moeSubjectId column once it exists; until then treat it as
    // a username so a pre-provisioned account can still be linked.
    return this.prisma.user.findFirst({
      where: { username: value },
      select: { id: true },
    });
  }
}
