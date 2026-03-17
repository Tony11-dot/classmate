import { PersistentVectorStore, VectorEntry } from '../vector/persistent/persistent-vector-store';

export class DomainPackBuilder {
  private store = new PersistentVectorStore();

  async build(topic: string, facts: string[]) {
    const entries: VectorEntry[] = facts.map((fact) => ({
      id: `${topic}:${fact.slice(0, 20)}`,
      vector: this.embed(fact),
      metadata: {
        topic,
        fact,
      },
    }));

    this.store.add(entries);
  }

  private embed(text: string): number[] {
    // simple fake embedding (replace later with real one)
    return Array.from({ length: 10 }, (_, i) => text.length % (i + 1));
  }
}
