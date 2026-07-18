import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

const VALID_KINDS = new Set(['questions', 'answers', 'solution', 'advanced']);

type ExamFileInput = {
  kind: string;
  url: string;
  mimeType?: string | null;
  fileName?: string | null;
  fileSize?: number | null;
};

@Injectable()
export class BagrutLibraryService {
  constructor(private readonly prisma: PrismaService) {}

  // Browse: exams for a subject (or all), newest year first, files attached.
  async listExams(subject?: string) {
    const where = subject ? { subject: String(subject).trim() } : {};
    return this.prisma.bagrutExam.findMany({
      where,
      orderBy: [{ year: 'desc' }, { createdAt: 'desc' }],
      include: { files: { orderBy: { sortOrder: 'asc' } } },
    });
  }

  async getExam(id: string) {
    const exam = await this.prisma.bagrutExam.findUnique({
      where: { id },
      include: { files: { orderBy: { sortOrder: 'asc' } } },
    });
    if (!exam) throw new NotFoundException('Exam not found');
    return exam;
  }

  private normalizeFiles(raw: any): ExamFileInput[] {
    const arr = Array.isArray(raw) ? raw : [];
    return arr
      .map((f: any, i: number) => ({
        kind: String(f?.kind ?? '').trim().toLowerCase(),
        url: String(f?.url ?? '').trim(),
        mimeType: f?.mimeType ? String(f.mimeType) : null,
        fileName: f?.fileName ? String(f.fileName) : null,
        fileSize: Number.isFinite(f?.fileSize) ? Number(f.fileSize) : null,
        sortOrder: i,
      }))
      .filter((f) => f.url.length > 0 && VALID_KINDS.has(f.kind));
  }

  async createExam(body: {
    subject: string;
    year: number;
    term?: string;
    title: string;
    files?: ExamFileInput[];
  }) {
    const subject = String(body?.subject ?? '').trim();
    const title = String(body?.title ?? '').trim();
    const year = Number(body?.year);
    const term = String(body?.term ?? '').trim();

    if (!subject) throw new BadRequestException('Subject is required.');
    if (!title) throw new BadRequestException('Title is required.');
    if (!Number.isFinite(year) || year < 1950 || year > 2100) {
      throw new BadRequestException('A valid year is required.');
    }

    const files = this.normalizeFiles(body?.files);
    if (!files.length) throw new BadRequestException('At least one file is required.');

    return this.prisma.bagrutExam.create({
      data: {
        subject,
        year,
        term,
        title,
        files: { create: files as any },
      },
      include: { files: { orderBy: { sortOrder: 'asc' } } },
    });
  }

  async updateExam(id: string, body: {
    subject?: string;
    year?: number;
    term?: string;
    title?: string;
    files?: ExamFileInput[];
  }) {
    const exam = await this.prisma.bagrutExam.findUnique({ where: { id } });
    if (!exam) throw new NotFoundException('Exam not found');

    const data: any = {};
    if (body.subject !== undefined) {
      const s = String(body.subject).trim();
      if (!s) throw new BadRequestException('Subject cannot be empty.');
      data.subject = s;
    }
    if (body.title !== undefined) {
      const t = String(body.title).trim();
      if (!t) throw new BadRequestException('Title cannot be empty.');
      data.title = t;
    }
    if (body.year !== undefined) {
      const y = Number(body.year);
      if (!Number.isFinite(y) || y < 1950 || y > 2100) throw new BadRequestException('A valid year is required.');
      data.year = y;
    }
    if (body.term !== undefined) data.term = String(body.term).trim();

    // If files are supplied, replace the whole set (simplest, matches the
    // manager edit-exam UX where the file list is re-picked wholesale).
    if (body.files !== undefined) {
      const files = this.normalizeFiles(body.files);
      if (!files.length) throw new BadRequestException('At least one file is required.');
      await this.prisma.bagrutExamFile.deleteMany({ where: { examId: id } });
      data.files = { create: files as any };
    }

    return this.prisma.bagrutExam.update({
      where: { id },
      data,
      include: { files: { orderBy: { sortOrder: 'asc' } } },
    });
  }

  async deleteExam(id: string) {
    const exam = await this.prisma.bagrutExam.findUnique({ where: { id } });
    if (!exam) throw new NotFoundException('Exam not found');
    await this.prisma.bagrutExam.delete({ where: { id } });
    return { ok: true };
  }
}
