import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  DmMessageKind,
  DmParticipantRole,
  DmParticipantState,
  DmThreadType,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateDirectRequestDto } from './dto/create-direct-request.dto';
import { ApproveMessageRequestDto } from './dto/approve-message-request.dto';
import { BlockMessageRequestDto } from './dto/block-message-request.dto';
import { CreateGroupThreadDto } from './dto/create-group-thread.dto';
import { SendMessageDto } from './dto/send-message.dto';
import { MarkThreadReadDto } from './dto/mark-thread-read.dto';

type AppUser = {
  id?: string;
  sub?: string;
  userId?: string;
};

type ThreadWithRelations = Awaited<ReturnType<MessagesService['loadThreadOrThrow']>>;

@Injectable()
export class MessagesService {
  constructor(private readonly prisma: PrismaService) {}

  private viewerId(user: AppUser): string {
    const id = String(user?.sub ?? user?.id ?? user?.userId ?? '').trim();
    if (!id) {
      throw new BadRequestException('Missing authenticated user');
    }
    return id;
  }

  private async requireUser(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, name: true, displayName: true },
    });
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return user;
  }

  private displayNameOf(user: { name?: string | null; displayName?: string | null } | null | undefined) {
    return String(user?.displayName ?? user?.name ?? '').trim() || 'Unknown';
  }

  private initialsOf(name: string) {
    const parts = String(name || '')
      .split(' ')
      .map((v) => v.trim())
      .filter((v) => v.length > 0)
      .slice(0, 2);

    if (!parts.length) return '??';
    return parts.map((v) => v[0]!.toUpperCase()).join();
  }

  private formatTime(value: Date | string | null | undefined) {
    if (!value) return '';
    const date = value instanceof Date ? value : new Date(value);
    return date.toLocaleTimeString('en-US', {
      hour: 'numeric',
      minute: '2-digit',
    });
  }

  private kindLabel(kind: DmMessageKind | string | null | undefined) {
    switch (String(kind ?? 'TEXT').toUpperCase()) {
      case 'IMAGE':
        return 'Photo';
      case 'VOICE':
        return 'Voice note';
      case 'VIDEO':
        return 'Video';
      case 'FILE':
        return 'File';
      default:
        return 'Message';
    }
  }

  private viewerRequestState(
    thread: {
      type: DmThreadType;
      participants: Array<{ userId: string; state: DmParticipantState }>;
    },
    viewerId: string,
  ) {
    if (thread.type === DmThreadType.GROUP) return 'none';

    const viewer = thread.participants.find((p) => p.userId === viewerId);
    if (!viewer) return 'none';

    switch (viewer.state) {
      case DmParticipantState.PENDING_INCOMING:
        return 'pendingIncoming';
      case DmParticipantState.PENDING_OUTGOING:
        return 'pendingOutgoing';
      case DmParticipantState.BLOCKED:
        return 'blocked';
      case DmParticipantState.ACCEPTED:
      default:
        return 'approved';
    }
  }

  private canViewerSend(
    thread: {
      type: DmThreadType;
      participants: Array<{ userId: string; state: DmParticipantState }>;
    },
    viewerId: string,
  ) {
    if (thread.type === DmThreadType.GROUP) {
      const viewer = thread.participants.find((p) => p.userId === viewerId);
      return viewer?.state === DmParticipantState.ACCEPTED;
    }

    const viewer = thread.participants.find((p) => p.userId === viewerId);
    return viewer?.state === DmParticipantState.ACCEPTED;
  }

  private async userMapForIds(userIds: string[]) {
    const ids = Array.from(new Set(userIds.map((v) => String(v).trim()).filter((v) => v.length > 0)));
    if (!ids.length) return new Map<string, { id: string; name: string; displayName: string | null }>();

    const rows = await this.prisma.user.findMany({
      where: { id: { in: ids } },
      select: { id: true, name: true, displayName: true },
    });

    return new Map(rows.map((row) => [row.id, row]));
  }

  private async loadParticipantOrThrow(threadId: string, userId: string) {
    const participant = await this.prisma.dmParticipant.findUnique({
      where: {
        threadId_userId: {
          threadId,
          userId,
        },
      },
      include: {
        thread: {
          include: {
            participants: true,
          },
        },
      },
    });

    if (!participant) {
      throw new ForbiddenException('No access to this thread');
    }

    return participant;
  }

  private async loadThreadOrThrow(threadId: string, userId: string) {
    await this.loadParticipantOrThrow(threadId, userId);

    const thread = await this.prisma.dmThread.findUnique({
      where: { id: threadId },
      include: {
        participants: {
          orderBy: { createdAt: 'asc' },
        },
        messages: {
          orderBy: { createdAt: 'asc' },
          include: {
            reactions: {
              orderBy: { createdAt: 'asc' },
              take: 1,
            },
          },
        },
      },
    });

    if (!thread) {
      throw new NotFoundException('Thread not found');
    }

    return thread;
  }

  private async threadToSummary(
    participant: {
      thread: {
        id: string;
        type: DmThreadType;
        title: string | null;
        updatedAt: Date;
        createdAt: Date;
        participants: Array<{
          userId: string;
          role: DmParticipantRole;
          state: DmParticipantState;
        }>;
        messages: Array<{
          id: string;
          senderId: string;
          text: string | null;
          kind: DmMessageKind;
          createdAt: Date;
        }>;
      };
      userId: string;
      state: DmParticipantState;
      lastSeenAt: Date | null;
    },
  ) {
    const thread = participant.thread;
    const viewerId = participant.userId;
    const otherIds = thread.participants
      .filter((p) => p.userId !== viewerId)
      .map((p) => p.userId);

    const users = await this.userMapForIds([...thread.participants.map((p) => p.userId), ...thread.messages.map((m) => m.senderId)]);
    const counterpart = otherIds.length ? users.get(otherIds[0]) : null;
    const latestMessage = thread.messages.length ? thread.messages[thread.messages.length - 1] : null;

    const title =
      thread.type === DmThreadType.GROUP
        ? String(thread.title ?? '').trim() || 'Group'
        : this.displayNameOf(counterpart);

    const subtitle = latestMessage
      ? (() => {
          const body = String(latestMessage.text ?? '').trim();
          if (body) {
            if (thread.type === DmThreadType.GROUP) {
              const senderName = this.displayNameOf(users.get(latestMessage.senderId));
              return `${senderName}: ${body}`;
            }
            return body;
          }

          const label = this.kindLabel(latestMessage.kind);
          if (thread.type === DmThreadType.GROUP) {
            const senderName = this.displayNameOf(users.get(latestMessage.senderId));
            return `${senderName}: ${label}`;
          }
          return label;
        })()
      : participant.state === DmParticipantState.PENDING_INCOMING
      ? 'Sent you a message request'
      : participant.state === DmParticipantState.PENDING_OUTGOING
      ? 'Waiting for approval'
      : 'No messages yet';

    const unreadCount =
      participant.lastSeenAt == null
        ? thread.messages.filter((m) => m.senderId !== viewerId).length
        : thread.messages.filter(
            (m) => m.senderId !== viewerId && m.createdAt > participant.lastSeenAt!,
          ).length;

    return {
      id: thread.id,
      type: String(thread.type).toLowerCase(),
      title,
      subtitle,
      isGroup: thread.type === DmThreadType.GROUP,
      isUnread: unreadCount > 0,
      unreadCount,
      lastMessageAt: this.formatTime(latestMessage?.createdAt ?? thread.updatedAt ?? thread.createdAt),
      requestState: this.viewerRequestState(thread, viewerId),
      initials:
        thread.type === DmThreadType.GROUP
          ? this.initialsOf(title)
          : this.initialsOf(this.displayNameOf(counterpart)),
      groupAvatarUrl: null,
      canSend: this.canViewerSend(thread, viewerId),
    };
  }

  private async threadToDetail(thread: ThreadWithRelations, viewerId: string) {
    const users = await this.userMapForIds([
      ...thread.participants.map((p) => p.userId),
      ...thread.messages.map((m) => m.senderId),
    ]);

    const otherIds = thread.participants
      .filter((p) => p.userId !== viewerId)
      .map((p) => p.userId);

    const counterpart = otherIds.length ? users.get(otherIds[0]) : null;

    const title =
      thread.type === DmThreadType.GROUP
        ? String(thread.title ?? '').trim() || 'Group'
        : this.displayNameOf(counterpart);

    return {
      id: thread.id,
      title,
      subtitle:
        thread.type === DmThreadType.GROUP
          ? `${thread.participants.length} members`
          : 'Direct message',
      isGroup: thread.type === DmThreadType.GROUP,
      requestState: this.viewerRequestState(thread, viewerId),
      participants: thread.participants.map((p) => {
        const user = users.get(p.userId);
        const displayName = this.displayNameOf(user);
        return {
          userId: p.userId,
          displayName,
          initials: this.initialsOf(displayName),
          isAdmin: p.role === DmParticipantRole.ADMIN,
          isBlocked: p.state === DmParticipantState.BLOCKED,
        };
      }),
      messages: thread.messages.map((m) => ({
        id: m.id,
        senderId: m.senderId,
        senderName: this.displayNameOf(users.get(m.senderId)),
        text: String(m.text ?? '').trim(),
        timeLabel: this.formatTime(m.createdAt),
        isMine: m.senderId === viewerId,
        reaction:
          Array.isArray(m.reactions) && m.reactions.length
            ? String(m.reactions[0]?.emoji ?? '').trim() || null
            : null,
        isPinned: false,
        kind: String(m.kind),
        mediaUrl: m.mediaUrl ?? null,
        replyToMessageId: null,
      })),
      canSend: this.canViewerSend(thread, viewerId),
    };
  }

  async fetchInbox(user: AppUser) {
    const userId = this.viewerId(user);

    const participants = await this.prisma.dmParticipant.findMany({
      where: {
        userId,
        state: {
          not: DmParticipantState.BLOCKED,
        },
      },
      include: {
        thread: {
          include: {
            participants: true,
            messages: {
              take: 1,
              orderBy: { createdAt: 'desc' },
            },
          },
        },
      },
      orderBy: { updatedAt: 'desc' },
    });

    const items = await Promise.all(participants.map((p) => this.threadToSummary(p)));
    items.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    return { items };
  }

  async fetchThread(user: AppUser, threadId: string) {
    const userId = this.viewerId(user);
    const thread = await this.loadThreadOrThrow(threadId, userId);
    return { thread: await this.threadToDetail(thread, userId) };
  }

  async fetchRequest(user: AppUser, threadId: string) {
    const userId = this.viewerId(user);
    const participant = await this.loadParticipantOrThrow(threadId, userId);

    if (
      participant.state !== DmParticipantState.PENDING_INCOMING &&
      participant.state !== DmParticipantState.PENDING_OUTGOING
    ) {
      throw new BadRequestException('Thread is not a pending request');
    }

    const thread = await this.loadThreadOrThrow(threadId, userId);
    return { request: await this.threadToDetail(thread, userId) };
  }

  async createDirectRequest(user: AppUser, dto: CreateDirectRequestDto) {
    const userId = this.viewerId(user);
    const recipientUserId = String(dto.recipientUserId ?? '').trim();
    const firstMessage = String(dto.firstMessage ?? '').trim();

    if (!recipientUserId) {
      throw new BadRequestException('recipientUserId is required');
    }
    if (!firstMessage) {
      throw new BadRequestException('firstMessage is required');
    }
    if (recipientUserId === userId) {
      throw new BadRequestException('Cannot message yourself');
    }

    await this.requireUser(userId);
    await this.requireUser(recipientUserId);

    const existing = await this.prisma.dmThread.findMany({
      where: {
        type: DmThreadType.DIRECT,
        participants: {
          some: {
            userId: {
              in: [userId, recipientUserId],
            },
          },
        },
      },
      include: {
        participants: true,
      },
    });

    const exact = existing.find((thread) => {
      const ids = thread.participants.map((p) => p.userId).sort();
      return ids.length === 2 && ids[0] === [userId, recipientUserId].sort()[0] && ids[1] === [userId, recipientUserId].sort()[1];
    });

    if (exact) {
      return this.fetchThread(user, exact.id);
    }

    const thread = await this.prisma.dmThread.create({
      data: {
        type: DmThreadType.DIRECT,
        createdById: userId,
        participants: {
          create: [
            {
              userId,
              role: DmParticipantRole.MEMBER,
              state: DmParticipantState.PENDING_OUTGOING,
            },
            {
              userId: recipientUserId,
              role: DmParticipantRole.MEMBER,
              state: DmParticipantState.PENDING_INCOMING,
            },
          ],
        },
        messages: {
          create: {
            senderId: userId,
            kind: DmMessageKind.TEXT,
            text: firstMessage,
          },
        },
      },
    });

    return this.fetchThread(user, thread.id);
  }

  async approveRequest(user: AppUser, dto: ApproveMessageRequestDto) {
    const userId = this.viewerId(user);
    const threadId = String(dto.threadId ?? '').trim();
    if (!threadId) {
      throw new BadRequestException('threadId is required');
    }

    const thread = await this.loadThreadOrThrow(threadId, userId);
    const viewerParticipant = thread.participants.find((p) => p.userId === userId);

    if (!viewerParticipant || viewerParticipant.state !== DmParticipantState.PENDING_INCOMING) {
      throw new ForbiddenException('Only the receiver can approve this request');
    }

    await this.prisma.dmParticipant.updateMany({
      where: { threadId },
      data: { state: DmParticipantState.ACCEPTED },
    });

    return { ok: true };
  }

  async blockRequest(user: AppUser, dto: BlockMessageRequestDto) {
    const userId = this.viewerId(user);
    const threadId = String(dto.threadId ?? '').trim();
    if (!threadId) {
      throw new BadRequestException('threadId is required');
    }

    const thread = await this.loadThreadOrThrow(threadId, userId);
    const viewerParticipant = thread.participants.find((p) => p.userId === userId);

    if (!viewerParticipant || viewerParticipant.state !== DmParticipantState.PENDING_INCOMING) {
      throw new ForbiddenException('Only the receiver can block this request');
    }

    await this.prisma.$transaction([
      this.prisma.dmParticipant.update({
        where: {
          threadId_userId: {
            threadId,
            userId,
          },
        },
        data: {
          state: DmParticipantState.BLOCKED,
        },
      }),
      this.prisma.dmParticipant.updateMany({
        where: {
          threadId,
          userId: {
            not: userId,
          },
        },
        data: {
          state: DmParticipantState.BLOCKED,
        },
      }),
    ]);

    return { ok: true };
  }

  async createGroup(user: AppUser, dto: CreateGroupThreadDto) {
    const userId = this.viewerId(user);
    const title = String(dto.title ?? '').trim();
    const memberIds = Array.from(
      new Set(
        (dto.memberIds ?? [])
          .map((v) => String(v ?? '').trim())
          .filter((v) => v.length > 0 && v !== userId),
      ),
    );

    if (!title) {
      throw new BadRequestException('title is required');
    }
    if (!memberIds.length) {
      throw new BadRequestException('At least one member is required');
    }

    await this.requireUser(userId);
    for (const memberId of memberIds) {
      await this.requireUser(memberId);
    }

    const thread = await this.prisma.dmThread.create({
      data: {
        type: DmThreadType.GROUP,
        title,
        createdById: userId,
        participants: {
          create: [
            {
              userId,
              role: DmParticipantRole.ADMIN,
              state: DmParticipantState.ACCEPTED,
            },
            ...memberIds.map((memberId) => ({
              userId: memberId,
              role: DmParticipantRole.MEMBER,
              state: DmParticipantState.ACCEPTED,
            })),
          ],
        },
      },
    });

    return this.fetchThread(user, thread.id);
  }

  async sendMessage(user: AppUser, dto: SendMessageDto) {
    const userId = this.viewerId(user);
    const threadId = String(dto.threadId ?? '').trim();
    const text = String(dto.text ?? '').trim();
    const mediaUrl = String(dto.mediaUrl ?? '').trim();
    const mediaMimeType = String(dto.mediaMimeType ?? '').trim();
    const rawKind = String(dto.kind ?? '').trim().toUpperCase();
    const kind = (rawKind || (mediaUrl ? 'FILE' : 'TEXT')) as DmMessageKind;

    if (!threadId) {
      throw new BadRequestException('threadId is required');
    }

    const participant = await this.loadParticipantOrThrow(threadId, userId);

    if (participant.state === DmParticipantState.BLOCKED) {
      throw new ForbiddenException('Thread is blocked');
    }
    if (participant.state !== DmParticipantState.ACCEPTED) {
      throw new ForbiddenException('Request is not approved yet');
    }
    if (!text && !mediaUrl) {
      throw new BadRequestException('text or mediaUrl is required');
    }

    const created = await this.prisma.dmMessage.create({
      data: {
        threadId,
        senderId: userId,
        kind,
        text: text || null,
        mediaUrl: mediaUrl || null,
        mediaMimeType: mediaMimeType || null,
      },
      include: {
        reactions: {
          take: 1,
          orderBy: { createdAt: 'asc' },
        },
      },
    });

    const thread = await this.prisma.dmThread.findUnique({
      where: { id: threadId },
      select: { id: true, title: true, createdById: true },
    });

    if (thread) {
      await this.prisma.dmThread.update({
        where: { id: threadId },
        data: { title: thread.title },
      });
    }

    await this.prisma.dmParticipant.update({
      where: {
        threadId_userId: {
          threadId,
          userId,
        },
      },
      data: {
        lastSeenAt: new Date(),
      },
    });

    const users = await this.userMapForIds([userId]);

    return {
      ok: true,
      message: {
        id: created.id,
        senderId: created.senderId,
        senderName: this.displayNameOf(users.get(created.senderId)),
        text: String(created.text ?? '').trim(),
        timeLabel: this.formatTime(created.createdAt),
        isMine: true,
        reaction:
          Array.isArray(created.reactions) && created.reactions.length
            ? String(created.reactions[0]?.emoji ?? '').trim() || null
            : null,
        isPinned: false,
        kind: String(created.kind),
        mediaUrl: created.mediaUrl ?? null,
        replyToMessageId: null,
      },
    };
  }

  async markThreadRead(user: AppUser, dto: MarkThreadReadDto) {
    const userId = this.viewerId(user);
    const threadId = String(dto.threadId ?? '').trim();
    if (!threadId) {
      throw new BadRequestException('threadId is required');
    }

    await this.loadParticipantOrThrow(threadId, userId);

    await this.prisma.dmParticipant.update({
      where: {
        threadId_userId: {
          threadId,
          userId,
        },
      },
      data: {
        lastSeenAt: new Date(),
      },
    });

    return { ok: true };
  }
}
