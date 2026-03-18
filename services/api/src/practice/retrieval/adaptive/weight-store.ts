export class WeightStore {
  private weights = {
    similarity: 1,
    recency: 0.5,
    confidence: 0.5,
  };

  get() {
    return this.weights;
  }

  update(delta: Partial<typeof this.weights>) {
    this.weights = {
      similarity: Math.max(0, this.weights.similarity + (delta.similarity || 0)),
      recency: Math.max(0, this.weights.recency + (delta.recency || 0)),
      confidence: Math.max(0, this.weights.confidence + (delta.confidence || 0)),
    };
  }
}
