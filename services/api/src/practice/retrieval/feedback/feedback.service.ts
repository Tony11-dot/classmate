import { Injectable } from '@nestjs/common';
import { PersistentVectorStore } from '../vector/persistent/persistent-vector-store';
import { EmbeddingService } from '../vector/embedding.service';

@Injectable()
export class FeedbackService {
  private store = new PersistentVectorStore();
  private embedder = new EmbeddingService();

  async record(input: {
    question: string;
    correct: boolean;
    subject: string;
    topic: string;
  }) {
    const embedding = await this.embedder.embed(input.question);

    await this.store.add({
      id: `feedback:${Date.now()}`,
      vector: embedding,
      metadata: {
        type: 'feedback',
        subject: input.subject,
        topic: input.topic,
        correct: input.correct,
        timestamp: Date.now(),
      },
    });
  }
}
