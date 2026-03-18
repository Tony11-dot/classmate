import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateDmThreadDto } from './dto/create-thread.dto';
import { RespondDmRequestDto } from './dto/respond-request.dto';
import { SendDmMessageDto } from './dto/send-message.dto';
import { ReactDmMessageDto } from './dto/react-message.dto';

@Injectable()
export class DmService {
  constructor(private readonly prisma: PrismaService) {}

  private userIdOf(user: any): string {
    return String(user?.sub ?? user?.id ?? user?.userId ?? '');
  }

  private async requireParticipant(threadId: string, userId: string) {
    const p = await this.prisma.dmParticipant.findUnique({
      where: { threadId_userId: { threadId, userId } },
    });
    if (!p) throw new ForbiddenException('Not in thread');
    return p;
  }

  private async canChat(threadId: string) {
    const parts = await this.prisma.dmParticipant.findMany({ where: { threadId } });
    return parts.every((p) => p.state === 'ACCEPTED');
  }

  private messageExpiry(mode?: 'ONCE' | 'REPLAY' | 'KEEP') {
    if (mode === 'ONCE') return { viewLimit: 1, replayLimit: 0 };
    if (mode === 'REPLAY') return { viewLimit: 999999, replayLimit: 2 };
    return { viewLimit: null, replayLimit: null };
  }

  async listThreads(user: any) {
    const userId = this.userIdOf(user);
    const mine = await this.prisma.dmParticipant.findMany({
      where: { userId },
      include: {
        thread: {
          include: {
            participants: true,
            messages: {
              orderBy: { createdAt: 'desc' },
              take: 1,
            },
          },
        },
      },
      orderBy: { updatedAt: 'desc' },
    });

    return {
      ok: true,
      items: mine.map((p) => {
        const thread = p.thread;
        const others = thread.participants.filter((x) => x.userId !== userId);
        const other = others[0];
        const latest = thread.messages[0];
        return {
          id: thread.id,
          isGroup: thread.type === 'GROUP',
          title: thread.type === 'GROUP' ? (thread.title ?? 'Group') : (other ? `User ${other.userId.slice(0, 6)}` : 'DM'),
          subtitle: latest?.text ?? (latest?.kind === 'IMAGE' ? 'Photo' : latest?.kind === 'VOICE' ? 'Voice message' : 'No messages yet'),
          updatedAt: thread.updatedAt,
          unreadCount: 0,
          requestState: p.state,
          isBlocked: p.state === 'BLOCKED',
          participants: thread.participants.map((x) => ({
            userId: x.userId,
            state: x.state,
            role: x.role,
          })),
        };
      }),
    };
  }

  async createThread(user: any, dto: CreateDmThreadDto) {
    const userId = this.userIdOf(user);
    const ids = Array.from(new Set((dto.participantIds ?? []).map(String).filter(Boolean)));

    if (!ids.length) throw new BadRequestException('participantIds required');

    const isGroup = dto.isGroup === true || ids.length > 1;

    if (!isGroup && ids.length !== 1) {
      throw new BadRequestException('direct threads require exactly one target');
    }

    if (!isGroup) {
      const targetId = ids[0];
      const existing = await this.prisma.dmThread.findFirst({
        where: {
          type: 'DIRECT',
          participants: {
            every: {
              userId: { in: [userId, targetId] },
            },
          },
        },
        include: { participants: true },
      });

      if (existing && existing.participants.length === 2) {
        return { ok: true, threadId: existing.id, reused: true };
      }
    }

    const thread = await this.prisma.dmThread.create({
      data: {
        type: isGroup ? 'GROUP' : 'DIRECT',
        title: isGroup ? (dto.title?.trim() || 'New group') : null,
        createdById: userId,
        participants: {
          create: [
            {
              userId,
              role: 'ADMIN',
              state: 'ACCEPTED',
            },
            ...ids.map((id) => ({
              userId: id,
              role: 'MEMBER',
              state: isGroup ? 'ACCEPTED' : 'PENDING_INCOMING',
            })),
          ],
        },
      },
    });

    if (!isGroup) {
      await this.prisma.dmParticipant.update({
        where: { threadId_userId: { threadId: thread.id, userId } },
        data: { state: 'PENDING_OUTGOING' },
      });
    }

    return { ok: true, threadId: thread.id };
  }

  async respondToRequest(user: any, threadId: string, dto: RespondDmRequestDto) {
    const userId = this.userIdOf(user);
    const me = await this.requireParticipant(threadId, userId);

    if (me.state !== 'PENDING_INCOMING' && me.state !== 'BLOCKED') {
      throw new BadRequestException('No actionable request');
    }

    if (dto.action === 'block') {
      await this.prisma.dmParticipant.update({
        where: { threadId_userId: { threadId, userId } },
        data: { state: 'BLOCKED' },
      });
      return { ok: true, state: 'BLOCKED' };
    }

    await this.prisma.dmParticipant.updateMany({
      where: { threadId },
      data: { state: 'ACCEPTED' },
    });

    return { ok: true, state: 'ACCEPTED' };
  }

  async unblock(user: any, threadId: string) {
    const userId = this.userIdOf(user);
    const me = await this.requireParticipant(threadId, userId);

    if (me.state !== 'BLOCKED') {
      throw new BadRequestException('Thread is not blocked');
    }

    await this.prisma.dmParticipant.update({
      where: { threadId_userId: { threadId, userId } },
      data: { state: 'PENDING_INCOMING' },
    });

    return { ok: true, state: 'PENDING_INCOMING' };
  }

  async listMessages(user: any, threadId: string) {
    const userId = this.userIdOf(user);
    await this.requireParticipant(threadId, userId);

    const rows = await this.prisma.dmMessage.findMany({
      where: { threadId },
      include: { reactions: true, views: true },
      orderBy: { createdAt: 'asc' },
    });

    const items = rows
      .filter((m) => {
        if (!m.mediaMode || m.mediaMode === 'KEEP') return true;
        const view = m.views.find((v) => v.viewerId === userId);
        if (!view) return true;
        if (m.mediaMode === 'ONCE') return false;
        if (m.mediaMode === 'REPLAY') return view.replayCount <= (m.replayLimit ?? 0);
        return true;
      })
      .map((m) => ({
        id: m.id,
        senderId: m.senderId,
        kind: m.kind,
        text: m.text ?? '',
        mediaUrl: m.mediaUrl,
        mediaMimeType: m.mediaMimeType,
        mediaMode: m.mediaMode,
        voiceDuration: null,
        createdAt: m.createdAt,
        mine: m.senderId === userId,
        reactions: m.reactions.map((r) => r.emoji),
      }));

    return { ok: true, items };
  }

  async sendMessage(user: any, threadId: string, dto: SendDmMessageDto) {
    const userId = this.userIdOf(user);
    const me = await this.requireParticipant(threadId, userId);

    if (me.state === 'BLOCKED') throw new ForbiddenException('Blocked thread');
    if (!(await this.canChat(threadId))) {
      throw new ForbiddenException('Request not accepted yet');
    }

    if (dto.kind === 'TEXT' && !(dto.text ?? '').trim()) {
      throw new BadRequestException('text required');
    }
    if ((dto.kind === 'IMAGE' || dto.kind === 'VOICE') && !(dto.mediaUrl ?? '').trim()) {
      throw new BadRequestException('mediaUrl required');
    }

    const limits = this.messageExpiry(dto.mediaMode);

    const msg = await this.prisma.dmMessage.create({
      data: {
        threadId,
        senderId: userId,
        kind: dto.kind as any,
        text: dto.text?.trim() || null,
        mediaUrl: dto.mediaUrl?.trim() || null,
        mediaMimeType: dto.mediaMimeType?.trim() || null,
        mediaMode: (dto.mediaMode as any) ?? null,
        viewLimit: limits.viewLimit,
        replayLimit: limits.replayLimit,
      },
    });

    await this.prisma.dmThread.update({
      where: { id: threadId },
      data: { updatedAt: new Date() },
    });

    return { ok: true, messageId: msg.id };
  }

  async recordView(user: any, messageId: string) {
    const userId = this.userIdOf(user);
    const msg = await this.prisma.dmMessage.findUnique({
      where: { id: messageId },
      include: { thread: true },
    });
    if (!msg) throw new NotFoundException('Message not found');

    await this.requireParticipant(msg.threadId, userId);

    const existing = await this.prisma.dmMessageView.findUnique({
      where: { messageId_viewerId: { messageId, viewerId: userId } },
    });

    if (!existing) {
      await this.prisma.dmMessageView.create({
        data: {
          messageId,
          viewerId: userId,
          replayCount: 1,
        },
      });
    } else {
      await this.prisma.dmMessageView.update({
        where: { messageId_viewerId: { messageId, viewerId: userId } },
        data: { replayCount: { increment: 1 }, viewedAt: new Date() },
      });
    }

    return { ok: true };
  }

  async react(user: any, messageId: string, dto: ReactDmMessageDto) {
    const userId = this.userIdOf(user);
    const msg = await this.prisma.dmMessage.findUnique({ where: { id: messageId } });
    if (!msg) throw new NotFoundException('Message not found');

    await this.prisma.dmReaction.upsert({
      where: {
        messageId_userId_emoji: {
          messageId,
          userId,
          emoji: dto.emoji,
        },
      },
      update: {},
      create: {
        messageId,
        userId,
        emoji: dto.emoji,
      },
    });

    return { ok: true };
  }
}
