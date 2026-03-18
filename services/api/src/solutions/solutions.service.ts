import { BadRequestException, ForbiddenException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { NovaVerifyService } from '../nova/nova.verify.service';
import type {
  CreateSolutionUploadBody,
  ListSolutionsQuery,
  ModerateSolutionBody,
  VerifySolutionBody,
} from './solutions.types';

@Injectable()

export class SolutionsService {
  constructor(
    private readonly novaVerify: NovaVerifyService,
    private readonly prisma: PrismaService,
  ) {}

  private userIdOf(user: any): string {
    return String(user?.sub ?? user?.id ?? user?.userId ?? '');
  }

  private rolesOf(user: any): string[] {
    return Array.isArray(user?.roles) ? user.roles.map(String) : [];
  }

  private isStaff(user: any): boolean {
    const roles = this.rolesOf(user).map((x) => x.toUpperCase());
    return roles.includes('ADMIN') || roles.includes('TEACHER') || roles.includes('SECRETARY');
  }

  async create(user: any, body: CreateSolutionUploadBody) {
    const userId = this.userIdOf(user);
    if (!userId) throw new ForbiddenException('Unauthorized');

    const subject = String(body.subject ?? '').trim();
    const bookTitle = String(body.bookTitle ?? '').trim();
    const questionNumber = String(body.questionNumber ?? '').trim();
    const pageNumber = Number(body.pageNumber ?? 0);
    const files = Array.isArray(body.files) ? body.files : [];

    if (!subject) throw new BadRequestException('subject required');
    if (!bookTitle) throw new BadRequestException('bookTitle required');
    if (!questionNumber) throw new BadRequestException('questionNumber required');
    if (!Number.isFinite(pageNumber) || pageNumber <= 0) {
      throw new BadRequestException('pageNumber must be positive');
    }
    if (!files.length) throw new BadRequestException('at least one file required');

    const book = await this.prisma.solutionBook.upsert({
      where: {
        subject_title: {
          subject,
          title: bookTitle,
        },
      },
      update: {},
      create: {
        subject,
        title: bookTitle,
        slug: bookTitle.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, ''),
      },
    });

    const created = await this.prisma.solutionUpload.create({
      data: {
        userId,
        subject,
        bookId: book.id,
        caption: body.caption?.trim() || null,
        pageNumber,
        questionNumber,
        uploaderName: body.uploaderName?.trim() || null,
        uploaderInitials: body.uploaderInitials?.trim() || null,
        moderationStatus: 'PENDING',
        verificationStatus: 'UNCHECKED',
        files: {
          create: files.map((f, index) => ({
            kind: String(f.kind ?? 'file'),
            url: String(f.url ?? '').trim(),
            mimeType: f.mimeType?.trim() || null,
            fileName: f.fileName?.trim() || null,
            fileSize:
              typeof f.fileSize === 'number' && Number.isFinite(f.fileSize)
                ? Math.max(0, Math.trunc(f.fileSize))
                : null,
            sortOrder: index,
          })),
        },
      },
      include: {
        book: true,
        files: { orderBy: { sortOrder: 'asc' } },
      },
    });

    return { ok: true, upload: created };
  }

  async list(query: ListSolutionsQuery) {
    const page = Math.max(1, Number(query.page ?? 1));
    const limit = Math.min(30, Math.max(1, Number(query.limit ?? 12)));
    const skip = (page - 1) * limit;

    const subject = String(query.subject ?? '').trim();
    const bookTitle = String(query.bookTitle ?? '').trim();
    const questionNumber = String(query.questionNumber ?? '').trim();
    const pageNumber =
      query.pageNumber != null && Number.isFinite(Number(query.pageNumber))
        ? Number(query.pageNumber)
        : null;

    const where: any = {
      isDeleted: false,
      moderationStatus: { not: 'REJECTED' },
      ...(subject ? { subject } : {}),
      ...(pageNumber != null ? { pageNumber } : {}),
      ...(questionNumber ? { questionNumber } : {}),
      ...(bookTitle
        ? {
            book: {
              title: bookTitle,
            },
          }
        : {}),
    };

    const [total, items] = await Promise.all([
      this.prisma.solutionUpload.count({ where }),
      this.prisma.solutionUpload.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ verificationStatus: 'desc' }, { createdAt: 'desc' }],
        include: {
          book: true,
          files: { orderBy: { sortOrder: 'asc' } },
        },
      }),
    ]);

    return {
      ok: true,
      page,
      limit,
      total,
      hasMore: skip + items.length < total,
      items,
    };
  }

  async books(subject?: string) {
    const where = subject ? { subject: String(subject).trim() } : {};
    const rows = await this.prisma.solutionBook.findMany({
      where,
      orderBy: [{ subject: 'asc' }, { title: 'asc' }],
    });
    return { ok: true, books: rows };
  }

  async subjects() {
    const rows = await this.prisma.solutionBook.findMany({
      distinct: ['subject'],
      select: { subject: true },
      orderBy: { subject: 'asc' },
    });
    return { ok: true, subjects: rows.map((x) => x.subject) };
  }

  async verify(user: any, id: string, body: VerifySolutionBody) {
    if (!this.isStaff(user)) throw new ForbiddenException('Staff only');

    const updated = await this.prisma.solutionUpload.update({
      where: { id },
      data: {
        verificationStatus: body.verificationStatus,
        verificationNote: body.verificationNote?.trim() || null,
      },
      include: {
        book: true,
        files: { orderBy: { sortOrder: 'asc' } },
      },
    });

    return { ok: true, upload: updated };
  }

  async moderate(user: any, id: string, body: ModerateSolutionBody) {
    if (!this.isStaff(user)) throw new ForbiddenException('Staff only');

    const updated = await this.prisma.solutionUpload.update({
      where: { id },
      data: {
        moderationStatus: body.moderationStatus,
        moderationReason: body.moderationReason?.trim() || null,
        isDeleted: body.isDeleted === true,
      },
      include: {
        book: true,
        files: { orderBy: { sortOrder: 'asc' } },
      },
    });

    return { ok: true, upload: updated };
  }
}
