import { Injectable } from '@nestjs/common';
import { EmbeddingService } from './vector/embedding.service';
import { RankingService } from './ranking.service';
import { PersistentVectorStore } from './vector/persistent/persistent-vector-store';

@Injectable()
export class RetrievalService {
  private embedder = new EmbeddingService();
  private ranker = new RankingService();
  private persistentStore = new PersistentVectorStore();

  async retrieve(input: { subject: string; topic: string }) {
    const query = `${input.subject} ${input.topic}`;

    const queryEmbedding = await this.embedder.embed(query);

    // existing sources (if any logic exists later, keep simple fallback)
    const results: any[] = [];

    const persistent = this.persistentStore.search(queryEmbedding, 5);

    const combined = [...persistent, ...results];

    return this.ranker.rank(queryEmbedding, combined).slice(0, 5);
  }
}
