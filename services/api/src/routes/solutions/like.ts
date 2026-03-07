import { Router } from 'express';
import { prisma } from '../../lib/prisma';
import type { Router as ExpressRouter } from 'express';

const router: ExpressRouter = Router();

router.post('/:id/like', async (req: any, res) => {
  const userId = req.user.id;
  const solutionId = req.params.id;

  const existing = await prisma.solutionLike.findUnique({
    where: {
      solutionId_userId: {
        userId,
        solutionId,
      },
    },
  });

  if (existing) {
    await prisma.solutionLike.delete({
      where: {
        solutionId_userId: {
          userId,
          solutionId,
        },
      },
    });

    return res.json({ liked: false });
  }

  await prisma.solutionLike.create({
    data: {
      userId,
      solutionId,
    },
  });

  res.json({ liked: true });
});

export default router;
