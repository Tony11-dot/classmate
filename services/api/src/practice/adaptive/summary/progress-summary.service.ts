import { Injectable } from '@nestjs/common';
import type {
  ProgressSummary,
  StrengthItem,
  TopicMasterySnapshot,
  WeaknessItem,
} from './progress-summary.types';

function clamp01(n: number): number {
  if (!Number.isFinite(n)) return 0;
  return Math.max(0, Math.min(1, n));
}

function safeInt(n: unknown): number {
  const v = Number(n);
  if (!Number.isFinite(v)) return 0;
  return Math.max(0, Math.floor(v));
}

@Injectable()
export class ProgressSummaryService {
  summarize(input: {
    topics: TopicMasterySnapshot[];
    weakLimit?: number;
    strongLimit?: number;
  }): ProgressSummary {
    const topics = Array.isArray(input.topics) ? input.topics : [];
    const weakLimit = Math.max(1, Math.min(10, Number(input.weakLimit ?? 3) || 3));
    const strongLimit = Math.max(1, Math.min(10, Number(input.strongLimit ?? 3) || 3));

    const normalized = topics.map((t) => {
      const attempts = safeInt(t.attempts);
      const correct = Math.min(attempts, safeInt(t.correct));
      const derivedAccuracy =
        attempts > 0 ? correct / attempts : clamp01(Number(t.accuracy ?? 0));

      return {
        subject: String(t.subject ?? '').trim(),
        topic: String(t.topic ?? '').trim(),
        accuracy: clamp01(derivedAccuracy),
        streak: safeInt(t.streak),
        attempts,
        correct,
        lastDifficulty: t.lastDifficulty,
      };
    });

    const totalAttempts = normalized.reduce((sum, t) => sum + t.attempts, 0);
    const totalCorrect = normalized.reduce((sum, t) => sum + t.correct, 0);
    const overallAccuracy =
      totalAttempts > 0 ? totalCorrect / totalAttempts : 0;

    const weakTopics: WeaknessItem[] = normalized
      .filter((t) => t.attempts > 0)
      .sort((a, b) => {
        if (a.accuracy !== b.accuracy) return a.accuracy - b.accuracy;
        if (a.attempts !== b.attempts) return b.attempts - a.attempts;
        return a.topic.localeCompare(b.topic);
      })
      .slice(0, weakLimit)
      .map((t) => ({
        subject: t.subject,
        topic: t.topic,
        accuracy: t.accuracy,
        attempts: t.attempts,
        recommendedDifficulty:
          t.accuracy < 0.45 ? 'easy' : t.accuracy < 0.75 ? 'medium' : 'hard',
        reason:
          t.accuracy < 0.45
            ? 'low_accuracy'
            : t.accuracy < 0.75
              ? 'needs_reinforcement'
              : 'stability_check',
      }));

    const strongTopics: StrengthItem[] = normalized
      .filter((t) => t.attempts > 0)
      .sort((a, b) => {
        if (a.accuracy !== b.accuracy) return b.accuracy - a.accuracy;
        if (a.streak !== b.streak) return b.streak - a.streak;
        if (a.attempts !== b.attempts) return b.attempts - a.attempts;
        return a.topic.localeCompare(b.topic);
      })
      .slice(0, strongLimit)
      .map((t) => ({
        subject: t.subject,
        topic: t.topic,
        accuracy: t.accuracy,
        streak: t.streak,
        attempts: t.attempts,
      }));

    const recommendedFocus = weakTopics.map(
      (t) => `${t.subject} — ${t.topic}`,
    );

    return {
      totalTopics: normalized.length,
      totalAttempts,
      totalCorrect,
      overallAccuracy,
      weakTopics,
      strongTopics,
      recommendedFocus,
    };
  }
}
