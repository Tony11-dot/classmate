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
import { SkipThrottle } from '@nestjs/throttler';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { PrismaService } from '../prisma/prisma.service';
import { RealtimeService } from '../realtime/realtime.service';
import { NotificationsHubService } from '../notifications/notifications-hub.service';
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
// Authenticated, high-frequency app traffic (chat polling, classroom list,
// meetings, join). Exempt from the global default throttle — it was tripping
// 429s during normal use ("cannot send", classrooms.list failed). Login stays
// strictly throttled in its own controller.
@SkipThrottle()
@Controller('student/classrooms')
export class StudentClassroomsController {
  constructor(
    private readonly prisma: PrismaService,
    private readonly realtime: RealtimeService,
    private readonly hub: NotificationsHubService,
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
   *  plus any TeacherMaterial that targets them directly, AND any material
   *  attached to a ScheduleSlot whose audience includes the student. */
  @Get('all-materials')
  async allMaterials(@Req() req: any) {
    const uid = this.uid(req);

    // Resolve the student's grade + cohorts so we can match audience scopes
    // beyond classroom membership (slot-level attachments + cohort-targeted
    // teacher materials).
    const [profile, studentCohorts, memberships] = await Promise.all([
      this.prisma.studentProfile.findUnique({
        where: { userId: uid },
        select: { grade: true },
      }),
      this.prisma.studentCohort.findMany({
        where: { studentId: uid },
        select: { cohortId: true },
      }),
      this.prisma.classroomMember.findMany({
        where: { studentId: uid },
        select: { classroomId: true, classroom: { select: { name: true, subject: true } } },
      }),
    ]);
    const grade = profile?.grade ?? null;
    const cohortIds = studentCohorts.map((c) => c.cohortId);
    const classroomIds = memberships.map((m) => m.classroomId);
    const classroomNameMap = new Map(memberships.map((m) => [m.classroomId, m.classroom]));

    // Slot-attached materials: find every slot whose audience matches this
    // student (direct studentId, one of their cohorts, or matching
    // audienceGrade), then pull the materials joined to those slots.
    const slotWhere: any = {
      OR: [
        { students: { some: { studentId: uid } } },
        ...(cohortIds.length ? [{ cohorts: { some: { cohortId: { in: cohortIds } } } }] : []),
        ...(grade != null ? [{ audienceGrade: grade }] : []),
      ],
    };
    const slotIds = (slotWhere.OR.length
      ? await this.prisma.scheduleSlot.findMany({ where: slotWhere, select: { id: true } })
      : []
    ).map((s) => s.id);

    const [classroomMaterials, teacherMaterials, slotMaterialRows] = await Promise.all([
      classroomIds.length
        ? this.prisma.classroomMaterial.findMany({
            where: { classroomId: { in: classroomIds } },
            orderBy: { createdAt: 'desc' },
          })
        : [],
      // TeacherMaterial targeting EVERYONE, this student directly, one
      // of their cohorts, or their grade.
      //
      // Use `not: false` instead of `equals: true` so legacy rows where
      // `published` was never explicitly set still surface — earlier
      // teacher screens occasionally created materials without the
      // boolean, leaving them invisible to students despite an
      // EVERYONE audience.
      this.prisma.teacherMaterial.findMany({
        where: {
          published: { not: false },
          OR: [
            // Gate the broadcast clause to records with NO narrower targeting, so a
            // grade-only item (stored as EVERYONE + targetGrades) no longer leaks
            // school-wide — it is matched by the targetGrades clause instead.
            { targetType: 'EVERYONE', targetCohortIds: { isEmpty: true }, targetStudentIds: { isEmpty: true }, targetGrades: { isEmpty: true } },
            { targetStudentIds: { has: uid } },
            ...(cohortIds.length ? [{ targetCohortIds: { hasSome: cohortIds } }] : []),
            ...(grade != null ? [{ targetGrades: { has: grade } }] : []),
          ],
        },
        orderBy: { createdAt: 'desc' },
        include: { teacher: { select: { name: true } } },
      }),
      slotIds.length
        ? this.prisma.scheduleSlotMaterial.findMany({
            where: { slotId: { in: slotIds } },
            include: {
              material: { include: { teacher: { select: { name: true } } } },
              slot: { select: { subject: true, period: true } },
            },
          })
        : [],
    ]);

    // Dedup teacher materials across direct-target and slot-cascade paths.
    const seenTeacherMaterialIds = new Set<string>();
    const teacherFromDirect = teacherMaterials.map((m) => {
      seenTeacherMaterialIds.add(m.id);
      return {
        ...m,
        _source: 'teacher',
        _teacherName: (m as any).teacher?.name ?? null,
      };
    });
    const teacherFromSlots = slotMaterialRows
      .filter((r: any) => r.material && !seenTeacherMaterialIds.has(r.material.id))
      .map((r: any) => {
        seenTeacherMaterialIds.add(r.material.id);
        return {
          ...r.material,
          _source: 'period',
          _teacherName: r.material.teacher?.name ?? null,
          _subject: r.material.subject ?? r.slot?.subject ?? null,
        };
      });

    const items = [
      // Drop classroom mirrors of a TeacherMaterial we're already showing from
      // the teacher-direct path. `createTeacherMaterial` writes both a
      // TeacherMaterial and a ClassroomMaterial mirror (back-ref
      // `teacherMaterialId`); without this filter the same material renders as
      // two identical cards.
      ...classroomMaterials
        .filter(
          (m: any) => !(m.teacherMaterialId && seenTeacherMaterialIds.has(m.teacherMaterialId)),
        )
        .map((m: any) => ({
          ...m,
          _source: 'classroom',
          _classroomName: classroomNameMap.get(m.classroomId)?.name ?? null,
          _subject: classroomNameMap.get(m.classroomId)?.subject ?? null,
        })),
      ...teacherFromDirect,
      ...teacherFromSlots,
    ].sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());

    return { ok: true, items };
  }

  /// Aggregated meetings across every classroom the student is in PLUS
  /// any TeacherMeeting whose audience targets them directly (EVERYONE,
  /// this student, one of their cohorts, or their grade). Mirrors the
  /// shape of `all-materials` so the mobile feed only needs one call.
  ///
  /// MUST be declared before the `:id` route below — otherwise Nest
  /// matches `/student/classrooms/all-meetings` against `:id` (id =
  /// "all-meetings") and 404s with "Classroom not found".
  @Get('all-meetings')
  async allMeetings(@Req() req: any) {
    const uid = this.uid(req);
    const [profile, studentCohorts, memberships] = await Promise.all([
      this.prisma.studentProfile.findUnique({
        where: { userId: uid },
        select: { grade: true, cohortId: true },
      }),
      this.prisma.studentCohort.findMany({
        where: { studentId: uid },
        select: { cohortId: true },
      }),
      this.prisma.classroomMember.findMany({
        where: { studentId: uid },
        select: { classroomId: true, classroom: { select: { name: true, subject: true } } },
      }),
    ]);
    const grade = profile?.grade ?? null;
    // Include BOTH the StudentCohort join-table rows AND the legacy
    // studentProfile.cohortId scalar. A student whose cohort was only ever
    // set via the scalar (older enrolment paths) would otherwise have an
    // empty cohort list here and miss every cohort-targeted meeting.
    const cohortIds = Array.from(
      new Set([
        ...studentCohorts.map((c) => c.cohortId),
        ...(profile?.cohortId ? [profile.cohortId] : []),
      ]),
    );
    const classroomIds = memberships.map((m) => m.classroomId);
    const classroomNameMap = new Map(memberships.map((m) => [m.classroomId, m.classroom]));

    const [classroomMeetings, teacherMeetings] = await Promise.all([
      classroomIds.length
        ? this.prisma.classroomMeeting.findMany({
            where: { classroomId: { in: classroomIds } },
            orderBy: [{ startsAt: 'asc' }],
          })
        : [],
      this.prisma.teacherMeeting.findMany({
        where: {
          OR: [
            // Gate the broadcast clause to records with NO narrower targeting, so a
            // grade-only item (stored as EVERYONE + targetGrades) no longer leaks
            // school-wide — it is matched by the targetGrades clause instead.
            { targetType: 'EVERYONE', targetCohortIds: { isEmpty: true }, targetStudentIds: { isEmpty: true }, targetGrades: { isEmpty: true } },
            { targetStudentIds: { has: uid } },
            ...(cohortIds.length ? [{ targetCohortIds: { hasSome: cohortIds } }] : []),
            ...(grade != null ? [{ targetGrades: { has: grade } }] : []),
          ],
        },
        orderBy: [{ startsAt: 'asc' }],
      }),
    ]);

    // Dedupe: a TeacherMeeting that already has a ClassroomMeeting mirror
    // should appear once, not twice. Mirror rows carry teacherMeetingId.
    const mirroredTeacherIds = new Set(
      (classroomMeetings as any[])
        .map((m) => m.teacherMeetingId)
        .filter((v): v is string => typeof v === 'string' && v.length > 0),
    );

    const items = [
      ...classroomMeetings.map((m) => ({
        ...m,
        _source: 'classroom',
        classroomName: classroomNameMap.get(m.classroomId)?.name ?? null,
        classroomSubject: classroomNameMap.get(m.classroomId)?.subject ?? null,
      })),
      ...teacherMeetings
        .filter((tm) => !mirroredTeacherIds.has(tm.id))
        .map((tm) => ({
          ...tm,
          _source: 'teacher',
          classroomName: null,
          classroomSubject: tm.subject ?? null,
        })),
    ].sort((a, b) => {
      const da = (a as any).startsAt ? new Date((a as any).startsAt).getTime() : 0;
      const db = (b as any).startsAt ? new Date((b as any).startsAt).getTime() : 0;
      return da - db;
    });

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
      // Reply fields included so the client can render the "↪ X said …"
      // preview AND tap-to-jump to the replied-to message. Previously
      // only basic fields were selected so classroom replies vanished
      // on every refresh — DMs already returned these so the bug was
      // classroom-specific.
      select: {
        id: true,
        classroomId: true,
        senderUserId: true,
        kind: true,
        text: true,
        mediaUrl: true,
        mediaMime: true,
        durationSec: true,
        createdAt: true,
        replyToMessageId: true,
        replyToSenderName: true,
        replyToText: true,
      } as any,
    });
    const hasMore = rows.length > take;
    const uid = this.uid(req);
    // Resolve sender names server-side. The client used to look them up via
    // the classroom roster, which broke for senders who had left the
    // classroom — their name fell through to "Unknown" even though the
    // User row still exists. Stamp the name on every row from a single
    // batch user fetch.
    const senderNames = await this.resolveSenderNames(rows.map((r) => r.senderUserId));
    const items = rows.slice(0, take).reverse().map((row) => ({
      ...row,
      isMine: row.senderUserId === uid,
      senderName: senderNames.get(row.senderUserId) ?? null,
    }));
    return { ok: true, items, nextCursor: hasMore ? (rows[take - 1]?.id ?? null) : null };
  }

  /// Batch lookup of display-friendly names for a set of user ids, from
  /// `name` (the single full-name source of truth).
  private async resolveSenderNames(ids: string[]): Promise<Map<string, string>> {
    const uniq = Array.from(new Set(ids.filter((v) => typeof v === 'string' && v.length > 0)));
    if (uniq.length === 0) return new Map();
    const users = await this.prisma.user.findMany({
      where: { id: { in: uniq } },
      select: { id: true, name: true } as any,
    });
    const out = new Map<string, string>();
    for (const u of users as any[]) {
      const v = String(u.name ?? '').trim();
      if (v) out.set(u.id, v);
    }
    return out;
  }

  @Post(':id/chat/text')
  async chatSendText(@Req() req: any, @Param('id') id: string, @Body() body: { text?: string; replyToMessageId?: string }) {
    const uid = this.uid(req);
    const text = String(body?.text ?? '').trim();
    if (!text) throw new BadRequestException('Missing text');
    await this.assertAccess(req, id);
    const reply = await this._resolveReplySnapshot(id, body?.replyToMessageId);
    const msg = await this.prisma.classroomMessage.create({
      data: {
        classroomId: id,
        senderUserId: uid,
        kind: 'TEXT',
        text,
        ...(reply ? {
          replyToMessageId: reply.id,
          replyToSenderName: reply.senderName,
          replyToText: reply.snippet,
        } : {}),
      } as any,
      select: {
        id: true, classroomId: true, senderUserId: true, kind: true,
        text: true, mediaUrl: true, mediaMime: true, durationSec: true,
        createdAt: true,
        replyToMessageId: true, replyToSenderName: true, replyToText: true,
      } as any,
    });
    this._emitClassroomMessage(id, uid);
    return { ok: true, item: msg };
  }

  /// Looks up the message being replied to and produces a snapshot
  /// (sender display name + short text preview) that gets denormalised
  /// onto the new message so the reply preview can render without
  /// joining back across the chat history. Returns null if the
  /// replyTarget id is missing, not in this classroom, or unreadable.
  private async _resolveReplySnapshot(
    classroomId: string,
    replyToMessageId: unknown,
  ): Promise<{ id: string; senderName: string; snippet: string } | null> {
    const id = String(replyToMessageId ?? '').trim();
    if (!id) return null;
    try {
      const parent = await this.prisma.classroomMessage.findFirst({
        where: { id, classroomId },
        select: { id: true, senderUserId: true, text: true, kind: true, durationSec: true },
      });
      if (!parent) return null;
      const senderNames = await this.resolveSenderNames([parent.senderUserId]);
      const senderName = senderNames.get(parent.senderUserId) ?? 'Someone';
      // Media replies must quote the TYPE, not the raw filename/URL. Emit the
      // same wire markers the client formats into "🎤 Voice message" / "🖼️
      // Photo" / "📎 File". Text messages quote their text.
      const kind = String(parent.kind ?? 'TEXT').toUpperCase();
      let snippet: string;
      if (kind === 'VOICE') {
        const d = Number(parent.durationSec ?? 0);
        snippet = d > 0 ? `[VOICE] [duration:${d}]` : '[VOICE]';
      } else if (kind === 'IMAGE') {
        snippet = '[IMAGE]';
      } else if (kind === 'FILE') {
        const name = (parent.text ?? '').trim();
        snippet = name ? `[FILE] ${name}` : '[FILE]';
      } else {
        const raw = (parent.text ?? '').trim();
        snippet = raw.length > 120 ? `${raw.slice(0, 120)}…` : raw;
      }
      return { id: parent.id, senderName, snippet };
    } catch {
      return null;
    }
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
  @UseInterceptors(FileInterceptor('file', { storage: diskStorage({ destination: (_req, _file, cb) => { ensureClassroomUploadsDir(); cb(null, 'uploads/classrooms'); }, filename: (_req, file, cb) => { const stamp = `${Date.now()}-${Math.round(Math.random() * 1e9)}`; const base = safeClassroomName(file?.originalname || 'upload'); const ext = extname(base); const stem = ext ? base.slice(0, -ext.length) : base; cb(null, `${stem}-${stamp}${ext}`); } }), limits: { fileSize: 150 * 1024 * 1024 } }))
  async chatSendMedia(@Req() req: any, @Param('id') id: string, @UploadedFile() file: any, @Body() body: { kind?: string; mediaUrl?: string; mediaMime?: string; durationSec?: number; text?: string; originalName?: string; replyToMessageId?: string }) {
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
    const reply = await this._resolveReplySnapshot(id, body?.replyToMessageId);
    const msg = await this.prisma.classroomMessage.create({
      data: {
        classroomId: id, senderUserId: uid, kind: persistedKind as any,
        text: fallbackText, mediaUrl, mediaMime: inferredMime || null,
        durationSec: Number.isFinite(durationNum) && durationNum > 0 ? durationNum : null,
        ...(reply ? {
          replyToMessageId: reply.id,
          replyToSenderName: reply.senderName,
          replyToText: reply.snippet,
        } : {}),
      } as any,
      select: {
        id: true, classroomId: true, senderUserId: true, kind: true,
        text: true, mediaUrl: true, mediaMime: true, durationSec: true,
        createdAt: true,
        replyToMessageId: true, replyToSenderName: true, replyToText: true,
      } as any,
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

  /// Joins one or more classrooms via a cohort code.  The code is generated
  /// by the teacher/admin against a Cohort (CohortJoinCode in the schema —
  /// classrooms don't carry their own codes today).  Matching the code:
  ///   1. Adds the student to the cohort (StudentCohort + legacy
  ///      studentProfile.cohortId scalar if still null).
  ///   2. Adds them as a ClassroomMember of every Classroom whose teacher's
  ///      slots target that cohort, so the cohort's classrooms appear in
  ///      the student's list immediately.
  /// Codes are single-use: the matching CohortJoinCode is deactivated.
  @Post('join')
  async joinByCode(@Req() req: any, @Body() body: { code?: string }) {
    const studentId = this.uid(req);
    if (!studentId) throw new BadRequestException('Missing student identity');
    const code = String(body?.code ?? '').trim();
    if (!code) throw new BadRequestException('Code is required');

    const now = new Date();
    // Iterate every active code across the platform. Was capped at 50
    // — a school with more than 50 active cohort codes (every cohort
    // gets one) silently 404'd codes that were valid on the teacher's
    // side. 2000 covers a multi-school deployment with room to spare;
    // matching is O(n) bcrypt compares so we want a sensible ceiling
    // either way.
    const candidates = await this.prisma.cohortJoinCode.findMany({
      where: {
        active: true,
        OR: [{ expiresAt: null }, { expiresAt: { gt: now } }],
      },
      orderBy: { createdAt: 'desc' },
      take: 2000,
    });
    // Normalise the supplied code: strip all whitespace so a paste with
    // newlines / NBSPs / hidden chars still matches. The code itself is
    // digits-only so this is safe.
    const normalisedCode = code.replace(/\s+/g, '');
    let matchedId: string | null = null;
    let matchedCohortId: string | null = null;
    for (const c of candidates) {
      if (c.expiresAt && c.expiresAt < now) continue;
      if (await bcrypt.compare(normalisedCode, c.codeHash)) {
        matchedId = c.id;
        matchedCohortId = c.cohortId;
        break;
      }
    }
    if (!matchedId || !matchedCohortId) {
      // ── Fallback: classroom join code ────────────────────────────────
      // Classrooms carry their own unique `joinCode` (shown on the teacher's
      // People screen). Match it directly — case-insensitive, whitespace
      // already stripped. This is a single unique lookup, so no collisions.
      const wanted = normalisedCode.toUpperCase();
      const hit = await this.prisma.classroom.findUnique({
        where: { joinCode: wanted },
        select: { id: true, name: true },
      });
      if (!hit) {
        throw new BadRequestException('Invalid or expired code');
      }

      await this.prisma.classroomMember.upsert({
        where: { classroomId_studentId: { classroomId: hit.id, studentId } },
        update: {},
        create: { classroomId: hit.id, studentId },
      });

      // Pull the student into any cohort this classroom's schedule targets,
      // so cohort/grade-scoped meetings, announcements and assignments also
      // surface for them.
      const slotCohorts = await this.prisma.scheduleSlotCohort.findMany({
        where: { slot: { classroomId: hit.id } },
        select: { cohortId: true },
      });
      const cohortIds = Array.from(
        new Set(slotCohorts.map((s) => s.cohortId).filter(Boolean)),
      );
      for (const cohortId of cohortIds) {
        await this.prisma.studentCohort.upsert({
          where: { studentId_cohortId: { studentId, cohortId } },
          update: {},
          create: { studentId, cohortId },
        });
      }

      try {
        await this.hub.notify({
          recipientUserIds: [studentId],
          type: 'CLASSROOM_INVITE',
          title: `Joined ${hit.name}`,
          body: hit.name,
          data: { classroomIds: [hit.id] },
        });
      } catch (e) {
        console.error('[student] classroom-code join notify failed:', e);
      }

      return { ok: true, classroomIds: [hit.id], cohortIds };
    }

    // Single-use: deactivate the matched code.  updateMany returns 0 if a
    // concurrent request already won the race.
    const deactivated = await this.prisma.cohortJoinCode.updateMany({
      where: { id: matchedId, active: true },
      data: { active: false },
    });
    if (deactivated.count !== 1) throw new BadRequestException('Invalid or expired code');

    // Cohort membership — both the new join table (multi-cohort) and the
    // legacy scalar (only when unset, so we don't clobber a primary).
    await this.prisma.studentCohort.upsert({
      where: { studentId_cohortId: { studentId, cohortId: matchedCohortId } },
      update: {},
      create: { studentId, cohortId: matchedCohortId },
    });
    const profile = await this.prisma.studentProfile.findUnique({
      where: { userId: studentId },
      select: { cohortId: true },
    });
    if (!profile) {
      await this.prisma.studentProfile.create({
        data: { userId: studentId, cohortId: matchedCohortId },
      });
    } else if (!profile.cohortId) {
      await this.prisma.studentProfile.update({
        where: { userId: studentId },
        data: { cohortId: matchedCohortId },
      });
    }

    // Auto-add to any classroom whose teacher's slots target this cohort.
    const slotCohorts = await this.prisma.scheduleSlotCohort.findMany({
      where: { cohortId: matchedCohortId },
      select: { slot: { select: { classroomId: true } } },
    });
    const classroomIds = Array.from(new Set(
      slotCohorts
        .map((sc: any) => sc.slot?.classroomId)
        .filter((id: any): id is string => typeof id === 'string' && id.length > 0),
    ));
    if (classroomIds.length) {
      await this.prisma.classroomMember.createMany({
        data: classroomIds.map((classroomId) => ({ classroomId, studentId })),
        skipDuplicates: true,
      });
      // Student already knows they joined (they triggered it), but
      // their parents likely don't. The hub's fanOutToParents path
      // covers this: a `CLASSROOM_INVITE` notification with the
      // student as direct recipient also creates a ParentNotification
      // for each linked parent.
      try {
        const classrooms = await this.prisma.classroom.findMany({
          where: { id: { in: classroomIds } },
          select: { name: true },
        });
        const names = classrooms.map((c) => c.name).filter(Boolean);
        await this.hub.notify({
          recipientUserIds: [studentId],
          type: 'CLASSROOM_INVITE',
          title: names.length === 1
            ? `Joined ${names[0]}`
            : `Joined ${names.length} classes`,
          body: names.join(', ').slice(0, 200),
          data: { cohortId: matchedCohortId, classroomIds },
        });
      } catch (e) { console.error('[student] join notify failed:', e); }
    }

    return { ok: true, cohortId: matchedCohortId, classroomIds };
  }
}
