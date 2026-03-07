import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { FeedProjectionService } from './feed-projection.service';

@Injectable()
export class OutboxRunnerService {
  private readonly logger = new Logger(OutboxRunnerService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly feedProjection: FeedProjectionService,
  ) {}

  async runOnce(limit = 50) {
    const events = await this.prisma.outboxEvent.findMany({
      where: {
        processedAt: null,
      },
      orderBy: [{ createdAt: 'asc' }],
      take: limit,
    });

    for (const event of events) {
      try {
        switch (event.type) {
          case 'solution.created':
            if (event.aggregateId) {
              await this.feedProjection.projectSolutionCreated(
                event.aggregateId,
              );
            }
            break;
          case 'solution.liked':
          case 'solution.unliked':
          case 'solution.commented':
          case 'solution.reposted':
            if (event.aggregateId) {
              await this.feedProjection.projectSolutionCounters(
                event.aggregateId,
              );
            }
            break;
          default:
            break;
        }

        await this.prisma.outboxEvent.update({
          where: { id: event.id },
          data: {
            processedAt: new Date(),
            failedAt: null,
            error: null,
          },
        });
      } catch (error) {
        const message =
          error instanceof Error ? error.message : 'Unknown outbox error';

        this.logger.error(`${event.type} failed: ${message}`);

        await this.prisma.outboxEvent.update({
          where: { id: event.id },
          data: {
            failedAt: new Date(),
            retryCount: { increment: 1 },
            error: message.slice(0, 1000),
          },
        });
      }
    }

    return { processed: events.length, ids: events.map((e) => e.id) };
  }
}
