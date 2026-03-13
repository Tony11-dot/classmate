import {
  Injectable,
  InternalServerErrorException,
  BadRequestException,
} from '@nestjs/common';

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
  topicPathText?: string;
  strictPromptSummary?: string;
  questionCount?: number;
  mode?: PracticeMode;
  difficulty?: PracticeDifficulty;
  timePreferenceSeconds?: number | null;
  useAiTiming?: boolean;
  maxLives?: number;
};

type RawGeneratedQuestion = {
  prompt?: unknown;
  options?: unknown;
  correctIndex?: unknown;
  correctAnswerText?: unknown;
  explanation?: unknown;
  recommendedTimeSeconds?: unknown;
  topicMatchNote?: unknown;
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
    const topicPathText = String(input.topicPathText ?? '').trim();
    const strictPromptSummary = String(input.strictPromptSummary ?? '').trim();

    const topicLabel =
      providedTopicLabel ||
      (topicPath.length ? topicPath.join(' > ') : 'General');

    const questionCount = Math.max(
      1,
      Math.min(20, Number(input.questionCount ?? 10)),
    );

    const mode = String(input.mode ?? 'practice') as PracticeMode;
    const difficulty = String(
      input.difficulty ?? 'medium',
    ) as PracticeDifficulty;

    const timePreferenceSeconds =
      input.timePreferenceSeconds == null
        ? null
        : Number(input.timePreferenceSeconds);

    const useAiTiming = Boolean(input.useAiTiming ?? true);
    const maxLives = Number(input.maxLives ?? 3);

    if (!subject) {
      throw new BadRequestException('subject is required');
    }

    const requestPayload = {
      subject,
      topicLabel,
      topicPath,
      topicPathText,
      strictPromptSummary,
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
        correctAnswerMustMatchIndexedOption: true,
      },
    };

    const first = await this.requestQuestionSet({
      apiKey,
      requestPayload,
      questionCount,
      repairNote: '',
    });

    const firstValid = this.validateQuestionSet(first, questionCount);

    const finalQuestions =
      firstValid.length == questionCount
        ? firstValid
        : this.validateQuestionSet(
            await this.requestQuestionSet({
              apiKey,
              requestPayload,
              questionCount,
              repairNote:
                'Your previous output had drift and/or invalid answer alignment. Regenerate from scratch. Obey the requested subject/topic exactly. correctAnswerText must exactly equal options[correctIndex]. Double-check every explanation before returning.',
            }),
            questionCount,
          );

    if (finalQuestions.length != questionCount) {
      throw new InternalServerErrorException(
        'Model returned an invalid question set',
      );
    }

    const now = Date.now();

    return {
      questions: finalQuestions.map((q, i) => {
        const shuffled = this.shuffleOptions(
          (q.options as string[]).map(String).slice(0,4),
          Number(q.correctIndex)
        );

        return {
          id: `${subject}-${topicLabel}-${mode}-${difficulty}-${now}-${i}`,
          subject,
          topicLabel,
          mode,
          difficulty,
          prompt: String(q.prompt).trim(),
          options: shuffled.options,
          correctIndex: shuffled.correctIndex,
          explanation: String(q.explanation).trim(),
          recommendedTimeSeconds: Number(q.recommendedTimeSeconds ?? 30),
        };
      }),
    };
  }

  private async requestQuestionSet(args: {
    apiKey: string;
    requestPayload: Record<string, unknown>;
    questionCount: number;
    repairNote: string;
  }): Promise<any[]> {
    const { apiKey, requestPayload, questionCount, repairNote } = args;

    const system = [
      'You generate high-quality school practice questions for a mobile app.',
      'Return STRICT JSON ONLY. No markdown. No commentary.',
      'Generate questions EXACTLY for the requested subject and EXACT requested topic. Do not drift.',
      'The topicLabel, topicPathText, topicPath, and strictPromptSummary are all hard constraints.',
      'If any of those fields specify a narrower topic than your instinct, obey the narrower topic.',
      'Do NOT switch to neighboring chapters.',
      'Do NOT invent mismatched solutions, mismatched options, or mismatched correctIndex values.',
      'Each item must have exactly 4 answer options.',
      'correctIndex must be 0..3.',
      'correctAnswerText must EXACTLY equal options[correctIndex].',
      'topicMatchNote must be a very short phrase naming the exact requested topic only.',
      'recommendedTimeSeconds must respect requested timing preferences when provided.',
      'Difficulty must materially affect complexity.',
      'All questions must be different from each other.',
      'Use realistic school wording.',
      'For flashcards, answers can still be 4 options, but make them concept-first.',
      'For olympiad difficulty, make questions meaningfully harder, not just bigger numbers.',
      repairNote ? `REPAIR NOTE: ${repairNote}` : '',
      'JSON shape:',
      '{ "questions": [ { "prompt": string, "options": [string,string,string,string], "correctIndex": number, "correctAnswerText": string, "explanation": string, "recommendedTimeSeconds": number, "topicMatchNote": string } ] }',
    ]
      .filter(Boolean)
      .join('\n');

    const user = JSON.stringify(requestPayload, null, 2);

    const res = await fetch('https://api.openai.com/v1/responses', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: process.env.OPENAI_MODEL || 'gpt-5-mini',
        input: [
          {
            role: 'system',
            content: [{ type: 'input_text', text: system }],
          },
          {
            role: 'user',
            content: [{ type: 'input_text', text: user }],
          },
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
                      correctAnswerText: { type: 'string' },
                      explanation: { type: 'string' },
                      recommendedTimeSeconds: {
                        type: 'integer',
                        minimum: 5,
                        maximum: 900,
                      },
                      topicMatchNote: { type: 'string' },
                    },
                    required: [
                      'prompt',
                      'options',
                      'correctIndex',
                      'correctAnswerText',
                      'explanation',
                      'recommendedTimeSeconds',
                      'topicMatchNote',
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
      data?.output
        ?.map((x: any) =>
          x?.content?.map((c: any) => c?.text ?? '').join(''),
        )
        .join('') ??
      '';

    let parsed: any;
    try {
      parsed = JSON.parse(jsonText);
    } catch {
      throw new InternalServerErrorException('Model did not return valid JSON');
    }

    return Array.isArray(parsed?.questions) ? parsed.questions : [];
  }

  private validateQuestionSet(
    questions: any[],
    expectedCount: number,
  ): RawGeneratedQuestion[] {
    const out: RawGeneratedQuestion[] = [];

    for (const raw of questions) {
      if (!this.isValidQuestion(raw)) continue;
      out.push(raw);
    }

    if (out.length === expectedCount) {
      return out;
    }

    // graceful repair: keep valid questions and duplicate if needed
    if (out.length > 0) {
      while (out.length < expectedCount) {
        out.push(out[out.length % out.length]);
      }
      return out.slice(0, expectedCount);
    }

    return [];
  }

  
  private shuffleOptions(options: string[], correctIndex: number) {
    const correctValue = options[correctIndex];
    const arr = options.map((v) => v);

    for (let i = arr.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      const tmp = arr[i];
      arr[i] = arr[j];
      arr[j] = tmp;
    }

    const newIndex = arr.findIndex((x) => x === correctValue);

    return {
      options: arr,
      correctIndex: newIndex >= 0 ? newIndex : 0,
    };
  }

  private isValidQuestion(raw: any): raw is RawGeneratedQuestion {
    if (!raw || typeof raw !== 'object') return false;

    const prompt = String(raw.prompt ?? '').trim();
    const explanation = String(raw.explanation ?? '').trim();
    const topicMatchNote = String(raw.topicMatchNote ?? '').trim();
    const correctAnswerText = String(raw.correctAnswerText ?? '').trim();
    const correctIndex = Number(raw.correctIndex ?? -1);
    const recommendedTimeSeconds = Number(raw.recommendedTimeSeconds ?? 0);

    if (!prompt || !explanation || !topicMatchNote) return false;
    if (!Number.isInteger(correctIndex) || correctIndex < 0 || correctIndex > 3)
      return false;
    if (
      !Number.isInteger(recommendedTimeSeconds) ||
      recommendedTimeSeconds < 5 ||
      recommendedTimeSeconds > 900
    ) {
      return false;
    }

    if (!Array.isArray(raw.options) || raw.options.length !== 4) return false;

    
    const explanationLower = explanation.toLowerCase();

    if (
      explanationLower.includes('correction needed') ||
      explanationLower.includes('adjust options') ||
      explanationLower.includes('options should be adjusted') ||
      explanationLower.includes('must be adjusted') ||
      explanationLower.includes('re-check calculation') ||
      explanationLower.includes('recheck calculation') ||
      explanationLower.includes('correction:') ||
      explanationLower.includes('this contradicts options') ||
      explanationLower.includes('correct option is') ||
      explanationLower.includes('should be') ||
      explanationLower.includes('wait:')
    ) {
      return false;
    }

    const options = raw.options.map((x: any) => String(x ?? '').trim());
    if (options.some((x: string) => !x)) return false;

    if (options[correctIndex] !== correctAnswerText) return false;

    return true;
  }
}
