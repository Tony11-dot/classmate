import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { NotificationsHubService } from '../notifications/notifications-hub.service';
import type {
  CreateBookBody,
  CreateSolutionUploadBody,
  ListSolutionsQuery,
  ModerateSolutionBody,
  ReportSolutionBody,
  ResolveReportBody,
  UpdateBookBody,
  VerifySolutionBody,
} from './solutions.types';

@Injectable()
export class SolutionsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly hub: NotificationsHubService,
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

  private isBookManager(user: any): boolean {
    const roles = this.rolesOf(user).map((x) => x.toUpperCase());
    return roles.includes('ADMIN') || roles.includes('TEACHER');
  }

  private isAdmin(user: any): boolean {
    return this.rolesOf(user).map((x) => x.toUpperCase()).includes('ADMIN');
  }

  // ── Solution uploads ──────────────────────────────────────────────────

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

    // Books are set by admins/teachers only — students can no longer create
    // them implicitly by uploading. The book MUST already exist.
    const book = await this.prisma.solutionBook.findUnique({
      where: { subject_title: { subject, title: bookTitle } },
    });
    if (!book) {
      throw new BadRequestException('Selected book does not exist for this subject');
    }

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
        moderationStatus: 'APPROVED',
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

  /// Builds a userId -> { name, grade, schoolName } map for a set of uploads.
  /// Each solution card shows the poster's name + grade + school, globally.
  private async authorsFor(userIds: string[]) {
    const ids = [...new Set(userIds.filter(Boolean))];
    if (!ids.length) return new Map<string, { name: string; grade: number | null; schoolName: string | null }>();
    const users = await this.prisma.user.findMany({
      where: { id: { in: ids } },
      select: {
        id: true,
        name: true,
        displayName: true,
        school: { select: { name: true } },
        studentProfile: { select: { grade: true } },
      },
    });
    const map = new Map<string, { name: string; grade: number | null; schoolName: string | null }>();
    for (const u of users) {
      map.set(u.id, {
        name: (u.displayName?.trim() || u.name || '').trim(),
        grade: u.studentProfile?.grade ?? null,
        schoolName: u.school?.name ?? null,
      });
    }
    return map;
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

    // GLOBAL feed — intentionally NOT scoped to the viewer's school. Students
    // see solutions + books from every school.
    const where: any = {
      isDeleted: false,
      moderationStatus: { not: 'REJECTED' },
      ...(subject ? { subject } : {}),
      ...(pageNumber != null ? { pageNumber } : {}),
      ...(questionNumber ? { questionNumber } : {}),
      ...(bookTitle ? { book: { title: bookTitle } } : {}),
    };

    const [total, items] = await Promise.all([
      this.prisma.solutionUpload.count({ where }),
      this.prisma.solutionUpload.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ createdAt: 'desc' }],
        include: {
          book: true,
          files: { orderBy: { sortOrder: 'asc' } },
        },
      }),
    ]);

    const authors = await this.authorsFor(items.map((i) => i.userId));
    const enriched = items.map((i) => ({
      ...i,
      author: authors.get(i.userId) ?? { name: i.uploaderName ?? '', grade: null, schoolName: null },
    }));

    return {
      ok: true,
      page,
      limit,
      total,
      hasMore: skip + items.length < total,
      items: enriched,
    };
  }

  // ── Books (admin/teacher managed) ─────────────────────────────────────

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

  private slugify(s: string): string {
    return s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
  }

  // Strip case, accents and non-alphanumerics so "Archimedes" and "archimidis"
  // compare on their bare letters only.
  private normalizeTitle(s: string): string {
    return String(s ?? '')
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      // Keep letters & numbers of ANY script (Arabic/Hebrew/Cyrillic/Latin),
      // drop spaces and punctuation only.
      .replace(/[^\p{L}\p{N}]+/gu, '');
  }

  // Classic Levenshtein edit distance (row-rolling, O(n) memory).
  private levenshtein(a: string, b: string): number {
    const m = a.length;
    const n = b.length;
    if (m === 0) return n;
    if (n === 0) return m;
    const dp = new Array<number>(n + 1);
    for (let j = 0; j <= n; j++) dp[j] = j;
    for (let i = 1; i <= m; i++) {
      let prev = dp[0];
      dp[0] = i;
      for (let j = 1; j <= n; j++) {
        const tmp = dp[j];
        dp[j] = Math.min(
          dp[j] + 1,
          dp[j - 1] + 1,
          prev + (a[i - 1] === b[j - 1] ? 0 : 1),
        );
        prev = tmp;
      }
    }
    return dp[n];
  }

  // Two book titles are "similar" if they're identical once normalized, one
  // contains the other, or they're within ~25% edit distance of each other
  // ("archimidis" vs "archimedes" = 2 edits over 10 chars → flagged).
  private isSimilarTitle(a: string, b: string): boolean {
    const na = this.normalizeTitle(a);
    const nb = this.normalizeTitle(b);
    if (!na || !nb) return false;
    if (na === nb) return true;
    if (na.length >= 4 && nb.length >= 4 && (na.includes(nb) || nb.includes(na))) return true;
    const maxLen = Math.max(na.length, nb.length);
    if (maxLen < 4) return false;
    return this.levenshtein(na, nb) <= Math.ceil(maxLen * 0.25);
  }

  async createBook(user: any, body: CreateBookBody) {
    if (!this.isBookManager(user)) throw new ForbiddenException('Only teachers and admins can manage books');
    const subject = String(body.subject ?? '').trim();
    const title = String(body.title ?? '').trim();
    const pages = Number(body.pages ?? 0);
    if (!subject) throw new BadRequestException('subject required');
    if (!title) throw new BadRequestException('title required');
    if (!Number.isFinite(pages) || pages <= 0) throw new BadRequestException('pages must be positive');

    // Fuzzy duplicate guard: warn when a SIMILAR (but not identical) book title
    // already exists in this subject, so teachers don't create near-dupes from
    // spelling differences. Identical titles fall through to the idempotent
    // upsert below. The client re-submits with confirmDuplicate=true to proceed.
    if (!body.confirmDuplicate) {
      const norm = this.normalizeTitle(title);
      const existingBooks = await this.prisma.solutionBook.findMany({
        where: { subject },
        select: { title: true },
      });
      const match = existingBooks.find(
        (b) => this.normalizeTitle(b.title) !== norm && this.isSimilarTitle(title, b.title),
      );
      if (match) {
        throw new ConflictException({
          duplicateWarning: true,
          existingTitle: match.title,
          message: `A book named "${match.title}" already exists in this subject. Make sure it isn't the same book before adding it again.`,
        });
      }
    }

    const coverUrl = body.coverUrl?.trim() || null;
    const book = await this.prisma.solutionBook.upsert({
      where: { subject_title: { subject, title } },
      update: { pages: Math.trunc(pages), ...(coverUrl != null ? { coverUrl } : {}) },
      create: { subject, title, pages: Math.trunc(pages), coverUrl, slug: this.slugify(title) },
    });
    return { ok: true, book };
  }

  async updateBook(user: any, id: string, body: UpdateBookBody) {
    if (!this.isBookManager(user)) throw new ForbiddenException('Only teachers and admins can manage books');
    const data: any = {};
    if (body.title != null && String(body.title).trim()) {
      data.title = String(body.title).trim();
      data.slug = this.slugify(data.title);
    }
    if (body.pages != null) {
      const pages = Number(body.pages);
      if (!Number.isFinite(pages) || pages <= 0) throw new BadRequestException('pages must be positive');
      data.pages = Math.trunc(pages);
    }
    if (body.coverUrl !== undefined) {
      data.coverUrl = body.coverUrl?.trim() || null;
    }
    const book = await this.prisma.solutionBook.update({ where: { id }, data });
    return { ok: true, book };
  }

  async deleteBook(user: any, id: string) {
    if (!this.isBookManager(user)) throw new ForbiddenException('Only teachers and admins can manage books');
    const count = await this.prisma.solutionUpload.count({ where: { bookId: id, isDeleted: false } });
    if (count > 0) {
      throw new BadRequestException(`Cannot delete a book that still has ${count} solution(s)`);
    }
    await this.prisma.solutionBook.delete({ where: { id } });
    return { ok: true };
  }

  // ── Reporting ─────────────────────────────────────────────────────────

  private async adminIdsForSchools(schoolIds: (string | null | undefined)[]): Promise<string[]> {
    const ids = [...new Set(schoolIds.filter((x): x is string => !!x))];
    if (!ids.length) return [];
    const admins = await this.prisma.user.findMany({
      where: { schoolId: { in: ids }, roles: { some: { role: 'ADMIN' as any } } },
      select: { id: true },
    });
    return admins.map((a) => a.id);
  }

  async report(user: any, uploadId: string, body: ReportSolutionBody) {
    const reporterId = this.userIdOf(user);
    if (!reporterId) throw new ForbiddenException('Unauthorized');

    const upload = await this.prisma.solutionUpload.findUnique({
      where: { id: uploadId },
      select: { id: true, userId: true, isDeleted: true },
    });
    if (!upload || upload.isDeleted) throw new BadRequestException('Solution not found');

    // Don't pile up duplicate pending reports from the same reporter.
    const existing = await this.prisma.solutionReport.findFirst({
      where: { uploadId, reporterId, status: 'PENDING' },
      select: { id: true },
    });
    if (existing) return { ok: true, alreadyReported: true };

    const report = await this.prisma.solutionReport.create({
      data: { uploadId, reporterId, reason: body?.reason?.trim() || null },
    });

    const [reporter, poster] = await Promise.all([
      this.prisma.user.findUnique({ where: { id: reporterId }, select: { schoolId: true, name: true } }),
      this.prisma.user.findUnique({ where: { id: upload.userId }, select: { schoolId: true, name: true } }),
    ]);

    const adminIds = await this.adminIdsForSchools([reporter?.schoolId, poster?.schoolId]);
    if (adminIds.length) {
      await this.hub.notify({
        recipientUserIds: adminIds,
        type: 'SOLUTION_REPORT',
        title: 'Solution reported',
        body: `A solution by ${poster?.name ?? 'a student'} was reported and needs review.`,
        data: { reportId: report.id, uploadId, route: '/admin/solution-reports' },
        fanOutToParents: false,
        severity: 'warning',
      });
    }

    return { ok: true, report };
  }

  /// Admin view: every report touching the admin's school — whether the
  /// reporter OR the poster belongs to it — newest pending first.
  async listReports(user: any) {
    if (!this.isAdmin(user)) throw new ForbiddenException('Admins only');
    const adminId = this.userIdOf(user);
    const admin = await this.prisma.user.findUnique({ where: { id: adminId }, select: { schoolId: true } });
    const adminSchool = admin?.schoolId ?? null;
    if (!adminSchool) return { ok: true, items: [] };

    const reports = await this.prisma.solutionReport.findMany({
      orderBy: [{ status: 'asc' }, { createdAt: 'desc' }],
      take: 300,
      include: {
        upload: {
          include: { book: true, files: { orderBy: { sortOrder: 'asc' } } },
        },
      },
    });

    const userIds = reports.flatMap((r) => [r.reporterId, r.upload.userId]);
    const people = await this.prisma.user.findMany({
      where: { id: { in: [...new Set(userIds)] } },
      select: {
        id: true,
        name: true,
        displayName: true,
        schoolId: true,
        school: { select: { name: true } },
        studentProfile: { select: { grade: true } },
      },
    });
    const personMap = new Map(people.map((p) => [p.id, p]));

    const items = reports
      .map((r) => {
        const reporter = personMap.get(r.reporterId);
        const poster = personMap.get(r.upload.userId);
        return { r, reporter, poster };
      })
      // Only reports where THIS admin's school is involved (reporter or poster).
      .filter(({ reporter, poster }) => reporter?.schoolId === adminSchool || poster?.schoolId === adminSchool)
      .map(({ r, reporter, poster }) => ({
        id: r.id,
        status: r.status,
        reason: r.reason,
        createdAt: r.createdAt,
        resolvedAt: r.resolvedAt,
        upload: r.upload,
        reporter: reporter
          ? {
              name: (reporter.displayName?.trim() || reporter.name || '').trim(),
              grade: reporter.studentProfile?.grade ?? null,
              schoolName: reporter.school?.name ?? null,
            }
          : null,
        poster: poster
          ? {
              name: (poster.displayName?.trim() || poster.name || '').trim(),
              grade: poster.studentProfile?.grade ?? null,
              schoolName: poster.school?.name ?? null,
            }
          : null,
      }));

    return { ok: true, items };
  }

  async resolveReport(user: any, reportId: string, body: ResolveReportBody) {
    if (!this.isAdmin(user)) throw new ForbiddenException('Admins only');
    const adminId = this.userIdOf(user);
    const action = String(body?.action ?? '').toLowerCase();
    if (action !== 'approve' && action !== 'remove') {
      throw new BadRequestException("action must be 'approve' or 'remove'");
    }

    const report = await this.prisma.solutionReport.findUnique({
      where: { id: reportId },
      include: { upload: { select: { id: true, userId: true } } },
    });
    if (!report) throw new BadRequestException('Report not found');

    // Confirm the acting admin's school is involved.
    const admin = await this.prisma.user.findUnique({ where: { id: adminId }, select: { schoolId: true } });
    const [reporter, poster] = await Promise.all([
      this.prisma.user.findUnique({ where: { id: report.reporterId }, select: { schoolId: true } }),
      this.prisma.user.findUnique({ where: { id: report.upload.userId }, select: { schoolId: true } }),
    ]);
    const involved =
      admin?.schoolId && (admin.schoolId === reporter?.schoolId || admin.schoolId === poster?.schoolId);
    if (!involved) throw new ForbiddenException('This report does not involve your school');

    const status = action === 'remove' ? 'REMOVED' : 'APPROVED';

    if (action === 'remove') {
      await this.prisma.solutionUpload.update({
        where: { id: report.uploadId },
        data: { isDeleted: true, moderationStatus: 'REJECTED', moderationReason: 'Removed after report' },
      });
    } else {
      await this.prisma.solutionUpload.update({
        where: { id: report.uploadId },
        data: { moderationStatus: 'APPROVED' },
      });
    }

    // Resolve every pending report on this upload in one stroke.
    await this.prisma.solutionReport.updateMany({
      where: { uploadId: report.uploadId, status: 'PENDING' },
      data: { status: status as any, resolvedById: adminId, resolvedAt: new Date() },
    });

    return { ok: true, status };
  }

  // ── Legacy staff actions (kept for the staff controller) ──────────────

  async verify(user: any, id: string, body: VerifySolutionBody) {
    if (!this.isStaff(user)) throw new ForbiddenException('Staff only');
    const updated = await this.prisma.solutionUpload.update({
      where: { id },
      data: {
        verificationStatus: body.verificationStatus,
        verificationNote: body.verificationNote?.trim() || null,
      },
      include: { book: true, files: { orderBy: { sortOrder: 'asc' } } },
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
      include: { book: true, files: { orderBy: { sortOrder: 'asc' } } },
    });
    return { ok: true, upload: updated };
  }
}
