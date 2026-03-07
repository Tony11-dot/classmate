import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import {
  Controller,
  Get,
  Param,
  Query,
  Req,
  UseGuards,
  Post,
  Body,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { PrismaService } from '../prisma/prisma.service';

@UseGuards(JwtAuthGuard)
@Roles(Role.STUDENT, Role.ADMIN)
@Controller('student/classrooms')
export class StudentClassroomsController {
  constructor(private readonly prisma: PrismaService) {}

  private async cohortIdFromUser(req: any): Promise<string> {
    const uid = String(req?.user?.sub ?? req?.user?.id ?? '');
    if (!uid) throw new Error('Missing user id');
    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: uid },
      select: { cohortId: true },
    });
    if (!sp?.cohortId) throw new Error('Student not onboarded');
    return String(sp.cohortId);
  }

  private async assertCourseInCohort(courseId: string, cohortId: string) {
    const course = await this.prisma.course.findFirst({
      where: { id: courseId, cohortId },
      select: {
        id: true,
        name: true,
        subject: true,
        teacherId: true,
        cohortId: true,
        groupTag: true,
      },
    });
    if (!course) throw new Error('Classroom not found');
    return course;
  }

  @Get()
  async list(@Req() req: any) {
    const cohortId = await this.cohortIdFromUser(req);
    const courses = await this.prisma.course.findMany({
      where: { cohortId },
      select: {
        id: true,
        name: true,
        subject: true,
        teacherId: true,
        cohortId: true,
        groupTag: true,
      },
      orderBy: [{ subject: 'asc' }, { name: 'asc' }, { id: 'asc' }],
    });
    return courses;
  }

  @Get(':id')
  async detail(@Req() req: any, @Param('id') id: string) {
    const cohortId = await this.cohortIdFromUser(req);
    const course = await this.assertCourseInCohort(String(id), cohortId);

    // Optional: include schedule template for the classroom (existing schedule template slots)
    const scheduleTemplate = await this.prisma.scheduleSlot.findMany({
      where: { courseId: course.id },
      select: {
        id: true,
        dayOfWeek: true,
        period: true,
      },
      orderBy: [{ dayOfWeek: 'asc' }, { period: 'asc' }, { id: 'asc' }],
    });

    // Stable empties for tabs (client safe)
    return {
      ...course,
      scheduleTemplate,
      announcements: [],
    };
  }

  // --- People tab (minimal v1: cohort classmates + teacher) ---
  @Get(':id/people')
  async people(@Req() req: any, @Param('id') id: string) {
    const cohortId = await this.cohortIdFromUser(req);
    const course = await this.assertCourseInCohort(String(id), cohortId);

    const students = await this.prisma.studentProfile.findMany({
      where: { cohortId },
      select: {
        userId: true,
        user: {
          select: {
            name: true,
          },
        },
      },
      orderBy: [{ userId: 'asc' }],
    });

    const teacherUserId = course.teacherId ? String(course.teacherId) : null;

    const teacher =
      teacherUserId
        ? await this.prisma.user.findUnique({
            where: { id: teacherUserId },
            select: { id: true, name: true },
          })
        : null;

    return {
      ok: true,
      items: {
        teacherUserId,
        studentUserIds: students.map((x) => x.userId),
        teacher: teacher
          ? {
              id: teacher.id,
              name: teacher.name ?? null,
            }
          : null,
        students: students.map((x) => ({
          id: x.userId,
          name: x.user?.name ?? null,
        })),
      },
    };
  }

  // --- Chat tab ---
  @Get(':id/chat')
  async chatList(
    @Req() req: any,
    @Param('id') id: string,
    @Query('cursor') cursor?: string,
    @Query('limit') limit?: string,
  ) {
    const cohortId = await this.cohortIdFromUser(req);
    await this.assertCourseInCohort(String(id), cohortId);

    const take = Math.min(Math.max(parseInt(limit ?? '30', 10) || 30, 1), 100);

    const rows = await this.prisma.classroomMessage.findMany({
      where: { courseId: String(id) },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take: take + 1,
      ...(cursor
        ? {
            cursor: { id: String(cursor) },
            skip: 1,
          }
        : {}),
      select: {
        id: true,
        courseId: true,
        senderUserId: true,
        kind: true,
        text: true,
        mediaUrl: true,
        mediaMime: true,
        durationSec: true,
        createdAt: true,
      },
    });

    const hasMore = rows.length > take;
    const itemsDesc = rows.slice(0, take);
    const nextCursor = hasMore
      ? (itemsDesc[itemsDesc.length - 1]?.id ?? null)
      : null;

    // Return oldest->newest for easier UI rendering
    const items = itemsDesc.reverse();

    return {
      ok: true,
      items,
      nextCursor,
    };
  }

  @Post(':id/chat/text')
  async chatSendText(
    @Req() req: any,
    @Param('id') id: string,
    @Body() body: { text?: string },
  ) {
    const cohortId = await this.cohortIdFromUser(req);
    await this.assertCourseInCohort(String(id), cohortId);

    const uid = String(req?.user?.sub ?? req?.user?.id ?? '');
    const text = String(body?.text ?? '').trim();
    if (!text) throw new Error('Missing text');

    const msg = await this.prisma.classroomMessage.create({
      data: {
        courseId: String(id),
        senderUserId: uid,
        kind: 'TEXT',
        text,
      },
      select: {
        id: true,
        courseId: true,
        senderUserId: true,
        kind: true,
        text: true,
        mediaUrl: true,
        mediaMime: true,
        durationSec: true,
        createdAt: true,
      },
    });

    return { ok: true, item: msg };
  }

  @Post(':id/chat/media')
  async chatSendMedia(
    @Req() req: any,
    @Param('id') id: string,
    @Body()
    body: {
      kind?: 'VOICE' | 'IMAGE' | 'DOC';
      mediaUrl?: string;
      mediaMime?: string;
      durationSec?: number;
      text?: string;
    },
  ) {
    const cohortId = await this.cohortIdFromUser(req);
    await this.assertCourseInCohort(String(id), cohortId);

    const uid = String(req?.user?.sub ?? req?.user?.id ?? '');
    const kind = String(body?.kind ?? '').toUpperCase();
    if (!['VOICE', 'IMAGE', 'DOC'].includes(kind))
      throw new Error('Invalid kind');
    const mediaUrl = String(body?.mediaUrl ?? '').trim();
    if (!mediaUrl) throw new Error('Missing mediaUrl');

    const msg = await this.prisma.classroomMessage.create({
      data: {
        courseId: String(id),
        senderUserId: uid,
        kind: kind as any,
        text: body?.text ? String(body.text).trim() : null,
        mediaUrl,
        mediaMime: body?.mediaMime ? String(body.mediaMime).trim() : null,
        durationSec: body?.durationSec ? Number(body.durationSec) : null,
      },
      select: {
        id: true,
        courseId: true,
        senderUserId: true,
        kind: true,
        text: true,
        mediaUrl: true,
        mediaMime: true,
        durationSec: true,
        createdAt: true,
      },
    });

    return { ok: true, item: msg };
  }

  // --- Assignments tab ---
  @Get(':id/assignments')
  async assignments(@Req() req: any, @Param('id') id: string) {
    const cohortId = await this.cohortIdFromUser(req);
    await this.assertCourseInCohort(String(id), cohortId);

    const items = await this.prisma.classroomAssignment.findMany({
      where: { courseId: String(id) },
      orderBy: [{ dueAt: 'asc' }, { createdAt: 'desc' }, { id: 'desc' }],
      select: {
        id: true,
        title: true,
        body: true,
        dueAt: true,
        createdBy: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    return { ok: true, items };
  }

  // --- Materials tab ---
  @Get(':id/materials')
  async materials(@Req() req: any, @Param('id') id: string) {
    const cohortId = await this.cohortIdFromUser(req);
    await this.assertCourseInCohort(String(id), cohortId);

    const items = await this.prisma.classroomMaterial.findMany({
      where: { courseId: String(id) },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      select: {
        id: true,
        title: true,
        description: true,
        url: true,
        mime: true,
        createdBy: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    return { ok: true, items };
  }

  // --- Meetings tab ---
  @Get(':id/meetings')
  async meetings(@Req() req: any, @Param('id') id: string) {
    const cohortId = await this.cohortIdFromUser(req);
    await this.assertCourseInCohort(String(id), cohortId);

    const items = await this.prisma.classroomMeeting.findMany({
      where: { courseId: String(id) },
      orderBy: [{ startsAt: 'asc' }, { id: 'asc' }],
      select: {
        id: true,
        title: true,
        link: true,
        createdBy: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    return { ok: true, items };
  }

  // Back-compat routes you already called earlier:
  @Get(':id/announcements')
  async announcements(@Req() req: any, @Param('id') id: string) {
    const cohortId = await this.cohortIdFromUser(req);
    await this.assertCourseInCohort(String(id), cohortId);
    return { ok: true, items: [] };
  }
}
