import { Injectable } from '@nestjs/common';
import type {
  PracticeAttemptRecord,
  PracticeSessionRecord,
  TopicMasteryRecord,
} from './practice-session.types';

type StoredSession = PracticeSessionRecord & {
  id: string;
  userId: string;
};

type StoredMastery = TopicMasteryRecord & {
  subject: string;
  topicLabel: string;
  totalAnswered: number;
  correctAnswered: number;
  accuracy: number;
  streak: number;
};

type CreateSessionInput = {
  userId?: string;
  sessionId: string;
  subject: string;
  topicLabel: string;
};

type RecordAttemptInput = {
  userId?: string;
  sessionId: string;
  subject: string;
  topicLabel: string;
  questionId: string;
  isCorrect: boolean;
  selectedIndex?: number;
  correctIndex?: number;
  difficulty?: 'easy' | 'medium' | 'hard' | 'olympiad' | 'adaptive';
  responseTimeMs?: number;
  awardedScore?: number;
};

type TopicSummary = {
  subject: string;
  topicLabel: string;
  totalAnswered: number;
  correctAnswered: number;
  accuracy: number;
  streak: number;
};

@Injectable()
export class PracticePersistenceService {
  private readonly sessions = new Map<string, StoredSession>();
  private readonly attemptsBySession = new Map<string, PracticeAttemptRecord[]>();
  private readonly topicMastery = new Map<string, StoredMastery>();
  private readonly userSessions = new Map<string, Set<string>>();

  private safeUserId(userId?: string): string {
    return String(userId ?? 'anonymous');
  }

  private linkUserSession(userId: string | undefined, sessionId: string): void {
    const uid = this.safeUserId(userId);
    const bucket = this.userSessions.get(uid) ?? new Set<string>();
    bucket.add(sessionId);
    this.userSessions.set(uid, bucket);
  }

  private toTopicKey(subject: string, topicLabel: string): string {
    return `${String(subject ?? '').trim()}::${String(topicLabel ?? '').trim()}`;
  }

  startSession(input: CreateSessionInput): StoredSession {
    return this.createSession(input);
  }

  createSession(input: CreateSessionInput): StoredSession {
    const existing = this.sessions.get(input.sessionId);
    if (existing) {
      this.linkUserSession(input.userId ?? existing.userId, input.sessionId);
      return existing;
    }

    const created = {
      id: input.sessionId,
      sessionId: input.sessionId,
      userId: this.safeUserId(input.userId),
      subject: input.subject,
      topicLabel: input.topicLabel,
      attempts: [],
    } as unknown as StoredSession;

    this.sessions.set(input.sessionId, created);
    this.attemptsBySession.set(input.sessionId, []);
    this.linkUserSession(created.userId, input.sessionId);
    return created;
  }

  getSession(sessionId: string): StoredSession | null {
    return this.sessions.get(sessionId) ?? null;
  }

  recordAttempt(input: RecordAttemptInput): PracticeAttemptRecord {
    const session =
      this.getSession(input.sessionId) ??
      this.createSession({
        userId: input.userId,
        sessionId: input.sessionId,
        subject: input.subject,
        topicLabel: input.topicLabel,
      });

    this.linkUserSession(input.userId ?? session.userId, input.sessionId);

    const attempt = {
      questionId: input.questionId,
      isCorrect: Boolean(input.isCorrect),
      selectedIndex:
        typeof input.selectedIndex === 'number' ? input.selectedIndex : undefined,
      correctIndex:
        typeof input.correctIndex === 'number' ? input.correctIndex : undefined,
      difficulty: input.difficulty ?? 'adaptive',
      responseTimeMs:
        typeof input.responseTimeMs === 'number' ? input.responseTimeMs : undefined,
      awardedScore:
        typeof input.awardedScore === 'number' ? input.awardedScore : 0,
      subject: input.subject,
      topicLabel: input.topicLabel,
      sessionId: input.sessionId,
    } as unknown as PracticeAttemptRecord;

    const bucket = this.attemptsBySession.get(input.sessionId) ?? [];
    bucket.push(attempt);
    this.attemptsBySession.set(input.sessionId, bucket);

    const updatedSession = {
      ...session,
      attempts: [...bucket],
    } as StoredSession;

    this.sessions.set(input.sessionId, updatedSession);
    return attempt;
  }

  listAttemptsBySession(sessionId: string): PracticeAttemptRecord[] {
    return [...(this.attemptsBySession.get(sessionId) ?? [])];
  }

  saveTopicMastery(
    topicKey: string,
    mastery: Partial<StoredMastery> & {
      subject?: string;
      topicLabel?: string;
      totalAnswered?: number;
      correctAnswered?: number;
      accuracy?: number;
      streak?: number;
      attempts?: number;
      correct?: number;
      userId?: string;
      lastUpdatedAt?: Date | string;
    },
  ): StoredMastery {
    const prev = this.topicMastery.get(topicKey);

    const totalAnswered = Number(
      mastery.totalAnswered ?? mastery.attempts ?? prev?.totalAnswered ?? 0,
    );

    const correctAnswered = Number(
      mastery.correctAnswered ?? mastery.correct ?? prev?.correctAnswered ?? 0,
    );

    const accuracy =
      typeof mastery.accuracy === 'number'
        ? mastery.accuracy
        : totalAnswered > 0
          ? correctAnswered / totalAnswered
          : 0;

    const streak = Number(mastery.streak ?? prev?.streak ?? 0);

    const saved = {
      ...(prev ?? {}),
      ...(mastery as object),
      userId: String(
        mastery.userId ??
          prev?.userId ??
          'anonymous',
      ),
      subject: String(mastery.subject ?? prev?.subject ?? ''),
      topicLabel: String(mastery.topicLabel ?? prev?.topicLabel ?? ''),
      totalAnswered,
      correctAnswered,
      accuracy,
      streak,
      lastUpdatedAt: (mastery.lastUpdatedAt as any) ?? prev?.lastUpdatedAt ?? new Date(),
    } as StoredMastery;

    this.topicMastery.set(topicKey, saved);
    return saved;
  }

  getTopicMastery(
    topicKey: string | { subject?: string; topicLabel?: string },
  ): StoredMastery | null {
    const keyStr =
      typeof topicKey === 'string'
        ? topicKey
        : this.toTopicKey(
            String(topicKey?.subject ?? ''),
            String(topicKey?.topicLabel ?? ''),
          );

    const existing = this.topicMastery.get(keyStr);
    if (existing) return existing;

    const [subject, topicLabel] = keyStr.split('::');
    if (!subject || !topicLabel) return null;

    let totalAnswered = 0;
    let correctAnswered = 0;
    let streak = 0;

    for (const attempts of this.attemptsBySession.values()) {
      for (const a of attempts as any[]) {
        if (a.subject === subject && a.topicLabel === topicLabel) {
          totalAnswered += 1;
          if (a.isCorrect) {
            correctAnswered += 1;
            streak += 1;
          } else {
            streak = 0;
          }
        }
      }
    }

    if (totalAnswered === 0) return null;

    const derived = {
      userId: 'anonymous',
      subject,
      topicLabel,
      totalAnswered,
      correctAnswered,
      accuracy: correctAnswered / totalAnswered,
      streak,
      lastUpdatedAt: new Date().toISOString(),
    } as unknown as StoredMastery;

    this.topicMastery.set(keyStr, derived);
    return derived;
  }

  getProgressSummary(userId: string) {
    const sessionIds = [...(this.userSessions.get(userId) ?? new Set<string>())];

    let totalAttempts = 0;
    let totalCorrect = 0;

    const topicMap = new Map<string, TopicSummary>();

    for (const sessionId of sessionIds) {
      const attempts = this.attemptsBySession.get(sessionId) ?? [];
      totalAttempts += attempts.length;

      for (const attempt of attempts as any[]) {
        if (attempt?.isCorrect) totalCorrect += 1;

        const subject = String(attempt?.subject ?? '');
        const topicLabel = String(attempt?.topicLabel ?? '');
        if (!subject || !topicLabel) continue;

        const key = `${subject}::${topicLabel}`;
        const row = topicMap.get(key) ?? {
          subject,
          topicLabel,
          totalAnswered: 0,
          correctAnswered: 0,
          accuracy: 0,
          streak: 0,
        };

        row.totalAnswered += 1;
        if (attempt?.isCorrect) {
          row.correctAnswered += 1;
          row.streak += 1;
        } else {
          row.streak = 0;
        }

        topicMap.set(key, row);
      }
    }

    const overallAccuracy =
      totalAttempts > 0 ? totalCorrect / totalAttempts : 0;

    const topicRows: TopicSummary[] = [...topicMap.values()].map((row) => ({
      ...row,
      accuracy:
        row.totalAnswered > 0
          ? row.correctAnswered / row.totalAnswered
          : 0,
    }));

    const weakTopics = [...topicRows].sort((a, b) => a.accuracy - b.accuracy);
    const strongestTopics = [...topicRows].sort(
      (a, b) => b.accuracy - a.accuracy,
    );

    return {
      userId,
      totalSessions: sessionIds.length,
      totalAttempts,
      totalCorrect,
      overallAccuracy,
      weakTopics,
      strongestTopics,
    };
  }
}
