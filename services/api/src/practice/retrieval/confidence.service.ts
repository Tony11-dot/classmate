import { Injectable } from '@nestjs/common';

@Injectable()
export class ConfidenceService {
  evaluate(chunks: { content: string }[]) {
    if (!chunks || chunks.length === 0) {
      return { ok: false, reason: 'no_content' };
    }

    const totalLength = chunks.reduce((acc, c) => acc + c.content.length, 0);

    if (totalLength < 200) {
      return { ok: false, reason: 'too_shallow' };
    }

    return { ok: true };
  }
}
