export class EvaluationService {
  private stats = {
    total: 0,
    success: 0,
    failure: 0,
    byTopic: {} as Record<string, { success: number; failure: number }>
  };

  record(input: {
    topic: string;
    success: boolean;
  }) {
    this.stats.total++;

    if (input.success) this.stats.success++;
    else this.stats.failure++;

    if (!this.stats.byTopic[input.topic]) {
      this.stats.byTopic[input.topic] = { success: 0, failure: 0 };
    }

    if (input.success) this.stats.byTopic[input.topic].success++;
    else this.stats.byTopic[input.topic].failure++;
  }

  getStats() {
    return this.stats;
  }
}
