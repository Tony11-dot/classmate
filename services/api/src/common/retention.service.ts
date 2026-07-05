import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

const DAY_MS = 24 * 60 * 60 * 1000;

function retentionDays(envKey: string, fallback: number): number {
  const v = Number(process.env[envKey]);
  return Number.isFinite(v) && v > 0 ? v : fallback;
}

/**
 * Data-retention sweeper. Israeli Privacy Amendment 13 (and general data-
 * minimisation) expect defined retention periods rather than keeping personal
 * data forever. This purges *ephemeral / behavioural* data past its window:
 *
 *   - AnalyticsEvent       — product telemetry (default 365d)
 *   - StudentBrainEvent    — behavioural learning-analytics (default 365d)
 *   - VerificationCode     — one-time codes; row.target holds an email/phone,
 *                            so old rows are also PII (default 30d past expiry)
 *   - PasswordResetToken   — single-use reset tokens (default 30d)
 *
 * It deliberately does NOT touch authoritative academic records (grades,
 * attendance, certificates) — those are retained per the school's own policy.
 * Windows are overridable via env. The sweep runs shortly after boot and then
 * once a day; every step is isolated so a failure can never crash the app.
 */
@Injectable()
export class RetentionService implements OnModuleInit {
  private readonly logger = new Logger(RetentionService.name);
  private timer?: ReturnType<typeof setInterval>;

  constructor(private readonly prisma: PrismaService) {}

  onModuleInit() {
    // First sweep a little after boot so it never competes with startup work.
    setTimeout(() => void this.runOnce().catch(() => undefined), 30_000);
    this.timer = setInterval(
      () => void this.runOnce().catch(() => undefined),
      DAY_MS,
    );
    // Don't keep the process alive just for the timer.
    if (typeof this.timer?.unref === 'function') this.timer.unref();
  }

  async runOnce(): Promise<Record<string, number>> {
    const now = Date.now();
    const analyticsCut = new Date(now - retentionDays('RETAIN_ANALYTICS_DAYS', 365) * DAY_MS);
    const brainCut = new Date(now - retentionDays('RETAIN_BRAIN_DAYS', 365) * DAY_MS);
    const tokenCut = new Date(now - retentionDays('RETAIN_TOKENS_DAYS', 30) * DAY_MS);

    const results: Record<string, number> = {};
    const step = async (label: string, fn: () => Promise<{ count: number }>) => {
      try {
        results[label] = (await fn()).count;
      } catch (e) {
        this.logger.warn(`retention ${label} sweep failed: ${(e as Error).message}`);
      }
    };

    await step('analyticsEvent', () =>
      this.prisma.analyticsEvent.deleteMany({ where: { createdAt: { lt: analyticsCut } } }),
    );
    await step('studentBrainEvent', () =>
      this.prisma.studentBrainEvent.deleteMany({ where: { createdAt: { lt: brainCut } } }),
    );
    await step('verificationCode', () =>
      this.prisma.verificationCode.deleteMany({ where: { expiresAt: { lt: tokenCut } } }),
    );
    await step('passwordResetToken', () =>
      this.prisma.passwordResetToken.deleteMany({ where: { createdAt: { lt: tokenCut } } }),
    );

    const total = Object.values(results).reduce((a, b) => a + b, 0);
    if (total > 0) this.logger.log(`retention sweep purged ${JSON.stringify(results)}`);
    return results;
  }
}
