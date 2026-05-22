import {
  Injectable,
  InternalServerErrorException,
  BadRequestException,
  HttpException,
  Optional,
} from '@nestjs/common';
import { PracticeEngineRegistry } from './engine/practice-engine.registry';
import { PracticeCacheService } from './cache/practice-cache.service';
import { RateLimitService } from '../common/rate-limit/rate-limit.service';
import { DedupService } from '../common/dedup/dedup.service';
import { resolveCanonicalPracticeSubject } from './catalog/practice-subject-catalog';
import {
  resolveCanonicalPracticeTopic,
  resolveCanonicalPracticeTopicLoose,
  isDeterministicPracticeTopic,
  isDeterministicPracticeTopicLoose,
} from './catalog/practice-topic-catalog';
import { analyzeCustomPracticeTopic } from './intake/custom-topic-intake';
import { FactualQuizService } from './factual/factual-quiz.service';
import { ConceptualTopicService } from './conceptual/conceptual-topic.service';
import { SymbolicTopicService } from './symbolic/symbolic-topic.service';
import { AdaptivePracticeFlowService } from './adaptive/flow/adaptive-practice-flow.service';
import { PracticeAiInsightsService } from './practice-ai-insights.service';
import { TokensService } from '../billing/tokens.service';
import type {
  AdaptiveAttemptInput,
  AdaptiveAttemptResult,
  AdaptiveSessionSummary,
} from './adaptive/contracts/adaptive-practice.types';
import { normalizeQuestionSetShape } from './practice.safety';
import {
  assessQuestionSetIntegrity,
  shouldAcceptConfidenceHeuristic,
} from './practice.safety';
import {
  practiceBadRequest,
  practiceGenerationFailed,
} from './errors/practice-error.util';

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
  /// Set by the controller so the AI generation path can bill the
  /// right user. Not part of the public request body — the controller
  /// pulls it from the JWT and stuffs it in here before calling.
  userId?: string;
};

type RawGeneratedQuestion = {
  prompt?: unknown;
  options?: unknown;
  correctIndex?: unknown;
  correctAnswerText?: unknown;
  explanation?: unknown;
  recommendedTimeSeconds?: unknown;
  topicMatchNote?: unknown;
  answerAudit?: unknown;
};

type StructuredAnswerType = 'math' | 'physics' | 'text' | 'code';

type StructuredAnswerAudit = {
  finalAnswer: string;
  steps: string;
  confidence: number;
  type: StructuredAnswerType;
  validationPassed: boolean;
  reason: string;
};

type VerifierDecision = {
  index?: unknown;
  verdict?: unknown;
  reason?: unknown;
};

type PracticeRouteKind =
  | 'deterministic'
  | 'grounded_factual'
  | 'conceptual'
  | 'symbolic'
  | 'ai_fallback';


function isStemStructuredSubject(subject: string): boolean {
  const s = String(subject ?? '').trim().toLowerCase();
  return [
    'math',
    'physics',
    'electronics',
    'chemistry',
    'biology',
    'computer science',
  ].includes(s);
}

function isLikelySymbolicBoundaryTopic(topic: string): boolean {
  const t = String(topic ?? '').trim().toLowerCase();

  const explicit =
    /\b(derivative|derivatives|partial derivative|partial derivatives|limit|limits|integral|integrals|matrix|matrices|matrix multiplication|vector|vectors|eigenvalue|eigenvalues|eigenvector|eigenvectors|determinant|determinants|gradient|gradients|jacobian|jacobians|taylor series|maclaurin series|sequence and series|series expansion|differential equation|differential equations|laplace transform|laplace transforms|fourier series|fourier transform|complex number|complex numbers|complex analysis|linear algebra|calculus|tensor|tensors|theorem|theorems|proof|proofs|series|transform|transforms)\b/.test(t);

  const symbolicStyle =
    /[=^+\-*/()]/.test(topic) ||
    /\b(solve|simplify|differentiate|integrate|factor|expand|evaluate|compute|calculate|prove)\b/.test(t);

  return explicit || symbolicStyle;
}

type PracticeRoutingDecision = {
  route: PracticeRouteKind;
  symbolicReason?: string;
  hasDeterministicCatalogTopic: boolean;
};

const PRACTICE_OPENAI_TIMEOUT_MS = 15000;
const PRACTICE_GENERATE_BUDGET_MS = 30000;




@Injectable()
export class PracticeService {
  private logPracticeEvent(event: string, payload: Record<string, unknown>) {
    try {
      console.log(
        JSON.stringify({
          scope: 'practice.generate',
          event,
          ...payload,
        }),
      );
    } catch {
      console.log(`[practice.generate] ${event}`);
    }
  }


  private cache = new PracticeCacheService();
  private rateLimit = new RateLimitService();
  private dedup = new DedupService();
  private engineRegistryFallback?: PracticeEngineRegistry;

  private getEngineRegistry(): any {
    if (this.engineRegistry) return this.engineRegistry;
    if (!this.engineRegistryFallback) {
      this.engineRegistryFallback = {
        generate: async () => [],
      } as any;
    }
    return this.engineRegistryFallback;
  }
  constructor(
    private readonly engineRegistry: PracticeEngineRegistry,
    @Optional()
    private readonly factualQuizService: FactualQuizService = new FactualQuizService(),
    @Optional()
    private readonly conceptualTopicService: ConceptualTopicService = new ConceptualTopicService(),
    @Optional()
    private readonly symbolicTopicService: SymbolicTopicService = new SymbolicTopicService(),
    @Optional()
    private readonly adaptivePracticeFlowService: AdaptivePracticeFlowService,
    @Optional()
    private readonly practiceAiInsightsService: PracticeAiInsightsService,
    @Optional()
    private readonly tokens?: TokensService,
  ) {}
  async submitAdaptiveAttempt(
    input: AdaptiveAttemptInput,
  ): Promise<AdaptiveAttemptResult> {
    return this.adaptivePracticeFlowService.submitAttempt(input);
  }

  async getAdaptiveSessionSummary(input: {
    sessionId: string;
    subject: string;
    topicLabel: string;
  }): Promise<AdaptiveSessionSummary> {
    return this.adaptivePracticeFlowService.getSessionSummary(input);
  }

  async getProgressSummary(userId: string) {
    return this.adaptivePracticeFlowService.getProgressSummary(userId);
  }

  async getAiInsightsSummary(userId: string) {
    const summary = await this.getProgressSummary(userId);
    return this.practiceAiInsightsService.generate(summary as any);
  }

  async generate(input: PracticeFilterPayload) {
    const apiKey = process.env.ANTHROPIC_API_KEY;
    const allowOpenTopicFallback = Boolean(apiKey);
    const providedTopicLabel = String(input.topicLabel ?? '').trim();
    const legacyTopic = String(input.topic ?? '').trim();
    const topicPath = Array.isArray(input.topicPath)
      ? input.topicPath.map(String).map((x) => x.trim()).filter(Boolean)
      : [];
    const explicitTopicPathText = String(input.topicPathText ?? '').trim();
    const strictPromptSummary = String(input.strictPromptSummary ?? '').trim();
    const strictTopicText = this.extractStrictTopicText(strictPromptSummary);

    const intake = analyzeCustomPracticeTopic({
      subject: input.subject,
      topicLabel: input.topicLabel,
      topicPathText: input.topicPathText,
      topic: input.topic,
    });

    const conceptualBroadEscape =
      intake.topicType === 'conceptual' ||
      intake.generationStrategy === 'conceptual' ||
      (
        intake.topicType === 'unknown' &&
        intake.quizzability === 'low' &&
        intake.breadth === 'broad' &&
        /^(music|art|philosophy|ethics|logic|writing|grammar)$/i.test(
          String(
            intake.rawTopic ??
              input.topicLabel ??
              input.topicPathText ??
              input.topic ??
              '',
          ).trim(),
        )
      );

    const subject = resolveCanonicalPracticeSubject(
      String(intake.effectiveSubject ?? input.subject ?? 'Math').trim(),
    );

    const rawTopicLabel =
      providedTopicLabel ||
      legacyTopic ||
      (topicPath.length ? topicPath[topicPath.length - 1] : 'General');

    const responseLanguageHint = this.inferResponseLanguageHint(
      subject,
      rawTopicLabel,
      explicitTopicPathText,
      strictTopicText,
    );

    const canonicalTopic =
      resolveCanonicalPracticeTopic(subject, rawTopicLabel) ||
      resolveCanonicalPracticeTopic(subject, explicitTopicPathText) ||
      resolveCanonicalPracticeTopicLoose(
        subject,
        rawTopicLabel,
        explicitTopicPathText,
        strictTopicText,
      ) ||
      null;

    const topicLabel = canonicalTopic?.canonicalTopic ?? rawTopicLabel;
    const hasDeterministicCatalogTopic =
      isDeterministicPracticeTopic(subject, rawTopicLabel) ||
      isDeterministicPracticeTopic(subject, explicitTopicPathText) ||
      isDeterministicPracticeTopicLoose(
        subject,
        rawTopicLabel,
        explicitTopicPathText,
        strictTopicText,
      ) ||
      Boolean(canonicalTopic?.deterministic);
    const hasDeterministicTopicCoverage =
      hasDeterministicCatalogTopic ||
      this.supportsDeterministicOpenTopicCoverage({
        subject,
        topicLabel: rawTopicLabel,
        topicPathText: explicitTopicPathText,
        strictTopicText,
      });

    const hardUnsupported =
      intake.topicType === 'unknown' &&
      intake.quizzability === 'low' &&
      intake.breadth !== 'broad' &&
      !hasDeterministicTopicCoverage &&
      !conceptualBroadEscape;

    if (hardUnsupported && !allowOpenTopicFallback) {
      const unsupportedSubject = String(
        intake.effectiveSubject ?? input.subject ?? 'General Knowledge',
      );
      const unsupportedTopic = String(
        intake.rawTopic ??
          input.topicLabel ??
          input.topicPathText ??
          input.topic ??
          '',
      ).trim();

      throw new BadRequestException({
        code: 'UNSUPPORTED_TOPIC',
        subject: unsupportedSubject,
        topic: unsupportedTopic,
        message: `Topic "${unsupportedTopic}" is not supported yet for ${unsupportedSubject}.`,
        suggestions: [],
      } as any);
    }

    const strictCatalogSubject =
      subject === 'Math' || subject === 'Physics' || subject === 'Electronics';

    const strictCatalogUnsupported =
      strictCatalogSubject &&
      !hasDeterministicTopicCoverage &&
      intake.topicType === 'unknown' &&
      intake.quizzability === 'low';

    if (strictCatalogUnsupported && !allowOpenTopicFallback) {
      const unsupportedTopic = String(
        intake.rawTopic ??
          input.topicLabel ??
          input.topicPathText ??
          input.topic ??
          rawTopicLabel ??
          '',
      ).trim();

      throw new BadRequestException({
        code: 'UNSUPPORTED_TOPIC',
        subject,
        topic: unsupportedTopic,
        message: `Topic "${unsupportedTopic}" is not supported yet for ${subject}.`,
        suggestions: [],
      } as any);
    }
    const shouldCanonicalizeTopicPathText =
      !!canonicalTopic &&
      !!rawTopicLabel &&
      rawTopicLabel.trim().toLowerCase() !==
        canonicalTopic.canonicalTopic.trim().toLowerCase();

    const topicPathText =
      explicitTopicPathText ||
      (shouldCanonicalizeTopicPathText
        ? canonicalTopic?.canonicalTopic
        : (providedTopicLabel ||
            legacyTopic ||
            canonicalTopic?.canonicalTopic ||
            (topicPath.length ? topicPath.join(' > ') : 'General')));

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
    const expectedTopicAnchorTokens = this.topicAnchorTokens(topicLabel);
    const requiredTopicAnchorCount = this.requiredTopicAnchorCount(
      expectedTopicAnchorTokens,
    );

    const requestPayload = {
      subject,
      topicLabel,
      topicPath,
      topicPathText,
      strictPromptSummary,
      responseLanguageHint,
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
        requireBodyTopicAnchor:
          !hasDeterministicTopicCoverage &&
          !canonicalTopic &&
          expectedTopicAnchorTokens.length >= 1,
        topicAnchorTokens:
          !hasDeterministicTopicCoverage && !canonicalTopic
            ? expectedTopicAnchorTokens
            : [],
        topicAnchorMinCount:
          !hasDeterministicTopicCoverage && !canonicalTopic
            ? requiredTopicAnchorCount
            : 0,
        relaxDifficultyValidation:
          hasDeterministicTopicCoverage && !hasDeterministicCatalogTopic,
      },
    };

    if (!subject) {
      throw new BadRequestException('subject is required');
    }

    const engineRegistry = this.getEngineRegistry();
    const deterministic =
      hasDeterministicTopicCoverage &&
      engineRegistry &&
      typeof (engineRegistry as any).generate === 'function'
        ? await (engineRegistry as any).generate({
            subject,
            topicLabel,
            topicPath,
            topicPathText,
            strictPromptSummary: strictTopicText,
            questionCount,
            mode,
            difficulty,
            timePreferenceSeconds,
            useAiTiming,
            maxLives,
          })
        : [];

    const validatedDeterministic = this.validateQuestionSet(
      Array.isArray(deterministic) ? deterministic : [],
      questionCount,
      requestPayload,
    );

    const conceptual =
      this.conceptualTopicService &&
      typeof (this.conceptualTopicService as any).resolve === 'function'
        ? (this.conceptualTopicService as any).resolve({
            subject,
            topicLabel,
            topicPathText,
            questionCount,
          })
        : {
            ready: false,
            seeds: [],
            gaps: ['conceptual_service_unavailable'],
            needsClarification: false,
          };

    const symbolic =
      this.symbolicTopicService &&
      typeof (this.symbolicTopicService as any).resolve === 'function'
        ? (this.symbolicTopicService as any).resolve({
            subject,
            topicLabel,
            topicPathText,
            questionCount,
            difficulty,
          })
        : {
            ready: false,
            seeds: [],
            gaps: ['symbolic_service_unavailable'],
            needsClarification: false,
          };

    
    const isUnsupportedSymbolicTopic =
      !hasDeterministicTopicCoverage &&
      (
        intake.generationStrategy === 'symbolic' ||
        intake.topicType === 'symbolic' ||
        isLikelySymbolicBoundaryTopic(topicLabel)
      );

    if (isUnsupportedSymbolicTopic && !symbolic.ready && !apiKey) {
      return {
        questions: [],
        symbolic: {
          ready: false,
          topic: symbolic.topic || topicLabel,
          gaps: symbolic.gaps.length
            ? symbolic.gaps
            : ['symbolic_generation_not_ready'],
        },
      };
    }

    const routing = this.buildRoutingDecision({
      intake,
      topicLabel,
      deterministicQuestions: validatedDeterministic,
      conceptual,
      symbolic,
      hasDeterministicCatalogTopic: hasDeterministicTopicCoverage,
    });

    if (
      routing.route === 'ai_fallback' &&
      this.shouldRejectAmbiguousAiFallback({
        intake,
        hasDeterministicCatalogTopic: hasDeterministicTopicCoverage,
        allowOpenTopicFallback,
      })
    ) {
      throw practiceBadRequest({
        message: `Topic "${topicLabel}" is too broad or ambiguous for exact practice generation.`,
        userMessage:
          'Make the topic more specific so we can generate an exact session without topic drift.',
        reasonCode: 'TOPIC_NEEDS_CLARIFICATION',
        suggestions: this.buildClarificationSuggestions(subject, topicLabel),
      });
    }

    if (
      routing.route === 'deterministic' &&
      validatedDeterministic.length === questionCount
    ) {
      const base = this.buildDeterministicResponse({
        subject,
        topicLabel,
        mode,
        difficulty,
        deterministic: validatedDeterministic,
      });

      const shouldAttachSymbolicMeta =
        symbolic.ready &&
        (
          intake.generationStrategy === 'symbolic' ||
          intake.topicType === 'symbolic' ||
          isLikelySymbolicBoundaryTopic(topicLabel)
        );

      if (shouldAttachSymbolicMeta) {
        return {
          ...base,
          symbolic: {
            ready: true,
            topic: symbolic.topic || topicLabel,
            gaps: [],
          },
        };
      }

      return base;
    }

    const conceptualBoundaryKeyword =
      /\b(big o|music theory|conditional|conditionals|if statements|algorithmic complexity|time complexity|space complexity|music)\b/i
        .test(topicLabel);

    const conceptualBoundary =
      intake.generationStrategy === 'conceptual' || conceptualBoundaryKeyword;

    if (conceptualBoundary && !conceptual.ready && !apiKey) {
      return {
        questions: [],
        conceptual: {
          ready: false,
          gaps: conceptual.gaps.length
            ? conceptual.gaps
            : ['broad_conceptual_topic'],
        },
      };
    }

    const symbolicBoundaryKeyword =
      /\b(derivative|derivatives|partial derivative|partial derivatives|limit|limits|integral|integrals|matrix|matrices|matrix multiplication|vector|vectors|eigenvalue|eigenvalues|eigenvector|eigenvectors|determinant|determinants|gradient|gradients|jacobian|jacobians|taylor series|maclaurin series|sequence and series|series expansion|differential equation|differential equations|laplace transform|laplace transforms|fourier series|fourier transform|complex number|complex numbers|complex analysis|linear algebra|calculus|tensor|tensors|theorem|theorems|proof|proofs|series|transform|transforms)\b/i
        .test(topicLabel);

    const symbolicBoundary =
      intake.generationStrategy === 'symbolic' ||
      intake.topicType === 'symbolic' ||
      symbolicBoundaryKeyword ||
      (Array.isArray(symbolic.gaps) &&
        symbolic.gaps.some((g) =>
          ['symbolic_generation_not_ready'].includes(String(g)),
        ));



    if (routing.route === 'grounded_factual') {
      const factualResponse = await this.buildFactualResponse({
        subject,
        topicLabel,
        questionCount,
        mode,
        difficulty,
        intake,
      });

      if ((factualResponse.questions?.length ?? 0) === questionCount || !apiKey) {
        return factualResponse;
      }
    }

    if (routing.route === 'conceptual' && conceptual.ready) {
      return this.buildConceptualResponse({
        subject,
        topicLabel,
        mode,
        difficulty,
        questionCount,
        conceptual,
      });
    }

    if (routing.route === 'symbolic') {
      if (symbolic.ready && symbolic.seeds.length > 0) {
        if (symbolic.seeds.length !== questionCount && apiKey) {
          // Fall through to verified AI rather than returning a partial symbolic set.
        } else {
        const now = Date.now();

        return {
          questions: this.materializeQuestions({
            subject,
            topicLabel: symbolic.topic,
            mode,
            difficulty,
            routeTag: 'symbolic',
            now,
            questions: symbolic.seeds.slice(0, questionCount).map((seed) => ({
              prompt: seed.stem,
              options: seed.options,
              correctIndex: seed.correctIndex,
              explanation: seed.explanation,
              recommendedTimeSeconds: seed.recommendedTimeSeconds ?? 35,
            })),
          }),
          symbolic: {
            ready: true,
            topic: symbolic.topic,
            gaps: [],
          },
        };
        }
      }

      if (!apiKey) {

      return {
        questions: [],
        symbolic: {
          ready: false,
          topic: symbolic.topic || topicLabel,
          gaps: Array.from(
            new Set([
              ...(symbolic.gaps.length ? symbolic.gaps : []),
              routing.symbolicReason ?? 'symbolic_generation_not_ready',
            ]),
          ),
        },
      };
      }
    }

    if (!apiKey) {
      throw practiceBadRequest({
        message: `Topic "${topicLabel}" currently needs AI-backed exact-topic generation, but that path is unavailable.`,
        userMessage:
          'We cannot generate this exact custom topic right now without AI-backed fallback. Try a more specific topic or use a covered catalog topic.',
        reasonCode: 'UNSUPPORTED_TOPIC',
        suggestions: this.buildClarificationSuggestions(subject, topicLabel),
      });
    }

    const attemptNotes = [
      '',
      'Regenerate from scratch. Use only clean, standard, classroom-valid questions. correctAnswerText must exactly equal options[correctIndex]. If any item is uncertain or the exact answer is not already in the options, discard it internally and generate a different item.',
      'Use conservative textbook-style questions only. No parameter traps unless trivial. Explanations must be short, final, direct, and option-agnostic.',
      'Final retry. Prefer simpler but unquestionably correct questions over ambitious ones. Never mention options, mismatch, correction, approximation, or uncertainty.',
    ];

    let finalQuestions: RawGeneratedQuestion[] = [];
    let bestLocalValidCount = 0;
    let bestStrictLocalValid: RawGeneratedQuestion[] = [];
    let bestTopicFirstValid: RawGeneratedQuestion[] = [];
    const generationDeadlineAt = Date.now() + this.practiceGenerationBudgetMs();
    let lastAiFailure: unknown = null;

    for (let attempt = 0; attempt < attemptNotes.length; attempt++) {
      const attemptTimeoutMs = this.remainingPracticeBudgetMs(generationDeadlineAt);
      if (attemptTimeoutMs <= 0) {
        this.logPracticeEvent('generation_budget_exhausted', {
          subject,
          topicLabel,
          mode,
          difficulty,
          questionCount,
          attempt: attempt + 1,
        });
        break;
      }

      let raw: any[];
      try {
        raw = await this.requestQuestionSet({
          apiKey,
          requestPayload,
          questionCount,
          repairNote: attemptNotes[attempt],
          timeoutMs: attemptTimeoutMs,
          billingUserId: input.userId,
        });
      } catch (error) {
        lastAiFailure = error;
        this.logPracticeEvent('generation_request_failed', {
          subject,
          topicLabel,
          mode,
          difficulty,
          questionCount,
          attempt: attempt + 1,
          reason: this.practiceErrorMessage(error),
        });
        break;
      }

      const locallyValid = this.validateQuestionSet(raw, questionCount, requestPayload);
      const topicFirstValid = this.validateQuestionSet(
        raw,
        questionCount,
        requestPayload,
        { ignoreDifficultyMode: true },
      );

      if (topicFirstValid.length === questionCount) {
        bestTopicFirstValid = normalizeQuestionSetShape(
          topicFirstValid as any,
        ) as any;
      }

      this.logPracticeEvent('attempt_local_validation', {
        attempt: attempt + 1,
        maxAttempts: attemptNotes.length,
        subject,
        topicLabel,
        mode,
        difficulty,
        localValid: locallyValid.length,
        requested: questionCount,
      });

      if (locallyValid.length !== questionCount) continue;

      if (this.remainingPracticeBudgetMs(generationDeadlineAt) <= 0) {
        this.logPracticeEvent('generation_budget_exhausted', {
          subject,
          topicLabel,
          mode,
          difficulty,
          questionCount,
          attempt: attempt + 1,
          phase: 'self_verify',
        });
        break;
      }

      let selfVerified: RawGeneratedQuestion[];
      try {
        selfVerified = await this.selfVerifyQuestionSet({
          apiKey,
          requestPayload,
          questions: locallyValid,
          timeoutMs: this.remainingPracticeBudgetMs(generationDeadlineAt),
          billingUserId: input.userId,
        });
      } catch (error) {
        lastAiFailure = error;
        this.logPracticeEvent('generation_self_verify_failed', {
          subject,
          topicLabel,
          mode,
          difficulty,
          questionCount,
          attempt: attempt + 1,
          reason: this.practiceErrorMessage(error),
        });
        break;
      }

      this.logPracticeEvent('attempt_self_verified', {
        attempt: attempt + 1,
        maxAttempts: attemptNotes.length,
        subject,
        topicLabel,
        mode,
        difficulty,
        selfVerified: selfVerified.length,
        requested: questionCount,
      });

      if (selfVerified.length !== questionCount) continue;

      const deterministicallyValid = this.deterministicallyValidateQuestionSet({
        questions: selfVerified,
        requestPayload,
      });

      this.logPracticeEvent('attempt_deterministic_validation', {
        attempt: attempt + 1,
        maxAttempts: attemptNotes.length,
        subject,
        topicLabel,
        mode,
        difficulty,
        deterministicValid: deterministicallyValid.length,
        requested: questionCount,
      });

      if (deterministicallyValid.length !== questionCount) continue;

      if (this.remainingPracticeBudgetMs(generationDeadlineAt) <= 0) {
        this.logPracticeEvent('generation_budget_exhausted', {
          subject,
          topicLabel,
          mode,
          difficulty,
          questionCount,
          attempt: attempt + 1,
          phase: 'verify',
        });
        break;
      }

      bestLocalValidCount = Math.max(
        bestLocalValidCount,
        deterministicallyValid.length,
      );
      if (deterministicallyValid.length === questionCount) {
        bestStrictLocalValid = normalizeQuestionSetShape(
          deterministicallyValid as any,
        ) as any;
      }

      let verified: RawGeneratedQuestion[];
      try {
        verified = await this.verifyQuestionSet({
          apiKey,
          requestPayload,
          questions: deterministicallyValid,
          timeoutMs: this.remainingPracticeBudgetMs(generationDeadlineAt),
          billingUserId: input.userId,
        });
      } catch (error) {
        lastAiFailure = error;
        this.logPracticeEvent('generation_verify_failed', {
          subject,
          topicLabel,
          mode,
          difficulty,
          questionCount,
          attempt: attempt + 1,
          reason: this.practiceErrorMessage(error),
        });
        break;
      }

      this.logPracticeEvent('attempt_verified', {
        attempt: attempt + 1,
        maxAttempts: attemptNotes.length,
        subject,
        topicLabel,
        mode,
        difficulty,
        verified: verified.length,
        requested: questionCount,
      });

      if (verified.length === questionCount) {
        finalQuestions = normalizeQuestionSetShape(verified as any) as any;
        break;
      }
    }

    if (
      finalQuestions.length !== questionCount &&
      bestStrictLocalValid.length === questionCount
    ) {
      this.logPracticeEvent('generation_strict_local_fallback', {
        subject,
        topicLabel,
        mode,
        difficulty,
        questionCount,
      });
      finalQuestions = bestStrictLocalValid;
    }

    if (
      finalQuestions.length !== questionCount &&
      bestTopicFirstValid.length === questionCount
    ) {
      this.logPracticeEvent('generation_topic_first_fallback', {
        subject,
        topicLabel,
        mode,
        difficulty,
        questionCount,
      });
      finalQuestions = bestTopicFirstValid;
    }

    if (finalQuestions.length !== questionCount) {
      this.logPracticeEvent('generation_failed', {
        subject,
        topicLabel,
        mode,
        difficulty,
        questionCount,
        bestLocalValidCount,
        finalQuestionsCount: finalQuestions.length,
        lastFailure: lastAiFailure
          ? this.practiceErrorMessage(lastAiFailure)
          : undefined,
      });

      throw practiceGenerationFailed({
        message: lastAiFailure
          ? this.practiceErrorMessage(lastAiFailure)
          : 'Model returned an invalid question set',
      });
    }

    const now = Date.now();

    return {
      questions: this.materializeQuestions({
        subject,
        topicLabel,
        mode,
        difficulty,
        routeTag: 'ai',
        now,
        questions: finalQuestions,
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


  private buildRoutingDecision(args: {
    intake: ReturnType<typeof analyzeCustomPracticeTopic>;
    topicLabel: string;
    deterministicQuestions: unknown[];
    conceptual: ReturnType<ConceptualTopicService['resolve']>;
    symbolic: ReturnType<SymbolicTopicService['resolve']>;
    hasDeterministicCatalogTopic: boolean;
  }): PracticeRoutingDecision {
    if (Array.isArray(args.deterministicQuestions) && args.deterministicQuestions.length > 0) {
      return {
        route: 'deterministic',
        hasDeterministicCatalogTopic: args.hasDeterministicCatalogTopic,
      };
    }

    if (args.intake.generationStrategy === 'grounded_factual') {
      return {
        route: 'grounded_factual',
        hasDeterministicCatalogTopic: args.hasDeterministicCatalogTopic,
      };
    }

    const conceptualKeyword =
      /\b(big o|music theory|conditional|conditionals|if statements|algorithmic complexity|time complexity|space complexity|music)\b/i
        .test(args.topicLabel);

    if (
      args.intake.generationStrategy === 'conceptual' ||
      args.conceptual.ok ||
      conceptualKeyword
    ) {
      return {
        route: 'conceptual',
        hasDeterministicCatalogTopic: args.hasDeterministicCatalogTopic,
      };
    }

    const symbolicKeyword =
      /(derivative|derivatives|partial derivative|partial derivatives|limit|limits|integral|integrals|matrix|matrices|matrix multiplication|vector|vectors|eigenvalue|eigenvalues|eigenvector|eigenvectors|determinant|determinants|gradient|gradients|jacobian|jacobians|taylor series|maclaurin series|sequence and series|series expansion|differential equation|differential equations|laplace transform|laplace transforms|fourier series|fourier transform|complex number|complex numbers|complex analysis|linear algebra|calculus|tensor|tensors|theorem|theorems|proof|proofs|series|transform|transforms)/i
        .test(args.topicLabel);

    const isSymbolic = args.symbolic.ready || args.symbolic.ok;

    if (isSymbolic) {
      return {
        route: 'symbolic',
        symbolicReason:
          args.symbolic.gaps?.[0] ?? 'symbolic_generation_not_ready',
        hasDeterministicCatalogTopic: args.hasDeterministicCatalogTopic,
      };
    }

    return {
      route: 'ai_fallback',
      hasDeterministicCatalogTopic: args.hasDeterministicCatalogTopic,
    };
  }

  private shouldRejectAmbiguousAiFallback(args: {
    intake: ReturnType<typeof analyzeCustomPracticeTopic>;
    hasDeterministicCatalogTopic: boolean;
    allowOpenTopicFallback: boolean;
  }): boolean {
    if (args.hasDeterministicCatalogTopic) return false;
    if (args.allowOpenTopicFallback) return false;

    return (
      args.intake.generationStrategy === 'fallback' &&
      args.intake.needsClarification
    );
  }

  private buildClarificationSuggestions(subject: string, topicLabel: string): string[] {
    const rawTopic = String(topicLabel ?? '').trim();
    const normalizedSubject = String(subject ?? '').trim().toLowerCase();

    const suggestions = [
      rawTopic
        ? `Specify the exact chapter or skill inside "${rawTopic}"`
        : 'Specify the exact chapter or skill you want to practice',
      'Add the exact concept, theorem, era, or problem type instead of a broad label',
    ];

    if (normalizedSubject === 'computer science') {
      suggestions.push('Include the exact language or construct, such as Python loops or C# nested conditions');
    } else if (normalizedSubject === 'math' || normalizedSubject === 'physics' || normalizedSubject === 'electronics') {
      suggestions.push('Name the exact formula, law, equation type, or subtopic you want');
    } else {
      suggestions.push('Use a narrower topic, for example a specific vocabulary skill, grammar concept, event, or unit');
    }

    return suggestions.slice(0, 3);
  }

  private supportsDeterministicOpenTopicCoverage(args: {
    subject: string;
    topicLabel: string;
    topicPathText?: string;
    strictTopicText?: string;
  }): boolean {
    const subject = String(args.subject ?? '').trim().toLowerCase();
    if (subject !== 'computer science') {
      return false;
    }

    const descriptor = `${args.topicLabel} ${args.topicPathText ?? ''} ${args.strictTopicText ?? ''}`
      .toLowerCase()
      .replace(/\s+/g, ' ')
      .trim();
    const hasKnownLanguage =
      /(c#|c sharp|csharp|python|javascript|java|html|hypertext markup)/i.test(
        descriptor,
      );
    const hasBasicsSignal =
      /\b(basic|basics|fundamental|fundamentals|intro|introduction|syntax|starter|getting started|beginner)\b/i.test(
        descriptor,
      );

    return hasKnownLanguage && hasBasicsSignal;
  }

  private buildConceptualResponse(args: {
    subject: string;
    topicLabel: string;
    mode: PracticeMode;
    difficulty: PracticeDifficulty;
    questionCount: number;
    conceptual: ReturnType<ConceptualTopicService['resolve']>;
  }) {
    if (!args.conceptual.ready) {
      return {
        questions: [],
        conceptual: {
          ready: false,
          gaps: args.conceptual.gaps.length
            ? args.conceptual.gaps
            : ['broad_conceptual_topic'],
        },
      };
    }

    const now = Date.now();

    return {
      questions: this.materializeQuestions({
        subject: args.subject,
        topicLabel: args.conceptual.topic,
        mode: args.mode,
        difficulty: args.difficulty,
        routeTag: 'conceptual',
        now,
        questions: args.conceptual.seeds.slice(0, args.questionCount).map((seed) => ({
          prompt: seed.stem,
          options: [
            seed.acceptedAnswers[0],
            'An unrelated statement',
            'A contradictory statement',
            'A vague incorrect statement',
          ],
          correctIndex: 0,
          explanation: seed.explanation,
          recommendedTimeSeconds: 30,
        })),
      }),
      conceptual: {
        ready: true,
        gaps: [],
      },
    };
  }

  private buildDeterministicResponse(args: {
    subject: string;
    topicLabel: string;
    mode: PracticeMode;
    difficulty: PracticeDifficulty;
    deterministic: unknown[];
  }) {
    const now = Date.now();

    return {
      questions: this.materializeQuestions({
        subject: args.subject,
        topicLabel: args.topicLabel,
        mode: args.mode,
        difficulty: args.difficulty,
        routeTag: 'deterministic',
        now,
        questions: args.deterministic as RawGeneratedQuestion[],
      }),
    };
  }

  private async buildFactualResponse(args: {
    subject: string;
    topicLabel: string;
    questionCount: number;
    mode: PracticeMode;
    difficulty: PracticeDifficulty;
    intake: ReturnType<typeof analyzeCustomPracticeTopic>;
  }) {
    if (
      !this.factualQuizService ||
      typeof (this.factualQuizService as any).buildFactPack !== 'function' ||
      typeof (this.factualQuizService as any).buildQuestionSeeds !== 'function'
    ) {
      return {
        questions: [],
        factual: {
          ready: false,
          evidence: [],
          gaps: ['factual_service_unavailable'],
        },
      };
    }

    const factualPack = await (this.factualQuizService as any).buildFactPack({
      subject: args.subject,
      topic: args.topicLabel,
      questionCount: args.questionCount,
      intake: args.intake,
    });

    if (factualPack.ok) {
      const seeded = await (this.factualQuizService as any).buildQuestionSeeds({
        subject: args.subject,
        topic: args.topicLabel,
        questionCount: args.questionCount,
        mode: args.mode,
        difficulty: args.difficulty,
      });

      if (seeded.ok && seeded.seeds.length === args.questionCount) {
        const now = Date.now();

        return {
          questions: this.materializeQuestions({
            subject: seeded.subject,
            topicLabel: seeded.topic,
            mode: args.mode,
            difficulty: args.difficulty,
            routeTag: 'factual',
            now,
            questions: seeded.seeds.map((seed) => {
              const accepted = seed.acceptedAnswers[0] ?? 'Unknown';
              const distractorBase = [
                'Not enough information',
                'A different era',
                'A different concept',
                'A different historical milestone',
                'An incorrect alternative',
              ].filter((x) => x !== accepted);

              return {
                prompt: seed.stem,
                options: [accepted, ...distractorBase].slice(0, 4),
                correctIndex: 0,
                explanation: seed.explanation,
                recommendedTimeSeconds: 30,
              };
            }),
          }),
          factual: {
            ready: true,
            evidence: seeded.evidence,
            gaps: [],
          },
        };
      }
    }

    return {
      questions: [],
      factual: {
        ready: false,
        subject: factualPack.subject,
        topic: factualPack.topic,
        needsClarification: factualPack.needsClarification,
        facts: factualPack.facts,
        evidence: factualPack.evidence,
        gaps: factualPack.gaps,
      },
    };
  }

  private async requestQuestionSet(args: {
    apiKey: string;
    requestPayload: Record<string, unknown>;
    questionCount: number;
    repairNote: string;
    timeoutMs?: number;
    billingUserId?: string;
  }): Promise<any[]> {
    const { apiKey, requestPayload, questionCount, repairNote, timeoutMs } = args;

    const rp: any = requestPayload;
    const system = [
      'You are a senior subject-matter teacher writing practice questions for your strongest student.',
      'Aim for textbook quality: thoughtful framing, realistic numbers, distinct distractors that each represent a plausible mistake — not throwaways.',
      'Each question should teach something on its own. Avoid trivia and avoid mechanical "plug the formula" prompts unless the topic IS pure mechanics.',
      'Vary the question types within the set when natural (conceptual / calculation / application / comparison) so the set feels like a real exam, not 10 clones.',
      'Difficulty should manifest in the actual cognitive load, not just bigger numbers.',
      '',
      'Return STRICT JSON ONLY. No commentary outside the JSON payload.',
      'Markdown and LaTeX are allowed inside JSON string fields when needed for correct rendering.',
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
      'If a prompt or explanation contains source code, put the code snippet in a fenced markdown code block inside the JSON string, with a language tag when obvious.',
      'If code spans multiple lines, it must still be fenced as a markdown code block. Never leave raw multi-line code unfenced.',
      'When you use fenced code blocks, prefer explicit language tags such as python, javascript, typescript, dart, java, csharp, bash, sql, html, css, or json.',
      'If a prompt or explanation contains math notation such as \\frac, \\lim, or \\sqrt, wrap inline math in $...$ and display math in $$...$$. Do not leave raw LaTeX commands outside delimiters.',
      'Render symbolic math cleanly and conventionally when needed: fractions, powers, roots, trig functions, logs, limits, derivatives, integrals, summations, matrices, vectors, set notation, subscripts, and superscripts should use proper LaTeX inside math delimiters.',
      'For matrices, determinants, or vectors, prefer standard LaTeX structures such as bmatrix, pmatrix, vmatrix, or aligned inline vector notation when appropriate. For piecewise definitions, prefer LaTeX cases notation.',
      'Never fake math with plain-text approximations when proper math notation is appropriate, and never emit malformed markdown fences or malformed LaTeX delimiters.',
      rp.responseLanguageHint
        ? `Write prompts, options, explanations, and topicMatchNote in ${String(rp.responseLanguageHint)} when natural for the requested topic. Preserve the same human language/script consistently across the whole set, except for literal code keywords and math notation.`
        : '',
      Array.isArray(rp.constraints?.topicAnchorTokens) &&
      rp.constraints.topicAnchorTokens.length > 0
        ? `Open-topic anchor rule: each item's prompt or explanation must explicitly include at least ${Math.max(1, Number(rp.constraints?.topicAnchorMinCount ?? 1))} of these topic anchors: ${rp.constraints.topicAnchorTokens.join(', ')}.`
        : '',
      Array.isArray(rp.constraints?.topicAnchorTokens) &&
      rp.constraints.topicAnchorTokens.length > 0
        ? 'Do not substitute neighboring concepts, examples, or related APIs unless the required anchor tokens still appear explicitly in the item body.'
        : '',
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
      timeoutMs,
      // Generation runs warm so questions feel like a thoughtful teacher
      // wrote them, not a temperature-0 schema-filler. Verification
      // passes below stay at 0 (the default) for deterministic judgement.
      temperature: 0.7,
      billingUserId: args.billingUserId,
      billingSource: 'practice-generate',
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

  private async selfVerifyQuestionSet(args: {
    apiKey: string;
    requestPayload: Record<string, unknown>;
    questions: RawGeneratedQuestion[];
    timeoutMs?: number;
    billingUserId?: string;
  }): Promise<RawGeneratedQuestion[]> {
    const { apiKey, requestPayload, questions, timeoutMs } = args;
    const confidenceThreshold = this.confidenceThreshold(requestPayload);

    const system = [
      'You are the self-verification layer for a school practice generator.',
      'Return STRICT JSON ONLY.',
      'For each item, solve it again from scratch before deciding anything.',
      'Recompute the result, compare it against the keyed option, and check whether the explanation is consistent with the final answer.',
      'If the keyed answer, final answer, steps, formatting, or reasoning is inconsistent, set validation_passed to false.',
      'Use the following structured contract for every item:',
      '{ "final_answer": string, "steps": string, "confidence": number, "type": "math" | "physics" | "text" | "code", "validation_passed": boolean }',
      'Keep steps concise, teacher-style, and cleanly formatted.',
      'Math steps and final_answer must use proper LaTeX when symbolic notation is needed.',
      'Code in steps must be inside fenced markdown code blocks with a language tag when obvious.',
      'Do not emit confident approvals for uncertain items. Low-confidence or inconsistent items must fail validation.',
      'JSON shape:',
      '{ "audits": [ { "index": number, "final_answer": string, "steps": string, "confidence": number, "type": "math" | "physics" | "text" | "code", "validation_passed": boolean, "reason": string } ] }',
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
      timeoutMs,
      billingUserId: args.billingUserId,
      billingSource: 'practice-self-verify',
      schemaName: 'practice_self_verify',
      schema: {
        type: 'object',
        additionalProperties: false,
        properties: {
          audits: {
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
                final_answer: { type: 'string' },
                steps: { type: 'string' },
                confidence: {
                  type: 'number',
                  minimum: 0,
                  maximum: 1,
                },
                type: {
                  type: 'string',
                  enum: ['math', 'physics', 'text', 'code'],
                },
                validation_passed: { type: 'boolean' },
                reason: { type: 'string' },
              },
              required: [
                'index',
                'final_answer',
                'steps',
                'confidence',
                'type',
                'validation_passed',
                'reason',
              ],
            },
          },
        },
        required: ['audits'],
      },
      system,
      user,
    });

    const audits = Array.isArray(parsed?.audits) ? parsed.audits : [];
    if (audits.length === 0) {
      return questions.map((question) => ({
        ...question,
        answerAudit: this.buildLegacyStructuredAudit(question, requestPayload),
      }));
    }

    const accepted = new Map<number, StructuredAnswerAudit>();
    const seenIndexes = new Set<number>();
    const reasonCounts = new Map<string, number>();

    for (const raw of audits) {
      const parsedAudit = this.parseStructuredAnswerAudit(raw, requestPayload);
      if (!parsedAudit) continue;
      const { index, audit } = parsedAudit;
      if (seenIndexes.has(index)) continue;
      seenIndexes.add(index);

      if (!audit.validationPassed) {
        reasonCounts.set(
          audit.reason || 'self_validation_failed',
          (reasonCounts.get(audit.reason || 'self_validation_failed') ?? 0) + 1,
        );
        continue;
      }

      if (audit.confidence < confidenceThreshold) {
        reasonCounts.set(
          'confidence_below_threshold',
          (reasonCounts.get('confidence_below_threshold') ?? 0) + 1,
        );
        continue;
      }

      accepted.set(index, audit);
    }

    if (reasonCounts.size > 0) {
      console.log(
        `[practice.self_verify] reject_summary ${JSON.stringify(Object.fromEntries(reasonCounts))}`,
      );
    }

    return questions.flatMap((question, index) => {
      const audit = accepted.get(index);
      if (!audit) return [];

      return [
        {
          ...question,
          explanation: audit.steps || question.explanation,
          answerAudit: audit,
        },
      ];
    });
  }

  private async verifyQuestionSet(args: {
    apiKey: string;
    requestPayload: Record<string, unknown>;
    questions: RawGeneratedQuestion[];
    timeoutMs?: number;
    billingUserId?: string;
  }): Promise<RawGeneratedQuestion[]> {
    const { apiKey, requestPayload, questions, timeoutMs } = args;

    const system = [
      'You are a strict academic verifier for a school practice generator.',
      'Return STRICT JSON ONLY.',
      'Solve each item independently from scratch.',
      'Reject any item with wrong math, wrong logic, wrong keyed answer, ambiguous wording, option mismatch, unsupported explanation, weak explanation, topic drift, or hidden self-correction.',
      'Reject any item whose actual complexity or recommendedTimeSeconds clearly does not match the requested difficulty.',
      'Easy should feel direct and short; hard should materially increase reasoning or time demand; olympiad should require genuinely harder insight, not cosmetic difficulty.',
      'Reject any item whose reading load, pacing, or style clearly does not match the requested mode.',
      'Flashcards should be short and recognition-oriented. speedRound should be especially fast and low-reading-load. examPrep should feel more formal and substantial than a quick drill item.',
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
      timeoutMs,
      billingUserId: args.billingUserId,
      billingSource: 'practice-verify',
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

  private parseStructuredAnswerAudit(
    raw: any,
    requestPayload: Record<string, unknown>,
  ): { index: number; audit: StructuredAnswerAudit } | null {
    if (!raw || typeof raw !== 'object') return null;

    const index = Number(raw.index ?? -1);
    const finalAnswer = this.sanitizeText(raw.final_answer ?? raw.finalAnswer);
    const steps = this.sanitizeText(raw.steps);
    const confidence = Number(raw.confidence ?? -1);
    const type = String(raw.type ?? '').trim() as StructuredAnswerType;
    const validationPassed = Boolean(
      raw.validation_passed ?? raw.validationPassed,
    );
    const reason = this.sanitizeText(raw.reason) || 'ok';

    if (!Number.isInteger(index) || index < 0) return null;
    if (!finalAnswer) return null;
    if (!steps) return null;
    if (!Number.isFinite(confidence) || confidence < 0 || confidence > 1) {
      return null;
    }
    if (!['math', 'physics', 'text', 'code'].includes(type)) return null;

    return {
      index,
      audit: {
        finalAnswer,
        steps,
        confidence,
        type,
        validationPassed,
        reason,
      },
    };
  }

  private async callResponsesJson(args: {
    apiKey: string;
    timeoutMs?: number;
    schemaName: string;
    schema: Record<string, unknown>;
    system: string;
    user: string;
    /// Override the default temperature. Verification passes use 0;
    /// generation passes use ~0.7 so questions read like a thoughtful
    /// teacher wrote them, not a constrained schema-filler.
    temperature?: number;
    /// Identifies which user to charge for this call (and what label
    /// to write to the TokenUsage audit table). When omitted (legacy
    /// callers) the call still runs but billing is skipped — never
    /// blocked, since some practice paths run before the user is even
    /// signed in (e.g. anonymous preview flows).
    billingUserId?: string;
    billingSource?: string;
  }): Promise<any> {
    const { apiKey, schema, system, user, timeoutMs } = args;
    const resolvedTimeoutMs = this.resolveOpenAiTimeoutMs(timeoutMs);

    // Cheap pre-flight: bail with 402 BEFORE we hit Anthropic. Skipped
    // when the caller didn't pass a userId or DI hasn't wired tokens in.
    if (args.billingUserId && this.tokens) {
      await this.tokens.assertHasTokens(args.billingUserId);
    }

    const Anthropic = require('@anthropic-ai/sdk').default ?? require('@anthropic-ai/sdk');
    const client = new Anthropic({ apiKey });
    const model = process.env.ANTHROPIC_MODEL || 'claude-sonnet-4-6';

    let res: any;
    try {
      res = await Promise.race([
        client.messages.create({
          model,
          max_tokens: 4000,
          system: `${system}\n\nIMPORTANT: Return ONLY valid JSON. No markdown fences, no explanation. The JSON must conform to this schema:\n${JSON.stringify(schema)}`,
          messages: [{ role: 'user', content: user }],
          temperature: args.temperature ?? 0,
        }),
        new Promise((_, reject) =>
          setTimeout(() => reject(new Error('ANTHROPIC_TIMEOUT')), resolvedTimeoutMs),
        ),
      ]);
    } catch (error: any) {
      if (String(error?.message).includes('ANTHROPIC_TIMEOUT')) {
        throw new InternalServerErrorException(
          `Anthropic request timed out after ${resolvedTimeoutMs}ms`,
        );
      }
      throw error;
    }

    // Charge the user for the call we just made. Done before JSON
    // parsing so a malformed response still bills (Anthropic charged us).
    if (args.billingUserId && this.tokens) {
      await this.tokens.chargeAnthropicResponse({
        userId: args.billingUserId,
        source: args.billingSource ?? 'practice-ai',
        model,
        response: res,
      });
    }

    const jsonText = res?.content?.[0]?.type === 'text' ? res.content[0].text : '';

    try {
      return JSON.parse(jsonText);
    } catch {
      throw new InternalServerErrorException('Model did not return valid JSON');
    }
  }

  private practiceGenerationBudgetMs(): number {
    const raw = Number(process.env.PRACTICE_GENERATE_BUDGET_MS);
    if (!Number.isFinite(raw)) return PRACTICE_GENERATE_BUDGET_MS;
    return Math.max(5000, Math.min(120000, Math.round(raw)));
  }

  private resolveOpenAiTimeoutMs(requestedTimeoutMs?: number): number {
    const envRaw = Number(process.env.PRACTICE_OPENAI_TIMEOUT_MS);
    const envTimeoutMs = Number.isFinite(envRaw)
      ? Math.max(3000, Math.min(60000, Math.round(envRaw)))
      : PRACTICE_OPENAI_TIMEOUT_MS;

    if (!Number.isFinite(requestedTimeoutMs as number)) {
      return envTimeoutMs;
    }

    if ((requestedTimeoutMs as number) <= 0) {
      return 1;
    }

    return Math.max(1000, Math.min(envTimeoutMs, Math.round(requestedTimeoutMs as number)));
  }

  private remainingPracticeBudgetMs(deadlineAt: number): number {
    return deadlineAt - Date.now();
  }

  private isAbortTimeoutError(error: unknown): boolean {
    const name = String((error as { name?: unknown })?.name ?? '');
    const message = String((error as { message?: unknown })?.message ?? '');
    return (
      name === 'AbortError' ||
      name === 'TimeoutError' ||
      /aborted|timed out/i.test(message)
    );
  }

  private practiceErrorMessage(error: unknown): string {
    if (error instanceof HttpException) {
      const response = error.getResponse();
      if (typeof response === 'string' && response.trim()) {
        return response;
      }
      if (
        response &&
        typeof response === 'object' &&
        'message' in response &&
        typeof (response as { message?: unknown }).message === 'string'
      ) {
        return String((response as { message: string }).message);
      }
    }

    if (error instanceof Error && error.message.trim()) {
      return error.message;
    }

    return 'Practice generation failed';
  }

  private validateQuestionSet(
    questions: any[],
    expectedCount: number,
    requestPayload?: Record<string, unknown>,
    options?: {
      ignoreDifficultyMode?: boolean;
    },
  ): RawGeneratedQuestion[] {
    const out: RawGeneratedQuestion[] = [];
    const seen = new Set<string>();
    const reasonCounts = new Map<string, number>();

    for (const [index, raw] of questions.entries()) {
      const reason = this.invalidReason(raw, requestPayload, options);
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

  private deterministicallyValidateQuestionSet(args: {
    questions: RawGeneratedQuestion[];
    requestPayload: Record<string, unknown>;
  }): RawGeneratedQuestion[] {
    const { questions, requestPayload } = args;
    const heuristicQuestions = questions.map((question) => ({
      prompt: String(question.prompt ?? ''),
      explanation: String(question.explanation ?? ''),
      correctAnswer: String(question.correctAnswerText ?? ''),
      options: Array.isArray(question.options) ? question.options : [],
    }));
    const assessment = assessQuestionSetIntegrity(heuristicQuestions);
    if (!assessment.ok) {
      console.log(
        `[practice.deterministic] reject_summary ${JSON.stringify({ set_integrity_failed: assessment.issues.length })}`,
      );
      return [];
    }

    if (!shouldAcceptConfidenceHeuristic(heuristicQuestions)) {
      console.log(
        `[practice.deterministic] reject_summary ${JSON.stringify({ confidence_heuristic_failed: 1 })}`,
      );
      return [];
    }

    const out: RawGeneratedQuestion[] = [];
    const reasonCounts = new Map<string, number>();

    for (const [index, raw] of questions.entries()) {
      const reason = this.deterministicValidationReason(raw, requestPayload);
      if (reason) {
        reasonCounts.set(reason, (reasonCounts.get(reason) ?? 0) + 1);
        console.log(
          `[practice.deterministic] reject index=${index} reason=${reason} prompt="${String(raw?.prompt ?? '').replace(/\s+/g, ' ').slice(0, 140)}"`,
        );
        continue;
      }

      out.push(raw);
    }

    if (reasonCounts.size > 0) {
      console.log(
        `[practice.deterministic] reject_summary ${JSON.stringify(Object.fromEntries(reasonCounts))}`,
      );
    }

    return out;
  }

  private deterministicValidationReason(
    raw: RawGeneratedQuestion,
    requestPayload: Record<string, unknown>,
  ): string | null {
    const audit = this.extractStructuredAnswerAudit(raw, requestPayload);
    const prompt = String(raw.prompt ?? '').trim();
    const explanation = String(raw.explanation ?? '').trim();
    const correctAnswerText = String(raw.correctAnswerText ?? '').trim();
    const subject = String(requestPayload.subject ?? '').trim().toLowerCase();

    if (!audit.validationPassed) return 'structured_validation_failed';
    if (audit.confidence < this.confidenceThreshold(requestPayload)) {
      return 'confidence_below_threshold';
    }
    if (!this.structuredAnswerMatches(raw, audit.finalAnswer)) {
      return 'structured_final_answer_mismatch';
    }
    if (this.hasDivisionByZeroSignal(`${prompt} ${explanation} ${audit.finalAnswer}`)) {
      return 'division_by_zero_detected';
    }
    if (
      (audit.type === 'physics' || subject === 'physics') &&
      this.hasImpossiblePhysicsValue(`${prompt} ${explanation} ${audit.finalAnswer}`)
    ) {
      return 'impossible_physics_value';
    }

    const numericExpectation = this.extractSimpleArithmeticExpectation(prompt);
    if (
      numericExpectation &&
      this.normalizeComparableAnswer(correctAnswerText) !==
        this.normalizeComparableAnswer(numericExpectation)
    ) {
      return 'deterministic_numeric_mismatch';
    }

    const linearExpectation = this.extractOneStepLinearExpectation(prompt);
    if (
      linearExpectation &&
      this.normalizeComparableAnswer(correctAnswerText) !==
        this.normalizeComparableAnswer(linearExpectation)
    ) {
      return 'deterministic_linear_mismatch';
    }

    return null;
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
    const normalized = String(value ?? '')
      .replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, ' ')
      .replace(/\r\n/g, '\n')
      .replace(/\r/g, '\n');

    return normalized
      .split('\n')
      .map((line) => line.replace(/[ \t]+/g, ' ').trimRight())
      .join('\n')
      .replace(/\n{3,}/g, '\n\n')
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
      answerAudit: q?.answerAudit,
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

  private invalidReason(
    raw: any,
    requestPayload?: Record<string, unknown>,
    options?: {
      ignoreDifficultyMode?: boolean;
    },
  ): string | null {
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

    const optionValues = raw.options.map((x: any) => String(x ?? '').trim());
    if (optionValues.some((x: string) => !x)) return 'empty_option';

    const normalizedOptions = optionValues.map((x) =>
      x.toLowerCase().replace(/\s+/g, ' '),
    );
    if (new Set(normalizedOptions).size !== 4) return 'duplicate_options';

    if (!correctAnswerText) return 'missing_correct_answer_text';
    if (optionValues[correctIndex] !== correctAnswerText) {
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

    if (requestPayload) {
      const topicReason = this.topicIntegrityReason(raw, requestPayload);
      if (topicReason) return topicReason;

      if (!options?.ignoreDifficultyMode) {
        const difficultyReason = this.difficultyIntegrityReason(raw, requestPayload);
        if (difficultyReason) return difficultyReason;

        const modeReason = this.modeIntegrityReason(raw, requestPayload);
        if (modeReason) return modeReason;
      }
    }

    if (this.containsUnfencedCodeBlock(prompt) || this.containsUnfencedCodeBlock(explanation)) {
      return 'unfenced_code_block';
    }

    if (this.containsRawLatexOutsideMath(prompt) || this.containsRawLatexOutsideMath(explanation)) {
      return 'raw_latex_outside_math';
    }

    return null;
  }

  private isValidQuestion(raw: any): raw is RawGeneratedQuestion {
    return this.invalidReason(raw) == null;
  }

  private materializeQuestions(args: {
    subject: string;
    topicLabel: string;
    mode: PracticeMode;
    difficulty: PracticeDifficulty;
    routeTag: string;
    now: number;
    questions: RawGeneratedQuestion[];
  }) {
    const normalized = normalizeQuestionSetShape(args.questions as any) as RawGeneratedQuestion[];

    return normalized.map((q, i) => {
      const safe = this.sanitizeQuestion(q);
      const shuffled = this.shuffleOptions(
        (safe.options as string[]).map(String).slice(0, 4),
        Number(safe.correctIndex),
      );

      return {
        id: `${args.subject}-${args.topicLabel}-${args.mode}-${args.difficulty}-${args.routeTag}-${args.now}-${i}`,
        subject: args.subject,
        topicLabel: args.topicLabel,
        mode: args.mode,
        difficulty: args.difficulty,
        prompt: String(safe.prompt).trim(),
        options: shuffled.options,
        correctIndex: shuffled.correctIndex,
        explanation: String(safe.explanation).trim(),
        recommendedTimeSeconds: Number(safe.recommendedTimeSeconds ?? 30),
      };
    });
  }

  private extractStrictTopicText(strictPromptSummary: string): string {
    return String(strictPromptSummary ?? '')
      .split(/\r?\n/)
      .map((line) => line.trim())
      .find((line) => /^topic\s*:/i.test(line))
      ?.replace(/^topic\s*:/i, '')
      .trim() ?? '';
  }

  private topicIntegrityReason(
    raw: RawGeneratedQuestion,
    requestPayload: Record<string, unknown>,
  ): string | null {
    const strictTopicText = this.extractStrictTopicText(
      String(requestPayload.strictPromptSummary ?? ''),
    );
    const expectedTopics = [
      String(requestPayload.topicLabel ?? ''),
      String(requestPayload.topicPathText ?? ''),
      strictTopicText,
    ]
      .flatMap((value) => this.topicVariants(value))
      .filter(Boolean);

    if (!expectedTopics.length) return null;

    const topicMatchNote = String(raw.topicMatchNote ?? '').trim();
    if (!topicMatchNote) return 'missing_topic_match_note';

    const noteVariants = this.topicVariants(topicMatchNote);
    const aligned = noteVariants.some((note) =>
      expectedTopics.some((expected) => this.topicVariantsAlign(note, expected)),
    );

    if (!aligned) return 'topic_drift';

    const requireBodyTopicAnchor = Boolean(
      (requestPayload.constraints as Record<string, unknown> | undefined)
        ?.requireBodyTopicAnchor,
    );

    if (requireBodyTopicAnchor) {
      const bodyText = `${String(raw.prompt ?? '')} ${String(raw.explanation ?? '')}`;
      const bodyTokens = new Set(this.topicTokenSet(bodyText));
      const configuredAnchorTokens = Array.isArray(
        (requestPayload.constraints as Record<string, unknown> | undefined)
          ?.topicAnchorTokens,
      )
        ? ((requestPayload.constraints as Record<string, unknown>).topicAnchorTokens as unknown[])
            .map((token) => this.normalizeTopicToken(String(token ?? '')))
            .filter((token): token is string => Boolean(token))
        : [];
      const expectedTokens = configuredAnchorTokens.length
        ? Array.from(new Set(configuredAnchorTokens))
        : this.topicAnchorTokens(expectedTopics.join(' '));

      if (expectedTokens.length > 0) {
        const anchoredCount = expectedTokens.filter((token) => bodyTokens.has(token)).length;
        const configuredMinAnchorCount = Number(
          (requestPayload.constraints as Record<string, unknown> | undefined)
            ?.topicAnchorMinCount,
        );
        const minAnchorCount = Number.isFinite(configuredMinAnchorCount)
          ? Math.max(1, Math.round(configuredMinAnchorCount))
          : this.requiredTopicAnchorCount(expectedTokens);
        if (anchoredCount < minAnchorCount) {
          return 'topic_anchor_missing_from_body';
        }
      }
    }

    return null;
  }

  private difficultyIntegrityReason(
    raw: RawGeneratedQuestion,
    requestPayload: Record<string, unknown>,
  ): string | null {
    const relaxDifficultyValidation = Boolean(
      (requestPayload.constraints as Record<string, unknown> | undefined)
        ?.relaxDifficultyValidation,
    );
    if (relaxDifficultyValidation) {
      return null;
    }

    const requestedDifficulty = String(
      requestPayload.difficulty ?? 'medium',
    ).trim().toLowerCase();
    const recommendedTimeSeconds = Number(raw.recommendedTimeSeconds ?? 0);
    const prompt = String(raw.prompt ?? '');
    const explanation = String(raw.explanation ?? '');
    const bodyText = `${prompt} ${explanation}`.toLowerCase();

    if (!Number.isFinite(recommendedTimeSeconds) || recommendedTimeSeconds <= 0) {
      return null;
    }

    const obviouslyAdvancedForEasy =
      /\b(prove|proof|theorem|rigorous|epsilon[- ]delta|jacobian|eigen(?:value|vector)?|fourier|laplace|tensor|diagonaliz(?:e|ation)|integration by parts|partial fraction(?:s)?|asymptotic|induction|contradiction)\b/i.test(
        bodyText,
      );
    const obviouslyTrivialForHard =
      /\b(?:what is|compute|evaluate|find|calculate)\s+\(?\s*-?\d+(?:\.\d+)?\s*[+\-*/]\s*-?\d+(?:\.\d+)?\s*\)?\b/i.test(
        bodyText,
      ) ||
      /\bsolve\s+for\s+[a-z]\s*:?\s*(?:[a-z]\s*[+\-]\s*\d+\s*=\s*\d+|\d+\s*[a-z]\s*=\s*\d+|[a-z]\s*\/\s*\d+\s*=\s*\d+)\b/i.test(
        bodyText,
      ) ||
      /\b(?:what is|find)\s+the\s+(?:value|derivative|capital|union|intersection)\s+of\s+[A-Za-z0-9]+\b/i.test(
        bodyText,
      );

    if (requestedDifficulty === 'easy' && obviouslyAdvancedForEasy) {
      return 'difficulty_too_hard_for_easy';
    }

    if (requestedDifficulty === 'easy' && recommendedTimeSeconds > 55) {
      return 'difficulty_too_hard_for_easy';
    }

    if (requestedDifficulty === 'hard' && recommendedTimeSeconds < 35) {
      return 'difficulty_too_easy_for_hard';
    }

    if (requestedDifficulty === 'hard' && obviouslyTrivialForHard) {
      return 'difficulty_too_easy_for_hard';
    }

    if (requestedDifficulty === 'olympiad' && recommendedTimeSeconds < 50) {
      return 'difficulty_too_easy_for_olympiad';
    }

    if (requestedDifficulty === 'olympiad' && obviouslyTrivialForHard) {
      return 'difficulty_too_easy_for_olympiad';
    }

    return null;
  }

  private modeIntegrityReason(
    raw: RawGeneratedQuestion,
    requestPayload: Record<string, unknown>,
  ): string | null {
    const requestedMode = String(requestPayload.mode ?? 'practice')
      .trim()
      .toLowerCase();
    const prompt = String(raw.prompt ?? '').trim();
    const recommendedTimeSeconds = Number(raw.recommendedTimeSeconds ?? 0);
    const promptLength = prompt.length;

    if (!Number.isFinite(recommendedTimeSeconds) || recommendedTimeSeconds <= 0) {
      return null;
    }

    if (requestedMode === 'flashcards') {
      if (recommendedTimeSeconds > 35) return 'mode_too_slow_for_flashcards';
      if (promptLength > 180) return 'mode_too_wordy_for_flashcards';
    }

    if (requestedMode === 'speedround') {
      if (recommendedTimeSeconds > 25) return 'mode_too_slow_for_speedround';
      if (promptLength > 140) return 'mode_too_wordy_for_speedround';
    }

    if (requestedMode === 'examprep') {
      if (recommendedTimeSeconds < 30) return 'mode_too_light_for_examprep';
      if (promptLength < 24) return 'mode_too_brief_for_examprep';
    }

    return null;
  }

  private topicVariants(value: string): string[] {
    const normalized = String(value ?? '')
      .toLowerCase()
      .replace(/[>\/·•,:;()[\]{}|_-]+/g, ' ')
      .replace(/\s+/g, ' ')
      .trim();

    if (!normalized) return [];

    const parts = normalized
      .split(/\s{2,}|\s>\s|\s/)
      .filter(Boolean);

    const segmentSplit = String(value ?? '')
      .toLowerCase()
      .split(/[>\/·•]+/)
      .map((part) =>
        part
          .replace(/[,:;()[\]{}|_-]+/g, ' ')
          .replace(/\s+/g, ' ')
          .trim(),
      )
      .filter(Boolean);

    const variants = new Set<string>([normalized, ...segmentSplit]);
    if (segmentSplit.length > 0) {
      variants.add(segmentSplit[segmentSplit.length - 1]);
    }
    if (parts.length >= 2) {
      variants.add(parts.slice(-2).join(' '));
    }

    return Array.from(variants).filter(Boolean);
  }

  private topicVariantsAlign(a: string, b: string): boolean {
    const left = this.topicTokenSet(a);
    const right = this.topicTokenSet(b);
    if (!left.length || !right.length) return false;

    const overlap = left.filter((token) => right.includes(token));
    const minRequired = Math.min(left.length, right.length);
    if (overlap.length >= minRequired) return true;

    return ` ${a} `.includes(` ${b} `) || ` ${b} `.includes(` ${a} `);
  }

  private topicTokenSet(value: string): string[] {
    return String(value ?? '')
      .toLowerCase()
      .replace(/[^a-z0-9+# ]+/g, ' ')
      .split(/\s+/)
      .map((token) => this.normalizeTopicToken(token))
      .filter((token): token is string => Boolean(token));
  }

  private topicAnchorTokens(value: string): string[] {
    const genericAnchorWords = new Set([
      'basic',
      'basics',
      'beginner',
      'beginners',
      'confusion',
      'example',
      'examples',
      'exercise',
      'exercises',
      'guide',
      'guides',
      'help',
      'issue',
      'issues',
      'intro',
      'introduction',
      'note',
      'notes',
      'overview',
      'practice',
      'problem',
      'problems',
      'question',
      'questions',
      'topic',
      'tutorial',
      'tutorials',
    ]);

    return Array.from(
      new Set(
        this.topicTokenSet(value).filter(
          (token) => token.length >= 4 && !genericAnchorWords.has(token),
        ),
      ),
    );
  }

  private normalizeTopicToken(token: string): string | null {
    const trimmed = String(token ?? '').trim().toLowerCase();
    if (trimmed.length < 3) return null;

    if (trimmed.endsWith('ies') && trimmed.length > 4) {
      return `${trimmed.slice(0, -3)}y`;
    }
    if (trimmed.endsWith('s') && trimmed.length > 4) {
      return trimmed.slice(0, -1);
    }
    return trimmed;
  }

  private requiredTopicAnchorCount(expectedTokens: string[]): number {
    if (expectedTokens.length <= 1) return 1;
    if (expectedTokens.length === 2) return 2;
    return 2;
  }

  private inferResponseLanguageHint(
    subject: string,
    topicLabel: string,
    topicPathText: string,
    strictTopicText: string,
  ): string | null {
    const normalizedSubject = String(subject ?? '').trim().toLowerCase();
    if (normalizedSubject === 'arabic') return 'Arabic';
    if (normalizedSubject === 'hebrew') return 'Hebrew';
    if (normalizedSubject === 'english') return 'English';

    const text = `${topicLabel} ${topicPathText} ${strictTopicText}`;
    if (/[\u0600-\u06FF]/.test(text)) return 'Arabic';
    if (/[\u0590-\u05FF]/.test(text)) return 'Hebrew';
    return null;
  }

  private containsUnfencedCodeBlock(text: string): boolean {
    const value = String(text ?? '');
    if (!value.includes('\n')) return false;
    // Already fenced — fine.
    if (value.includes('```') || value.includes('~~~')) return false;

    // Strip ALL math regions before checking — LaTeX uses {} extensively
    // and would otherwise produce false positives on every math explanation.
    const stripped = value
      .replace(/\\\[[\s\S]*?\\\]/g, ' ')   // \[...\]
      .replace(/\\\([\s\S]*?\\\)/g, ' ')   // \(...\)
      .replace(/\$\$[\s\S]*?\$\$/g, ' ')   // $$...$$
      .replace(/\$[^$\n]+?\$/g, ' ');       // $...$

    const lines = stripped
      .split(/\r?\n/)
      .map((line) => line.trim())
      .filter(Boolean);

    if (lines.length < 2) return false;

    // Only flag lines with clear programming syntax (not LaTeX).
    // Deliberately excludes { } ; since LaTeX uses them constantly.
    const codeLikeLines = lines.filter((line) =>
      /(^|\s)(if\s*\(|else\s*\{|else\s+if|for\s*\(|while\s*\(|switch\s*\(|def\s+\w|class\s+\w|function\s+\w|\breturn\b|print\(|console\.|System\.out|Console\.Write|let\s+\w|const\s+\w|var\s+\w|int\s+\w|double\s+\w|void\s+\w|public\s+\w|private\s+\w)/.test(line)
    );

    return codeLikeLines.length >= 2;
  }

  private containsRawLatexOutsideMath(text: string): boolean {
    // Strip ALL valid math delimiter styles before checking for raw LaTeX.
    // Both \(...\)/\[...\] and $...$ / $$...$$ are valid — the new prompts
    // use \(...\) and \[...\] which must not be flagged as raw.
    const stripped = String(text ?? '')
      .replace(/```[\s\S]*?```/g, ' ')
      .replace(/~~~[\s\S]*?~~~/g, ' ')
      .replace(/\$\$[\s\S]*?\$\$/g, ' ')
      .replace(/\$[^$\n]+?\$/g, ' ')
      .replace(/\\\([\s\S]*?\\\)/g, ' ')
      .replace(/\\\[[\s\S]*?\\\]/g, ' ');

    return /\\(frac|sqrt|cdot|times|leq|geq|neq|pm|mp|approx|left|right|alpha|beta|gamma|delta|theta|lambda|mu|pi|sigma|lim|int|sum|prod)\b/.test(
      stripped,
    );
  }

  private extractStructuredAnswerAudit(
    raw: RawGeneratedQuestion,
    requestPayload: Record<string, unknown>,
  ): StructuredAnswerAudit {
    const existing = raw.answerAudit;
    if (existing && typeof existing === 'object') {
      const parsed = this.parseStructuredAnswerAudit(
        { index: 0, ...(existing as Record<string, unknown>) },
        requestPayload,
      );
      if (parsed) return parsed.audit;
    }

    return this.buildLegacyStructuredAudit(raw, requestPayload);
  }

  private buildLegacyStructuredAudit(
    raw: RawGeneratedQuestion,
    requestPayload: Record<string, unknown>,
  ): StructuredAnswerAudit {
    return {
      finalAnswer: this.sanitizeText(raw.correctAnswerText),
      steps:
        this.sanitizeText(raw.explanation) || 'No verified steps were provided.',
      confidence: 0.93,
      type: this.inferStructuredAnswerType(raw, requestPayload),
      validationPassed: true,
      reason: 'legacy_fallback',
    };
  }

  private inferStructuredAnswerType(
    raw: RawGeneratedQuestion,
    requestPayload: Record<string, unknown>,
  ): StructuredAnswerType {
    const text = `${String(raw.prompt ?? '')}\n${String(raw.explanation ?? '')}`;
    const subject = String(requestPayload.subject ?? '').trim().toLowerCase();
    if (text.includes('```') || text.includes('~~~')) return 'code';
    if (subject === 'physics') return 'physics';
    if (/[∫∑ΣΠ√]|\\(frac|sqrt|lim|int|sum|prod)\b|\b(?:sin|cos|tan|log|ln)\b|[_^]/.test(text)) {
      return subject === 'physics' ? 'physics' : 'math';
    }
    return 'text';
  }

  private confidenceThreshold(requestPayload: Record<string, unknown>): number {
    const difficulty = String(requestPayload.difficulty ?? 'medium')
      .trim()
      .toLowerCase();

    switch (difficulty) {
      case 'easy':
        return 0.72;
      case 'hard':
        return 0.82;
      case 'olympiad':
        return 0.86;
      case 'medium':
      default:
        return 0.78;
    }
  }

  private structuredAnswerMatches(
    raw: RawGeneratedQuestion,
    finalAnswer: string,
  ): boolean {
    const normalizedFinal = this.normalizeComparableAnswer(finalAnswer);
    const normalizedCorrect = this.normalizeComparableAnswer(
      String(raw.correctAnswerText ?? ''),
    );

    if (!normalizedFinal || !normalizedCorrect) return false;
    if (normalizedFinal === normalizedCorrect) return true;

    const letter = normalizedFinal.replace(/[^a-d]/g, '');
    const correctIndex = Number(raw.correctIndex ?? -1);
    if (letter.length === 1 && correctIndex >= 0) {
      return 'abcd'.indexOf(letter) === correctIndex;
    }

    return false;
  }

  private normalizeComparableAnswer(value: string): string {
    return String(value ?? '')
      .replace(/```[\s\S]*?```/g, ' ')
      .replace(/~~~[\s\S]*?~~~/g, ' ')
      .replace(/\$\$([\s\S]*?)\$\$/g, '$1')
      .replace(/\$([^$\n]+)\$/g, '$1')
      .replace(/\\text\{([^{}]+)\}/g, '$1')
      .replace(/\\frac\{([^{}]+)\}\{([^{}]+)\}/g, '$1/$2')
      .replace(/[^\p{L}\p{N}+\-*/.=()/ ]+/gu, ' ')
      .replace(/\s+/g, ' ')
      .trim()
      .toLowerCase();
  }

  private hasDivisionByZeroSignal(text: string): boolean {
    const normalized = String(text ?? '').replace(/\s+/g, ' ');
    return /\/\s*0(?:\D|$)/.test(normalized) || /\\frac\{[^{}]+\}\{0\}/.test(normalized);
  }

  private hasImpossiblePhysicsValue(text: string): boolean {
    const normalized = String(text ?? '').toLowerCase();
    return /-\d+(?:\.\d+)?\s*k\b/.test(normalized) || /negative\s+kelvin/.test(normalized);
  }

  private extractSimpleArithmeticExpectation(prompt: string): string | null {
    const match = String(prompt ?? '')
      .trim()
      .match(/\b(?:what is|compute|evaluate|find|calculate)\s+\(?\s*(-?\d+(?:\.\d+)?)\s*([+\-*/])\s*(-?\d+(?:\.\d+)?)\s*\)?\??/i);
    if (!match) return null;

    const left = Number(match[1]);
    const op = match[2];
    const right = Number(match[3]);
    if (!Number.isFinite(left) || !Number.isFinite(right)) return null;
    if (op === '/' && right === 0) return null;

    const value =
      op === '+'
        ? left + right
        : op === '-'
          ? left - right
          : op === '*'
            ? left * right
            : left / right;

    return Number.isInteger(value) ? String(value) : String(Number(value.toFixed(6)));
  }

  private extractOneStepLinearExpectation(prompt: string): string | null {
    const match = String(prompt ?? '')
      .trim()
      .match(/\bsolve\s+for\s+([a-z])\s*:?\s*\1\s*([+\-])\s*(\d+(?:\.\d+)?)\s*=\s*(-?\d+(?:\.\d+)?)\.?/i);
    if (!match) return null;

    const sign = match[2];
    const term = Number(match[3]);
    const rhs = Number(match[4]);
    if (!Number.isFinite(term) || !Number.isFinite(rhs)) return null;

    const value = sign === '+' ? rhs - term : rhs + term;
    return Number.isInteger(value) ? String(value) : String(Number(value.toFixed(6)));
  }
}