import { Worker } from 'bullmq';

const enabled = process.env.NODE_ENV !== 'test';

export const practiceWorker = !enabled
  ? null
  : new Worker(
      'practice',
      async (job) => job.data,
      {
        connection: {
          host: process.env.REDIS_HOST || '127.0.0.1',
          port: Number(process.env.REDIS_PORT || 6379),
        },
      },
    );
