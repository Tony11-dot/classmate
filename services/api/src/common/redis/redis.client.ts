import Redis from 'ioredis';

// Redis is optional (used by the practice queue/dedup, which aren't on the
// request hot path). When no Redis is configured, the default client connected
// eagerly to 127.0.0.1:6379 and spammed the logs with "Unhandled error event:
// ECONNREFUSED" on a tight retry loop. Make it lazy + quiet: don't connect
// until something actually uses it, cap retries, and swallow connection errors
// so a missing Redis doesn't flood the logs.
export const redis = new Redis({
  host: process.env.REDIS_HOST || '127.0.0.1',
  port: Number(process.env.REDIS_PORT || 6379),
  lazyConnect: true,
  enableOfflineQueue: false,
  maxRetriesPerRequest: 1,
  // Stop retrying the connection after a couple of attempts when Redis is
  // absent, instead of an infinite reconnect storm.
  retryStrategy: (times) => (times > 2 ? null : 200),
});

// Never let an unhandled 'error' event crash the process or spam logs when
// Redis isn't available. Log once-ish at debug level instead.
let loggedRedisError = false;
redis.on('error', (err) => {
  if (!loggedRedisError) {
    loggedRedisError = true;
    // eslint-disable-next-line no-console
    console.warn('[redis] unavailable (optional) — continuing without it:', err?.message ?? err);
  }
});
