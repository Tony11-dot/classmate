import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { TokensService } from './tokens.service';
import {
  findPlanByProductId,
  findTopupByProductId,
  SUBSCRIPTION_PLANS,
} from './plan.catalog';

/// RevenueCat sends a single webhook for every subscription / purchase
/// event across both Apple and Google. Their docs:
/// https://www.revenuecat.com/docs/integrations/webhooks
///
/// Why route through RevenueCat instead of direct Apple/Google webhooks:
///   - One integration covers iOS + Android (no duplicated parsing)
///   - Handles edge cases (grace periods, billing retries, family
///     sharing) without us re-implementing each store's quirks
///   - Sandbox events look identical to prod events with a flag
///
/// Auth: RevenueCat sends an `Authorization: Bearer <secret>` header
/// where the secret matches `REVENUECAT_WEBHOOK_SECRET` set in Railway.
/// We reject anything else with 401 so a leaked URL alone can't grant
/// tokens.

interface RcEvent {
  type: string;
  id: string;
  app_user_id: string;
  product_id?: string;
  /// Unix millis when the new period ends.
  expiration_at_ms?: number;
  /// 'INITIAL_PURCHASE' events have this; renewals too.
  store?: 'APP_STORE' | 'PLAY_STORE' | 'STRIPE' | string;
  /// Subscription identifier — stable across renewals.
  original_app_user_id?: string;
  original_transaction_id?: string;
  /// On RENEWAL / EXPIRATION the new state.
  is_trial_period?: boolean;
}

@Injectable()
export class RevenueCatWebhookService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly tokens: TokensService,
  ) {}

  async handle(body: any, authHeader: string): Promise<{ ok: true }> {
    const expected = process.env.REVENUECAT_WEBHOOK_SECRET;
    if (!expected) {
      // Don't accept any webhook if the secret isn't configured — that
      // would let anyone post here. Better to fail loudly than silently
      // grant entitlements.
      // eslint-disable-next-line no-console
      console.error('[rc.webhook] REVENUECAT_WEBHOOK_SECRET not set; rejecting');
      throw new UnauthorizedException('Webhook not configured');
    }
    const sent = (authHeader || '').replace(/^Bearer\s+/i, '').trim();
    if (sent !== expected) throw new UnauthorizedException('Bad webhook secret');

    const event: RcEvent = body?.event ?? body;
    const eventType = String(event?.type ?? '');
    const eventId = String(event?.id ?? '');
    const userId = String(event?.app_user_id ?? '').trim();

    // Persist the raw event FIRST so even if processing crashes we have
    // it for replay/inspection. The unique index on rcEventId makes
    // duplicate deliveries safe.
    try {
      await this.prisma.storeWebhookEvent.create({
        data: {
          provider: 'revenuecat',
          eventType,
          rcEventId: eventId || null,
          userId: userId || null,
          rawPayload: body as any,
        },
      });
    } catch (e: any) {
      if (e?.code === 'P2002') {
        // Duplicate eventId — already processed. RC retries on 5xx so this is normal.
        return { ok: true };
      }
      // eslint-disable-next-line no-console
      console.error('[rc.webhook] persist failed', e);
    }

    if (!userId) {
      // eslint-disable-next-line no-console
      console.error('[rc.webhook] no app_user_id on event', eventType);
      return { ok: true };
    }

    switch (eventType) {
      case 'INITIAL_PURCHASE':
      case 'RENEWAL':
        // Period boundary — bucket resets to the (possibly new) tier's
        // monthly quota.
        await this.applyPurchase(userId, event, 'reset');
        break;
      case 'PRODUCT_CHANGE':
        // Mid-period tier change. NEVER reduce the user's current
        // bucket — Apple's billing model means the user is paying for
        // the old tier until the period ends, so they keep those
        // tokens. On UPGRADE, bump the bucket up to the new (higher)
        // tier's quota immediately so the user gets what they paid for.
        // The next RENEWAL event will reset to the new tier's quota
        // cleanly.
        await this.applyPurchase(userId, event, 'preserve');
        break;
      case 'NON_RENEWING_PURCHASE':
        await this.applyTopup(userId, event);
        break;
      case 'CANCELLATION':
        await this.markCancelled(userId, event);
        break;
      case 'EXPIRATION':
        await this.markExpired(userId, event);
        break;
      case 'BILLING_ISSUE':
        await this.markBillingIssue(userId, event);
        break;
      case 'SUBSCRIPTION_PAUSED':
        await this.markPaused(userId, event);
        break;
      case 'REFUND':
        await this.handleRefund(userId, event);
        break;
      default:
        // TEST events / unknown types — ignore but keep the raw row.
        break;
    }

    await this.prisma.storeWebhookEvent.updateMany({
      where: { rcEventId: eventId },
      data: { processedAt: new Date() },
    });

    return { ok: true };
  }

  private async applyPurchase(
    userId: string,
    event: RcEvent,
    mode: 'reset' | 'preserve',
  ) {
    const plan = findPlanByProductId(event.product_id ?? '');
    if (!plan) {
      // eslint-disable-next-line no-console
      console.error('[rc.webhook] unknown product on purchase', event.product_id);
      return;
    }
    const expiresAt = event.expiration_at_ms
      ? new Date(event.expiration_at_ms)
      : new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // 30d safety

    // Mark prior active subs as EXPIRED so the user only has one
    // ACTIVE row at a time.
    await this.prisma.userSubscription.updateMany({
      where: { userId, status: 'ACTIVE' },
      data: { status: 'EXPIRED' },
    });

    await this.prisma.userSubscription.create({
      data: {
        userId,
        planTier: plan.tier,
        status: 'ACTIVE',
        store: this.storeKey(event.store),
        storeTransactionId: event.original_transaction_id ?? null,
        rcSubscriptionId: event.id,
        storeProductId: event.product_id ?? null,
        currentPeriodEnd: expiresAt,
      },
    });

    // Top-up bucket is always untouched — those carry over across
    // plan changes by design.
    if (mode === 'reset') {
      // INITIAL_PURCHASE / RENEWAL: bucket resets to the tier's full
      // monthly quota. Standard cycle behavior.
      await this.tokens.grant({
        userId,
        monthlyReset: plan.monthlyTokens,
        resetAt: expiresAt,
      });
    } else {
      // PRODUCT_CHANGE: tier change mid-period.
      //   - UPGRADE (new quota > current): bump bucket up so the user
      //     immediately gets what they paid for.
      //   - DOWNGRADE (new quota <= current): leave bucket alone. The
      //     user paid for the higher tier this period — they keep
      //     those tokens until the next RENEWAL boundary, then drop
      //     to the new tier's quota. This is the bug the user hit:
      //     downgrade was reducing 1M → 300K immediately.
      await this.tokens.grantPreservingFloor({
        userId,
        floor: plan.monthlyTokens,
        resetAt: expiresAt,
      });
    }
  }

  private async applyTopup(userId: string, event: RcEvent) {
    const pack = findTopupByProductId(event.product_id ?? '');
    if (!pack) {
      // eslint-disable-next-line no-console
      console.error('[rc.webhook] unknown top-up product', event.product_id);
      return;
    }
    await this.tokens.grant({ userId, topupAdd: pack.tokens });
  }

  private async markCancelled(userId: string, event: RcEvent) {
    await this.prisma.userSubscription.updateMany({
      where: { userId, rcSubscriptionId: event.id, status: 'ACTIVE' },
      data: { status: 'CANCELLED', cancelledAt: new Date() },
    });
  }

  private async markExpired(userId: string, event: RcEvent) {
    await this.prisma.userSubscription.updateMany({
      where: { userId, rcSubscriptionId: event.id },
      data: { status: 'EXPIRED' },
    });
    // Knock the user back to FREE quota.
    const freePlan = SUBSCRIPTION_PLANS.find((p) => p.tier === 'FREE')!;
    await this.tokens.grant({
      userId,
      monthlyReset: freePlan.monthlyTokens,
    });
  }

  private async markBillingIssue(userId: string, event: RcEvent) {
    await this.prisma.userSubscription.updateMany({
      where: { userId, rcSubscriptionId: event.id },
      data: { status: 'IN_GRACE_PERIOD' },
    });
  }

  private async markPaused(userId: string, event: RcEvent) {
    await this.prisma.userSubscription.updateMany({
      where: { userId, rcSubscriptionId: event.id },
      data: { status: 'ON_HOLD' },
    });
  }

  private async handleRefund(userId: string, event: RcEvent) {
    await this.prisma.userSubscription.updateMany({
      where: { userId, rcSubscriptionId: event.id },
      data: { status: 'REFUNDED' },
    });
    // Zero out tokens granted by this refunded purchase. We don't know
    // the exact granted amount after the user has spent some, so we
    // reset to FREE quota — simpler than reverse-accounting. The user
    // gets the refund from Apple/Google; we get the loss of margin.
    const freePlan = SUBSCRIPTION_PLANS.find((p) => p.tier === 'FREE')!;
    await this.tokens.grant({
      userId,
      monthlyReset: freePlan.monthlyTokens,
    });
  }

  private storeKey(rcStore?: string): string {
    switch ((rcStore ?? '').toUpperCase()) {
      case 'APP_STORE':
        return 'apple';
      case 'PLAY_STORE':
        return 'google';
      case 'STRIPE':
        return 'web';
      default:
        return 'unknown';
    }
  }
}
