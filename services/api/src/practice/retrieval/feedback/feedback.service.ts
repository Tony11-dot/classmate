export class FeedbackService {
  constructor(private ranker: any, private store: any) {}

  async record(input: {
    items: any[];
    success: boolean;
    feedback?: any;
  }) {
    const { items, success } = input;

    // 1️⃣ update adaptive weights
    if (items && typeof success === 'boolean') {
      this.ranker.updateWeights(items, success);
    }

    // 2️⃣ persist feedback (optional memory layer)
    if (items && items.length > 0) {
      await this.store.add({
        id: `feedback-${Date.now()}`,
        vector: items[0]?.vector || [],
        metadata: {
          success,
          timestamp: Date.now(),
        },
      });
    }
  }
}
