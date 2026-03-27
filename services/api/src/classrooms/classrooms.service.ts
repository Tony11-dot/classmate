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
  async forwardClassroomChatMessage(user: any, courseId: string, body: any) {
    const viewerId = String(user?.sub ?? user?.id ?? '').trim();
    const messageId = String(body?.messageId ?? '').trim();
    const targetThreadIds = Array.from(
      new Set(
        (Array.isArray(body?.targetThreadIds) ? body.targetThreadIds : [])
          .map((v: any) => String(v ?? '').trim())
          .filter(Boolean),
      ),
    );

    if (!viewerId) throw new Error('Missing authenticated user');
    if (!courseId) throw new Error('courseId is required');
    if (!messageId) throw new Error('messageId is required');
    if (!targetThreadIds.length) throw new Error('targetThreadIds is required');

    const course = await this.prisma.course.findUnique({
      where: { id: courseId },
      select: { id: true, teacherId: true, cohortId: true, title: true, name: true },
    });
    if (!course) throw new Error('Course not found');

    const isTeacher = String(course.teacherId ?? '') === viewerId;
    const enrollment = await this.prisma.enrollment.findFirst({
      where: { courseId, studentId: viewerId },
      select: { id: true },
    });

    const hasAccess = isTeacher || !!enrollment;
    if (!hasAccess) throw new Error('No access to this classroom');

    const source = await this.prisma.classroomChatMessage?.findFirst?.({
      where: { id: messageId, courseId },
    });

    if (!source) throw new Error('Classroom message not found');

    for (const threadId of targetThreadIds) {
      const participant = await this.prisma.dmParticipant.findUnique({
        where: { threadId_userId: { threadId, userId: viewerId } },
        include: { thread: true },
      });
      if (!participant) throw new Error('No access to target thread');
      if (String(participant.state) !== 'ACCEPTED') {
        throw new Error('Cannot forward into a non-approved thread');
      }

      await this.prisma.dmMessage.create({
        data: {
          threadId,
          senderId: viewerId,
          kind: String(source.kind ?? 'TEXT') as any,
          text: source.text ?? null,
          mediaUrl: source.mediaUrl ?? null,
          mediaMimeType: source.mediaMimeType ?? null,
        },
      });

      await this.prisma.dmParticipant.update({
        where: { threadId_userId: { threadId, userId: viewerId } },
        data: { lastSeenAt: new Date() },
      });
    }

    return { ok: true, forwardedCount: targetThreadIds.length };
  }


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
