import { Injectable } from '@nestjs/common';
import { MasteryService } from '../mastery.service';
import { AttemptEvaluatorService } from '../evaluator/attempt-evaluator.service';
import { AdaptiveSelectorService } from '../selector/adaptive-selector.service';
import { PracticePersistenceService } from '../persistence/practice-persistence.service';
import { ProgressSummaryService } from '../summary/progress-summary.service';
import type {
  AdaptiveAttemptInput,
  AdaptiveAttemptResult,
  AdaptiveSessionSummary,
} from '../contracts/adaptive-practice.types';

@Injectable()
export class AdaptivePracticeFlowService {
  constructor(
    private readonly masteryService: MasteryService = new MasteryService(),
    private readonly evaluator: AttemptEvaluatorService = new AttemptEvaluatorService(),
    private readonly selector: AdaptiveSelectorService = new AdaptiveSelectorService(),
    private readonly persistence: PracticePersistenceService = new PracticePersistenceService(),
    private readonly summary: ProgressSummaryService = new ProgressSummaryService(),
  ) {}

  private toTopicKey(subject: string, topicLabel: string): string {
    return `${String(subject ?? '').trim()}::${String(topicLabel ?? '').trim()}`;
  }

  private toMasteryState(input: {
    subject: string;
    topicLabel: string;
    stored?: any;
  }) {
    const base = this.masteryService.createEmpty(input.subject, input.topicLabel);
    const stored = input.stored ?? {};
    return {
      ...base,
      attempts: Number(stored.totalAnswered ?? stored.attempts ?? base.attempts ?? 0),
      correct: Number(stored.correctAnswered ?? stored.correct ?? base.correct ?? 0),
      streak: Number(stored.streak ?? base.streak ?? 0),
      accuracy:
        typeof stored.accuracy === 'number'
          ? stored.accuracy
          : base.accuracy,
      lastOutcome: (stored as any).lastOutcome ?? base.lastOutcome,
      band: (stored as any).band ?? base.band,
    };
  }

  private pickNextDifficulty(mastery: {
    accuracy?: number;
    streak?: number;
  }) {
    return this.selector.choose({
      masteryScore: Number(mastery.accuracy ?? 0),
      streak: Number(mastery.streak ?? 0),
      recentAccuracy: Number(mastery.accuracy ?? 0),
    });
  }

  private computeAwardedScore(input: {
    isCorrect: boolean;
    responseTimeMs?: number;
  }): number {
    if (!input.isCorrect) return 0;
    const ms = Number(input.responseTimeMs ?? 0);
    if (ms > 0 && ms <= 15000) return 10;
    if (ms > 15000 && ms <= 30000) return 8;
    return 6;
  }

  submitAttempt(input: AdaptiveAttemptInput): AdaptiveAttemptResult {
    const topicKey = this.toTopicKey(input.subject, input.topicLabel);

    this.persistence.createSession({
      sessionId: input.sessionId,
      subject: input.subject,
      topicLabel: input.topicLabel,
      userId: 'anonymous',
    });

    const prevStored =
      this.persistence.getTopicMastery(topicKey) ??
      this.persistence.getTopicMastery({
        subject: input.subject,
        topicLabel: input.topicLabel,
      });

    const prevMastery = this.toMasteryState({
      subject: input.subject,
      topicLabel: input.topicLabel,
      stored: prevStored,
    });

    const evaluated = this.evaluator.evaluate({
      selectedIndex: input.selectedIndex,
      correctIndex: input.correctIndex,
      responseTimeSeconds:
        typeof input.responseTimeMs === 'number'
          ? input.responseTimeMs / 1000
          : undefined,
    });

    const awardedScore = this.computeAwardedScore({
      isCorrect: Boolean(evaluated.isCorrect),
      responseTimeMs: input.responseTimeMs,
    });

    const nextMastery = this.masteryService.update(prevMastery, {
      isCorrect: Boolean(evaluated.isCorrect),
    });

    this.persistence.recordAttempt({
      userId: 'anonymous',
      sessionId: input.sessionId,
      subject: input.subject,
      topicLabel: input.topicLabel,
      questionId: input.questionId,
      isCorrect: Boolean(evaluated.isCorrect),
      selectedIndex: input.selectedIndex,
      correctIndex: input.correctIndex,
      difficulty: input.difficulty ?? 'adaptive',
      responseTimeMs: input.responseTimeMs,
      awardedScore,
    });

    const storedMastery = this.persistence.saveTopicMastery(topicKey, {
      userId: 'anonymous',
      subject: input.subject,
      topicLabel: input.topicLabel,
      totalAnswered: Number((nextMastery as any).attempts ?? 0),
      correctAnswered: Number((nextMastery as any).correct ?? 0),
      accuracy: Number((nextMastery as any).accuracy ?? 0),
      streak: Number((nextMastery as any).streak ?? 0),
    });

    const nextChoice = this.pickNextDifficulty(storedMastery);
    const sessionAttempts = this.persistence.listAttemptsBySession(input.sessionId);
    const weakAreas =
      storedMastery.accuracy < 0.6 ? [input.topicLabel] : [];
    const strengths =
      storedMastery.accuracy >= 0.8 ? [input.topicLabel] : [];

    void this.summary;

    return {
      sessionId: input.sessionId,
      topicKey,
      isCorrect: Boolean(evaluated.isCorrect),
      awardedScore,
      targetDifficulty: nextChoice.targetDifficulty,
      streak: Number(storedMastery.streak ?? 0),
      accuracy: Number(storedMastery.accuracy ?? 0),
      recommendedFocus:
        weakAreas.length > 0
          ? weakAreas
          : strengths.length > 0
            ? []
            : sessionAttempts.length >= 2
              ? [input.topicLabel]
              : [],
    };
  }

  getSessionSummary(input: {
    sessionId: string;
    subject: string;
    topicLabel: string;
  }): AdaptiveSessionSummary {
    const topicKey = this.toTopicKey(input.subject, input.topicLabel);
    const attempts = this.persistence.listAttemptsBySession(input.sessionId);
    const mastery =
      this.persistence.getTopicMastery(topicKey) ??
      this.persistence.getTopicMastery({
        subject: input.subject,
        topicLabel: input.topicLabel,
      }) ??
      this.persistence.saveTopicMastery(topicKey, {
        userId: 'anonymous',
        subject: input.subject,
        topicLabel: input.topicLabel,
        totalAnswered: attempts.length,
        correctAnswered: attempts.filter((x: any) => x.isCorrect).length,
        accuracy:
          attempts.length > 0
            ? attempts.filter((x: any) => x.isCorrect).length / attempts.length
            : 0,
        streak: (() => {
          let streak = 0;
          for (const a of attempts as any[]) {
            streak = a.isCorrect ? streak + 1 : 0;
          }
          return streak;
        })(),
      });

    const next = this.pickNextDifficulty(mastery);
    const correct = attempts.filter((x: any) => x?.isCorrect).length;
    const weakAreas = mastery.accuracy < 0.6 ? [input.topicLabel] : [];
    const strengths = mastery.accuracy >= 0.8 ? [input.topicLabel] : [];

    return {
      sessionId: input.sessionId,
      subject: input.subject,
      topicLabel: input.topicLabel,
      attempts: attempts.length,
      correct,
      accuracy: Number(mastery.accuracy ?? 0),
      currentDifficulty: next.targetDifficulty,
      weakAreas,
      strengths,
    };
  }
}
