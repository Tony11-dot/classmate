import { Injectable } from '@nestjs/common';

@Injectable()
export class EmbeddingService {
  private extractor: any;

  async init() {
    if (process.env.NODE_ENV === 'test') return;

    if (!this.extractor) {
      const { pipeline } = await import('@xenova/transformers');
      this.extractor = await pipeline(
        'feature-extraction',
        'Xenova/all-MiniLM-L6-v2'
      );
    }
  }

  async embed(text: string): Promise<number[]> {
    // ✅ TEST MODE (fast + deterministic)
    if (process.env.NODE_ENV === 'test') {
      return Array(384).fill(0.1);
    }

    await this.init();

    const output = await this.extractor(text, {
      pooling: 'mean',
      normalize: true,
    });

    return Array.from(output.data);
  }
}
