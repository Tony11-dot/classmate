import { Injectable } from '@nestjs/common';

export type SourceChunk = {
  content: string;
  source: string;
};

@Injectable()
export class MultiSourceService {
  async fetch(topic: string): Promise<SourceChunk[]> {
    const results: SourceChunk[] = [];

    // Wikipedia
    try {
      const res = await fetch(`https://en.wikipedia.org/api/rest_v1/page/summary/${encodeURIComponent(topic)}`);
      const data: any = await res.json();
      if (data.extract) {
        results.push({
          content: data.extract,
          source: 'wikipedia',
        });
      }
    } catch {}

    // Simple fallback: keyword expansion (VERY IMPORTANT)
    const variants = [
      topic,
      `${topic} definition`,
      `${topic} explanation`,
      `${topic} basics`,
    ];

    for (const v of variants) {
      results.push({
        content: v,
        source: 'query-expansion',
      });
    }

    return results;
  }
}
