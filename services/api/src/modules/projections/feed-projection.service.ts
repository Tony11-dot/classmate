import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { computeFeedRankingScore } from '../feed/feed-score';

@Injectable()
export class FeedProjectionService {
  constructor(private readonly prisma: PrismaService) {}

  private async getLikeCount(solutionId: string) {
    return this.prisma.solutionLike.count({
      where: { solutionId },
    });
  }

  private async getCommentCount(solutionId: string) {
    return this.prisma.solutionComment.count({
      where: { solutionId },
    });
  }

  private async getRepostCount(solutionId: string) {
    const candidate = (this.prisma as any).solutionRepost;
    if (!candidate?.count) return 0;
    return candidate.count({
      where: { solutionId },
    });
  }

  private async getPrimaryImageUrl(solutionId: string) {
    const candidate = (this.prisma as any).solutionImage;
    if (!candidate?.findFirst) return null;
    const image = await candidate.findFirst({
      where: { solutionId },
      orderBy: { createdAt: 'asc' },
      select: { url: true },
    });
    return image?.url ?? null;
  }

  private async getImageCount(solutionId: string) {
    const candidate = (this.prisma as any).solutionImage;
    if (!candidate?.count) return 0;
    return candidate.count({
      where: { solutionId },
    });
  }

  private async getAuthorName(authorId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: authorId },
      select: { name: true },
    });
    return user?.name ?? 'Unknown';
  }

  async projectSolutionCreated(solutionId: string) {
    const solution = await this.prisma.solution.findUnique({
      where: { id: solutionId },
      select: {
        id: true,
        authorId: true,
        subject: true,
        sourceType: true,
        sourceName: true,
        page: true,
        questionNumber: true,
        title: true,
        body: true,
        createdAt: true,
      },
    });

    if (!solution) return;

    const [
      authorName,
      likeCount,
      commentCount,
      repostCount,
      primaryImageUrl,
      imageCount,
    ] = await Promise.all([
      this.getAuthorName(solution.authorId),
      this.getLikeCount(solution.id),
      this.getCommentCount(solution.id),
      this.getRepostCount(solution.id),
      this.getPrimaryImageUrl(solution.id),
      this.getImageCount(solution.id),
    ]);

    const rankingScore = computeFeedRankingScore({
      likeCount,
      commentCount,
      repostCount,
      teacherPick: false,
      bestSolution: false,
      createdAt: solution.createdAt,
    });

    await this.prisma.feedSolutionCard.upsert({
      where: { solutionId: solution.id },
      update: {
        authorName,
        subject: solution.subject,
        sourceType: solution.sourceType,
        sourceName: solution.sourceName,
        page: solution.page,
        questionNumber: solution.questionNumber,
        title: solution.title,
        bodyPreview: solution.body?.slice(0, 280) ?? null,
        primaryImageUrl,
        imageCount,
        likeCount,
        commentCount,
        repostCount,
        rankingScore,
      },
      create: {
        solutionId: solution.id,
        schoolId: '00000000-0000-0000-0000-000000000000',
        classId: null,
        authorId: solution.authorId,
        authorName,
        subject: solution.subject,
        sourceType: solution.sourceType,
        sourceName: solution.sourceName,
        page: solution.page,
        questionNumber: solution.questionNumber,
        title: solution.title,
        bodyPreview: solution.body?.slice(0, 280) ?? null,
        primaryImageUrl,
        imageCount,
        likeCount,
        commentCount,
        repostCount,
        rankingScore,
        teacherPick: false,
        bestSolution: false,
        difficulty: null,
        createdAt: solution.createdAt,
      },
    });
  }

  async projectSolutionCounters(solutionId: string) {
    const solution = await this.prisma.solution.findUnique({
      where: { id: solutionId },
      select: {
        id: true,
        createdAt: true,
      },
    });

    if (!solution) return;

    const [likeCount, commentCount, repostCount] = await Promise.all([
      this.getLikeCount(solutionId),
      this.getCommentCount(solutionId),
      this.getRepostCount(solutionId),
    ]);

    const rankingScore = computeFeedRankingScore({
      likeCount,
      commentCount,
      repostCount,
      createdAt: solution.createdAt,
    });

    await this.prisma.feedSolutionCard.update({
      where: { solutionId },
      data: {
        likeCount,
        commentCount,
        repostCount,
        rankingScore,
      },
    });
  }
}
