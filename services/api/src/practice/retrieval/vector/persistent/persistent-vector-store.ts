export type VectorEntry = {
  id: string;
  vector: number[];
  metadata: any;
  score?: number;
};

export class PersistentVectorStore {
  private store: VectorEntry[] = [];

  search(queryVector: number[], k: number): VectorEntry[] {
    return this.store.slice(0, k);
  }

  add(entry: VectorEntry | VectorEntry[]) {
    if (Array.isArray(entry)) {
      for (const e of entry) {
        this.store.push({ ...e, score: e.score ?? 0 });
      }
    } else {
      this.store.push({ ...entry, score: entry.score ?? 0 });
    }
  }
}
