export type VectorEntry = {
  id: string;
  vector: number[];
  metadata: Record<string, any>;
};

export class PersistentVectorStore {
  private store: VectorEntry[] = [];

  add(entries: VectorEntry[]) {
    this.store.push(...entries);
  }

  search(query: number[], k: number): VectorEntry[] {
    // naive similarity (dot product)
    const scored = this.store.map(e => ({
      entry: e,
      score: this.dot(query, e.vector),
    }));

    return scored
      .sort((a, b) => b.score - a.score)
      .slice(0, k)
      .map(s => s.entry);
  }

  private dot(a: number[], b: number[]) {
    return a.reduce((sum, v, i) => sum + v * (b[i] || 0), 0);
  }
}
