import { WeightStore } from './adaptive/weight-store';

export class RankingService {
  private weights = new WeightStore();

  rank(queryVector: number[], items: any[]) {
    const w = this.weights.get();

    return items.map((item: any) => {
      let similarity = 0;
      let recency = 0;
      let confidence = 0;

      if (item.vector && queryVector) {
        similarity = this.cosineSimilarity(queryVector, item.vector);
      }

      if (item.metadata?.timestamp) {
        const age = Date.now() - item.metadata.timestamp;
        recency = Math.max(0, 1 - age / (1000 * 60 * 60 * 24));
      }

      if (item.metadata?.confidence) {
        confidence = item.metadata.confidence;
      }

      const score =
        w.similarity * similarity +
        w.recency * recency +
        w.confidence * confidence;

      return { ...item, score, signals: { similarity, recency, confidence } };
    }).sort((a, b) => b.score - a.score);
  }

  updateWeights(items: any[], success: boolean) {
    const top = items[0];
    if (!top || !top.signals) return;

    const factor = success ? 0.05 : -0.05;

    this.weights.update({
      similarity: top.signals.similarity * factor,
      recency: top.signals.recency * factor,
      confidence: top.signals.confidence * factor,
    });
  }

  cosineSimilarity(a: number[], b: number[]) {
    const dot = a.reduce((sum, val, i) => sum + val * (b[i] || 0), 0);
    const magA = Math.sqrt(a.reduce((sum, val) => sum + val * val, 0));
    const magB = Math.sqrt(b.reduce((sum, val) => sum + val * val, 0));
    if (!magA || !magB) return 0;
    return dot / (magA * magB);
  }

  debug(items: any[]) {
    console.log(
      'RANKING_DEBUG',
      items.map((i: any) => ({
        score: i.score,
        topic: i.metadata?.topic,
        correct: i.metadata?.correct,
        signals: i.signals,
      }))
    );

    console.log('WEIGHTS', this.weights.get());
  }
}
