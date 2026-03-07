import { Module } from '@nestjs/common';
import { PrismaModule } from '../../prisma/prisma.module';
import { FeedProjectionService } from './feed-projection.service';
import { OutboxRunnerService } from './outbox-runner.service';

@Module({
  imports: [PrismaModule],
  providers: [FeedProjectionService, OutboxRunnerService],
  exports: [FeedProjectionService, OutboxRunnerService],
})
export class ProjectionsModule {}
