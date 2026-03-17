type Scored<T> = { item: T; score: number };

export class RankingService {
  rank<T extends { vector: number[]; metadata?: any }>(
    query: number[],
    items: T[],
  ): T[] {
    const scored: Scored<T>[] = items.map((item) => ({
      item,
      score: this.score(query, item),
    }));

    return scored
      .sort((a, b) => b.score - a.score)
      .map((s) => s.item);
  }

  private score(query: number[], item: { vector: number[]; metadata?: any }) {
    const sim = this.cosine(query, item.vector);

    // optional signals
    const recencyBoost = item.metadata?.createdAt
      ? this.recency(item.metadata.createdAt)
      : 1;

    const confidenceBoost = item.metadata?.confidence ?? 1;

    return sim * recencyBoost * confidenceBoost;
  }

  private cosine(a: number[], b: number[]) {
    const dot = a.reduce((sum, v, i) => sum + v * (b[i] || 0), 0);
    const magA = Math.sqrt(a.reduce((sum, v) => sum + v * v, 0));
    const magB = Math.sqrt(b.reduce((sum, v) => sum + v * v, 0));
    return dot / (magA * magB + 1e-8);
  }

  private recency(date: string | number) {
    const age = Date.now() - new Date(date).getTime();
    const days = age / (1000 * 60 * 60 * 24);
    return 1 / (1 + days * 0.05); // decay
  }
}
