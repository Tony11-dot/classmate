import { Injectable } from '@nestjs/common';
import { EmbeddingService } from './embedding.service';
import { InMemoryVectorStore } from './vector/vector-store';
import { MultiSourceService } from './multi-source.service';

@Injectable()
export class RetrievalService {
  private store = new InMemoryVectorStore();

  constructor(
    private readonly embedding: EmbeddingService,
    private readonly multi: MultiSourceService,
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
  }) {
    const raw = await this.multi.fetch(input.topic);

    for (const r of raw) {
      const pieces = this.chunk(r.content);

      for (const p of pieces) {
        const emb = await this.embedding.embed(p);

        this.store.add({
          id: Math.random().toString(),
          content: p,
          embedding: emb,
          source: r.source,
        });
      }
    }

    const queryEmb = await this.embedding.embed(input.topic);

    const results = this.store.search(queryEmb, 5);

    return results;
  }
}
