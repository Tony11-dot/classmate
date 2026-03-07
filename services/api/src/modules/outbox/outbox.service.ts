import { Injectable } from '@nestjs/common';
import { Prisma, PrismaClient } from '@prisma/client';
import { OutboxEventPayload, OutboxEventType } from './outbox.types';

@Injectable()
export class OutboxService {
  async publish(
    db: Prisma.TransactionClient | PrismaClient,
    input: {
      type: OutboxEventType;
      aggregateId?: string | null;
      payload: OutboxEventPayload;
      availableAt?: Date;
    },
  ) {
    return db.outboxEvent.create({
      data: {
        type: input.type,
        aggregateId: input.aggregateId ?? null,
        payload: input.payload as Prisma.InputJsonValue,
        availableAt: input.availableAt ?? new Date(),
      },
    });
  }
}
