import {
  ForbiddenException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { hasAnyRole } from '../auth/roles';
import { CreateNoteDto, UpdateNoteDto } from './dto/note.dto';

/// Staff notes about students (Apple-Notes-like, but per student).
/// Access model: TEACHER + ADMIN of the student's school see all of that
/// student's notes (shared staff record, author shown on each note); a note
/// is editable/deletable by its author or any ADMIN. Students, parents and
/// secretaries never reach these routes (controller @Roles) and every query
/// below is school-scoped — cross-school reads are impossible by
/// construction.
@Injectable()
export class NotesService {
  constructor(private readonly prisma: PrismaService) {}

  private staff(user: any): { userId: string; schoolId: string; isAdmin: boolean } {
    const userId = String(user?.id ?? user?.sub ?? '');
    const schoolId = user?.schoolId ? String(user.schoolId) : '';
    if (!userId) throw new UnauthorizedException();
    if (!hasAnyRole(user, ['TEACHER', 'ADMIN'])) {
      throw new ForbiddenException('Staff only');
    }
    if (!schoolId) throw new ForbiddenException('No school on account');
    return { userId, schoolId, isAdmin: hasAnyRole(user, ['ADMIN']) };
  }

  /// The student browser: every student in the caller's school with their
  /// grade/cohort and how many notes exist for them. `q` filters by name.
  async listStudents(user: any, q?: string) {
    const { schoolId } = this.staff(user);
    const query = (q ?? '').trim();
    const students = await this.prisma.user.findMany({
      where: {
        schoolId,
        roles: { some: { role: 'STUDENT' } },
        ...(query
          ? { name: { contains: query, mode: 'insensitive' as const } }
          : {}),
      },
      select: {
        id: true,
        name: true,
        studentProfile: {
          select: { grade: true, cohort: { select: { name: true, grade: true } } },
        },
      },
      orderBy: { name: 'asc' },
    });

    const counts = await this.prisma.studentNote.groupBy({
      by: ['studentId'],
      where: { schoolId },
      _count: { _all: true },
    });
    const countMap = new Map(counts.map((c) => [c.studentId, c._count._all]));

    return {
      ok: true,
      students: students.map((s) => ({
        studentId: s.id,
        name: s.name,
        grade: s.studentProfile?.grade ?? s.studentProfile?.cohort?.grade ?? null,
        cohortName: s.studentProfile?.cohort?.name ?? null,
        noteCount: countMap.get(s.id) ?? 0,
      })),
    };
  }

  /// Guard every per-student operation: the target must be a STUDENT in the
  /// caller's school. Returns the student's display info.
  private async requireStudent(schoolId: string, studentId: string) {
    const student = await this.prisma.user.findFirst({
      where: {
        id: studentId,
        schoolId,
        roles: { some: { role: 'STUDENT' } },
      },
      select: {
        id: true,
        name: true,
        studentProfile: {
          select: { grade: true, cohort: { select: { name: true, grade: true } } },
        },
      },
    });
    if (!student) throw new NotFoundException('Student not found');
    return student;
  }

  async listNotes(user: any, studentId: string) {
    const { schoolId, userId, isAdmin } = this.staff(user);
    const student = await this.requireStudent(schoolId, studentId);

    const notes = await this.prisma.studentNote.findMany({
      where: { schoolId, studentId },
      orderBy: { updatedAt: 'desc' },
    });

    const authorIds = [...new Set(notes.map((n) => n.authorId))];
    const authors = authorIds.length
      ? await this.prisma.user.findMany({
          where: { id: { in: authorIds } },
          select: { id: true, name: true },
        })
      : [];
    const authorMap = new Map(authors.map((a) => [a.id, a.name]));

    return {
      ok: true,
      student: {
        studentId: student.id,
        name: student.name,
        grade:
          student.studentProfile?.grade ??
          student.studentProfile?.cohort?.grade ??
          null,
        cohortName: student.studentProfile?.cohort?.name ?? null,
      },
      notes: notes.map((n) => ({
        id: n.id,
        title: n.title,
        body: n.body,
        authorId: n.authorId,
        authorName: authorMap.get(n.authorId) ?? '',
        canEdit: isAdmin || n.authorId === userId,
        createdAt: n.createdAt.toISOString(),
        updatedAt: n.updatedAt.toISOString(),
      })),
    };
  }

  async createNote(user: any, studentId: string, dto: CreateNoteDto) {
    const { schoolId, userId } = this.staff(user);
    await this.requireStudent(schoolId, studentId);
    const note = await this.prisma.studentNote.create({
      data: {
        schoolId,
        studentId,
        authorId: userId,
        title: (dto.title ?? '').trim(),
        body: dto.body ?? '',
      },
    });
    return { ok: true, noteId: note.id };
  }

  /// Load a note the caller may MODIFY: same school AND (author or ADMIN).
  private async requireEditableNote(user: any, noteId: string) {
    const { schoolId, userId, isAdmin } = this.staff(user);
    const note = await this.prisma.studentNote.findFirst({
      where: { id: noteId, schoolId },
    });
    if (!note) throw new NotFoundException('Note not found');
    if (!isAdmin && note.authorId !== userId) {
      throw new ForbiddenException('Only the author or an admin can change this note');
    }
    return note;
  }

  async updateNote(user: any, noteId: string, dto: UpdateNoteDto) {
    const note = await this.requireEditableNote(user, noteId);
    await this.prisma.studentNote.update({
      where: { id: note.id },
      data: {
        ...(dto.title !== undefined ? { title: dto.title.trim() } : {}),
        ...(dto.body !== undefined ? { body: dto.body } : {}),
      },
    });
    return { ok: true };
  }

  async deleteNote(user: any, noteId: string) {
    const note = await this.requireEditableNote(user, noteId);
    await this.prisma.studentNote.delete({ where: { id: note.id } });
    return { ok: true };
  }
}
