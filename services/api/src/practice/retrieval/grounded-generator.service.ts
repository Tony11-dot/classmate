import { Injectable } from '@nestjs/common';
import Anthropic from '@anthropic-ai/sdk';

@Injectable()
export class GroundedGeneratorService {
  private client = new Anthropic({
    apiKey: process.env.ANTHROPIC_API_KEY,
  });

  async generate(input: {
    subject: string;
    topic: string;
    difficulty: string;
    count: number;
    chunks: { content: string }[];
  }) {
    const context = input.chunks.map(c => c.content).join('\n\n');

    const prompt = `
You are a STRICT academic exam generator.

RULES:
- ONLY use the provided context
- If unsure → DO NOT GUESS
- Questions must be precise and unambiguous
- EXACTLY ${input.count} questions
- Each must have 4 options
- One correct answer
- Explanation must match context

CONTEXT:
${context}

Return ONLY a JSON array. No markdown, no explanation.
`;

    const res = await this.client.messages.create({
      model: process.env.ANTHROPIC_MODEL || 'claude-sonnet-4-6',
      max_tokens: 4096,
      system: 'You are a strict academic exam generator. Return only valid JSON arrays.',
      messages: [{ role: 'user', content: prompt }],
      temperature: 0,
    } as any);

    const text = res.content[0]?.type === 'text' ? res.content[0].text : '[]';

    try {
      return JSON.parse(text);
    } catch {
      return [];
    }
  }
}
