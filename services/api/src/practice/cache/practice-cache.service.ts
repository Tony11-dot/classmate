import { redis } from '../../common/redis/redis.client';

export class PracticeCacheService {
  async get(key: string) {
    const v = await redis.get(key);
    return v ? JSON.parse(v) : null;
  }

  async set(key: string, value: any, ttl = 60) {
    await redis.set(key, JSON.stringify(value), 'EX', ttl);
  }
}
