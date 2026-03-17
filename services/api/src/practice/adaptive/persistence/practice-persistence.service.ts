import { Injectable } from '@nestjs/common';
import type {
  PracticeAttemptRecord,
  PracticeProgressSummary,
  PracticeSessionRecord,
  TopicMasteryRecord,
  UpsertPracticeAttemptInput,
} from './practice-session.types';

function nowIso(): string {
  return new Date().toISOString();
}

function keyOf(userId: string, subject: string, topicLabel: string): string {
  return `${userId}::${subject}::${topicLabel}`.toLowerCase();
}

@Injectable()
export class PracticePersistenceService {
  private readonly sessions = new Map<string, PracticeSessionRecord>();
  private readonly mastery = new Map<string, TopicMasteryRecord>();

  startSession(input: {
    userId: string;
    sessionId?: string;
    subject: string;
    topicLabel: string;
    mode: string;
  }): PracticeSessionRecord {
    const id =
      input.sessionId?.trim() ||
      `ps_${input.userId}_${input.subject}_${input.topicLabel}_${Date.now()}`;

    const existing = this.sessions.get(id);
    if (existing) return existing;

    const session: PracticeSessionRecord = {
      id,
      userId: input.userId,
      subject: input.subject,
      topicLabel: input.topicLabel,
      mode: input.mode,
      startedAt: nowIso(),
      updatedAt: nowIso(),
      attempts: [],
    };

    this.sessions.set(id, session);
    return session;
  }

  recordAttempt(input: UpsertPracticeAttemptInput): {
    session: PracticeSessionRecord;
    mastery: TopicMasteryRecord;
    attempt: PracticeAttemptRecord;
  } {
    const session = this.startSession({
      userId: input.userId,
      sessionId: input.sessionId,
      subject: input.subject,
      topicLabel: input.topicLabel,
      mode: input.mode,
    });

    const attempt: PracticeAttemptRecord = {
      questionId: input.questionId,
      subject: input.subject,
      topicLabel: input.topicLabel,
      difficulty: input.difficulty,
      mode: input.mode,
      isCorrect: Boolean(input.isCorrect),
      selectedIndex: input.selectedIndex ?? null,
      correctIndex: input.correctIndex ?? null,
      answeredAt: nowIso(),
    };

    session.attempts.push(attempt);
    session.updatedAt = nowIso();

    const masteryKey = keyOf(input.userId, input.subject, input.topicLabel);
    const previous =
      this.mastery.get(masteryKey) ??
      ({
        userId: input.userId,
        subject: input.subject,
        topicLabel: input.topicLabel,
        accuracy: 0,
        streak: 0,
        totalAnswered: 0,
        correctAnswered: 0,
        lastUpdatedAt: nowIso(),
      } satisfies TopicMasteryRecord);

    const totalAnswered = previous.totalAnswered + 1;
    const correctAnswered = previous.correctAnswered + (input.isCorrect ? 1 : 0);
    const streak = input.isCorrect ? previous.streak + 1 : 0;
    const accuracy =
      totalAnswered > 0 ? Number((correctAnswered / totalAnswered).toFixed(4)) : 0;

    const mastery: TopicMasteryRecord = {
      ...previous,
      totalAnswered,
      correctAnswered,
      streak,
      accuracy,
      lastUpdatedAt: nowIso(),
    };

    this.mastery.set(masteryKey, mastery);

    return { session, mastery, attempt };
  }

  getSession(sessionId: string): PracticeSessionRecord | null {
    return this.sessions.get(sessionId) ?? null;
  }

  getTopicMastery(input: {
    userId: string;
    subject: string;
    topicLabel: string;
  }): TopicMasteryRecord | null {
    return (
      this.mastery.get(keyOf(input.userId, input.subject, input.topicLabel)) ?? null
    );
  }

  getProgressSummary(userId: string): PracticeProgressSummary {
    const sessions = [...this.sessions.values()].filter((s) => s.userId === userId);
    const topicMastery = [...this.mastery.values()].filter((m) => m.userId === userId);

    const totalAttempts = sessions.reduce((sum, s) => sum + s.attempts.length, 0);
    const totalCorrect = sessions.reduce(
      (sum, s) => sum + s.attempts.filter((a) => a.isCorrect).length,
      0,
    );
    const overallAccuracy =
      totalAttempts > 0 ? Number((totalCorrect / totalAttempts).toFixed(4)) : 0;

    const ranked = [...topicMastery]
      .map((m) => ({
        subject: m.subject,
        topicLabel: m.topicLabel,
        accuracy: m.accuracy,
        totalAnswered: m.totalAnswered,
      }))
      .sort((a, b) => {
        if (a.accuracy !== b.accuracy) return a.accuracy - b.accuracy;
        return b.totalAnswered - a.totalAnswered;
      });

    return {
      userId,
      totalSessions: sessions.length,
      totalAttempts,
      totalCorrect,
      overallAccuracy,
      weakTopics: ranked.slice(0, 5),
      strongestTopics: [...ranked].reverse().slice(0, 5),
    };
  }
}
