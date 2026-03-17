export class RankingService {
  rank(queryVector: number[], items: any[]) {
    return items.map((item: any) => {
      let score = 0;

      // semantic similarity (assumes precomputed or placeholder)
      if (item.vector && queryVector) {
        score += this.cosineSimilarity(queryVector, item.vector);
      }

      // recency boost
      if (item.metadata?.timestamp) {
        const age = Date.now() - item.metadata.timestamp;
        score += Math.max(0, 1 - age / (1000 * 60 * 60 * 24)); // decay over 1 day
      }

      // confidence boost
      if (item.metadata?.confidence) {
        score += item.metadata.confidence;
      }

      return { ...item, score };
    }).sort((a, b) => b.score - a.score);
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
      }))
    );
  }
}
