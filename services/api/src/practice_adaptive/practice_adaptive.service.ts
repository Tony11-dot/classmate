import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

type AttemptInput = {
  userId: string;
  subject: string;
  topicLabel: string;
  mode: string;
  difficulty: string;
  questionId: string;
  prompt: string;
  selectedIndex?: number | null;
  correctIndex: number;
  isCorrect: boolean;
  timeTakenMs?: number | null;
  usedNova?: boolean;
  source?: string;
};

@Injectable()
export class PracticeAdaptiveService {
  constructor(private readonly prisma: PrismaService) {}

  private _difficultyBeta(difficulty: string) {
    switch ((difficulty || '').toLowerCase()) {
      case 'easy':
        return -1.0;
      case 'medium':
        return 0.0;
      case 'hard':
        return 0.8;
      case 'olympiad':
        return 1.6;
      case 'adaptive':
        return 0.4;
      case 'bagrut':
        return 1.0;
      default:
        return 0.0;
    }
  }

  private _sigmoid(x: number) {
    return 1 / (1 + Math.exp(-x));
  }

  async recordAttempt(input: AttemptInput) {
    const created = await this.prisma.practiceAttempt.create({
      data: {
        userId: input.userId,
        subject: input.subject,
        topicLabel: input.topicLabel,
        mode: input.mode,
        difficulty: input.difficulty,
        questionId: input.questionId,
        prompt: input.prompt,
        selectedIndex: input.selectedIndex ?? null,
        correctIndex: input.correctIndex,
        isCorrect: input.isCorrect,
        timeTakenMs: input.timeTakenMs ?? null,
        usedNova: input.usedNova ?? false,
        source: input.source ?? 'ai',
      },
    });

    const profile =
      (await this.prisma.practiceSkillProfile.findUnique({
        where: {
          userId_subject_topicLabel: {
            userId: input.userId,
            subject: input.subject,
            topicLabel: input.topicLabel,
          },
        },
      })) ??
      (await this.prisma.practiceSkillProfile.create({
        data: {
          userId: input.userId,
          subject: input.subject,
          topicLabel: input.topicLabel,
        },
      }));

    const theta = profile.theta ?? 0;
    const beta = this._difficultyBeta(input.difficulty);
    const p = this._sigmoid(theta - beta);
    const actual = input.isCorrect ? 1 : 0;

    const lr = Math.max(0.08, Math.min(0.22, 0.18 / Math.max(0.7, profile.uncertainty)));
    const nextTheta = theta + lr * (actual - p);
    const nextUncertainty = Math.max(0.18, profile.uncertainty * 0.96);
    const nextSeen = profile.totalSeen + 1;
    const nextCorrect = profile.totalCorrect + (input.isCorrect ? 1 : 0);
    const nextStreak = input.isCorrect ? profile.streak + 1 : 0;

    const updated = await this.prisma.practiceSkillProfile.update({
      where: {
        userId_subject_topicLabel: {
          userId: input.userId,
          subject: input.subject,
          topicLabel: input.topicLabel,
        },
      },
      data: {
        theta: nextTheta,
        uncertainty: nextUncertainty,
        streak: nextStreak,
        totalSeen: nextSeen,
        totalCorrect: nextCorrect,
      },
    });

    return {
      attempt: created,
      profile: updated,
      nextDifficultyHint:
        nextTheta < -0.35 ? 'easy' :
        nextTheta < 0.45 ? 'medium' :
        nextTheta < 1.15 ? 'hard' :
        'olympiad',
    };
  }

  async getProfile(userId: string, subject: string, topicLabel: string) {
    return this.prisma.practiceSkillProfile.findUnique({
      where: {
        userId_subject_topicLabel: {
          userId,
          subject,
          topicLabel,
        },
      },
    });
  }
}
