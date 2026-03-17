import { Injectable } from '@nestjs/common';
import { RetrievalService } from './retrieval.service';
import { GroundedGeneratorService } from './grounded-generator.service';
import { DomainPackBuilder } from './domain-builder/domain-pack.builder';

@Injectable()
export class GroundedPracticeService {
  private domainBuilder = new DomainPackBuilder();

  constructor(
    private readonly retrieval: RetrievalService,
    private readonly generator: GroundedGeneratorService = new GroundedGeneratorService(),
  ) {}

  async generate(input: {
    subject: string;
    topic: string;
    difficulty: string;
    count: number;
  }) {
    const topic = input.topic;

    const chunks = await this.retrieval.retrieve({
      subject: input.subject,
      topic,
    });

    // ============================================
    // AUTO DOMAIN LEARNING (SAFE)
    // ============================================
    if (!chunks.length && topic) {
      const generatedFacts = [
        `${topic} is a core concept.`,
        `${topic} includes key principles and applications.`,
        `${topic} is studied within its domain.`,
      ];

      await this.domainBuilder.build(topic, generatedFacts);

      return {
        questions: [],
        grounded: false,
        learned: true,
      };
    }

    const questions = await this.generator.generate({
      subject: input.subject,
      topic,
      difficulty: input.difficulty,
      count: input.count,
      chunks,
    });

    return {
      questions,
      grounded: true,
      sources: chunks.map((c: any) => c.source),
    };
  }
}
