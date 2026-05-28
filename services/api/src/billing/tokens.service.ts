import {
  BadRequestException,
  HttpException,
  HttpStatus,
  Injectable,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { computeCost, extractAnthropicUsage } from './cost.model';
import { findPlanByTier, freeQuota } from './plan.catalog';

/// Pulls our internal user id out of the JWT-decoded `req.user` blob.
/// Centralised so every AI call site uses the same fallback order
/// (`sub` is the JWT subject we set in auth, but older code paths
/// stamp `id` / `userId`).
export function userIdFromReq(user: any): string {
  return String(user?.sub ?? user?.id ?? user?.userId ?? '').trim();
}

/// Thrown when a user tries to use NOVA / Practice / etc. but has 0
/// remaining tokens. The HTTP layer maps it to 402 Payment Required so
/// the client can detect it without parsing error messages.
export class OutOfTokensError extends HttpException {
  constructor(remaining: number) {
    super(
      {
        ok: false,
        error: 'OUT_OF_TOKENS',
        message:
          'You have used all your tokens for this period. Upgrade your plan or buy a top-up to continue.',
        remaining,
      },
      HttpStatus.PAYMENT_REQUIRED,
    );
  }
}

export interface BalanceSnapshot {
  planTokensRemaining: number;
  topupTokensRemaining: number;
  totalRemaining: number;
  resetAt: Date | null;
  activeTier: string; // 'FREE' | 'BUDGET' | 'BALANCE' | 'COMMITMENT'
}

@Injectable()
export class TokensService {
  constructor(private readonly prisma: PrismaService) {}

  /// Returns the user's current balance, lazily creating a row + seeding
  /// the FREE quota on first read. Idempotent — repeat calls on an
  /// already-seeded user just read the existing row.
  async getBalance(userId: string): Promise<BalanceSnapshot> {
    const [balance, activeSub] = await Promise.all([
      this.prisma.tokenBalance.findUnique({ where: { userId } }),
      this.prisma.userSubscription.findFirst({
        where: { userId, status: 'ACTIVE' },
        orderBy: { startedAt: 'desc' },
      }),
    ]);

    if (!balance) {
      const seeded = await this.prisma.tokenBalance.upsert({
        where: { userId },
        create: {
          userId,
          planTokensRemaining: freeQuota(),
          topupTokensRemaining: 0,
          resetAt: this.nextMonthStart(),
        },
        update: {},
      });
      return {
        planTokensRemaining: seeded.planTokensRemaining,
        topupTokensRemaining: seeded.topupTokensRemaining,
        totalRemaining: seeded.planTokensRemaining + seeded.topupTokensRemaining,
        resetAt: seeded.resetAt,
        activeTier: activeSub?.planTier ?? 'FREE',
      };
    }

    // Auto-reset the plan bucket if the period has rolled over.  This
    // is a safety net — the webhook is supposed to bump resetAt on each
    // renewal, but if the webhook is delayed (or the user is on FREE
    // and there's no webhook), this lazy-reset keeps the experience
    // working without manual intervention.
    if (balance.resetAt && balance.resetAt <= new Date()) {
      const quota = activeSub
        ? findPlanByTier(activeSub.planTier)?.monthlyTokens ?? freeQuota()
        : freeQuota();
      const next = await this.prisma.tokenBalance.update({
        where: { userId },
        data: {
          planTokensRemaining: quota,
          resetAt: this.nextMonthStart(),
        },
      });
      return {
        planTokensRemaining: next.planTokensRemaining,
        topupTokensRemaining: next.topupTokensRemaining,
        totalRemaining: next.planTokensRemaining + next.topupTokensRemaining,
        resetAt: next.resetAt,
        activeTier: activeSub?.planTier ?? 'FREE',
      };
    }

    return {
      planTokensRemaining: balance.planTokensRemaining,
      topupTokensRemaining: balance.topupTokensRemaining,
      totalRemaining: balance.planTokensRemaining + balance.topupTokensRemaining,
      resetAt: balance.resetAt,
      activeTier: activeSub?.planTier ?? 'FREE',
    };
  }

  /// Cheap pre-flight check. Call this BEFORE kicking off an AI request
  /// so we 402 before paying Anthropic. Doesn't deduct — that's
  /// `commitUsage`'s job after we know the actual token counts.
  async assertHasTokens(userId: string): Promise<void> {
    const b = await this.getBalance(userId);
    if (b.totalRemaining <= 0) {
      throw new OutOfTokensError(0);
    }
  }

  /// Record a completed AI call and deduct from the user's balance.
  /// Drains the plan bucket first, then top-ups. Atomic — if the
  /// balance row is mutated concurrently the second update sees the
  /// post-first-update state and adjusts accordingly.
  async commitUsage(params: {
    userId: string;
    source: string; // 'nova' | 'practice' | 'tutor' | ...
    model: string;
    inputTokens: number;
    cachedInputTokens: number;
    outputTokens: number;
  }): Promise<{ tokensCharged: number; costUsd: number }> {
    const { userId, source, model, inputTokens, cachedInputTokens, outputTokens } = params;
    if (!userId) throw new BadRequestException('userId required for usage logging');

    const cost = computeCost(model, inputTokens, cachedInputTokens, outputTokens);

    // Run inside a transaction so the balance update + usage log are
    // tied to the same DB snapshot. If either fails the whole thing
    // rolls back.
    await this.prisma.$transaction(async (tx) => {
      // Ensure balance row exists so the decrement below has a target.
      const balance = await tx.tokenBalance.upsert({
        where: { userId },
        create: {
          userId,
          planTokensRemaining: freeQuota(),
          topupTokensRemaining: 0,
          resetAt: this.nextMonthStart(),
        },
        update: {},
      });

      let charge = cost.tokensCharged;

      // Drain plan bucket first.
      const planSpent = Math.min(balance.planTokensRemaining, charge);
      charge -= planSpent;

      // Then drain top-ups for any remainder. We let the balance go
      // slightly negative if both buckets are empty — that way a user
      // who slipped past the pre-flight check (race condition) still
      // gets their reply and we just owe them on margin. Cheap insurance.
      const topupSpent = Math.min(balance.topupTokensRemaining, charge);
      charge -= topupSpent;

      await tx.tokenBalance.update({
        where: { userId },
        data: {
          planTokensRemaining: { decrement: planSpent },
          topupTokensRemaining: { decrement: topupSpent },
        },
      });

      await tx.tokenUsage.create({
        data: {
          userId,
          source,
          model,
          inputTokens,
          cachedInputTokens,
          outputTokens,
          tokensCharged: cost.tokensCharged,
          costUsd: cost.costUsd,
        },
      });
    });

    return cost;
  }

  /// Convenience: charge a finished Anthropic response in one call.
  /// Accepts the raw response (or its `.usage` block) plus the source
  /// label + model the call used. Swallowed on missing userId — we never
  /// want a billing failure to break an AI call that already succeeded.
  async chargeAnthropicResponse(params: {
    userId: string;
    source: string;
    model: string;
    response: any;
  }): Promise<void> {
    const { userId, source, model, response } = params;
    if (!userId) return;
    const usage = extractAnthropicUsage(response);
    try {
      await this.commitUsage({ userId, source, model, ...usage });
    } catch (e) {
      // Never let a billing write break a successful AI call.
      // eslint-disable-next-line no-console
      console.error('[billing] commitUsage failed:', e);
    }
  }

  /// Grant tokens (called by RevenueCat webhook on renewal / purchase).
  /// `monthlyReset` resets the plan bucket; `topupAdd` increments top-ups
  /// without touching the plan bucket.
  async grant(params: {
    userId: string;
    monthlyReset?: number;
    topupAdd?: number;
    resetAt?: Date;
  }): Promise<void> {
    const { userId, monthlyReset, topupAdd, resetAt } = params;
    await this.prisma.tokenBalance.upsert({
      where: { userId },
      create: {
        userId,
        planTokensRemaining: monthlyReset ?? freeQuota(),
        topupTokensRemaining: topupAdd ?? 0,
        resetAt: resetAt ?? this.nextMonthStart(),
      },
      update: {
        ...(monthlyReset !== undefined ? { planTokensRemaining: monthlyReset } : {}),
        ...(topupAdd !== undefined ? { topupTokensRemaining: { increment: topupAdd } } : {}),
        ...(resetAt !== undefined ? { resetAt } : {}),
      },
    });
  }

  /// Used by the webhook on PRODUCT_CHANGE (mid-period tier change).
  /// Sets planTokensRemaining = max(current, floor) — i.e. UPGRADE
  /// bumps the bucket up to the new tier's ceiling so the user
  /// immediately gets the larger allocation; DOWNGRADE leaves the
  /// bucket alone so the user keeps the tokens they already paid for
  /// during this billing period. The next RENEWAL fires a regular
  /// grant() with the new tier's quota, which is when downgrades
  /// actually take effect on the bucket.
  async grantPreservingFloor(params: {
    userId: string;
    floor: number;
    resetAt?: Date;
  }): Promise<void> {
    const { userId, floor, resetAt } = params;
    const existing = await this.prisma.tokenBalance.findUnique({
      where: { userId },
      select: { planTokensRemaining: true },
    });
    const currentRemaining = existing?.planTokensRemaining ?? 0;
    const nextValue = Math.max(currentRemaining, floor);
    await this.prisma.tokenBalance.upsert({
      where: { userId },
      create: {
        userId,
        planTokensRemaining: nextValue,
        topupTokensRemaining: 0,
        resetAt: resetAt ?? this.nextMonthStart(),
      },
      update: {
        planTokensRemaining: nextValue,
        ...(resetAt !== undefined ? { resetAt } : {}),
      },
    });
  }

  private nextMonthStart(): Date {
    const d = new Date();
    return new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth() + 1, 1));
  }
}
