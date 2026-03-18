import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  DmMediaMode,
  DmMessageKind,
  DmParticipantRole,
  DmParticipantState,
  DmThreadType,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateDmThreadDto } from './dto/create-thread.dto';
import { ReactDmMessageDto } from './dto/react-message.dto';
import { RespondDmRequestDto } from './dto/respond-request.dto';
import { SendDmMessageDto } from './dto/send-message.dto';

@Injectable()
export class DmService {
  constructor(private readonly prisma: PrismaService) {}

  private userIdOf(user: any): string {
    return String(user?.sub ?? user?.id ?? user?.userId ?? '').trim();
  }

  private displayNameFromUserId(userId: string): string {
    const raw = String(userId || 'student').trim();
    const base = raw.includes('@') ? raw.split('@')[0] : raw;
    return base
      .split(/[._-]/g)
      .filter(Boolean)
      .map((x) => x.charAt(0).toUpperCase() + x.slice(1))
      .join(' ') || 'Student';
  }

  private avatarTextFromName(name: string): string {
    const parts = name
      .trim()
      .split(/\s+/)
      .filter(Boolean);
    if (parts.length === 0) return 'ST';
    if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
    return `${parts[0][0] ?? ''}${parts[parts.length - 1][0] ?? ''}`.toUpperCase();
  }

  private handleFromUserId(userId: string): string {
    const raw = String(userId || 'student').trim();
    const base = raw.includes('@') ? raw.split('@')[0] : raw;
    return `@${base.replace(/\s+/g, '').toLowerCase() || 'student'}`;
  }

  private async requireParticipant(threadId: string, userId: string) {
    const participant = await this.prisma.dmParticipant.findUnique({
      where: { threadId_userId: { threadId, userId } },
      include: {
        thread: {
          include: {
            participants: true,
          },
        },
      },
    });

    if (!participant) {
      throw new ForbiddenException('Not a participant in this thread');
    }

    return participant;
  }

  private async canChat(threadId: string) {
    const parts = await this.prisma.dmParticipant.findMany({
      where: { threadId },
      select: { state: true },
    });

    if (parts.length === 0) return false;
    if (parts.some((p) => p.state === DmParticipantState.BLOCKED)) return false;

    return parts.every((p) => p.state === DmParticipantState.ACCEPTED);
  }

  async listThreads(user: any) {
    const userId = this.userIdOf(user);

    const parts = await this.prisma.dmParticipant.findMany({
      where: { userId },
      include: {
        thread: {
          include: {
            participants: true,
            messages: {
              orderBy: { createdAt: 'desc' },
              take: 1,
              include: {
                reactions: true,
              },
            },
          },
        },
      },
      orderBy: {
        thread: {
          updatedAt: 'desc',
        },
      },
    });

    return parts.map((p) => {
      const thread = p.thread;
      const otherParticipant =
        thread.type === DmThreadType.DIRECT
          ? thread.participants.find((x) => x.userId !== userId)
          : null;

      const otherName = this.displayNameFromUserId(otherParticipant?.userId || 'student');
      const latest = thread.messages[0];

      return {
        id: thread.id,
        type: thread.type,
        title:
          thread.type === DmThreadType.GROUP
            ? thread.title || 'Group'
            : otherName,
        subtitle:
          latest?.text?.trim() ||
          (latest?.kind === DmMessageKind.IMAGE
            ? 'Photo'
            : latest?.kind === DmMessageKind.VOICE
              ? 'Voice message'
              : 'Start chatting'),
        avatarText:
          thread.type === DmThreadType.GROUP
            ? (thread.title || 'GR').slice(0, 2).toUpperCase()
            : this.avatarTextFromName(otherName),
        requestState:
          p.state === DmParticipantState.PENDING_INCOMING
            ? 'pendingIncoming'
            : p.state === DmParticipantState.PENDING_OUTGOING
              ? 'pendingOutgoing'
              : p.state === DmParticipantState.BLOCKED
                ? 'blocked'
                : 'accepted',
        isGroup: thread.type === DmThreadType.GROUP,
        isBlocked: p.state === DmParticipantState.BLOCKED,
        unreadCount: 0,
        updatedAt: thread.updatedAt,
        participants: thread.participants.map((pp) => {
          const name = this.displayNameFromUserId(pp.userId);
          return {
            id: pp.userId,
            fullName: name,
            handle: this.handleFromUserId(pp.userId),
            avatarText: this.avatarTextFromName(name),
            status: null,
          };
        }),
      };
    });
  }

  async createThread(user: any, dto: CreateDmThreadDto) {
    const userId = this.userIdOf(user);
    const ids = Array.from(
      new Set(
        (dto.participantIds || [])
          .map((x) => String(x).trim())
          .filter((x) => x && x !== userId),
      ),
    );

    if (ids.length === 0) {
      throw new BadRequestException('participantIds required');
    }

    const isGroup = Boolean(dto.isGroup || ids.length > 1);

    if (!isGroup && ids.length === 1) {
      const existing = await this.prisma.dmThread.findFirst({
        where: {
          type: DmThreadType.DIRECT,
          participants: {
            every: {
              userId: { in: [userId, ids[0]] },
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
        type: isGroup ? DmThreadType.GROUP : DmThreadType.DIRECT,
        title: isGroup ? (dto.title?.trim() || 'New group') : null,
        createdById: userId,
        participants: {
          create: [
            {
              userId,
              role: DmParticipantRole.ADMIN,
              state: isGroup
                ? DmParticipantState.ACCEPTED
                : DmParticipantState.PENDING_OUTGOING,
            },
            ...ids.map((id) => ({
              userId: id,
              role: DmParticipantRole.MEMBER,
              state: isGroup
                ? DmParticipantState.ACCEPTED
                : DmParticipantState.PENDING_INCOMING,
            })),
          ],
        },
      },
    });

    return { ok: true, threadId: thread.id };
  }

  async respondToRequest(user: any, threadId: string, dto: RespondDmRequestDto) {
    const userId = this.userIdOf(user);
    await this.requireParticipant(threadId, userId);

    const action = String(dto?.action || '').trim().toLowerCase();
    if (action !== 'accept' && action !== 'block') {
      throw new BadRequestException('action must be accept or block');
    }

    await this.prisma.dmParticipant.update({
      where: { threadId_userId: { threadId, userId } },
      data: {
        state:
          action === 'accept'
            ? DmParticipantState.ACCEPTED
            : DmParticipantState.BLOCKED,
      },
    });

    if (action === 'accept') {
      await this.prisma.dmParticipant.updateMany({
        where: {
          threadId,
          userId: { not: userId },
          state: DmParticipantState.PENDING_OUTGOING,
        },
        data: { state: DmParticipantState.ACCEPTED },
      });
    }

    return { ok: true };
  }

  async unblock(user: any, threadId: string) {
    const userId = this.userIdOf(user);
    await this.requireParticipant(threadId, userId);

    await this.prisma.dmParticipant.update({
      where: { threadId_userId: { threadId, userId } },
      data: { state: DmParticipantState.ACCEPTED },
    });

    return { ok: true };
  }

  async listMessages(user: any, threadId: string) {
    const userId = this.userIdOf(user);
    await this.requireParticipant(threadId, userId);

    const rows = await this.prisma.dmMessage.findMany({
      where: { threadId },
      orderBy: { createdAt: 'asc' },
      include: {
        reactions: true,
      },
    });

    return rows.map((m) => ({
      id: m.id,
      senderId: m.senderId,
      senderName: m.senderId === userId ? 'You' : this.displayNameFromUserId(m.senderId),
      isMine: m.senderId === userId,
      kind: m.kind,
      text: m.text ?? '',
      mediaUrl: m.mediaUrl ?? null,
      mediaMode: m.mediaMode ?? null,
      voiceDuration: null,
      createdAt: m.createdAt,
      reactions: m.reactions.map((r) => r.emoji),
    }));
  }

  async sendMessage(user: any, threadId: string, dto: SendDmMessageDto) {
    const userId = this.userIdOf(user);
    await this.requireParticipant(threadId, userId);

    if (!(await this.canChat(threadId))) {
      throw new ForbiddenException('Thread is not open for chatting yet');
    }

    const kind = String(dto?.kind || 'TEXT').trim().toUpperCase();
    if (!['TEXT', 'IMAGE', 'VOICE'].includes(kind)) {
      throw new BadRequestException('Invalid message kind');
    }

    const text = String(dto?.text || '').trim();
    if (kind === 'TEXT' && !text) {
      throw new BadRequestException('text is required for TEXT messages');
    }

    const mediaModeRaw = String(dto?.mediaMode || '').trim().toUpperCase();
    const mediaMode =
      mediaModeRaw === 'ONCE'
        ? DmMediaMode.ONCE
        : mediaModeRaw === 'REPLAY'
          ? DmMediaMode.REPLAY
          : mediaModeRaw === 'KEEP'
            ? DmMediaMode.KEEP
            : null;

    const message = await this.prisma.dmMessage.create({
      data: {
        threadId,
        senderId: userId,
        kind: kind as DmMessageKind,
        text: text || null,
        mediaUrl: dto?.mediaUrl || null,
        mediaMimeType: dto?.mediaMimeType || null,
        mediaMode,
        viewLimit: mediaMode === DmMediaMode.ONCE ? 1 : null,
        replayLimit: mediaMode === DmMediaMode.REPLAY ? 2 : null,
      },
      include: {
        reactions: true,
      },
    });

    await this.prisma.dmThread.update({
      where: { id: threadId },
      data: { updatedAt: new Date() },
    });

    return {
      ok: true,
      message: {
        id: message.id,
        senderId: message.senderId,
        senderName: 'You',
        isMine: true,
        kind: message.kind,
        text: message.text ?? '',
        mediaUrl: message.mediaUrl ?? null,
        mediaMode: message.mediaMode ?? null,
        voiceDuration: null,
        createdAt: message.createdAt,
        reactions: message.reactions.map((r) => r.emoji),
      },
    };
  }

  async recordView(user: any, messageId: string) {
    const userId = this.userIdOf(user);

    const msg = await this.prisma.dmMessage.findUnique({
      where: { id: messageId },
      include: {
        thread: true,
      },
    });

    if (!msg) {
      throw new NotFoundException('Message not found');
    }

    await this.requireParticipant(msg.threadId, userId);

    const existing = await this.prisma.dmMessageView.findUnique({
      where: { messageId_viewerId: { messageId, viewerId: userId } },
    });

    const nextReplayCount = (existing?.replayCount ?? 0) + 1;

    if (msg.mediaMode === DmMediaMode.ONCE && existing) {
      throw new ForbiddenException('This media can only be viewed once');
    }

    if (
      msg.mediaMode === DmMediaMode.REPLAY &&
      msg.replayLimit != null &&
      nextReplayCount > msg.replayLimit
    ) {
      throw new ForbiddenException('Replay limit reached');
    }

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
        data: {
          replayCount: { increment: 1 },
          viewedAt: new Date(),
        },
      });
    }

    return { ok: true };
  }

  async react(user: any, messageId: string, dto: ReactDmMessageDto) {
    const userId = this.userIdOf(user);

    const msg = await this.prisma.dmMessage.findUnique({
      where: { id: messageId },
    });

    if (!msg) {
      throw new NotFoundException('Message not found');
    }

    await this.requireParticipant(msg.threadId, userId);

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
