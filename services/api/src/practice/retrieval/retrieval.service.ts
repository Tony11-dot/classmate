import { Injectable } from '@nestjs/common';

import { EmbeddingService } from './embedding.service';
import { InMemoryVectorStore } from './vector/vector-store';

export type RetrievedChunk = {
  content: string;
  source: string;
};

@Injectable()
export class RetrievalService {
  private store = new InMemoryVectorStore();

  constructor(
    private readonly embedding: EmbeddingService = new EmbeddingService(),
  ) {}

  private chunk(text: string, size = 300): string[] {
    const chunks: string[] = [];
    for (let i = 0; i < text.length; i += size) {
      chunks.push(text.slice(i, i + size));
    }
    return chunks;
  }

  async retrieve(input: {
    subject: string;
    topic: string;
  }): Promise<RetrievedChunk[]> {
    const query = encodeURIComponent(input.topic);

    try {
      const res = await fetch(
        `https://en.wikipedia.org/api/rest_v1/page/summary/${query}`
      );
      const data: any = await res.json();

      if (!data.extract) return [];

      const chunks = this.chunk(data.extract);

      // index chunks
      for (const c of chunks) {
        const emb = await this.embedding.embed(c);
        this.store.add({
          id: Math.random().toString(),
          content: c,
          embedding: emb,
          source: `wikipedia:${input.topic}`,
        });
      }

      // query embedding
      const queryEmb = await this.embedding.embed(input.topic);

      const results = this.store.search(queryEmb, 3);

      return results.map(r => ({
        content: r.content,
        source: r.source,
      }));
    } catch {
      return [];
    }
  }
}
