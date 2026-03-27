import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { ApproveMessageRequestDto } from './dto/approve-message-request.dto';
import { BlockMessageRequestDto } from './dto/block-message-request.dto';
import { CreateDirectRequestDto } from './dto/create-direct-request.dto';
import { CreateGroupThreadDto } from './dto/create-group-thread.dto';
import { MarkThreadReadDto } from './dto/mark-thread-read.dto';
import { SendMessageDto } from './dto/send-message.dto';

@Injectable()
export class MessagesService {
  constructor(private readonly prisma: PrismaService) {}

  private initials(name: string) {
    return String(name || '')
      .trim()
      .split(/\s+/)
      .filter((v) => v.length > 0)
      .slice(0, 2)
      .map((v) => v[0]!.toUpperCase())
      .join('');
  }

  private async userOrThrow(userId: string) {
    const row = await this.prisma.user.findUnique({
      where: { id: String(userId) },
      select: { id: true, name: true, displayName: true },
    });
    if (!row) throw new NotFoundException('User not found');
    return row;
  }

  private async participantOrThrow(threadId: string, userId: string) {
    const participant = await this.prisma.dmParticipant.findUnique({
      where: {
        threadId_userId: {
          threadId: String(threadId),
          userId: String(userId),
        },
      },
      include: {
        thread: true,
      },
    });
    if (!participant) throw new ForbiddenException('Not a participant in this thread');
    return participant;
  }

  private mapRequestState(thread: any, participant: any) {
    const status = String(thread?.requestState ?? '').toUpperCase();
    const createdByUserId = String(thread?.createdByUserId ?? '');

    if (status === 'BLOCKED') return 'BLOCKED';
    if (status === 'APPROVED') return 'APPROVED';
    if (status === 'PENDING') {
      return createdByUserId === String(participant?.userId ?? '')
        ? 'PENDING_OUTGOING'
        : 'PENDING_INCOMING';
    }
    return 'NONE';
  }

  private mapThreadType(raw: any) {
    const value = String(raw ?? '').toUpperCase();
    if (value === 'GROUP') return 'GROUP';
    return 'DIRECT';
  }

  private async visibleMessages(threadId: string) {
    return this.prisma.dmMessage.findMany({
      where: { threadId: String(threadId) },
      orderBy: [{ createdAt: 'asc' }],
      include: {
        sender: {
          select: {
            id: true,
            name: true,
            displayName: true,
          },
        },
      },
    });
  }

  async getInbox(userId: string) {
    await this.userOrThrow(userId);

    const rows = await this.prisma.dmParticipant.findMany({
      where: { userId: String(userId), isHidden: false },
      include: {
        thread: {
          include: {
            participants: {
              include: {
                user: {
                  select: {
                    id: true,
                    name: true,
                    displayName: true,
                  },
                },
              },
            },
            messages: {
              orderBy: [{ createdAt: 'desc' }],
              take: 1,
              include: {
                sender: {
                  select: {
                    id: true,
                    name: true,
                    displayName: true,
                  },
                },
              },
            },
          },
        },
      },
      orderBy: [{ updatedAt: 'desc' }],
    });

    const items = rows.map((participant) => {
      const thread = participant.thread;
      const others = thread.participants.filter((p) => p.userId !== userId);
      const other = others[0]?.user;
      const lastMessage = thread.messages[0] ?? null;

      const title =
        this.mapThreadType(thread.type) === 'GROUP'
          ? String(thread.title ?? 'Group')
          : String(other?.displayName || other?.name || 'Unknown');

      const initials =
        this.mapThreadType(thread.type) === 'GROUP'
          ? this.initials(String(thread.title ?? 'Group'))
          : this.initials(String(other?.displayName || other?.name || 'Unknown'));

      const subtitle =
        thread.requestState === 'PENDING' && String(thread.createdByUserId) !== String(userId)
          ? 'Sent you a message request'
          : lastMessage
          ? (() => {
              const senderName =
                String(
                  lastMessage.sender?.displayName ||
                    lastMessage.sender?.name ||
                    '',
                ).trim();
              const text = String(lastMessage.text ?? '').trim();
              if (this.mapThreadType(thread.type) === 'GROUP' && senderName) {
                return `${senderName}: ${text || 'Attachment'}`;
              }
              return text || 'Attachment';
            })()
          : 'No messages yet';

      const unreadCount = Number(participant.unreadCount ?? 0);

      return {
        id: thread.id,
        type: this.mapThreadType(thread.type),
        title,
        subtitle,
        isGroup: this.mapThreadType(thread.type) === 'GROUP',
        isUnread: unreadCount > 0,
        unreadCount,
        lastMessageAt: lastMessage
          ? new Date(lastMessage.createdAt).toLocaleTimeString('en-US', {
              hour: 'numeric',
              minute: '2-digit',
            })
          : '',
        requestState: this.mapRequestState(thread, participant),
        initials,
        groupAvatarUrl: null,
      };
    });

    return { ok: true, items, viewerUserId: userId };
  }

  async getThread(userId: string, threadId: string) {
    const participant = await this.participantOrThrow(threadId, userId);
    const thread = await this.prisma.dmThread.findUnique({
      where: { id: String(threadId) },
      include: {
        participants: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                displayName: true,
              },
            },
          },
        },
      },
    });
    if (!thread) throw new NotFoundException('Thread not found');
    if (thread.requestState === 'PENDING') {
      throw new BadRequestException('Thread is still a request');
    }

    const messages = await this.visibleMessages(threadId);
    const other = thread.participants.find((p) => p.userId !== userId)?.user;

    const payload = {
      id: thread.id,
      title:
        this.mapThreadType(thread.type) === 'GROUP'
          ? String(thread.title ?? 'Group')
          : String(other?.displayName || other?.name || 'Unknown'),
      subtitle:
        this.mapThreadType(thread.type) === 'GROUP'
          ? `${thread.participants.length} members`
          : 'Direct chat',
      isGroup: this.mapThreadType(thread.type) === 'GROUP',
      requestState: this.mapRequestState(thread, participant),
      participants: thread.participants.map((p) => ({
        userId: p.user.id,
        displayName: String(p.user.displayName || p.user.name || 'Unknown'),
        initials: this.initials(String(p.user.displayName || p.user.name || 'Unknown')),
        isAdmin: Boolean(p.isAdmin),
        isBlocked: false,
      })),
      messages: messages.map((m) => ({
        id: m.id,
        senderId: m.senderId,
        senderName: String(m.sender?.displayName || m.sender?.name || 'Unknown'),
        text: String(m.text ?? ''),
        timeLabel: new Date(m.createdAt).toLocaleTimeString('en-US', {
          hour: 'numeric',
          minute: '2-digit',
        }),
        isMine: String(m.senderId) === String(userId),
        reaction: null,
        isPinned: Boolean(m.isPinned),
      })),
    };

    return { ok: true, thread: payload, viewerUserId: userId };
  }

  async getRequest(userId: string, threadId: string) {
    const participant = await this.participantOrThrow(threadId, userId);
    const thread = await this.prisma.dmThread.findUnique({
      where: { id: String(threadId) },
      include: {
        participants: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                displayName: true,
              },
            },
          },
        },
      },
    });
    if (!thread) throw new NotFoundException('Request not found');
    if (thread.requestState !== 'PENDING') {
      throw new BadRequestException('Request no longer pending');
    }

    const messages = await this.visibleMessages(threadId);
    const other = thread.participants.find((p) => p.userId !== userId)?.user;

    return {
      ok: true,
      request: {
        id: thread.id,
        title: String(other?.displayName || other?.name || 'Unknown'),
        subtitle: 'Message request',
        isGroup: false,
        requestState: this.mapRequestState(thread, participant),
        participants: thread.participants.map((p) => ({
          userId: p.user.id,
          displayName: String(p.user.displayName || p.user.name || 'Unknown'),
          initials: this.initials(String(p.user.displayName || p.user.name || 'Unknown')),
          isAdmin: Boolean(p.isAdmin),
          isBlocked: false,
        })),
        messages: messages.map((m) => ({
          id: m.id,
          senderId: m.senderId,
          senderName: String(m.sender?.displayName || m.sender?.name || 'Unknown'),
          text: String(m.text ?? ''),
          timeLabel: new Date(m.createdAt).toLocaleTimeString('en-US', {
            hour: 'numeric',
            minute: '2-digit',
          }),
          isMine: String(m.senderId) === String(userId),
        })),
      },
      viewerUserId: userId,
    };
  }

  async createDirectRequest(userId: string, dto: CreateDirectRequestDto) {
    if (String(userId) === String(dto.recipientUserId)) {
      throw new BadRequestException('Cannot message yourself');
    }

    await this.userOrThrow(userId);
    await this.userOrThrow(dto.recipientUserId);

    const existing = await this.prisma.dmThread.findFirst({
      where: {
        type: 'DIRECT',
        participants: {
          some: { userId: String(userId) },
        },
        AND: [
          {
            participants: {
              some: { userId: String(dto.recipientUserId) },
            },
          },
        ],
      },
      include: {
        participants: true,
      },
    });

    if (existing && existing.participants.length === 2) {
      return {
        ok: true,
        threadId: existing.id,
        requestState: existing.requestState === 'PENDING' ? 'PENDING_OUTGOING' : 'APPROVED',
      };
    }

    const thread = await this.prisma.dmThread.create({
      data: {
        type: 'DIRECT',
        requestState: 'PENDING',
        createdByUserId: String(userId),
        participants: {
          create: [
            { userId: String(userId), isAdmin: false, unreadCount: 0 },
            { userId: String(dto.recipientUserId), isAdmin: false, unreadCount: 1 },
          ],
        },
        messages: {
          create: {
            senderId: String(userId),
            kind: 'TEXT',
            text: String(dto.firstMessage).trim(),
          },
        },
      },
    });

    return {
      ok: true,
      threadId: thread.id,
      requestState: 'PENDING_OUTGOING',
    };
  }

  async approveRequest(userId: string, dto: ApproveMessageRequestDto) {
    await this.participantOrThrow(dto.threadId, userId);

    const updated = await this.prisma.dmThread.update({
      where: { id: String(dto.threadId) },
      data: { requestState: 'APPROVED' },
    });

    return {
      ok: true,
      threadId: updated.id,
      requestState: 'APPROVED',
      actedByUserId: userId,
    };
  }

  async blockRequest(userId: string, dto: BlockMessageRequestDto) {
    await this.participantOrThrow(dto.threadId, userId);

    const updated = await this.prisma.dmThread.update({
      where: { id: String(dto.threadId) },
      data: { requestState: 'BLOCKED' },
    });

    return {
      ok: true,
      threadId: updated.id,
      requestState: 'BLOCKED',
      actedByUserId: userId,
    };
  }

  async createGroup(userId: string, dto: CreateGroupThreadDto) {
    await this.userOrThrow(userId);

    const uniqueMemberIds = Array.from(
      new Set([String(userId), ...dto.memberIds.map((v) => String(v))]),
    );

    const thread = await this.prisma.dmThread.create({
      data: {
        type: 'GROUP',
        title: String(dto.title).trim(),
        requestState: 'APPROVED',
        createdByUserId: String(userId),
        participants: {
          create: uniqueMemberIds.map((memberId) => ({
            userId: memberId,
            isAdmin: memberId === String(userId),
            unreadCount: 0,
          })),
        },
      },
    });

    return {
      ok: true,
      threadId: thread.id,
      title: thread.title,
      memberIds: uniqueMemberIds,
      createdByUserId: userId,
    };
  }

  async sendMessage(userId: string, dto: SendMessageDto) {
    const participant = await this.participantOrThrow(dto.threadId, userId);
    if (participant.thread.requestState === 'BLOCKED') {
      throw new ForbiddenException('Thread is blocked');
    }

    const text = String(dto.text ?? '').trim();
    if (!text) throw new BadRequestException('text is required');

    const message = await this.prisma.dmMessage.create({
      data: {
        threadId: String(dto.threadId),
        senderId: String(userId),
        kind: 'TEXT',
        text,
        replyToMessageId: dto.replyToMessageId?.trim() || null,
      },
    });

    await this.prisma.dmParticipant.updateMany({
      where: {
        threadId: String(dto.threadId),
        userId: { not: String(userId) },
      },
      data: {
        unreadCount: { increment: 1 },
      },
    });

    await this.prisma.dmParticipant.updateMany({
      where: {
        threadId: String(dto.threadId),
        userId: String(userId),
      },
      data: {
        unreadCount: 0,
      },
    });

    await this.prisma.dmThread.update({
      where: { id: String(dto.threadId) },
      data: {
        updatedAt: new Date(),
        requestState:
          participant.thread.requestState === 'PENDING' ? 'APPROVED' : undefined,
      },
    });

    return { ok: true, messageId: message.id, threadId: dto.threadId };
  }

  async markThreadRead(userId: string, dto: MarkThreadReadDto) {
    await this.participantOrThrow(dto.threadId, userId);

    await this.prisma.dmParticipant.update({
      where: {
        threadId_userId: {
          threadId: String(dto.threadId),
          userId: String(userId),
        },
      },
      data: {
        unreadCount: 0,
        lastReadAt: new Date(),
      },
    });

    return { ok: true, threadId: dto.threadId };
  }
}
