import { Injectable } from '@nestjs/common';
import { pipeline } from '@xenova/transformers';

@Injectable()
export class EmbeddingService {
  private extractor: any;

  async init() {
    if (!this.extractor) {
      this.extractor = await pipeline('feature-extraction', 'Xenova/all-MiniLM-L6-v2');
    }
  }

  async embed(text: string): Promise<number[]> {
    await this.init();
    const result = await this.extractor(text, { pooling: 'mean', normalize: true });
    return Array.from(result.data);
  }
}
