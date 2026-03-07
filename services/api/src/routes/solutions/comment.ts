import { Router } from 'express';
import { prisma } from '../../lib/prisma';
import type { Router as ExpressRouter } from 'express';

const router: ExpressRouter = Router();

router.post('/:solutionId/comment', async (req: any, res) => {
  const userId = req.user?.id;
  const { solutionId } = req.params;
  const { body } = req.body;

  if (!body) {
    return res.status(400).json({ error: 'body required' });
  }

  const comment = await prisma.solutionComment.create({
    data: {
      body,
      solution: { connect: { id: solutionId } },
      author: { connect: { id: userId } },
    },
  });

  const commentCount = await prisma.solutionComment.count({
    where: { solution: { id: solutionId } },
  });

  res.json({
    ok: true,
    comment,
    commentCount,
  });
});

export default router;
