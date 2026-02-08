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
    return this.prisma.solution.findMany({
      where: q,
      orderBy: { createdAt: 'desc' },
      include: { images: true },
    });
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
