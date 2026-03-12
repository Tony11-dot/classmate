import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class BagrutService {
  constructor(private prisma: PrismaService) {}

  async getQuestion(subject: string, topic: string) {
    return this.prisma.bagrutQuestion.findFirst({
      where: {
        subject,
        topicLabel: topic,
      },
      orderBy: {
        year: 'desc',
      },
    });
  }

  async getExam(subject: string) {
    return this.prisma.bagrutQuestion.findMany({
      where: { subject },
      orderBy: { year: 'desc' },
      take: 6,
    });
  }
}
