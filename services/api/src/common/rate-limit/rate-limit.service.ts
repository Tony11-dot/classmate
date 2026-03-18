import { redis } from '../redis/redis.client';

export class RateLimitService {
  async check(userId: string, limit = 30, windowSec = 60) {
    const key = `rate:${userId}`;

    const count = await redis.incr(key);

    if (count === 1) {
      await redis.expire(key, windowSec);
    }

    if (count > limit) {
      throw new Error('RATE_LIMIT_EXCEEDED');
    }
  }
}
