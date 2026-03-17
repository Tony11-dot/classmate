import { Injectable } from '@nestjs/common';
import OpenAI from 'openai';

@Injectable()
export class GroundedGeneratorService {
  private client = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY,
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

Return ONLY JSON array.
`;

    const res = await this.client.chat.completions.create({
      model: 'gpt-4o-mini',
      temperature: 0,
      messages: [{ role: 'user', content: prompt }],
    });

    const text = res.choices[0]?.message?.content ?? '[]';

    try {
      return JSON.parse(text);
    } catch {
      return [];
    }
  }
}
