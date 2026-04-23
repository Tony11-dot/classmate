import { Injectable } from '@nestjs/common';
import { anthropic } from '../common/openai.client';

@Injectable()
export class NovaVerifyService {
  async verifySolution(input: {
    caption?: string;
    files: { mimeType: string }[];
  }) {
    try {
      const prompt = `
You are an academic validator AI inside ClassMate.

Your job:
Decide if a student-uploaded solution is VALID or NOT.

Rules:
- Must contain a real attempt to solve a question
- Must not be empty, spam, or irrelevant
- Images/PDFs imply attempt unless obviously invalid

Input:
Caption: ${input.caption ?? 'none'}
Files count: ${input.files.length}
File types: ${input.files.map(f => f.mimeType).join(', ')}

Respond ONLY in JSON:
{
  "status": "VERIFIED" | "REJECTED",
  "reason": "short explanation"
}
`;

      const res = await anthropic.messages.create({
        model: process.env.ANTHROPIC_MODEL || 'claude-haiku-4-5-20251001',
        max_tokens: 256,
        system: 'You are a strict academic validator.',
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.2,
      } as any);

      const text = res.content[0]?.type === 'text' ? res.content[0].text : '{}';

      let parsed: any;
      try {
        parsed = JSON.parse(text);
      } catch {
        return { status: 'VERIFIED', reason: null };
      }

      if (!parsed?.status) {
        return { status: 'VERIFIED', reason: null };
      }

      return {
        status: parsed.status,
        reason: parsed.reason ?? null,
      };
    } catch (e) {
      return { status: 'VERIFIED', reason: null };
    }
  }
}
