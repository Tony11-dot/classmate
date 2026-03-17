import {
  Injectable,
  InternalServerErrorException,
  BadRequestException,
} from '@nestjs/common';
import { PracticeEngineRegistry } from './engine/practice-engine.registry';

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
  topic?: string;
  topicLabel?: string;
  topicPath?: string[];
  topicPathText?: string;
  strictPromptSummary?: string;
  questionCount?: number;
  count?: number;
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

type VerifierDecision = {
  index?: unknown;
  verdict?: unknown;
  reason?: unknown;
};

@Injectable()
export class PracticeService {
  constructor(private readonly engineRegistry: PracticeEngineRegistry) {}
  async generate(input: PracticeFilterPayload) {
    const apiKey = process.env.OPENAI_API_KEY;

    const subject = String(input.subject ?? 'Math').trim();
    const providedTopicLabel = String(input.topicLabel ?? '').trim();
    const legacyTopic = String(input.topic ?? '').trim();
    const topicPath = Array.isArray(input.topicPath)
      ? input.topicPath.map(String).map((x) => x.trim()).filter(Boolean)
      : [];
    const topicPathText =
      String(input.topicPathText ?? '').trim() ||
      providedTopicLabel ||
      legacyTopic;
    const strictPromptSummary = String(input.strictPromptSummary ?? '').trim();

    const topicLabel =
      providedTopicLabel ||
      legacyTopic ||
      (topicPath.length ? topicPath.join(' > ') : 'General');

    const requestedCountRaw = Number(input.questionCount ?? input.count ?? 10);
    const questionCount = Math.max(
      1,
      Math.min(20, Number.isFinite(requestedCountRaw) ? requestedCountRaw : 10),
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

    const deterministic = await this.engineRegistry.generate({
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
    });

    if (deterministic && deterministic.length === questionCount) {
      const now = Date.now();

      return {
        questions: deterministic.map((q, i) => {
          const safe = this.sanitizeQuestion(q);
          const shuffled = this.shuffleOptions(
            (safe.options as string[]).map(String).slice(0, 4),
            Number(safe.correctIndex),
          );

          return {
            id: `${subject}-${topicLabel}-${mode}-${difficulty}-${now}-${i}`,
            subject,
            topicLabel,
            mode,
            difficulty,
            prompt: safe.prompt,
            options: shuffled.options,
            correctIndex: shuffled.correctIndex,
            explanation: safe.explanation,
            recommendedTimeSeconds: safe.recommendedTimeSeconds,
          };
        }),
      };
    }

    if (!apiKey) {
      throw new InternalServerErrorException('OPENAI_API_KEY is missing');
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
      'Regenerate from scratch. Use only clean, standard, classroom-valid questions. correctAnswerText must exactly equal options[correctIndex]. If any item is uncertain or the exact answer is not already in the options, discard it internally and generate a different item.',
      'Use conservative textbook-style questions only. No parameter traps unless trivial. Explanations must be short, final, direct, and option-agnostic.',
      'Final retry. Prefer simpler but unquestionably correct questions over ambitious ones. Never mention options, mismatch, correction, approximation, or uncertainty.',
    ];

    let finalQuestions: RawGeneratedQuestion[] = [];
    let bestLocalValid: RawGeneratedQuestion[] = [];

    for (let attempt = 0; attempt < attemptNotes.length; attempt++) {
      const raw = await this.requestQuestionSet({
        apiKey,
        requestPayload,
        questionCount,
        repairNote: attemptNotes[attempt],
      });

      const locallyValid = this.validateQuestionSet(raw, questionCount);

      console.log(
        `[practice.generate] attempt=${attempt + 1}/${attemptNotes.length} local_valid=${locallyValid.length}/${questionCount}`,
      );

      if (locallyValid.length !== questionCount) continue;

      bestLocalValid = locallyValid;

      const verified = await this.verifyQuestionSet({
        apiKey,
        requestPayload,
        questions: locallyValid,
      });

      console.log(
        `[practice.generate] attempt=${attempt + 1}/${attemptNotes.length} verified=${verified.length}/${questionCount}`,
      );

      if (verified.length === questionCount) {
        finalQuestions = verified;
        break;
      }
    }

    if (finalQuestions.length !== questionCount && bestLocalValid.length === questionCount) {
      console.log(
        `[practice.generate] verifier_fallback_using_local_valid count=${bestLocalValid.length}`,
      );
      finalQuestions = bestLocalValid;
    }

    if (finalQuestions.length !== questionCount) {
      throw new InternalServerErrorException(
        'Model returned an invalid question set',
      );
    }

    const now = Date.now();

    return {
      questions: finalQuestions.map((q, i) => {
        const safe = this.sanitizeQuestion(q);
        const shuffled = this.shuffleOptions(
          (safe.options as string[]).map(String).slice(0, 4),
          Number(safe.correctIndex),
        );

        return {
          id: `${subject}-${topicLabel}-${mode}-${difficulty}-${now}-${i}`,
          subject,
          topicLabel,
          mode,
          difficulty,
          prompt: String(safe.prompt).trim(),
          options: shuffled.options,
          correctIndex: shuffled.correctIndex,
          explanation: String(safe.explanation).trim(),
          recommendedTimeSeconds: Number(safe.recommendedTimeSeconds ?? 30),
        };
      }),
    };
  }


  private modeInstruction(mode: PracticeMode): string {
    switch (mode) {
      case 'flashcards':
        return 'Mode shaping: flashcards must be concept-first, recognition-heavy, short, memory-oriented, and definition/relationship focused.';
      case 'speedRound':
        return 'Mode shaping: speedRound must prefer quick-answer, low-reading-load prompts with compact numbers and minimal setup.';
      case 'examPrep':
        return 'Mode shaping: examPrep must feel like classroom exam material, balanced in wording, slightly formal, and realistic in structure.';
      case 'conceptBuilder':
        return 'Mode shaping: conceptBuilder must emphasize understanding, interpretation, and why/when a concept applies.';
      case 'adaptive':
        return 'Mode shaping: adaptive must stay classroom-valid and choose a moderate learning gradient across the set.';
      case 'practice':
      default:
        return 'Mode shaping: practice must be balanced, classroom-valid, and straightforward.';
    }
  }

  private difficultyInstruction(difficulty: PracticeDifficulty): string {
    switch (difficulty) {
      case 'easy':
        return 'Difficulty shaping: easy means direct, single-step or very light reasoning, low trap risk, simple numbers.';
      case 'medium':
        return 'Difficulty shaping: medium means standard classroom level, moderate reasoning, no unusual traps.';
      case 'hard':
        return 'Difficulty shaping: hard means clearly more demanding multi-step reasoning, but still school-valid and clean.';
      case 'olympiad':
        return 'Difficulty shaping: olympiad means meaningfully harder insight/reasoning, not merely larger numbers.';
      case 'adaptive':
      default:
        return 'Difficulty shaping: adaptive means moderate, stable, school-valid difficulty unless other constraints imply otherwise.';
    }
  }

  private timingInstruction(
    timePreferenceSeconds: number | null,
    useAiTiming: boolean,
  ): string {
    if (timePreferenceSeconds != null && Number.isFinite(timePreferenceSeconds)) {
      return `Timing shaping: target about ${Math.max(5, Math.round(timePreferenceSeconds))} seconds per question unless correctness would suffer.`;
    }

    if (useAiTiming) {
      return 'Timing shaping: choose recommendedTimeSeconds realistically based on reading load and reasoning depth.';
    }

    return 'Timing shaping: keep recommendedTimeSeconds conservative and stable.';
  }

  private livesInstruction(maxLives: number): string {
    if (maxLives <= 1) {
      return 'Lives shaping: with 1 life, avoid trick wording and favor fairness, clarity, and unambiguous correctness.';
    }

    if (maxLives <= 2) {
      return 'Lives shaping: with low lives, keep challenge but reduce gotcha phrasing and avoid brittle interpretation.';
    }

    return 'Lives shaping: standard fairness is enough; challenge may be normal for the chosen difficulty.';
  }

  private async requestQuestionSet(args: {
    apiKey: string;
    requestPayload: Record<string, unknown>;
    questionCount: number;
    repairNote: string;
  }): Promise<any[]> {
    const { apiKey, requestPayload, questionCount, repairNote } = args;

    const rp: any = requestPayload;
    const system = [
      'You generate high-quality school practice questions for a mobile app.',
      'Return STRICT JSON ONLY. No markdown. No commentary.',
      'Generate questions EXACTLY for the requested subject and EXACT requested topic. Do not drift.',
      'The topicLabel, topicPathText, topicPath, and strictPromptSummary are all hard constraints.',
      'If any of those fields specify a narrower topic than your instinct, obey the narrower topic.',
      'Do NOT switch to neighboring chapters.',
      'Do NOT invent mismatched solutions, mismatched options, or mismatched correctIndex values.',
      'If the correct final answer is not exactly present in the 4 options, throw away that item internally and generate a different one before responding.',
      'Never mention option mismatch, correction, reconsideration, repair, approximation, or uncertainty in the explanation.',
      'Each item must have exactly 4 answer options.',
      'correctIndex must be 0..3.',
      'correctAnswerText must EXACTLY equal options[correctIndex].',
      'topicMatchNote must be a very short phrase naming the exact requested topic only.',
      'recommendedTimeSeconds must respect requested timing preferences when provided.',
      'Difficulty must materially affect complexity.',
      'All questions must be different from each other.',
      'Use realistic school wording.',
      'Keep response style/order consistent across the whole set.',
      'Within one set, keep formatting, granularity, and tone stable.',
      'Explanations must be concise, final, teacher-style solutions.',
      'Explanations must be option-agnostic and must not narrate self-correction.',
      this.modeInstruction(String(rp.mode ?? 'practice') as any),
      this.difficultyInstruction(String(rp.difficulty ?? 'medium') as any),
      this.timingInstruction(
        rp.timePreferenceSeconds == null ? null : Number(rp.timePreferenceSeconds),
        Boolean(rp.useAiTiming ?? true),
      ),
      this.livesInstruction(Number(rp.maxLives ?? 3)),
      repairNote ? `REPAIR NOTE: ${repairNote}` : '',
      'JSON shape:',
      '{ "questions": [ { "prompt": string, "options": [string,string,string,string], "correctIndex": number, "correctAnswerText": string, "explanation": string, "recommendedTimeSeconds": number, "topicMatchNote": string } ] }',
    ]
      .filter(Boolean)
      .join('\n');

    const user = JSON.stringify(requestPayload, null, 2);

    const parsed = await this.callResponsesJson({
      apiKey,
      schemaName: 'practice_questions',
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
      system,
      user,
    });

    return Array.isArray(parsed?.questions) ? parsed.questions : [];
  }

  private async verifyQuestionSet(args: {
    apiKey: string;
    requestPayload: Record<string, unknown>;
    questions: RawGeneratedQuestion[];
  }): Promise<RawGeneratedQuestion[]> {
    const { apiKey, requestPayload, questions } = args;

    const system = [
      'You are a strict academic verifier for a school practice generator.',
      'Return STRICT JSON ONLY.',
      'Solve each item independently from scratch.',
      'Reject any item with wrong math, wrong logic, wrong keyed answer, ambiguous wording, option mismatch, unsupported explanation, weak explanation, topic drift, or hidden self-correction.',
      'Reject any item if the explanation mentions mismatch, adjustment, correction, reconsideration, closest option, approximation, repair, or uncertainty.',
      'Accept only if the keyed answer is exactly correct and the explanation is clean, final, teacher-style, and actually supports that answer.',
      'Be conservative. If uncertain, reject.',
      'Keep reasons extremely short.',
      'JSON shape:',
      '{ "decisions": [ { "index": number, "verdict": "accept" | "reject", "reason": string } ] }',
    ].join('\n');

    const user = JSON.stringify(
      {
        requestPayload,
        questions: questions.map((q, index) => ({
          index,
          prompt: q.prompt,
          options: q.options,
          correctIndex: q.correctIndex,
          correctAnswerText: q.correctAnswerText,
          explanation: q.explanation,
          topicMatchNote: q.topicMatchNote,
          recommendedTimeSeconds: q.recommendedTimeSeconds,
        })),
      },
      null,
      2,
    );

    const parsed = await this.callResponsesJson({
      apiKey,
      schemaName: 'practice_verifier',
      schema: {
        type: 'object',
        additionalProperties: false,
        properties: {
          decisions: {
            type: 'array',
            minItems: questions.length,
            maxItems: questions.length,
            items: {
              type: 'object',
              additionalProperties: false,
              properties: {
                index: {
                  type: 'integer',
                  minimum: 0,
                  maximum: Math.max(0, questions.length - 1),
                },
                verdict: {
                  type: 'string',
                  enum: ['accept', 'reject'],
                },
                reason: { type: 'string' },
              },
              required: ['index', 'verdict', 'reason'],
            },
          },
        },
        required: ['decisions'],
      },
      system,
      user,
    });

    const decisions = Array.isArray(parsed?.decisions) ? parsed.decisions : [];
    const accepted = new Set<number>();
    const seenIndexes = new Set<number>();
    const reasonCounts = new Map<string, number>();

    for (const raw of decisions) {
      const decision = this.parseVerifierDecision(raw);
      if (!decision) continue;
      if (seenIndexes.has(decision.index)) continue;
      seenIndexes.add(decision.index);

      if (decision.verdict === 'accept') {
        accepted.add(decision.index);
      } else {
        reasonCounts.set(decision.reason, (reasonCounts.get(decision.reason) ?? 0) + 1);
      }
    }

    if (reasonCounts.size > 0) {
      console.log(
        `[practice.verify] reject_summary ${JSON.stringify(Object.fromEntries(reasonCounts))}`,
      );
    }

    if (accepted.size === 0) {
      return [];
    }

    return questions.filter((_, index) => accepted.has(index));
  }

  private parseVerifierDecision(raw: any): {
    index: number;
    verdict: 'accept' | 'reject';
    reason: string;
  } | null {
    if (!raw || typeof raw !== 'object') return null;

    const index = Number(raw.index ?? -1);
    const verdict = String(raw.verdict ?? '').trim();
    const reason = String(raw.reason ?? '').trim();

    if (!Number.isInteger(index) || index < 0) return null;
    if (verdict !== 'accept' && verdict !== 'reject') return null;
    if (!reason) return null;

    return {
      index,
      verdict,
      reason,
    };
  }

  private async callResponsesJson(args: {
    apiKey: string;
    schemaName: string;
    schema: Record<string, unknown>;
    system: string;
    user: string;
  }): Promise<any> {
    const { apiKey, schemaName, schema, system, user } = args;

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
        max_output_tokens: 4000,
        text: {
          format: {
            type: 'json_schema',
            name: schemaName,
            strict: true,
            schema,
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

    try {
      return JSON.parse(jsonText);
    } catch {
      throw new InternalServerErrorException('Model did not return valid JSON');
    }
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

    return out.length > 0 ? out : [];
  }

  private questionFingerprint(raw: RawGeneratedQuestion) {
    const prompt = String(raw.prompt ?? '')
      .trim()
      .toLowerCase()
      .replace(/\s+/g, ' ');

    const options = Array.isArray(raw.options)
      ? raw.options
          .map((x: any) =>
            String(x ?? '').trim().toLowerCase().replace(/\s+/g, ' '),
          )
          .join('||')
      : '';

    return `${prompt}##${options}`;
  }

  private sanitizeText(value: unknown): string {
    return String(value ?? '')
      .replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, ' ')
      .replace(/\\r\\n/g, '\n')
      .replace(/\\r/g, '\n')
      .replace(/\s+/g, ' ')
      .trim();
  }

  private sanitizeQuestion(q: any) {
    let options = Array.isArray(q?.options)
      ? q.options
          .map((x: any) => this.sanitizeText(x))
          .filter(Boolean)
      : [];

    const seen = new Set<string>();
    const unique: string[] = [];
    for (const option of options) {
      const key = option.toLowerCase().replace(/\s+/g, ' ');
      if (seen.has(key)) continue;
      seen.add(key);
      unique.push(option);
    }
    options = unique;

    while (options.length < 4) {
      const candidate = `Option ${options.length + 1}`;
      const key = candidate.toLowerCase();
      if (!seen.has(key)) {
        seen.add(key);
        options.push(candidate);
      }
    }

    options = options.slice(0, 4);

    let correctIndex = Number.isInteger(q?.correctIndex) ? q.correctIndex : 0;
    if (correctIndex < 0 || correctIndex >= options.length) correctIndex = 0;

    const prompt = this.sanitizeText(q?.prompt) || 'Question prompt unavailable.';
    const explanation =
      this.sanitizeText(q?.explanation) || 'Step-by-step solution not provided.';
    const topicMatchNote = this.sanitizeText(q?.topicMatchNote);
    const correctAnswerText = this.sanitizeText(q?.correctAnswerText);
    const recommendedTimeSecondsRaw = Number(q?.recommendedTimeSeconds ?? 30);
    const recommendedTimeSeconds = Number.isFinite(recommendedTimeSecondsRaw)
      ? Math.max(5, Math.min(900, Math.round(recommendedTimeSecondsRaw)))
      : 30;

    return {
      ...q,
      prompt,
      options,
      correctIndex,
      explanation,
      topicMatchNote,
      correctAnswerText,
      recommendedTimeSeconds,
    };
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
      'for coherence',
      'closest is',
      'not in the options',
      'not among the options',
      'option mismatch',
      'mismatch',
      're-examine',
      'reconsider',
      'fixing this accordingly',
      'replace options',
      'change question',
      'choose option',
      'check again',
      'double-check',
      'review again',
      'revisit',
      'but the options',
      'however the options',
      'does not match the options',
      "doesn't match the options",
      'approximately',
      'approximate',
      'assuming a typo',
      'assuming typo',
      'if the options',
      'if options',
      'nearest option',
      'nearest answer',
      'pick the closest',
      'best match',
      'best choice from the options',
      'none of the options',
      'none match',
      'option not listed',
      'not listed',
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
