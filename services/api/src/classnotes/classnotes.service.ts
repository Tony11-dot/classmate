import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import {
  NotebookUpsertDto,
  NotebookPatchDto,
  NotebookPagesUpsertDto,
  ShelfUpsertDto,
} from './dto/classnotes.dto';

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
        // Tombstoned notebooks are gone as far as any reader is concerned; the
        // row only survives so the native app can learn about the deletion.
        where: { userId, deletedAt: null },
        // Manually arranged first, in the order the user dragged them into, then
        // everything untouched by newest edit. Postgres sorts NULLs last on ASC,
        // which is exactly that.
        orderBy: [{ sortIndex: 'asc' }, { updatedAt: 'desc' }],
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
        coverImage: n.coverImage,
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
    const existing = await this.ownedNotebook(id, userId);
    // Deleted from ClassMate and the app hasn't caught up yet: do NOT resurrect
    // it. The app's next `GET /classnotes/changes` tells it to delete its copy.
    if (existing?.deletedAt) return { ok: true, skipped: 'deleted' as const };

    const data = {
      title: dto.title,
      coverColorHex: dto.coverColorHex,
      template: dto.template,
      shelfId: dto.shelfId ?? null,
      pageCount: dto.pageCount,
      createdAt: new Date(dto.createdAt),
      updatedAt: new Date(dto.updatedAt),
      // Only when the push actually carried a render. An older build omits the
      // field entirely, and that must not erase the cover already stored.
      ...(dto.coverImage !== undefined ? { coverImage: dto.coverImage } : {}),
    };
    // An unacknowledged ClassMate edit is newer than anything the app knows, so
    // keep the remote title/shelf and take only the rest of the push.
    if (existing?.remoteEditedAt) {
      const { title: _title, shelfId: _shelfId, ...rest } = data;
      await this.prisma.classNotesNotebook.update({ where: { id }, data: rest });
      return { ok: true, skipped: 'remoteEdited' as const };
    }
    await this.prisma.classNotesNotebook.upsert({
      where: { id },
      create: { id, userId, ...data },
      update: data,
    });
    return { ok: true };
  }

  /// An edit from the ClassMate ClassNotes tab: rename, re-shelve, recolour.
  /// Stamped `remoteEditedAt` so it survives the app's next full push and gets
  /// pulled down to the iPad.
  async patchNotebook(user: any, id: string, dto: NotebookPatchDto) {
    const userId = this.uid(user);
    const existing = await this.ownedNotebook(id, userId);
    if (!existing || existing.deletedAt) throw new NotFoundException('No such notebook');

    const data: Prisma.ClassNotesNotebookUpdateInput = {
      remoteEditedAt: new Date(),
      updatedAt: new Date(),
    };
    if (dto.title !== undefined) data.title = dto.title.trim();
    if (dto.coverColorHex !== undefined) data.coverColorHex = dto.coverColorHex;
    // `shelfId: null` means "unfile it" — a real value, not an omission.
    if (dto.shelfId !== undefined) data.shelfId = dto.shelfId ?? null;

    await this.prisma.classNotesNotebook.update({ where: { id }, data });
    return { ok: true };
  }

  /// The order the user dragged their notebooks into. Ids they didn't touch stay
  /// after the arranged ones (their sortIndex is left null).
  async reorderNotebooks(user: any, ids: string[]) {
    const userId = this.uid(user);
    const owned = await this.prisma.classNotesNotebook.findMany({
      where: { id: { in: ids }, userId, deletedAt: null },
      select: { id: true },
    });
    const ownedIds = new Set(owned.map((n) => n.id));
    const ordered = ids.filter((id) => ownedIds.has(id));
    await this.prisma.$transaction(
      ordered.map((id, index) =>
        this.prisma.classNotesNotebook.update({
          where: { id },
          data: { sortIndex: index },
        }),
      ),
    );
    return { ok: true, count: ordered.length };
  }

  /// Deleting from ClassMate is a TOMBSTONE, not a row delete. The native app
  /// pushes its whole library on every launch, so a deleted notebook would
  /// reappear within a minute; the marker survives that, and the app removes its
  /// local copy the next time it pulls changes. The page images go now — they're
  /// the bulk, and nothing needs them again.
  async deleteNotebook(user: any, id: string) {
    const userId = this.uid(user);
    const existing = await this.ownedNotebook(id, userId);
    if (!existing) return { ok: true };
    await this.prisma.$transaction([
      this.prisma.classNotesPage.deleteMany({ where: { notebookId: id, userId } }),
      this.prisma.classNotesNotebook.update({
        where: { id },
        data: { deletedAt: new Date(), remoteEditedAt: null, pageCount: 0 },
      }),
    ]);
    return { ok: true };
  }

  /// What the native app has to apply locally: notebooks deleted or edited from
  /// ClassMate since it last acknowledged. Called on launch, BEFORE the app
  /// pushes, so a rename here isn't overwritten by the copy on the iPad.
  async getChanges(user: any) {
    const userId = this.uid(user);
    const rows = await this.prisma.classNotesNotebook.findMany({
      where: {
        userId,
        OR: [{ deletedAt: { not: null } }, { remoteEditedAt: { not: null } }],
      },
      select: {
        id: true,
        title: true,
        shelfId: true,
        coverColorHex: true,
        deletedAt: true,
      },
    });
    return {
      deletedIds: rows.filter((r) => r.deletedAt).map((r) => r.id),
      edited: rows
        .filter((r) => !r.deletedAt)
        .map((r) => ({
          id: r.id,
          title: r.title,
          shelfId: r.shelfId,
          coverColorHex: r.coverColorHex,
        })),
    };
  }

  /// The app has applied these locally: purge the tombstones for good and clear
  /// the remote-edit marks so its own pushes are authoritative again.
  async ackChanges(user: any, ids: string[]) {
    const userId = this.uid(user);
    if (!ids.length) return { ok: true, count: 0 };
    const [deleted, cleared] = await this.prisma.$transaction([
      this.prisma.classNotesNotebook.deleteMany({
        where: { id: { in: ids }, userId, deletedAt: { not: null } },
      }),
      this.prisma.classNotesNotebook.updateMany({
        where: { id: { in: ids }, userId, deletedAt: null },
        data: { remoteEditedAt: null },
      }),
    ]);
    return { ok: true, count: deleted.count + cleared.count };
  }

  /// Rendered page images for a notebook, ordered by pageIndex. Ownership is
  /// checked first (a client can only read pages of its OWN notebook).
  async getNotebookPages(user: any, notebookId: string) {
    const userId = this.uid(user);
    await this.assertOwnsNotebook(notebookId, userId);
    const pages = await this.prisma.classNotesPage.findMany({
      where: { notebookId, userId },
      orderBy: { pageIndex: 'asc' },
      select: { pageIndex: true, dataUrl: true, attachments: true },
    });
    // Always hand the client an array, even for pages synced before attachments
    // existed (attachments is null there).
    return {
      pages: pages.map((p) => ({
        pageIndex: p.pageIndex,
        dataUrl: p.dataUrl,
        attachments: Array.isArray(p.attachments) ? p.attachments : [],
      })),
    };
  }

  /// Upsert the uploaded page images, then prune any rows at pageIndex >=
  /// pageCount so removed pages disappear. Ownership-checked; every row is
  /// stamped with the caller's userId. `updatedAt` is the server's now().
  async upsertNotebookPages(
    user: any,
    notebookId: string,
    dto: NotebookPagesUpsertDto,
  ) {
    const userId = this.uid(user);
    await this.assertOwnsNotebook(notebookId, userId);
    const now = new Date();
    const upserts = dto.pages.map((p) => {
      // An omitted `attachments` means "this client doesn't send them"; an empty
      // array means "this page has none" and must clear whatever was there.
      // Cast to Prisma's JSON input type: the DTO is a class array, which
      // structurally satisfies a JSON array but not its declared type.
      const attachments = (p.attachments ?? []) as unknown as Prisma.InputJsonValue;
      return this.prisma.classNotesPage.upsert({
        where: { notebookId_pageIndex: { notebookId, pageIndex: p.pageIndex } },
        create: {
          notebookId,
          userId,
          pageIndex: p.pageIndex,
          dataUrl: p.dataUrl,
          attachments,
          updatedAt: now,
        },
        update: { userId, dataUrl: p.dataUrl, attachments, updatedAt: now },
      });
    });
    await this.prisma.$transaction([
      ...upserts,
      this.prisma.classNotesPage.deleteMany({
        where: { notebookId, userId, pageIndex: { gte: dto.pageCount } },
      }),
    ]);
    return { ok: true, count: dto.pages.length };
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
    await this.ownedNotebook(id, userId);
  }

  /// The notebook's sync-relevant state, or null when it doesn't exist yet (a
  /// first push creates it). Throws if it belongs to somebody else.
  private async ownedNotebook(id: string, userId: string) {
    const row = await this.prisma.classNotesNotebook.findUnique({
      where: { id },
      select: { userId: true, deletedAt: true, remoteEditedAt: true },
    });
    if (!row) return null;
    if (row.userId !== userId) {
      throw new ForbiddenException('Not your notebook');
    }
    return row;
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
