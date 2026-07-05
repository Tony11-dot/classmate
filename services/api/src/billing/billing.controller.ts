import { Controller, Get, Post, Req, UseGuards, Headers, HttpCode } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Public } from '../auth/public.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { ALL_APP_ROLES } from '../auth/roles';
import { TokensService } from './tokens.service';
import { SUBSCRIPTION_PLANS, TOPUP_PACKS } from './plan.catalog';
import { PrismaService } from '../prisma/prisma.service';
import { RevenueCatWebhookService } from './revenuecat.webhook';

@Controller('billing')
export class BillingController {
  constructor(
    private readonly tokens: TokensService,
    private readonly prisma: PrismaService,
    private readonly rcWebhook: RevenueCatWebhookService,
  ) {}

  /// Static plan catalog. The client renders the Plans screen from this
  /// — server-driven so we can adjust prices/quotas/copy without a Flutter
  /// release. Public (no auth) so the marketing landing page could also
  /// fetch it later.
  @Public()
  @Get('plans')
  plans() {
    return {
      ok: true,
      subscriptions: SUBSCRIPTION_PLANS,
      topups: TOPUP_PACKS,
    };
  }

  /// Returns the caller's current balance + active tier. Wraps
  /// TokensService.getBalance with a thin auth check.
  @UseGuards(JwtAuthGuard)
  @Roles(...ALL_APP_ROLES)
  @Get('me')
  async me(@Req() req: any) {
    const userId = String(req?.user?.sub ?? req?.user?.id ?? '');
    const snapshot = await this.tokens.getBalance(userId);
    return { ok: true, balance: snapshot };
  }

  /// RevenueCat sends every subscription event here — purchases,
  /// renewals, cancellations, refunds. Validated against the shared
  /// secret header; raw event stored in StoreWebhookEvent before
  /// processing so we can replay if our logic has a bug.
  ///
  /// @Public bypasses the global JwtAuthGuard — RC doesn't send a JWT,
  /// it sends our own webhook secret in the Authorization header which
  /// the RevenueCatWebhookService validates separately. Without @Public
  /// the JWT guard 401s every test event before it reaches our handler.
  @Public()
  @Post('webhooks/revenuecat')
  @HttpCode(200)
  async revenuecatWebhook(
    @Req() req: any,
    @Headers('authorization') auth?: string,
  ) {
    return this.rcWebhook.handle(req.body, auth ?? '');
  }
}
