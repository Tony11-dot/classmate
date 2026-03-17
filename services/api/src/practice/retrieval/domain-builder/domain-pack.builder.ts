import { PersistentVectorStore, VectorEntry } from '../vector/persistent/persistent-vector-store';
import { EmbeddingService } from '../vector/embedding.service';

export class DomainPackBuilder {
  private store = new PersistentVectorStore();
  private embedder = new EmbeddingService();

  async build(topic: string, facts: string[]) {
    const entries: VectorEntry[] = [];

    for (const fact of facts) {
      const vector = await this.embedder.embed(fact);

      entries.push({
        id: `${topic}:${fact.slice(0, 20)}`,
        vector,
        metadata: {
          topic,
          fact,
        },
      });
    }

    this.store.add(entries as any);
  }
}
