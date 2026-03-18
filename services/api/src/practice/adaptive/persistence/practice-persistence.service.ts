import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';
import type {
  PracticeAttemptRecord,
  PracticeProgressSummary,
  PracticeSessionRecord,
  TopicMasteryRecord,
} from './practice-session.types';

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
  mode?: string;
  prompt?: string;
};

type SaveTopicMasteryInput = Partial<TopicMasteryRecord> & {
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
  constructor(private readonly prisma: PrismaService) {}

  private safeUserId(userId?: string): string {
    return String(userId ?? 'anonymous');
  }

  private toTopicKey(subject: string, topicLabel: string): string {
    return `${String(subject ?? '').trim()}::${String(topicLabel ?? '').trim()}`;
  }

  private toAttemptRecord(row: any): PracticeAttemptRecord {
    return {
      questionId: String(row.questionId ?? ''),
      subject: String(row.subject ?? ''),
      topicLabel: String(row.topicLabel ?? ''),
      difficulty: String(row.difficulty ?? 'adaptive'),
      mode: String(row.mode ?? 'adaptive'),
      isCorrect: Boolean(row.isCorrect),
      selectedIndex: row.selectedIndex ?? null,
      correctIndex: row.correctIndex ?? null,
      answeredAt:
        row.createdAt instanceof Date
          ? row.createdAt.toISOString()
          : new Date().toISOString(),
    };
  }

  private async buildSessionRecord(
    sessionId: string,
  ): Promise<PracticeSessionRecord | null> {
    const rows = await this.prisma.practiceAttempt.findMany({
      where: { sessionId },
      orderBy: { createdAt: 'asc' },
    });

    if (!rows.length) return null;

    const first = rows[0];
    const last = rows[rows.length - 1];

    return {
      id: String(sessionId),
      userId: String(first.userId ?? 'anonymous'),
      subject: String(first.subject ?? ''),
      topicLabel: String(first.topicLabel ?? ''),
      mode: String(first.mode ?? 'adaptive'),
      startedAt:
        first.createdAt instanceof Date
          ? first.createdAt.toISOString()
          : new Date().toISOString(),
      updatedAt:
        last.createdAt instanceof Date
          ? last.createdAt.toISOString()
          : new Date().toISOString(),
      attempts: rows.map((row) => this.toAttemptRecord(row)),
    };
  }

  async startSession(input: CreateSessionInput): Promise<PracticeSessionRecord> {
    return this.createSession(input);
  }

  async createSession(
    input: CreateSessionInput,
  ): Promise<PracticeSessionRecord> {
    const existing = await this.buildSessionRecord(input.sessionId);
    if (existing) return existing;

    const now = new Date().toISOString();

    return {
      id: String(input.sessionId),
      userId: this.safeUserId(input.userId),
      subject: String(input.subject ?? ''),
      topicLabel: String(input.topicLabel ?? ''),
      mode: 'adaptive',
      startedAt: now,
      updatedAt: now,
      attempts: [],
    };
  }

  async getSession(sessionId: string): Promise<PracticeSessionRecord | null> {
    return this.buildSessionRecord(sessionId);
  }

  async recordAttempt(
    input: RecordAttemptInput,
  ): Promise<PracticeAttemptRecord> {
    const userId = this.safeUserId(input.userId);

    await this.prisma.practiceAttempt.create({
      data: {
        userId,
        sessionId: String(input.sessionId),
        subject: String(input.subject ?? ''),
        topicLabel: String(input.topicLabel ?? ''),
        mode: String(input.mode ?? 'adaptive'),
        difficulty: String(input.difficulty ?? 'adaptive'),
        questionId: String(input.questionId ?? ''),
        prompt: String(input.prompt ?? input.questionId ?? ''),
        selectedIndex:
          typeof input.selectedIndex === 'number' ? input.selectedIndex : null,
        correctIndex:
          typeof input.correctIndex === 'number' ? input.correctIndex : -1,
        isCorrect: Boolean(input.isCorrect),
        timeTakenMs:
          typeof input.responseTimeMs === 'number' ? input.responseTimeMs : null,
        awardedScore:
          typeof input.awardedScore === 'number' ? input.awardedScore : 0,
        usedNova: false,
        source: 'adaptive',
      },
    });

    return {
      questionId: String(input.questionId ?? ''),
      subject: String(input.subject ?? ''),
      topicLabel: String(input.topicLabel ?? ''),
      difficulty: String(input.difficulty ?? 'adaptive'),
      mode: String(input.mode ?? 'adaptive'),
      isCorrect: Boolean(input.isCorrect),
      selectedIndex:
        typeof input.selectedIndex === 'number' ? input.selectedIndex : null,
      correctIndex:
        typeof input.correctIndex === 'number' ? input.correctIndex : null,
      answeredAt: new Date().toISOString(),
    };
  }

  async listAttemptsBySession(sessionId: string): Promise<PracticeAttemptRecord[]> {
    const rows = await this.prisma.practiceAttempt.findMany({
      where: { sessionId },
      orderBy: { createdAt: 'asc' },
    });

    return rows.map((row) => this.toAttemptRecord(row));
  }

  async saveTopicMastery(
    topicKey: string,
    mastery: SaveTopicMasteryInput,
  ): Promise<TopicMasteryRecord> {
    const prev = await this.getTopicMastery(topicKey);

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

    const subject = String(mastery.subject ?? prev?.subject ?? '');
    const topicLabel = String(mastery.topicLabel ?? prev?.topicLabel ?? '');
    const userId = this.safeUserId(mastery.userId ?? prev?.userId);

    const saved = await this.prisma.practiceSkillProfile.upsert({
      where: {
        userId_subject_topicLabel: {
          userId,
          subject,
          topicLabel,
        },
      },
      update: {
        theta: accuracy,
        streak,
        totalSeen: totalAnswered,
        totalCorrect: correctAnswered,
      },
      create: {
        userId,
        subject,
        topicLabel,
        theta: accuracy,
        streak,
        totalSeen: totalAnswered,
        totalCorrect: correctAnswered,
      },
    });

    return {
      userId: String(saved.userId),
      subject: String(saved.subject),
      topicLabel: String(saved.topicLabel),
      accuracy: Number(saved.theta ?? 0),
      streak: Number(saved.streak ?? 0),
      totalAnswered: Number(saved.totalSeen ?? 0),
      correctAnswered: Number(saved.totalCorrect ?? 0),
      lastUpdatedAt: saved.updatedAt.toISOString(),
    };
  }

  async getTopicMastery(
    topicKey: string | { subject?: string; topicLabel?: string; userId?: string },
  ): Promise<TopicMasteryRecord | null> {
    const keyStr =
      typeof topicKey === 'string'
        ? topicKey
        : this.toTopicKey(
            String(topicKey?.subject ?? ''),
            String(topicKey?.topicLabel ?? ''),
          );

    const [subject, topicLabel] = keyStr.split('::');
    if (!subject || !topicLabel) return null;

    const userId =
      typeof topicKey === 'string'
        ? 'anonymous'
        : this.safeUserId(topicKey.userId);

    const existing = await this.prisma.practiceSkillProfile.findUnique({
      where: {
        userId_subject_topicLabel: {
          userId,
          subject,
          topicLabel,
        },
      },
    });

    if (existing) {
      return {
        userId: String(existing.userId),
        subject: String(existing.subject),
        topicLabel: String(existing.topicLabel),
        accuracy: Number(existing.theta ?? 0),
        streak: Number(existing.streak ?? 0),
        totalAnswered: Number(existing.totalSeen ?? 0),
        correctAnswered: Number(existing.totalCorrect ?? 0),
        lastUpdatedAt: existing.updatedAt.toISOString(),
      };
    }

    const attempts = await this.prisma.practiceAttempt.findMany({
      where: {
        userId,
        subject,
        topicLabel,
      },
      orderBy: { createdAt: 'asc' },
    });

    if (!attempts.length) return null;

    let streak = 0;
    let correctAnswered = 0;

    for (const attempt of attempts) {
      if (attempt.isCorrect) {
        correctAnswered += 1;
        streak += 1;
      } else {
        streak = 0;
      }
    }

    const totalAnswered = attempts.length;
    const accuracy =
      totalAnswered > 0 ? correctAnswered / totalAnswered : 0;

    return {
      userId,
      subject,
      topicLabel,
      accuracy,
      streak,
      totalAnswered,
      correctAnswered,
      lastUpdatedAt:
        attempts[attempts.length - 1].createdAt instanceof Date
          ? attempts[attempts.length - 1].createdAt.toISOString()
          : new Date().toISOString(),
    };
  }

  async getProgressSummary(userId: string): Promise<PracticeProgressSummary> {
    const normalizedUserId = this.safeUserId(userId);

    let rows = await this.prisma.practiceAttempt.findMany({
      where: { userId: normalizedUserId },
      orderBy: { createdAt: 'asc' },
    });

    if (!rows.length && normalizedUserId !== 'anonymous') {
      rows = await this.prisma.practiceAttempt.findMany({
        where: { userId: 'anonymous' },
        orderBy: { createdAt: 'asc' },
      });
    }

    let totalCorrect = 0;
    const sessionIds = new Set<string>();
    const topicMap = new Map<string, TopicSummary>();

    for (const row of rows) {
      if (row.isCorrect) totalCorrect += 1;
      if (row.sessionId) sessionIds.add(String(row.sessionId));

      const subject = String(row.subject ?? '');
      const topicLabel = String(row.topicLabel ?? '');
      if (!subject || !topicLabel) continue;

      const key = `${subject}::${topicLabel}`;
      const current = topicMap.get(key) ?? {
        subject,
        topicLabel,
        totalAnswered: 0,
        correctAnswered: 0,
        accuracy: 0,
        streak: 0,
      };

      current.totalAnswered += 1;
      if (row.isCorrect) {
        current.correctAnswered += 1;
        current.streak += 1;
      } else {
        current.streak = 0;
      }

      topicMap.set(key, current);
    }

    const totalAttempts = rows.length;
    const overallAccuracy =
      totalAttempts > 0 ? totalCorrect / totalAttempts : 0;

    const topicRows: TopicSummary[] = [...topicMap.values()].map((row) => ({
      ...row,
      accuracy:
        row.totalAnswered > 0
          ? row.correctAnswered / row.totalAnswered
          : 0,
    }));

    const weakTopics = [...topicRows].sort((a, b) => {
      const byAccuracy = a.accuracy - b.accuracy;
      if (byAccuracy !== 0) return byAccuracy;
      return b.totalAnswered - a.totalAnswered;
    });

    const strongestTopics = [...topicRows].sort((a, b) => {
      const byAccuracy = b.accuracy - a.accuracy;
      if (byAccuracy !== 0) return byAccuracy;
      return b.totalAnswered - a.totalAnswered;
    });

    return {
      userId: normalizedUserId,
      totalSessions: sessionIds.size,
      totalAttempts,
      totalCorrect,
      overallAccuracy,
      weakTopics,
      strongestTopics,
    };
  }
}
