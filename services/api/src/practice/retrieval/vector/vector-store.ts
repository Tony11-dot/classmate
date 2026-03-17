export type VectorDoc = {
  id: string;
  content: string;
  embedding: number[];
  source: string;
};

export class InMemoryVectorStore {
  private docs: VectorDoc[] = [];

  add(doc: VectorDoc) {
    this.docs.push(doc);
  }

  search(queryEmbedding: number[], k = 3): VectorDoc[] {
    const scored = this.docs.map(doc => ({
      doc,
      score: cosineSimilarity(queryEmbedding, doc.embedding),
    }));

    return scored
      .sort((a, b) => b.score - a.score)
      .slice(0, k)
      .map(s => s.doc);
  }
}

function cosineSimilarity(a: number[], b: number[]) {
  let dot = 0, normA = 0, normB = 0;

  for (let i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }

  return dot / (Math.sqrt(normA) * Math.sqrt(normB));
}
