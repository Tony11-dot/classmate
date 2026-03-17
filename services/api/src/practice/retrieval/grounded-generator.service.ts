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
You are an expert ${input.subject} exam writer.

STRICT RULES:
- Only use the provided context
- No hallucinations
- Generate EXACTLY ${input.count} MCQs
- Each question must have 4 options
- One correct answer
- Include explanation
- Difficulty: ${input.difficulty}

CONTEXT:
${context}

OUTPUT JSON:
[
  {
    "prompt": "...",
    "options": ["A","B","C","D"],
    "correctIndex": 0,
    "explanation": "..."
  }
]
`;

    const res = await this.client.chat.completions.create({
      model: 'gpt-4o-mini',
      temperature: 0.2,
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
