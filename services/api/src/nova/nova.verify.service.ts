import { Injectable, Optional } from '@nestjs/common';
import { anthropic } from '../common/openai.client';
import { TokensService } from '../billing/tokens.service';

@Injectable()
export class NovaVerifyService {
  constructor(@Optional() private readonly tokens?: TokensService) {}

  async verifySolution(input: {
    caption?: string;
    files: { mimeType: string }[];
    /// User uploading the solution — used to bill the verifier call.
    /// Optional so the API stays backwards-compatible for callers that
    /// don't have a user (e.g. internal moderation tools).
    billingUserId?: string;
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

      const model = process.env.ANTHROPIC_MODEL || 'claude-haiku-4-5-20251001';
      const res = await anthropic.messages.create({
        model,
        max_tokens: 256,
        system: 'You are a strict academic validator.',
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.2,
      } as any);

      if (this.tokens && input.billingUserId) {
        await this.tokens.chargeAnthropicResponse({
          userId: input.billingUserId,
          source: 'solution-verify',
          model,
          response: res,
        });
      }

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
