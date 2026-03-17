import { Injectable } from '@nestjs/common';
import { RetrievalService } from './retrieval.service';
import { GroundedGeneratorService } from './grounded-generator.service';

@Injectable()
export class GroundedPracticeService {
  constructor(
    private readonly retrieval: RetrievalService = new RetrievalService(),
    private readonly generator: GroundedGeneratorService = new GroundedGeneratorService(),
  ) {}

  async generate(input: {
    subject: string;
    topic: string;
    difficulty: string;
    count: number;
  }) {
    const chunks = await this.retrieval.retrieve({
      subject: input.subject,
      topic: input.topic,
    });

    if (!chunks.length) {
      return { questions: [], grounded: false };
    }

    const questions = await this.generator.generate({
      subject: input.subject,
      topic: input.topic,
      difficulty: input.difficulty,
      count: input.count,
      chunks,
    });

    return {
      questions,
      grounded: true,
      sources: chunks.map(c => c.source),
    };
  }
}
