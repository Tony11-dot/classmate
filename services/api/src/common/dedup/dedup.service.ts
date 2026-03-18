import { redis } from '../redis/redis.client';

export class DedupService {
  async acquire(key: string): Promise<boolean> {
    const lockKey = `lock:${key}`;

    // use raw args (works with ALL ioredis typings)
    const res = await redis.set(
      lockKey,
      '1',
      'EX',
      5,
      'NX'
    );

    return res === 'OK';
  }

  async release(key: string) {
    const lockKey = `lock:${key}`;
    await redis.del(lockKey);
  }
}
