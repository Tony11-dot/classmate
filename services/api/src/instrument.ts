// Sentry bootstrap. Imported on the VERY FIRST line of main.ts so the SDK
// is initialised before Nest (and the modules it instruments) load.
//
// Entirely env-gated: with no SENTRY_DSN set this is a no-op, so local dev,
// tests, and any environment without the key are completely unaffected.
// captureException() elsewhere also no-ops safely when Sentry isn't init'd.
//
// To turn it on: set SENTRY_DSN (+ optional SENTRY_ENV) in the Railway
// service variables and redeploy. No code change needed.
import * as Sentry from '@sentry/node';

const dsn = process.env.SENTRY_DSN;

if (dsn) {
  Sentry.init({
    dsn,
    environment:
      process.env.SENTRY_ENV || process.env.NODE_ENV || 'production',
    // Railway injects the commit SHA — use it as the release so a stack
    // trace in Sentry points at the exact deploy that produced it.
    release: process.env.RAILWAY_GIT_COMMIT_SHA || undefined,
    // Errors only — no performance tracing. Zero added request latency and
    // it keeps us well inside Sentry's free event quota.
    tracesSampleRate: 0,
  });
}

export { Sentry };
