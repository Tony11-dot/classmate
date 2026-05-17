import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import {
  Controller,
  Delete,
  Get,
  ForbiddenException,
  Param,
  Query,
  Req,
  UseGuards,
  Post,
  Body,
  UploadedFile,
  UseInterceptors,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { PrismaService } from '../prisma/prisma.service';
import { RealtimeService } from '../realtime/realtime.service';
import * as bcrypt from 'bcrypt';
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
@Roles(Role.STUDENT, Role.TEACHER, Role.ADMIN)
@Controller('student/classrooms')
export class StudentClassroomsController {
  constructor(
    private readonly prisma: PrismaService,
    private readonly realtime: RealtimeService,
  ) {}

  private uid(req: any) { return String(req?.user?.sub ?? req?.user?.id ?? ''); }

  private isTeacherOrAdmin(req: any) {
    const roles: string[] = Array.isArray(req?.user?.roles) ? req.user.roles : [];
    return roles.includes('TEACHER') || roles.includes('ADMIN');
  }

  private async assertAccess(req: any, classroomId: string) {
    const cr = await this.prisma.classroom.findUnique({
      where: { id: classroomId },
      select: { id: true, name: true, subject: true, teacherId: true },
    });
    if (!cr) throw new NotFoundException('Classroom not found');
    if (this.isTeacherOrAdmin(req)) return cr;
    const uid = this.uid(req);
    const member = await this.prisma.classroomMember.findUnique({
      where: { classroomId_studentId: { classroomId, studentId: uid } },
    });
    if (!member) throw new ForbiddenException('Not a member of this classroom');
    return cr;
  }

  @Get()
  async list(@Req() req: any) {
    const uid = this.uid(req);
    if (this.isTeacherOrAdmin(req)) {
      return this.prisma.classroom.findMany({
        where: { teacherId: uid },
        orderBy: { createdAt: 'desc' },
        select: { id: true, name: true, subject: true, createdAt: true, _count: { select: { members: true } } },
      });
    }
    const memberships = await this.prisma.classroomMember.findMany({
      where: { studentId: uid },
      select: { classroom: { select: { id: true, name: true, subject: true, teacherId: true, teacher: { select: { name: true } } } } },
      orderBy: { joinedAt: 'desc' },
    });
    return memberships.map((m) => m.classroom);
  }

  /** Aggregated materials across all classrooms the student is a member of,
   *  plus any TeacherMaterial that targets them directly. */
  @Get('all-materials')
  async allMaterials(@Req() req: any) {
    const uid = this.uid(req);

    // ClassroomMaterial from classrooms the student is a member of
    const memberships = await this.prisma.classroomMember.findMany({
      where: { studentId: uid },
      select: { classroomId: true, classroom: { select: { name: true, subject: true } } },
    });
    const classroomIds = memberships.map((m) => m.classroomId);
    const classroomNameMap = new Map(memberships.map((m) => [m.classroomId, m.classroom]));

    const [classroomMaterials, teacherMaterials] = await Promise.all([
      classroomIds.length
        ? this.prisma.classroomMaterial.findMany({
            where: { classroomId: { in: classroomIds } },
            orderBy: { createdAt: 'desc' },
          })
        : [],
      // TeacherMaterial targeting EVERYONE or this student's cohort/directly
      this.prisma.teacherMaterial.findMany({
        where: {
          published: true,
          OR: [
            { targetType: 'EVERYONE' },
            { targetStudentIds: { has: uid } },
          ],
        },
        orderBy: { createdAt: 'desc' },
        include: { teacher: { select: { name: true } } },
      }),
    ]);

    const items = [
      ...classroomMaterials.map((m) => ({
        ...m,
        _source: 'classroom',
        _classroomName: classroomNameMap.get(m.classroomId)?.name ?? null,
        _subject: classroomNameMap.get(m.classroomId)?.subject ?? null,
      })),
      ...teacherMaterials.map((m) => ({
        ...m,
        _source: 'teacher',
        _teacherName: (m as any).teacher?.name ?? null,
      })),
    ].sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());

    return { ok: true, items };
  }

  @Get(':id')
  async detail(@Req() req: any, @Param('id') id: string) {
    const cr = await this.assertAccess(req, id);
    const slotIds = (await this.prisma.scheduleSlotCohort.findMany({ select: { slotId: true }, where: {} })).map(() => ''); // placeholder
    return { ...cr, announcements: [] };
  }

  @Get(':id/people')
  async people(@Req() req: any, @Param('id') id: string) {
    await this.assertAccess(req, id);
    const [classroom, members] = await Promise.all([
      this.prisma.classroom.findUnique({
        where: { id },
        select: { teacherId: true, teacher: { select: { id: true, name: true } } },
      }),
      this.prisma.classroomMember.findMany({
        where: { classroomId: id },
        select: { studentId: true, student: { select: { name: true } } },
        orderBy: { joinedAt: 'asc' },
      }),
    ]);
    const teacher = classroom?.teacher ?? null;
    return {
      ok: true,
      items: {
        teacher: teacher ? { id: teacher.id, name: teacher.name } : null,
        teacherUserId: classroom?.teacherId ?? null,
        students: members.map((m) => ({ id: m.studentId, name: m.student?.name ?? null })),
        studentUserIds: members.map((m) => m.studentId),
      },
    };
  }

  @Get(':id/chat')
  async chatList(@Req() req: any, @Param('id') id: string, @Query('cursor') cursor?: string, @Query('limit') limit?: string) {
    await this.assertAccess(req, id);
    const take = Math.min(Math.max(parseInt(limit ?? '30', 10) || 30, 1), 100);
    const rows = await this.prisma.classroomMessage.findMany({
      where: { classroomId: id },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take: take + 1,
      ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
      select: { id: true, classroomId: true, senderUserId: true, kind: true, text: true, mediaUrl: true, mediaMime: true, durationSec: true, createdAt: true },
    });
    const hasMore = rows.length > take;
    const uid = this.uid(req);
    const items = rows.slice(0, take).reverse().map((row) => ({ ...row, isMine: row.senderUserId === uid }));
    return { ok: true, items, nextCursor: hasMore ? (rows[take - 1]?.id ?? null) : null };
  }

  @Post(':id/chat/text')
  async chatSendText(@Req() req: any, @Param('id') id: string, @Body() body: { text?: string }) {
    const uid = this.uid(req);
    const text = String(body?.text ?? '').trim();
    if (!text) throw new BadRequestException('Missing text');
    await this.assertAccess(req, id);
    const msg = await this.prisma.classroomMessage.create({
      data: { classroomId: id, senderUserId: uid, kind: 'TEXT', text },
      select: { id: true, classroomId: true, senderUserId: true, kind: true, text: true, mediaUrl: true, mediaMime: true, durationSec: true, createdAt: true },
    });
    // Push real-time event to all classroom members (excluding sender)
    this._emitClassroomMessage(id, uid);
    return { ok: true, item: msg };
  }

  private async _emitClassroomMessage(classroomId: string, senderUserId: string) {
    try {
      const members = await this.prisma.classroomMember.findMany({
        where: { classroomId, studentId: { not: senderUserId } },
        select: { studentId: true },
      });
      const teacher = await this.prisma.classroom.findUnique({
        where: { id: classroomId },
        select: { teacherId: true },
      });
      const targets = members.map((m) => m.studentId);
      if (teacher?.teacherId && teacher.teacherId !== senderUserId) targets.push(teacher.teacherId);
      this.realtime.emitToUsers(targets, { type: 'classroom_message', classroomId });
    } catch (_) {}
  }

  @Post(':id/chat/forward')
  async chatForward(@Req() req: any, @Param('id') id: string, @Body() body: { messageId?: string; targetThreadIds?: string[] }) {
    await this.assertAccess(req, id);
    const uid = this.uid(req);
    const messageId = String(body?.messageId ?? '').trim();
    const targetThreadIds = Array.from(new Set((Array.isArray(body?.targetThreadIds) ? body.targetThreadIds : []).map((v) => String(v ?? '').trim()).filter((v) => v.length > 0)));
    if (!uid || !messageId || !targetThreadIds.length) throw new BadRequestException('Missing required fields');

    const source = await this.prisma.classroomMessage.findFirst({
      where: { id: messageId, classroomId: id },
      select: { id: true, kind: true, text: true, mediaUrl: true, mediaMime: true, durationSec: true },
    });
    if (!source) throw new BadRequestException('Message not found');

    for (const targetId of targetThreadIds) {
      const sourceKind = String(source.kind ?? 'TEXT').toUpperCase();
      const sourceText = String(source.text ?? '').trim();
      const sourceDuration = Number.isFinite(Number(source.durationSec)) && Number(source.durationSec) > 0 ? Number(source.durationSec) : 0;
      const forwardedText = sourceKind === 'VOICE' ? (sourceText || `[VOICE] Voice message [duration:${sourceDuration}]`) : (sourceText || null);

      const dmParticipant = await this.prisma.dmParticipant.findUnique({ where: { threadId_userId: { threadId: targetId, userId: uid } } });
      if (dmParticipant) {
        if (String(dmParticipant.state) !== 'ACCEPTED') continue;
        await this.prisma.dmMessage.create({ data: { threadId: targetId, senderId: uid, kind: sourceKind as any, text: forwardedText != null ? `Forwarded\n${forwardedText}` : 'Forwarded', mediaUrl: source.mediaUrl ?? null, mediaMimeType: String(source.mediaMime ?? '') || null, forwardedFromId: null } });
        // Bubble the thread to the top of the inbox + mark the sender as
        // having seen their own message. Without this the inbox query
        // (which orders by thread.updatedAt) didn't refresh — receivers
        // could miss the new message until something else touched the row.
        await this.prisma.dmThread.update({ where: { id: targetId }, data: { updatedAt: new Date() } });
        await this.prisma.dmParticipant.update({
          where: { threadId_userId: { threadId: targetId, userId: uid } },
          data: { lastSeenAt: new Date() },
        });
        // Push to OTHER participants over realtime so their inbox + open
        // thread refresh instantly, same as a normal DM send.
        try {
          const others = await this.prisma.dmParticipant.findMany({
            where: { threadId: targetId, userId: { not: uid } },
            select: { userId: true },
          });
          this.realtime.emitToUsers(
            others.map((p) => p.userId),
            { type: 'dm_message', threadId: targetId },
          );
        } catch (_) {}
      } else {
        const targetCr = await this.prisma.classroom.findUnique({ where: { id: targetId }, select: { id: true } });
        if (!targetCr) continue;
        await this.prisma.classroomMessage.create({ data: { classroomId: targetId, senderUserId: uid, kind: sourceKind as any, text: forwardedText != null ? `Forwarded\n${forwardedText}` : 'Forwarded', mediaUrl: source.mediaUrl ?? null, mediaMime: String(source.mediaMime ?? '') || null, durationSec: sourceDuration > 0 ? sourceDuration : null } });
        // Realtime fanout to classroom members so the target classroom's
        // open chat view refreshes instantly. Same pattern as a normal
        // classroom send (line 213-216 above).
        try {
          const members = await this.prisma.classroomMember.findMany({
            where: { classroomId: targetId, studentId: { not: uid } },
            select: { studentId: true },
          });
          this.realtime.emitToUsers(
            members.map((m) => m.studentId),
            { type: 'classroom_message', classroomId: targetId },
          );
        } catch (_) {}
      }
    }
    return { ok: true, forwardedCount: targetThreadIds.length };
  }

  @Post(':id/chat/media')
  @UseInterceptors(FileInterceptor('file', { storage: diskStorage({ destination: (_req, _file, cb) => { ensureClassroomUploadsDir(); cb(null, 'uploads/classrooms'); }, filename: (_req, file, cb) => { const stamp = `${Date.now()}-${Math.round(Math.random() * 1e9)}`; const base = safeClassroomName(file?.originalname || 'upload'); const ext = extname(base); const stem = ext ? base.slice(0, -ext.length) : base; cb(null, `${stem}-${stamp}${ext}`); } }), limits: { fileSize: 40 * 1024 * 1024 } }))
  async chatSendMedia(@Req() req: any, @Param('id') id: string, @UploadedFile() file: any, @Body() body: { kind?: string; mediaUrl?: string; mediaMime?: string; durationSec?: number; text?: string; originalName?: string }) {
    await this.assertAccess(req, id);
    const uid = this.uid(req);
    const inferredMime = String(body?.mediaMime ?? file?.mimetype ?? '').trim();
    let kind = String(body?.kind ?? '').trim().toUpperCase();
    if (!kind) { const mime = inferredMime.toLowerCase(); kind = mime.startsWith('image/') ? 'IMAGE' : mime.startsWith('audio/') ? 'VOICE' : mime.startsWith('video/') ? 'VIDEO' : 'FILE'; }
    if (!['VOICE', 'IMAGE', 'VIDEO', 'FILE'].includes(kind)) throw new BadRequestException('Invalid kind');
    const mediaUrl = String(body?.mediaUrl ?? (file?.filename ? `/uploads/classrooms/${file.filename}` : '')).trim();
    if (!mediaUrl) throw new BadRequestException('Missing mediaUrl');
    const originalName = String(body?.originalName ?? file?.originalname ?? file?.filename ?? '').trim();
    const rawText = String(body?.text ?? '').trim();
    const fallbackText = rawText || (kind === 'IMAGE' ? `[IMAGE] ${originalName || 'image'}` : kind === 'VOICE' ? `[VOICE] ${originalName || 'voice'}` : `[FILE] ${originalName || 'file'}`);
    const durationNum = Number(body?.durationSec ?? 0);
    const persistedKind = kind === 'FILE' ? 'DOC' : kind;
    const msg = await this.prisma.classroomMessage.create({
      data: { classroomId: id, senderUserId: uid, kind: persistedKind as any, text: fallbackText, mediaUrl, mediaMime: inferredMime || null, durationSec: Number.isFinite(durationNum) && durationNum > 0 ? durationNum : null },
      select: { id: true, classroomId: true, senderUserId: true, kind: true, text: true, mediaUrl: true, mediaMime: true, durationSec: true, createdAt: true },
    });
    this._emitClassroomMessage(id, uid);
    return { ok: true, item: msg };
  }

  @Get(':id/assignments')
  async assignments(@Req() req: any, @Param('id') id: string) {
    await this.assertAccess(req, id);
    const items = await this.prisma.classroomAssignment.findMany({
      where: { classroomId: id },
      orderBy: [{ dueAt: 'asc' }, { createdAt: 'desc' }],
      select: { id: true, title: true, body: true, dueAt: true, attachments: true, createdBy: true, createdAt: true, updatedAt: true } as any,
    });
    return { ok: true, items };
  }

  @Post(':id/assignments/:assignmentId/submit')
  async submitAssignment(@Req() req: any, @Param('id') id: string, @Param('assignmentId') assignmentId: string, @Body() body: any) {
    await this.assertAccess(req, id);
    const studentId = this.uid(req);
    if (!studentId) throw new BadRequestException('Missing student identity');
    const note = body?.note ? String(body.note).trim().slice(0, 4000) : null;
    const files = Array.isArray(body?.files) ? body.files : [];
    const submission = await this.prisma.assignmentSubmission.upsert({
      where: { assignmentId_studentId: { assignmentId, studentId } },
      update: { note, files, updatedAt: new Date() } as any,
      create: { assignmentId, studentId, note, files } as any,
      select: { id: true, assignmentId: true, studentId: true, submittedAt: true, note: true, files: true } as any,
    });
    // Notify teacher in real-time about new submission
    try {
      const cr = await this.prisma.classroom.findUnique({ where: { id }, select: { teacherId: true } });
      if (cr?.teacherId) this.realtime.emitToUser(cr.teacherId, { type: 'assignment_created', classroomId: id });
    } catch {}
    return { ok: true, submission };
  }

  @Get(':id/materials')
  async materials(@Req() req: any, @Param('id') id: string) {
    await this.assertAccess(req, id);
    const items = await this.prisma.classroomMaterial.findMany({
      where: { classroomId: id },
      orderBy: [{ createdAt: 'desc' }],
      select: { id: true, title: true, description: true, url: true, mime: true, attachments: true, createdBy: true, createdAt: true, updatedAt: true },
    });
    return { ok: true, items };
  }

  @Get(':id/meetings')
  async meetings(@Req() req: any, @Param('id') id: string) {
    await this.assertAccess(req, id);
    const items = await this.prisma.classroomMeeting.findMany({
      where: { classroomId: id },
      orderBy: [{ startsAt: 'asc' }],
      select: { id: true, title: true, link: true, startsAt: true, endsAt: true, createdBy: true, createdAt: true, updatedAt: true },
    });
    return { ok: true, items };
  }

  @Get(':id/announcements')
  async announcements(@Req() req: any, @Param('id') id: string) {
    await this.assertAccess(req, id);
    return { ok: true, items: [] };
  }

  @Post(':id/leave')
  async leaveClassroom(@Req() req: any, @Param('id') id: string) {
    const studentId = this.uid(req);
    if (!studentId) throw new BadRequestException('Missing student identity');
    await this.prisma.classroomMember.deleteMany({ where: { classroomId: id, studentId } });
    return { ok: true };
  }
}
