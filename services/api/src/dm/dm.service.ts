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
    return String(user?.sub ?? user?.id ?? user?.userId ?? '');
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
      select: { userId: true, state: true },
    });

    if (parts.length === 0) return false;

    const blocked = parts.some((p) => p.state === DmParticipantState.BLOCKED);
    if (blocked) return false;

    return parts.every((p) =>
      p.state === DmParticipantState.ACCEPTED,
    );
  }

  async listThreads(user: any) {
    const userId = this.userIdOf(user);

    const parts = await this.prisma.dmParticipant.findMany({
      where: { userId },
      include: {
        thread: {
          include: {
            participants: {
              include: {
                user: true,
              },
            },
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
      const thread = await this.prisma.dmThread.findUnique({ where: { id: p.threadId }, include: { participants: true } });
      const other =
        thread.type === DmThreadType.DIRECT
          ? thread.participants.find((x) => x.userId !== userId)
          : null;

      const latest = thread.messages[0];

      return {
        id: thread.id,
        type: thread.type,
        title:
          thread.type === DmThreadType.GROUP
            ? thread.title || 'Group'
            : other?.user?.name || 'Student',
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
            : (other?.user?.name || 'ST')
                .split(' ')
                .map((x) => x[0] || '')
                .join('')
                .slice(0, 2)
                .toUpperCase(),
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
        participants: thread.participants.map((pp) => ({
          id: pp.userId,
          fullName: pp.user?.name || 'Student',
          handle: `@${(pp.user?.email || pp.userId).split('@')[0]}`,
          avatarText: (pp.user?.name || 'ST')
            .split(' ')
            .map((x) => x[0] || '')
            .join('')
            .slice(0, 2)
            .toUpperCase(),
          status: null,
        })),
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

    const createParticipants = [
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
    ];

    const thread = await this.prisma.dmThread.create({
      data: {
        type: isGroup ? DmThreadType.GROUP : DmThreadType.DIRECT,
        title: isGroup ? (dto.title?.trim() || 'New group') : null,
        createdById: userId,
        participants: {
          create: createParticipants,
        },
      },
    });

    return { ok: true, threadId: thread.id };
  }

  async respondToRequest(user: any, threadId: string, dto: RespondDmRequestDto) {
    const userId = this.userIdOf(user);
    const me = await this.requireParticipant(threadId, userId);

    if (me.state !== DmParticipantState.PENDING_INCOMING) {
      throw new BadRequestException('No incoming request to respond to');
    }

    if (dto.action === 'accept') {
      await this.prisma.dmParticipant.updateMany({
        where: {
          threadId,
          state: {
            in: [
              DmParticipantState.PENDING_INCOMING,
              DmParticipantState.PENDING_OUTGOING,
            ],
          },
        },
        data: { state: DmParticipantState.ACCEPTED },
      });

      return { ok: true, state: 'accepted' };
    }

    if (dto.action === 'block') {
      await this.prisma.dmParticipant.update({
        where: { threadId_userId: { threadId, userId } },
        data: { state: DmParticipantState.BLOCKED },
      });

      return { ok: true, state: 'blocked' };
    }

    throw new BadRequestException('Unsupported action');
  }

  async unblock(user: any, threadId: string) {
    const userId = this.userIdOf(user);
    const me = await this.requireParticipant(threadId, userId);

    if (me.state !== DmParticipantState.BLOCKED) {
      return { ok: true, state: 'unchanged' };
    }

    await this.prisma.dmParticipant.update({
      where: { threadId_userId: { threadId, userId } },
      data: { state: DmParticipantState.ACCEPTED },
    });

    return { ok: true, state: 'accepted' };
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

    return rows
      .filter((m) => {
        if (!m.expiresAt) return true;
        return m.expiresAt > new Date();
      })
      .map((m) => ({
        id: m.id,
        senderId: m.senderId,
        senderName: m.senderId === userId ? 'You' : 'Student',
        isMine: m.senderId === userId,
        kind:
          m.kind === DmMessageKind.IMAGE
            ? 'image'
            : m.kind === DmMessageKind.VOICE
              ? 'voice'
              : 'text',
        text: m.text || '',
        mediaUrl: m.mediaUrl,
        mediaMode:
          m.mediaMode === DmMediaMode.ONCE
            ? 'once'
            : m.mediaMode === DmMediaMode.REPLAY
              ? 'replay'
              : m.mediaMode === DmMediaMode.KEEP
                ? 'keep'
                : null,
        voiceDuration: null,
        createdAt: m.createdAt,
        reactions: m.reactions.map((r) => r.emoji),
      }));
  }

  async sendMessage(user: any, threadId: string, dto: SendDmMessageDto) {
    const userId = this.userIdOf(user);
    await this.requireParticipant(threadId, userId);

    if (!(await this.canChat(threadId))) {
      throw new ForbiddenException('Chat is not open yet');
    }

    const kind =
      dto.kind === 'IMAGE'
        ? DmMessageKind.IMAGE
        : dto.kind === 'VOICE'
          ? DmMessageKind.VOICE
          : DmMessageKind.TEXT;

    const mediaMode =
      dto.mediaMode === 'ONCE'
        ? DmMediaMode.ONCE
        : dto.mediaMode === 'REPLAY'
          ? DmMediaMode.REPLAY
          : dto.mediaMode === 'KEEP'
            ? DmMediaMode.KEEP
            : null;

    const expiresAt =
      mediaMode === DmMediaMode.ONCE
        ? new Date(Date.now() + 24 * 60 * 60 * 1000)
        : null;

    const msg = await this.prisma.dmMessage.create({
      data: {
        threadId,
        senderId: userId,
        kind,
        text: dto.text?.trim() || null,
        mediaUrl: dto.mediaUrl?.trim() || null,
        mediaMimeType: dto.mediaMimeType?.trim() || null,
        mediaMode,
        viewLimit: mediaMode === DmMediaMode.ONCE ? 1 : null,
        replayLimit: mediaMode === DmMediaMode.REPLAY ? 10 : null,
        expiresAt,
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
        data: {
          replayCount: { increment: 1 },
          viewedAt: new Date(),
        },
      });
    }

    if (
      msg.mediaMode === DmMediaMode.ONCE &&
      msg.senderId !== userId
    ) {
      await this.prisma.dmMessage.update({
        where: { id: messageId },
        data: { expiresAt: new Date() },
      });
    }

    return { ok: true };
  }

  async react(user: any, messageId: string, dto: ReactDmMessageDto) {
    const userId = this.userIdOf(user);

    const msg = await this.prisma.dmMessage.findUnique({
      where: { id: messageId },
    });

    if (!msg) throw new NotFoundException('Message not found');

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
