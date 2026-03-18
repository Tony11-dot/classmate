export class FeedbackService {
  constructor(private ranker: any, private store: any, private evaluation: any) {}

  async record(input: {
    items: any[];
    success: boolean;
    topic?: string;
    correct?: boolean;
    timeMs?: number;
  }) {
    const { items, success, topic } = input;

    // adaptive weights
    if (items && typeof success === 'boolean') {
      this.ranker.updateWeights(items, success);
    }

    // evaluation tracking
    if (topic) {
      this.evaluation.record({
        topic,
        success,
      });
    }

    // persistence
    if (items && items.length > 0) {
      await this.store.add({
        id: `feedback-${Date.now()}`,
        vector: items[0]?.vector || [],
        metadata: {
          success,
          topic,
          timestamp: Date.now(),
        },
      });
    }
  }
}
