import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { hasAnyRole } from '../auth/permissions';
import { AddSolutionImageDto } from './dto/add-solution-image.dto';

@Injectable()
export class SolutionsService {
  constructor(private readonly prisma: PrismaService) {}

  private ensureStaff(user: any) {
    if (!hasAnyRole(user, ['ADMIN', 'TEACHER', 'SECRETARY'])) {
      throw new ForbiddenException('Staff only');
    }
  }

  async create(user: any, dto: any) {
    this.ensureStaff(user);
    return this.prisma.solution.create({
      data: { ...dto, authorId: user.id ?? user.sub },
      include: { images: true },
    });
  }

  async list(q: any) {
    const limitRaw = q?.limit ?? q?.take ?? 20
    const take = Math.max(1, Math.min(50, parseInt(String(limitRaw), 10) || 20))

    // simple cursor pagination (optional): /solutions?cursor=<id>&limit=20
    const cursorId = q?.cursor ? String(q.cursor) : undefined

    // whitelist filters only
    const where: any = {}
    if (q?.subject) where.subject = String(q.subject)
    if (q?.sourceType) where.sourceType = String(q.sourceType)
    if (q?.sourceName) where.sourceName = String(q.sourceName)
    if (q?.questionNumber) where.questionNumber = String(q.questionNumber)
    if (q?.authorId) where.authorId = String(q.authorId)

    return this.prisma.solution.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      include: { images: true },
      take,
      ...(cursorId ? { cursor: { id: cursorId }, skip: 1 } : {}),
    })
  }
