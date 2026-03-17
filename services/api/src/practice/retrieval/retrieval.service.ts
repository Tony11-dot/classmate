import { Injectable } from '@nestjs/common';

export type RetrievedChunk = {
  content: string;
  source: string;
};

@Injectable()
export class RetrievalService {
  async retrieve(input: {
    subject: string;
    topic: string;
  }): Promise<RetrievedChunk[]> {
    const query = `${input.subject} ${input.topic}`;

    // TEMP: simple grounded retrieval via curated prompts
    // (NEXT: replace with embeddings/vector DB)

    // For now → simulate strong grounding
    return [
      {
        source: 'internal_seed',
        content: `Explain ${query} with accurate academic detail, definitions, mechanisms, and key facts.`,
      },
    ];
  }
}
