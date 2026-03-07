import { Router } from 'express';
import type { Router as ExpressRouter } from 'express';

const router: ExpressRouter = Router();

router.get('/health', async (_req, res) => {
  res.json({
    ok: true,
    service: 'classmate-api',
    time: new Date().toISOString(),
  });
});

export default router;
