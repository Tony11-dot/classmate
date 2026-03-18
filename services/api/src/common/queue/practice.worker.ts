import { Worker } from 'bullmq';

const enabled =
  process.env.NODE_ENV !== 'test' &&
  process.env.ENABLE_PRACTICE_WORKER === 'true';

export const practiceWorker = !enabled
  ? null
  : new Worker(
      'practice',
      async (job) => job.data,
      {
        connection: {
          host: process.env.REDIS_HOST || 'redis',
          port: Number(process.env.REDIS_PORT || 6379),
        },
      },
    );

export async function closePracticeWorker() {
  if (practiceWorker) await practiceWorker.close();
}
