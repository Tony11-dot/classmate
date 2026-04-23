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

    const results: any[] = [];
    const persistent = this.persistentStore.search(queryEmbedding, 5);

    const combined = [...persistent, ...results];

    const ranked = this.ranker.rank(queryEmbedding, combined);

    const feedbackBoosted = ranked.map((item: any) => {
      if (item.metadata?.correct === true) item.score += 0.1;
      if (item.metadata?.correct === false) item.score -= 0.1;
      return item;
    });

    return feedbackBoosted
      .sort((a: any, b: any) => b.score - a.score)
      .slice(0, 5);
  }
}
