import { PrismaClient } from '@prisma/client';
import { FeedProjectionService } from '../src/modules/projections/feed-projection.service';

async function main() {
  const prisma = new PrismaClient();
  const feed = new FeedProjectionService(prisma as any);

  const solutions = await prisma.solution.findMany({
    select: { id: true },
    orderBy: [{ createdAt: 'asc' }],
  });

  for (const s of solutions) {
    await feed.projectSolutionCreated(s.id);
  }

  console.log({ backfilled: solutions.length });
  await prisma.$disconnect();
}

main().catch(async (e) => {
  console.error(e);
  process.exit(1);
});
