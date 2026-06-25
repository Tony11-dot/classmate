/**
 * Single source of truth for the local-dev auth bypass.
 *
 * SECURITY: a bypass must require BOTH
 *   1. an explicit opt-in flag (`DEV_AUTH_BYPASS=1`), and
 *   2. a strict, exact non-production env name.
 *
 * The previous logic keyed off `appEnv.includes('dev')` alone, so any env
 * string containing "dev"/"test" (or a stray `DEV_AUTH_BYPASS`) silently
 * disabled every role check. Prod must never bypass: with the flag unset
 * (the default), this always returns false.
 */
export function isDevAuthBypassEnabled(): boolean {
  if (process.env.DEV_AUTH_BYPASS !== '1') return false;
  const appEnv = (process.env.APP_ENV ?? process.env.NODE_ENV ?? 'production')
    .trim()
    .toLowerCase();
  return appEnv === 'development' || appEnv === 'dev' || appEnv === 'test';
}
