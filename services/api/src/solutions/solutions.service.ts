import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { AddSolutionImageDto } from './dto/add-solution-image.dto';

@Injectable()
export class SolutionsService {
  constructor(private prisma: PrismaService) {}

  private ensureStaff(user: any) {
    const roles: string[] = user?.roles ?? [];
    const ok = roles.includes('ADMIN') || roles.includes('TEACHER');
    if (!ok) throw new ForbiddenException('Staff only');
  }

  async create(user: any, dto: any) {
    this.ensureStaff(user);
    return this.prisma.solution.create({
      data: { ...dto, authorId: user.sub },
      include: { images: true },
    });
  }

  async list(q: any) {
    // NOTE: students can list; staff-only is create/update/delete
    const take = Math.max(1, Math.min(Number(q?.limit ?? 20) || 20, 50));

    const where: any = {};
    if (q?.subject) where.subject = String(q.subject);
    if (q?.sourceType) where.sourceType = String(q.sourceType);
    if (q?.sourceName) where.sourceName = String(q.sourceName);
    if (q?.page !== undefined && q?.page !== null && String(q.page).length) where.page = Number(q.page);
    if (q?.questionNumber) where.questionNumber = String(q.questionNumber);

    const cursorRaw = q?.cursor ? String(q.cursor) : '';
    if (cursorRaw) {
      const parts = cursorRaw.split('|');
      if (parts.length !== 2) throw new BadRequestException('Invalid cursor');
      const [createdAtStr, id] = parts;
      const createdAt = new Date(createdAtStr);
      if (!createdAtStr || !id || Number.isNaN(createdAt.getTime())) throw new BadRequestException('Invalid cursor');

      where.OR = [
        { createdAt: { lt: createdAt } },
        { createdAt, id: { lt: id } },
      ];
    }

    const rows = await this.prisma.solution.findMany({
      where,
      take,
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      include: { images: true },
    });

    const nextCursor =
      rows.length === take
        ? `${rows[rows.length - 1].createdAt.toISOString()}|${rows[rows.length - 1].id}`
        : null;

    return { items: rows, nextCursor };
  }

  async get(id: string) {
    const s = await this.prisma.solution.findUnique({
      where: { id },
      include: { images: true },
    });
    if (!s) throw new NotFoundException();
    return s;
  }

  async update(user: any, id: string, dto: any) {
    this.ensureStaff(user);
    return this.prisma.solution.update({
      where: { id },
      data: dto,
      include: { images: true },
    });
  }

  async remove(user: any, id: string) {
    this.ensureStaff(user);
    await this.prisma.solution.delete({ where: { id } });
    return { ok: true };
  }

  async addImage(user: any, id: string, dto: AddSolutionImageDto) {
    this.ensureStaff(user);
    return this.prisma.solutionImage.create({
      data: { solutionId: id, ...dto },
    });
  }

  async deleteImage(user: any, imageId: string) {
    this.ensureStaff(user);
    await this.prisma.solutionImage.delete({ where: { id: imageId } });
    return { ok: true };
  }
}
