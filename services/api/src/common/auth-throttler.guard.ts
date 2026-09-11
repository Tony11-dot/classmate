import { ExecutionContext, Injectable } from '@nestjs/common';
import { ThrottlerGuard } from '@nestjs/throttler';

/// Custom throttler guard that scopes the strict `auth` bucket per-account
/// instead of per-IP-only.
///
/// The stock guard keys every login request from an IP into one shared bucket,
/// so hitting 5 logins in 15 minutes trips the 429 — even when they're 5
/// *different, successful* accounts. That bit QA hard: signing into 5 roles
/// back-to-back from one browser 429'd the last one ("You're making requests
/// too quickly"), and it bites any real user who has several accounts on one
/// device (the account switcher).
///
/// Folding the login identifier into the key gives each account its own
/// budget, so multi-account use never collides — while per-account brute-force
/// defence is unchanged (still 5 tries / 15 min against any single account),
/// and the global `default` bucket (1200/min/IP) remains the blanket backstop.
@Injectable()
export class AuthThrottlerGuard extends ThrottlerGuard {
  protected generateKey(context: ExecutionContext, suffix: string, name: string): string {
    if (name === 'auth') {
      const req = context.switchToHttp().getRequest();
      const body = (req?.body ?? {}) as Record<string, unknown>;
      const identifier = String(
        body.identifier ?? body.email ?? body.username ?? '',
      )
        .trim()
        .toLowerCase();
      if (identifier) {
        // suffix is the IP tracker; append the account so distinct accounts
        // from the same IP get distinct buckets.
        return super.generateKey(context, `${suffix}:${identifier}`, name);
      }
    }
    return super.generateKey(context, suffix, name);
  }
}
