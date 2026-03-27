import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

type DayOfWeek = 0 | 1 | 2 | 3 | 4 | 5 | 6;

const PERIOD_TIME: Record<number, { start: string; end: string }> = {
  1: { start: '08:00', end: '08:45' },
  2: { start: '08:50', end: '09:35' },
  3: { start: '09:45', end: '10:30' },
  4: { start: '10:35', end: '11:20' },
  5: { start: '11:30', end: '12:15' },
  6: { start: '12:20', end: '13:05' },
  7: { start: '13:15', end: '14:00' },
  8: { start: '14:05', end: '14:50' },
  9: { start: '15:00', end: '15:45' },
  10: { start: '15:50', end: '16:35' },
};

function timesForPeriod(period: number): { startTime: string; endTime: string } {
  const t = PERIOD_TIME[Number(period)] ?? { start: '00:00', end: '00:00' };
  return { startTime: t.start, endTime: t.end };
}

@Injectable()
export class ClassroomsService {
  constructor(private readonly prisma: PrismaService) {}

  private async cohortIdForStudentUserId(userId: string): Promise<string> {
    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: String(userId) },
      select: { cohortId: true },
    });
    if (!sp?.cohortId) throw new BadRequestException('Student not onboarded');
    return String(sp.cohortId);
  }

  private async courseIdsForCohort(cohortId: string): Promise<string[]> {
    const rows = await this.prisma.scheduleSlot.findMany({
      where: { cohortId: String(cohortId), courseId: { not: null } },
      select: { courseId: true },
      distinct: ['courseId'],
    });

    return rows
      .map((r) => r.courseId)
      .filter(Boolean)
      .map((x) => String(x));
  }

  async listStudentClassrooms(studentUserId: string) {
    const cohortId = await this.cohortIdForStudentUserId(studentUserId);
    const courseIds = await this.courseIdsForCohort(cohortId);

    if (!courseIds.length) return [];

    const courses = await this.prisma.course.findMany({
      where: { id: { in: courseIds } },
      orderBy: [{ subject: 'asc' }, { name: 'asc' }],
      select: {
        id: true,
        name: true,
        subject: true,
        teacherId: true,
        cohortId: true,
        groupTag: true,
      },
    });

    return courses.map((c) => ({
      id: c.id,
      name: c.name,
      subject: c.subject,
      teacherId: c.teacherId ?? null,
      cohortId: c.cohortId ?? null,
      groupTag: c.groupTag ?? null,
    }));
  }

  async getStudentClassroom(studentUserId: string, courseId: string) {
    const cohortId = await this.cohortIdForStudentUserId(studentUserId);

    const course = await this.prisma.course.findUnique({
      where: { id: String(courseId) },
      select: {
        id: true,
        name: true,
        subject: true,
        teacherId: true,
        cohortId: true,
        groupTag: true,
      },
    });
    if (!course) throw new BadRequestException('Invalid classroom id');

    const tmpl = await this.prisma.scheduleSlot.findMany({
      where: {
        cohortId: String(cohortId),
        courseId: String(courseId),
      },
      orderBy: [{ dayOfWeek: 'asc' }, { period: 'asc' }],
      select: { id: true, dayOfWeek: true, period: true },
    });

    const template = tmpl.map((r) => {
      const { startTime, endTime } = timesForPeriod(Number(r.period));
      return {
        id: r.id,
        dayOfWeek: Number(r.dayOfWeek) as DayOfWeek,
        period: Number(r.period),
        startTime,
        endTime,
      };
    });

    // announcements: placeholder (wired in Session 6)
    return {
      id: course.id,
      name: course.name,
      subject: course.subject,
      teacherId: course.teacherId ?? null,
      cohortId: cohortId,
      groupTag: course.groupTag ?? null,
      scheduleTemplate: template,
      announcements: [],
    };
  }
}
