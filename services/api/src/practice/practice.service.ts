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

    const attemptNotes = [
      '',
      'Your previous output had drift and/or invalid answer alignment. Regenerate from scratch. Obey the requested subject/topic exactly. correctAnswerText must exactly equal options[correctIndex]. Double-check every explanation before returning. Every question must be unique. If any item is uncertain, replace it with a fresh valid item.',
      'RETRY HARDER: Do not leave any unresolved mismatch. Never mention adjusting options, correcting later, or uncertainty. Return only fully solved, internally consistent questions with final answers already aligned to the options.',
      'FINAL RETRY: Every item must be classroom-valid on first read. No meta commentary. No repairing language. No option mismatch. No duplicate prompts. Prefer simpler but correct questions over ambitious but uncertain ones.',
    ];

    let finalQuestions: RawGeneratedQuestion[] = [];

    for (let attempt = 0; attempt < attemptNotes.length; attempt++) {
      const raw = await this.requestQuestionSet({
        apiKey,
        requestPayload,
        questionCount,
        repairNote: attemptNotes[attempt],
      });

      const valid = this.validateQuestionSet(raw, questionCount);

      console.log(
        `[practice.generate] attempt=${attempt + 1}/${attemptNotes.length} valid=${valid.length}/${questionCount}`,
      );

      if (valid.length === questionCount) {
        finalQuestions = valid;
        break;
      }
    }

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
    const seen = new Set<string>();
    const reasonCounts = new Map<string, number>();

    for (const [index, raw] of questions.entries()) {
      const reason = this.invalidReason(raw);
      if (reason != null) {
        reasonCounts.set(reason, (reasonCounts.get(reason) ?? 0) + 1);

        const promptPreview = String(raw?.prompt ?? '')
          .replace(/\s+/g, ' ')
          .slice(0, 140);

        const explanationPreview = String(raw?.explanation ?? '')
          .replace(/\s+/g, ' ')
          .slice(0, 500);

        console.log(
          `[practice.generate] reject index=${index} reason=${reason} prompt="${promptPreview}" explanation="${explanationPreview}"`,
        );
        continue;
      }

      const fp = this.questionFingerprint(raw);
      if (seen.has(fp)) {
        reasonCounts.set(
          'duplicate_fingerprint',
          (reasonCounts.get('duplicate_fingerprint') ?? 0) + 1,
        );
        console.log(
          `[practice.generate] reject index=${index} reason=duplicate_fingerprint prompt="${String(raw?.prompt ?? '').replace(/\s+/g, ' ').slice(0, 140)}"`,
        );
        continue;
      }

      seen.add(fp);
      out.push(raw);
    }

    if (reasonCounts.size > 0) {
      console.log(
        `[practice.generate] reject_summary ${JSON.stringify(Object.fromEntries(reasonCounts))}`,
      );
    }

    return out.length === expectedCount ? out : [];
  }


  private questionFingerprint(raw: RawGeneratedQuestion) {
    const prompt = String(raw.prompt ?? '')
      .trim()
      .toLowerCase()
      .replace(/\s+/g, ' ');

    const options = Array.isArray(raw.options)
      ? raw.options
          .map((x: any) => String(x ?? '').trim().toLowerCase().replace(/\s+/g, ' '))
          .join('||')
      : '';

    return `${prompt}##${options}`;
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

  private invalidReason(raw: any): string | null {
    if (!raw || typeof raw !== 'object') return 'not_object';

    const prompt = String(raw.prompt ?? '').trim();
    const explanation = String(raw.explanation ?? '').trim();
    const topicMatchNote = String(raw.topicMatchNote ?? '').trim();
    const correctAnswerText = String(raw.correctAnswerText ?? '').trim();
    const correctIndex = Number(raw.correctIndex ?? -1);
    const recommendedTimeSeconds = Number(raw.recommendedTimeSeconds ?? 0);

    if (!prompt) return 'missing_prompt';
    if (!explanation) return 'missing_explanation';
    if (prompt.length < 12) return 'prompt_too_short';
    if (explanation.length < 18) return 'explanation_too_short';

    if (!Number.isInteger(correctIndex) || correctIndex < 0 || correctIndex > 3) {
      return 'invalid_correct_index';
    }

    if (
      !Number.isInteger(recommendedTimeSeconds) ||
      recommendedTimeSeconds < 5 ||
      recommendedTimeSeconds > 900
    ) {
      return 'invalid_recommended_time';
    }

    if (!Array.isArray(raw.options)) return 'options_not_array';
    if (raw.options.length !== 4) return 'options_length_not_4';

    const options = raw.options.map((x: any) => String(x ?? '').trim());
    if (options.some((x: string) => !x)) return 'empty_option';

    const normalizedOptions = options.map((x) =>
      x.toLowerCase().replace(/\s+/g, ' '),
    );
    if (new Set(normalizedOptions).size !== 4) return 'duplicate_options';

    if (!correctAnswerText) return 'missing_correct_answer_text';
    if (options[correctIndex] !== correctAnswerText) {
      return 'correct_answer_text_mismatch';
    }

    const explanationLower = explanation.toLowerCase();
    const promptLower = prompt.toLowerCase();
    const noteLower = topicMatchNote.toLowerCase();

    const badPhrases = [
      'correction needed',
      'adjust options',
      'options should be adjusted',
      'must be adjusted',
      're-check calculation',
      'recheck calculation',
      'correction:',
      'this contradicts options',
      'correct option is',
      'wait:',
      'to align with problem',
      'to match options',
      'options mismatch',
      'accept as final',
    ];

    for (const phrase of badPhrases) {
      if (explanationLower.includes(phrase)) {
        return `bad_phrase:${phrase}`;
      }
    }

    if (promptLower === explanationLower) return 'prompt_equals_explanation';

    if (topicMatchNote && noteLower.length < 2) {
      return 'topic_match_note_too_short';
    }

    return null;
  }

  private isValidQuestion(raw: any): raw is RawGeneratedQuestion {
    return this.invalidReason(raw) == null;
  }
}
