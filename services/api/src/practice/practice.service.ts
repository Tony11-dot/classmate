import { Injectable, InternalServerErrorException, BadRequestException } from '@nestjs/common';

type PracticeMode =
  | 'practice'
  | 'flashcards'
  | 'speedRound'
  | 'examPrep'
  | 'conceptBuilder'
  | 'adaptive';

type PracticeDifficulty =
  | 'easy'
  | 'medium'
  | 'hard'
  | 'olympiad'
  | 'adaptive';

type PracticeFilterPayload = {
  subject?: string;
  topicLabel?: string;
  topicPath?: string[];
  questionCount?: number;
  mode?: PracticeMode;
  difficulty?: PracticeDifficulty;
  timePreferenceSeconds?: number | null;
  useAiTiming?: boolean;
  maxLives?: number;
};

@Injectable()
export class PracticeService {
  async generate(input: PracticeFilterPayload) {
    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) {
      throw new InternalServerErrorException('OPENAI_API_KEY is missing');
    }

    const subject = String(input.subject ?? 'Math').trim();
    const providedTopicLabel = String(input.topicLabel ?? '').trim();
    const topicPath = Array.isArray(input.topicPath)
      ? input.topicPath.map(String).map((x) => x.trim()).filter(Boolean)
      : [];
    const topicLabel = providedTopicLabel || (topicPath.length ? topicPath.join(' > ') : 'General');
    const questionCount = Math.max(1, Math.min(20, Number(input.questionCount ?? 10)));
    const mode = String(input.mode ?? 'practice') as PracticeMode;
    const difficulty = String(input.difficulty ?? 'medium') as PracticeDifficulty;
    const timePreferenceSeconds =
      input.timePreferenceSeconds == null ? null : Number(input.timePreferenceSeconds);
    const useAiTiming = Boolean(input.useAiTiming ?? true);
    const maxLives = Number(input.maxLives ?? 3);

    if (!subject) {
      throw new BadRequestException('subject is required');
    }

    const system = [
      'You generate high-quality school practice questions for a mobile app.',
      'Return STRICT JSON ONLY. No markdown. No commentary.',
      'Generate questions EXACTLY for the requested subject and topic. Do not drift.',
      'The topicLabel is the source of truth for the requested topic.',
      'If topicLabel says Conditions / Conditionals / If-Else / Boolean logic, generate ONLY conditional logic questions.',
      'If the subject/topic is computer science + conditions/conditionals/if-else/branching/boolean logic, do NOT generate Big-O.',
      'Difficulty must materially affect complexity.',
      'All questions must be different from each other.',
      'Avoid static repeated templates.',
      'Use realistic school wording.',
      'Each item must be valid, solvable, and have exactly 4 answer options.',
      'correctIndex must be 0..3 and must match the correct option.',
      'recommendedTimeSeconds must respect requested timing preferences when provided.',
      'For flashcards, answers can still be 4 options, but make them concept-first.',
      'For olympiad difficulty, make questions meaningfully harder, not just bigger numbers.',
      'JSON shape:',
      '{ "questions": [ { "prompt": string, "options": [string,string,string,string], "correctIndex": number, "explanation": string, "recommendedTimeSeconds": number } ] }',
    ].join('\n');

    const user = JSON.stringify(
      {
        subject,
        topicPath,
        topicLabel,
        questionCount,
        mode,
        difficulty,
        timePreferenceSeconds,
        useAiTiming,
        maxLives,
        constraints: {
          exactTopicMatch: true,
          noTopicDrift: true,
          uniqueQuestions: true,
          fourOptionsExactly: true,
        },
      },
      null,
      2,
    );

    const res = await fetch('https://api.openai.com/v1/responses', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: process.env.OPENAI_MODEL || 'gpt-5-mini',
        input: [
          { role: 'system', content: [{ type: 'input_text', text: system }] },
          { role: 'user', content: [{ type: 'input_text', text: user }] },
        ],
        text: {
          format: {
            type: 'json_schema',
            name: 'practice_questions',
            strict: true,
            schema: {
              type: 'object',
              additionalProperties: false,
              properties: {
                questions: {
                  type: 'array',
                  minItems: questionCount,
                  maxItems: questionCount,
                  items: {
                    type: 'object',
                    additionalProperties: false,
                    properties: {
                      prompt: { type: 'string' },
                      options: {
                        type: 'array',
                        minItems: 4,
                        maxItems: 4,
                        items: { type: 'string' },
                      },
                      correctIndex: {
                        type: 'integer',
                        minimum: 0,
                        maximum: 3,
                      },
                      explanation: { type: 'string' },
                      recommendedTimeSeconds: {
                        type: 'integer',
                        minimum: 5,
                        maximum: 900,
                      },
                    },
                    required: [
                      'prompt',
                      'options',
                      'correctIndex',
                      'explanation',
                      'recommendedTimeSeconds',
                    ],
                  },
                },
              },
              required: ['questions'],
            },
          },
        },
      }),
    });

    if (!res.ok) {
      const text = await res.text();
      throw new InternalServerErrorException(`OpenAI error: ${text}`);
    }

    const data: any = await res.json();
    const jsonText =
      data?.output_text ??
      data?.output?.map((x: any) => x?.content?.map((c: any) => c?.text ?? '').join('')).join('') ??
      '';

    let parsed: any;
    try {
      parsed = JSON.parse(jsonText);
    } catch {
      throw new InternalServerErrorException('Model did not return valid JSON');
    }

    const questions = Array.isArray(parsed?.questions) ? parsed.questions : [];

    return {
      questions: questions.map((q: any, i: number) => ({
        id: `${subject}-${topicLabel}-${mode}-${difficulty}-${Date.now()}-${i}`,
        subject,
        topicLabel,
        mode,
        difficulty,
        prompt: String(q.prompt ?? '').trim(),
        options: Array.isArray(q.options) ? q.options.map(String).slice(0, 4) : [],
        correctIndex: Number(q.correctIndex ?? 0),
        explanation: String(q.explanation ?? '').trim(),
        recommendedTimeSeconds: Number(q.recommendedTimeSeconds ?? 30),
      })),
    };
  }
}
