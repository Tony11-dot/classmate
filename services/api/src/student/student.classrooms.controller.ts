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
  UploadedFile,
  UseInterceptors,
  BadRequestException,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { PrismaService } from '../prisma/prisma.service';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { mkdirSync } from 'fs';


function ensureClassroomUploadsDir() {
  mkdirSync('uploads', { recursive: true });
  mkdirSync('uploads/classrooms', { recursive: true });
}

function safeClassroomName(raw: string) {
  return String(raw || 'upload').replace(/[^a-zA-Z0-9._-]/g, '_');
}

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

    const teacher = teacherUserId
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
    const uid = String(req?.user?.sub ?? req?.user?.id ?? '');
    const role = String(req?.user?.role ?? req?.user?.roles?.[0] ?? '').toUpperCase();
    const text = String(body?.text ?? '').trim();
    if (!text) throw new BadRequestException('Missing text');

    if (role === 'STUDENT') {
      // Students must belong to the course cohort
      const cohortId = await this.cohortIdFromUser(req);
      await this.assertCourseInCohort(String(id), cohortId);
    } else {
      // Teachers and admins: just verify the course exists
      const exists = await this.prisma.course.findUnique({
        where: { id: String(id) },
        select: { id: true },
      });
      if (!exists) throw new BadRequestException('Classroom not found');
    }

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


  @Post(':id/chat/forward')
  async chatForward(
    @Req() req: any,
    @Param('id') id: string,
    @Body() body: { messageId?: string; targetThreadIds?: string[] },
  ) {
    const cohortId = await this.cohortIdFromUser(req);
    await this.assertCourseInCohort(String(id), cohortId);

    const uid = String(req?.user?.sub ?? req?.user?.id ?? '').trim();
    const messageId = String(body?.messageId ?? '').trim();
    const targetThreadIds = Array.from(
      new Set(
        (Array.isArray(body?.targetThreadIds) ? body.targetThreadIds : [])
          .map((v) => String(v ?? '').trim())
          .filter((v) => v.length > 0),
      ),
    );

    if (!uid) throw new BadRequestException('Missing user id');
    if (!messageId) throw new BadRequestException('Missing messageId');
    if (!targetThreadIds.length) {
      throw new BadRequestException('Missing targetThreadIds');
    }

    const source = await this.prisma.classroomMessage.findFirst({
      where: {
        id: messageId,
        courseId: String(id),
      },
      select: {
        id: true,
        kind: true,
        text: true,
        mediaUrl: true,
        mediaMime: true,
        durationSec: true,
      },
    });

    if (!source) {
      throw new BadRequestException('Classroom message not found');
    }

    for (const targetThreadId of targetThreadIds) {
      const sourceKind = String(source.kind ?? 'TEXT').trim().toUpperCase();
      const sourceText = String(source.text ?? '').trim();
      const sourceMediaMime = String(source.mediaMime ?? '').trim();
      const sourceDuration =
        Number.isFinite(Number(source.durationSec ?? 0)) &&
        Number(source.durationSec ?? 0) > 0
          ? Number(source.durationSec)
          : 0;
      const forwardedText =
        sourceKind === 'VOICE'
          ? (() => {
              const tagged = /\[duration:\d+\]/i.test(sourceText);
              if (tagged) return sourceText;
              if (sourceText) return `${sourceText} [duration:${sourceDuration}]`;
              return sourceDuration > 0
                ? `[VOICE] Voice message [duration:${sourceDuration}]`
                : '[VOICE] Voice message';
            })()
          : sourceText || null;

      // Try DM participant first
      const participant = await this.prisma.dmParticipant.findUnique({
        where: { threadId_userId: { threadId: targetThreadId, userId: uid } },
      });

      if (participant) {
        if (String(participant.state) !== 'ACCEPTED') {
          throw new BadRequestException('Cannot forward into a non-approved thread');
        }
        await this.prisma.dmMessage.create({
          data: {
            threadId: targetThreadId,
            senderId: uid,
            kind: sourceKind as any,
            text: forwardedText != null ? `Forwarded\n${forwardedText}` : 'Forwarded',
            mediaUrl: source.mediaUrl ?? null,
            mediaMimeType: sourceMediaMime || null,
            forwardedFromId: null, // source is ClassroomMessage; DmMessage FK can only ref DmMessage
          },
        });
        await this.prisma.dmParticipant.update({
          where: { threadId_userId: { threadId: targetThreadId, userId: uid } },
          data: { lastSeenAt: new Date() },
        });
      } else {
        // Try classroom target
        const targetCourse = await this.prisma.course.findFirst({
          where: { id: targetThreadId, cohortId },
          select: { id: true },
        });
        if (!targetCourse) {
          throw new BadRequestException('Invalid target thread');
        }
        await this.prisma.classroomMessage.create({
          data: {
            courseId: targetThreadId,
            senderUserId: uid,
            kind: sourceKind as any,
            text: forwardedText != null ? `Forwarded\n${forwardedText}` : 'Forwarded',
            mediaUrl: source.mediaUrl ?? null,
            mediaMime: sourceMediaMime || null,
            durationSec: sourceDuration > 0 ? sourceDuration : null,
          },
        });
      }
    }

    return { ok: true, forwardedCount: targetThreadIds.length };
  }

  @Post(':id/chat/media')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: (_req, _file, cb) => {
          ensureClassroomUploadsDir();
          cb(null, 'uploads/classrooms');
        },
        filename: (_req, file, cb) => {
          const stamp = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
          const base = safeClassroomName(file?.originalname || 'upload');
          const ext = extname(base);
          const stem = ext ? base.slice(0, -ext.length) : base;
          cb(null, `${stem}-${stamp}${ext}`);
        },
      }),
      limits: { fileSize: 40 * 1024 * 1024 },
    }),
  )
  async chatSendMedia(
    @Req() req: any,
    @Param('id') id: string,
    @UploadedFile() file: any,
    @Body()
    body: {
      kind?: 'VOICE' | 'IMAGE' | 'VIDEO' | 'FILE';
      mediaUrl?: string;
      mediaMime?: string;
      durationSec?: number;
      text?: string;
      originalName?: string;
    },
  ) {
    const cohortId = await this.cohortIdFromUser(req);
    await this.assertCourseInCohort(String(id), cohortId);

    const uid = String(req?.user?.sub ?? req?.user?.id ?? '').trim();

    const rawKind = String(body?.kind ?? '').trim().toUpperCase();
    const inferredMime = String(body?.mediaMime ?? file?.mimetype ?? '').trim();

    let kind = rawKind;
    if (!kind) {
      const mime = inferredMime.toLowerCase();
      if (mime.startsWith('image/')) kind = 'IMAGE';
      else if (mime.startsWith('audio/')) kind = 'VOICE';
      else if (mime.startsWith('video/')) kind = 'VIDEO';
      else kind = 'FILE';
    }

    
    if (!['VOICE', 'IMAGE', 'VIDEO', 'FILE'].includes(kind)) {
      throw new BadRequestException('Invalid kind');
    }

    const mediaUrl = String(
      body?.mediaUrl ??
        (file?.filename ? `/uploads/classrooms/${file.filename}` : ''),
    ).trim();

    if (!mediaUrl) {
      throw new BadRequestException('Missing mediaUrl');
    }

    const mime = inferredMime;
    const originalName = String(
      body?.originalName ?? file?.originalname ?? file?.filename ?? '',
    ).trim();

    const rawText = String(body?.text ?? '').trim();
    const fallbackText =
      rawText.length > 0
        ? rawText
        : kind === 'IMAGE'
          ? `[IMAGE] ${originalName || 'image'}`
          : kind === 'VOICE'
            ? `[VOICE] ${originalName || 'voice'}`
            : kind === 'VIDEO'
              ? `[VIDEO] ${originalName || 'video'}`
              : `[FILE] ${originalName || 'file'}`;

    const durationNum = Number(body?.durationSec ?? 0);

    // DB may still use DOC instead of FILE for classroom messages.
    const persistedKind = kind === 'FILE' ? 'DOC' : kind;

    const msg = await this.prisma.classroomMessage.create({
      data: {
        courseId: String(id),
        senderUserId: uid,
        kind: persistedKind as any,
        text: fallbackText,
        mediaUrl,
        mediaMime: mime || null,
        durationSec:
          Number.isFinite(durationNum) && durationNum > 0 ? durationNum : null,
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
