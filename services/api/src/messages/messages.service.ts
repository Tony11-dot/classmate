import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateDirectRequestDto } from './dto/create-direct-request.dto';
import { ApproveMessageRequestDto } from './dto/approve-message-request.dto';
import { BlockMessageRequestDto } from './dto/block-message-request.dto';
import { CreateGroupThreadDto } from './dto/create-group-thread.dto';

type AppUser = {
  id?: string;
  sub?: string;
  userId?: string;
};

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

  private displayNameOf(user: { name?: string | null; displayName?: string | null }) {
    return String(user.displayName ?? user.name ?? '').trim() || 'Unknown';
  }

  private initialsOf(name: string) {
    const parts = name
      .split(' ')
      .map((v) => v.trim())
      .where((v) => v.length > 0)
      .slice(0, 2);
    if (!parts.length) return '??';
    return parts.map((v) => v[0]!.toUpperCase()).join();
  }

  private async requireMembership(threadId: string, userId: string) {
    const membership = await this.prisma.messageThreadMember.findUnique({
      where: {
        threadId_userId: {
          threadId,
          userId,
        },
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            displayName: true,
          },
        },
        thread: true,
      },
    });

    if (!membership) {
      throw new ForbiddenException('No access to this thread');
    }

    if (membership.isBlocked) {
      throw new ForbiddenException('Thread is blocked');
    }

    return membership;
  }

  private async threadToSummary(thread: any, viewerId: string) {
    const viewerMembership = (thread.members ?? []).find(
      (m: any) => String(m.userId) === viewerId,
    );
    const otherMembers = (thread.members ?? []).filter(
      (m: any) => String(m.userId) !== viewerId,
    );
    const counterpart = otherMembers[0]?.user;
    const title =
      thread.type === 'GROUP'
        ? String(thread.title ?? 'Group').trim() || 'Group'
        : this.displayNameOf(counterpart ?? {});

    const initials =
      thread.type === 'GROUP'
        ? this.initialsOf(title)
        : this.initialsOf(this.displayNameOf(counterpart ?? {}));

    const subtitleSource = thread.messages?.[0];
    const subtitle = subtitleSource
      ? String(subtitleSource.text ?? '').trim() || this.kindLabel(subtitleSource.kind)
      : thread.requestState === 'PENDING_INCOMING'
      ? 'Sent you a message request'
      : 'No messages yet';

    const unreadCount = 0;
    const lastMessageAt = thread.lastMessageAt
      ? new Date(thread.lastMessageAt).toLocaleTimeString('en-US', {
          hour: 'numeric',
          minute: '2-digit',
        })
      : '';

    return {
      id: thread.id,
      type: String(thread.type).toLowerCase(),
      title,
      subtitle,
      isGroup: String(thread.type) === 'GROUP',
      isUnread: unreadCount > 0,
      unreadCount,
      lastMessageAt,
      requestState: this.requestStateForViewer(thread, viewerId),
      initials,
      groupAvatarUrl: thread.groupAvatarUrl ?? null,
      canSend: this.canViewerSend(thread, viewerId),
    };
  }

  private requestStateForViewer(thread: any, viewerId: string) {
    const state = String(thread.requestState ?? 'NONE');
    if (state === 'PENDING_INCOMING' && String(thread.requestTargetUserId ?? '') === viewerId) {
      return 'pendingIncoming';
    }
    if (state === 'PENDING_INCOMING') {
      return 'pendingOutgoing';
    }
    if (state === 'APPROVED') return 'approved';
    if (state === 'BLOCKED') return 'blocked';
    return 'none';
  }

  private canViewerSend(thread: any, viewerId: string) {
    const state = this.requestStateForViewer(thread, viewerId);
    return state === 'approved' || state === 'none';
  }

  private kindLabel(kind: unknown) {
    switch (String(kind ?? 'TEXT')) {
      case 'IMAGE':
        return 'Photo';
      case 'VOICE':
        return 'Voice note';
      case 'FILE':
        return 'File';
      case 'SYSTEM':
        return 'System';
      default:
        return 'Message';
    }
  }

  private async messageToClient(message: any, viewerId: string) {
    const senderName = this.displayNameOf(message.sender ?? {});
    return {
      id: message.id,
      senderId: message.senderId,
      senderName,
      text: String(message.text ?? '').trim(),
      timeLabel: new Date(message.createdAt).toLocaleTimeString('en-US', {
        hour: 'numeric',
        minute: '2-digit',
      }),
      isMine: String(message.senderId) === viewerId,
      reaction:
        Array.isArray(message.reactions) && message.reactions.length
          ? String(message.reactions[0]?.emoji ?? '').trim() || null
          : null,
      isPinned: false,
      kind: String(message.kind ?? 'TEXT'),
      mediaUrl: message.mediaUrl ?? null,
      replyToMessageId: message.replyToMessageId ?? null,
    };
  }

  async fetchInbox(user: AppUser) {
    const viewerId = this.viewerId(user);

    const threads = await this.prisma.messageThread.findMany({
      where: {
        members: {
          some: {
            userId: viewerId,
            isArchived: false,
          },
        },
      },
      include: {
        members: {
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
          take: 1,
          orderBy: { createdAt: 'desc' },
        },
      },
      orderBy: [
        { lastMessageAt: 'desc' },
        { createdAt: 'desc' },
      ],
    });

    return {
      items: await Promise.all(threads.map((t) => this.threadToSummary(t, viewerId))),
    };
  }

  async fetchThread(user: AppUser, threadId: string) {
    const viewerId = this.viewerId(user);
    await this.requireMembership(threadId, viewerId);

    const thread = await this.prisma.messageThread.findUnique({
      where: { id: threadId },
      include: {
        members: {
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
          orderBy: { createdAt: 'asc' },
          include: {
            sender: {
              select: {
                id: true,
                name: true,
                displayName: true,
              },
            },
            reactions: true,
          },
        },
      },
    });

    if (!thread) {
      throw new NotFoundException('Thread not found');
    }

    const otherMembers = thread.members.filter((m) => String(m.userId) !== viewerId);
    const counterpart = otherMembers[0]?.user;
    const title =
      thread.type === 'GROUP'
        ? String(thread.title ?? 'Group').trim() || 'Group'
        : this.displayNameOf(counterpart ?? {});

    return {
      id: thread.id,
      title,
      subtitle:
        thread.type === 'GROUP'
          ? `${thread.members.length} members`
          : 'Direct message',
      isGroup: String(thread.type) === 'GROUP',
      requestState: this.requestStateForViewer(thread, viewerId),
      participants: thread.members.map((m) => ({
        userId: m.userId,
        displayName: this.displayNameOf(m.user),
        initials: this.initialsOf(this.displayNameOf(m.user)),
        isAdmin: String(m.role).toUpperCase() === 'ADMIN',
        isBlocked: !!m.isBlocked,
      })),
      messages: await Promise.all(
        thread.messages.map((message) => this.messageToClient(message, viewerId)),
      ),
      canSend: this.canViewerSend(thread, viewerId),
    };
  }

  async fetchRequest(user: AppUser, threadId: string) {
    const detail = await this.fetchThread(user, threadId);
    if (!String(detail.requestState).startsWith('pending')) {
      throw new BadRequestException('Thread is not a pending request');
    }
    return detail;
  }

  async createDirectRequest(user: AppUser, dto: CreateDirectRequestDto) {
    const creatorId = this.viewerId(user);
    const targetId = String(dto.recipientUserId ?? '').trim();
    const firstMessage = String(dto.firstMessage ?? '').trim();

    if (!targetId) {
      throw new BadRequestException('recipientUserId is required');
    }
    if (!firstMessage) {
      throw new BadRequestException('firstMessage is required');
    }
    if (creatorId === targetId) {
      throw new BadRequestException('Cannot message yourself');
    }

    await this.requireUser(creatorId);
    await this.requireUser(targetId);

    const existing = await this.prisma.messageThread.findFirst({
      where: {
        type: 'DIRECT',
        members: {
          every: {
            userId: {
              in: [creatorId, targetId],
            },
          },
        },
      },
      include: {
        members: true,
      },
    });

    if (existing && existing.members.length === 2) {
      return this.fetchThread(user, existing.id);
    }

    const thread = await this.prisma.messageThread.create({
      data: {
        type: 'DIRECT',
        createdByUserId: creatorId,
        requestState: 'PENDING_INCOMING',
        requestTargetUserId: targetId,
        lastMessageAt: new Date(),
        members: {
          create: [
            { userId: creatorId, role: 'MEMBER' },
            { userId: targetId, role: 'MEMBER' },
          ],
        },
        messages: {
          create: {
            senderId: creatorId,
            kind: 'TEXT',
            text: firstMessage,
          },
        },
      },
    });

    return this.fetchThread(user, thread.id);
  }

  async approveRequest(user: AppUser, dto: ApproveMessageRequestDto) {
    const viewerId = this.viewerId(user);
    const threadId = String(dto.threadId ?? '').trim();
    if (!threadId) throw new BadRequestException('threadId is required');

    const membership = await this.requireMembership(threadId, viewerId);
    const thread = membership.thread;

    if (String(thread.requestTargetUserId ?? '') !== viewerId) {
      throw new ForbiddenException('Only the receiver can approve this request');
    }

    await this.prisma.messageThread.update({
      where: { id: threadId },
      data: {
        requestState: 'APPROVED',
        requestDecisionById: viewerId,
        requestDecisionAt: new Date(),
      },
    });

    return { ok: true };
  }

  async blockRequest(user: AppUser, dto: BlockMessageRequestDto) {
    const viewerId = this.viewerId(user);
    const threadId = String(dto.threadId ?? '').trim();
    if (!threadId) throw new BadRequestException('threadId is required');

    const membership = await this.requireMembership(threadId, viewerId);
    const thread = membership.thread;

    if (String(thread.requestTargetUserId ?? '') !== viewerId) {
      throw new ForbiddenException('Only the receiver can block this request');
    }

    await this.prisma.$transaction([
      this.prisma.messageThread.update({
        where: { id: threadId },
        data: {
          requestState: 'BLOCKED',
          requestDecisionById: viewerId,
          requestDecisionAt: new Date(),
        },
      }),
      this.prisma.messageThreadMember.update({
        where: {
          threadId_userId: {
            threadId,
            userId: viewerId,
          },
        },
        data: {
          isBlocked: true,
        },
      }),
    ]);

    return { ok: true };
  }

  async createGroup(user: AppUser, dto: CreateGroupThreadDto) {
    const creatorId = this.viewerId(user);
    const title = String(dto.title ?? '').trim();
    const memberIds = Array.from(
      new Set(
        (dto.memberIds ?? [])
          .map((v) => String(v ?? '').trim())
          .filter((v) => v.length > 0 && v !== creatorId),
      ),
    );

    if (!title) throw new BadRequestException('title is required');
    if (memberIds.length < 1) {
      throw new BadRequestException('At least one member is required');
    }

    await this.requireUser(creatorId);
    for (const memberId of memberIds) {
      await this.requireUser(memberId);
    }

    const thread = await this.prisma.messageThread.create({
      data: {
        type: 'GROUP',
        title,
        createdByUserId: creatorId,
        requestState: 'NONE',
        members: {
          create: [
            { userId: creatorId, role: 'ADMIN' },
            ...memberIds.map((userId) => ({
              userId,
              role: 'MEMBER',
            })),
          ],
        },
      },
    });

    return this.fetchThread(user, thread.id);
  }
}
