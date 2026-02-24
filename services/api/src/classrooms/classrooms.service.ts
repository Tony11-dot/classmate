import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

export type ClassroomSummary = {
  id: string;
  name: string;
  teacher: string | null;
  studentCount: number;
};

export type ClassroomDetail = {
  id: string;
  name: string;
  teacher: string | null;
  description: string | null;
};

@Injectable()
export class ClassroomsService {
  constructor(private readonly prisma: PrismaService) {}

  private mapSummary(c: any): ClassroomSummary {
    return {
      id: String(c.id),
      name: String(c.name ?? c.subject ?? 'Classroom'),
      teacher: c.teacher?.name ?? c.teacher?.displayName ?? c.teacher?.email ?? null,
      studentCount: Number(c._count?.enrollments ?? 0),
    };
  }

  private mapDetail(c: any): ClassroomDetail {
    return {
      id: String(c.id),
      name: String(c.name ?? c.subject ?? 'Classroom'),
      teacher: c.teacher?.name ?? c.teacher?.displayName ?? c.teacher?.email ?? null,
      description: null,
    };
  }

  async listForStudent(userId: string): Promise<ClassroomSummary[]> {
    // StudentProfile optional (do not block MVP)
    await this.prisma.studentProfile.findFirst({ where: { userId }, select: { userId: true } }).catch(() => null);

    const enroll = await this.prisma.enrollment.findMany({
      where: { studentId: userId },
      select: { courseId: true },
    });
    const courseIds = Array.from(new Set(enroll.map((e) => String(e.courseId)).filter(Boolean)));
if (!courseIds.length) return [];

    const courses = await this.prisma.course.findMany({
      where: { id: { in: courseIds } },
      select: {
        id: true,
        name: true,
        subject: true,
        teacher: { select: { name: true, displayName: true, email: true } },
        _count: { select: { enrollments: true } },
      },
      orderBy: [{ name: 'asc' }],
    });

    return courses.map((c) => this.mapSummary(c));
  }

  async getForStudent(userId: string, id: string): Promise<ClassroomDetail> {
    const c = await this.prisma.course.findUnique({
      where: { id },
      select: {
        id: true,
        name: true,
        subject: true,
        teacher: { select: { name: true, displayName: true, email: true } },
      },
    });
    if (!c) throw new NotFoundException('Classroom not found');

    const m = await this.prisma.enrollment.findFirst({
      where: { courseId: id, studentId: userId },
      select: { id: true },
    });
    if (!m) throw new ForbiddenException('Not a member');

    return this.mapDetail(c);
  }

  async listForParent(parentId: string): Promise<ClassroomSummary[]> {
    const links = await this.prisma.parentChild.findMany({
      where: { parentId },
      select: { childId: true },
    });
    const childIds = links.map((l) => l.childId);
    if (!childIds.length) return [];

    const enroll = await this.prisma.enrollment.findMany({
      where: { studentId: { in: childIds } },
      select: { courseId: true },
    });
    const courseIds = Array.from(new Set(enroll.map((e) => String(e.courseId)).filter(Boolean)));
    if (!courseIds.length) return [];

    const courses = await this.prisma.course.findMany({
      where: { id: { in: courseIds } },
      select: {
        id: true,
        name: true,
        subject: true,
        teacher: { select: { name: true, displayName: true, email: true } },
        _count: { select: { enrollments: true } },
      },
      orderBy: [{ name: 'asc' }],
    });

    const byId = new Map<string, ClassroomSummary>();
    for (const c of courses) byId.set(String(c.id), this.mapSummary(c));
    return Array.from(byId.values());
  }

  async getForParent(parentId: string, id: string): Promise<ClassroomDetail> {
    const links = await this.prisma.parentChild.findMany({
      where: { parentId },
      select: { childId: true },
    });
    const childIds = links.map((l) => l.childId);
    if (!childIds.length) throw new ForbiddenException('No linked children');

    const c = await this.prisma.course.findUnique({
      where: { id },
      select: {
        id: true,
        name: true,
        subject: true,
        teacher: { select: { name: true, displayName: true, email: true } },
      },
    });
    if (!c) throw new NotFoundException('Classroom not found');

    const m = await this.prisma.enrollment.findFirst({
      where: { courseId: id, studentId: { in: childIds } },
      select: { id: true },
    });
    if (!m) throw new ForbiddenException('Not a member via children');

    return this.mapDetail(c);
  }

  async listForAdmin(_adminId: string): Promise<ClassroomSummary[]> {
    const courses = await this.prisma.course.findMany({
      select: {
        id: true,
        name: true,
        subject: true,
        teacher: { select: { name: true, displayName: true, email: true } },
        _count: { select: { enrollments: true } },
      },
      orderBy: [{ name: 'asc' }],
    });
    return courses.map((c) => this.mapSummary(c));
  }

  async getForAdmin(_adminId: string, id: string): Promise<ClassroomDetail> {
    const c = await this.prisma.course.findUnique({
      where: { id },
      select: {
        id: true,
        name: true,
        subject: true,
        teacher: { select: { name: true, displayName: true, email: true } },
      },
    });
    if (!c) throw new NotFoundException('Classroom not found');
    return this.mapDetail(c);
  }
}
