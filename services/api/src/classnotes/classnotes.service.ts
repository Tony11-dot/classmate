import { ForbiddenException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { NotebookUpsertDto, ShelfUpsertDto } from './dto/classnotes.dto';

/// Per-user ClassNotes library sync. Every query is scoped to the caller's own
/// `userId` (derived from the JWT); a client can only read/write its OWN books.
@Injectable()
export class ClassnotesService {
  constructor(private readonly prisma: PrismaService) {}

  private uid(user: any): string {
    const id = String(user?.id ?? user?.sub ?? '');
    if (!id) throw new ForbiddenException('No user');
    return id;
  }

  /// The full library for the signed-in user, pre-ordered the ClassNotes way:
  /// shelves by sortIndex, notebooks most-recently-updated first.
  async getLibrary(user: any) {
    const userId = this.uid(user);
    const [shelves, notebooks] = await Promise.all([
      this.prisma.classNotesShelf.findMany({
        where: { userId },
        orderBy: { sortIndex: 'asc' },
      }),
      this.prisma.classNotesNotebook.findMany({
        where: { userId },
        orderBy: { updatedAt: 'desc' },
      }),
    ]);
    return {
      shelves: shelves.map((s) => ({
        id: s.id,
        name: s.name,
        colorHex: s.colorHex,
        symbolName: s.symbolName,
        sortIndex: s.sortIndex,
        createdAt: s.createdAt.toISOString(),
      })),
      notebooks: notebooks.map((n) => ({
        id: n.id,
        title: n.title,
        coverColorHex: n.coverColorHex,
        template: n.template,
        shelfId: n.shelfId,
        pageCount: n.pageCount,
        createdAt: n.createdAt.toISOString(),
        updatedAt: n.updatedAt.toISOString(),
      })),
    };
  }

  async upsertNotebook(user: any, id: string, dto: NotebookUpsertDto) {
    const userId = this.uid(user);
    await this.assertOwnsNotebook(id, userId);
    const data = {
      title: dto.title,
      coverColorHex: dto.coverColorHex,
      template: dto.template,
      shelfId: dto.shelfId ?? null,
      pageCount: dto.pageCount,
      createdAt: new Date(dto.createdAt),
      updatedAt: new Date(dto.updatedAt),
    };
    await this.prisma.classNotesNotebook.upsert({
      where: { id },
      create: { id, userId, ...data },
      update: data,
    });
    return { ok: true };
  }

  async deleteNotebook(user: any, id: string) {
    const userId = this.uid(user);
    await this.prisma.classNotesNotebook.deleteMany({ where: { id, userId } });
    return { ok: true };
  }

  async upsertShelf(user: any, id: string, dto: ShelfUpsertDto) {
    const userId = this.uid(user);
    await this.assertOwnsShelf(id, userId);
    const data = {
      name: dto.name,
      colorHex: dto.colorHex,
      symbolName: dto.symbolName,
      sortIndex: dto.sortIndex,
      createdAt: new Date(dto.createdAt),
    };
    await this.prisma.classNotesShelf.upsert({
      where: { id },
      create: { id, userId, ...data },
      update: data,
    });
    return { ok: true };
  }

  async deleteShelf(user: any, id: string) {
    const userId = this.uid(user);
    // Un-file this user's notebooks that referenced the shelf, then remove it.
    // (shelfId is a bare reference, so this keeps orphaned pointers from
    // lingering even if the native un-file sync races the delete.)
    await this.prisma.$transaction([
      this.prisma.classNotesNotebook.updateMany({
        where: { userId, shelfId: id },
        data: { shelfId: null },
      }),
      this.prisma.classNotesShelf.deleteMany({ where: { id, userId } }),
    ]);
    return { ok: true };
  }

  private async assertOwnsNotebook(id: string, userId: string) {
    const row = await this.prisma.classNotesNotebook.findUnique({
      where: { id },
      select: { userId: true },
    });
    if (row && row.userId !== userId) {
      throw new ForbiddenException('Not your notebook');
    }
  }

  private async assertOwnsShelf(id: string, userId: string) {
    const row = await this.prisma.classNotesShelf.findUnique({
      where: { id },
      select: { userId: true },
    });
    if (row && row.userId !== userId) {
      throw new ForbiddenException('Not your shelf');
    }
  }
}
