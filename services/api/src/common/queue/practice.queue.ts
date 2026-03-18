import { Queue } from 'bullmq';

export const practiceQueue = new Queue('practice', {
  connection: {
    host: '127.0.0.1',
    port: 6379,
  },
});
