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
import { EditMessageDto } from './dto/edit-message.dto';
import { TogglePinMessageDto } from './dto/toggle-pin-message.dto';
import { DeleteMessageDto } from './dto/delete-message.dto';
import { ForwardMessageDto } from './dto/forward-message.dto';
import { ReactMessageDto } from './dto/react-message.dto';

type AppUser = {
  id?: string;
  sub?: string;
  userId?: string;
};

type ThreadWithRelations = Awaited<
  ReturnType<MessagesService['loadThreadOrThrow']>
>;

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

  private displayNameOf(
    user:
      | { name?: string | null; displayName?: string | null }
      | null
      | undefined,
  ) {
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

  private mapDmReactions(
    reactions: Array<{ emoji?: string | null; userId?: string | null }> | null | undefined,
    viewerId: string,
  ): Record<string, string[]> {
    const out: Record<string, string[]> = {};
    for (const reaction of reactions ?? []) {
      const emoji = String(reaction?.emoji ?? '').trim();
      const userId = String(reaction?.userId ?? '').trim();
      if (!emoji || !userId) continue;
      (out[emoji] ??= []).push(userId === viewerId ? 'me' : userId);
    }
    return out;
  }

  private formatTime(value: Date | string | null | undefined) {
    if (!value) return '';
    const date = value instanceof Date ? value : new Date(value);
    return date.toLocaleTimeString('en-US', {
      hour: 'numeric',
      minute: '2-digit',
    });
  }

  private toIsoString(value: Date | string | null | undefined) {
    if (!value) return '';
    const date = value instanceof Date ? value : new Date(value);
    return Number.isFinite(date.getTime()) ? date.toISOString() : '';
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

  private voiceDurationSeconds(message: {
    mediaMimeType?: string | null;
    text?: string | null;
  }) {
    const text = String(message?.text ?? '').trim();
    const mime = String(message?.mediaMimeType ?? '')
      .trim()
      .toLowerCase();

    const tagged = text.match(/\[duration:(\d+)\]/i);
    if (tagged) {
      const parsed = Number(tagged[1] ?? 0);
      return Number.isFinite(parsed) && parsed > 0 ? parsed : null;
    }

    if (mime.startsWith('audio/')) return null;
    return null;
  }

  private deliveryStateForMessage(
    message: { senderId: string; createdAt: Date },
    thread: {
      type: DmThreadType;
      participants: Array<{ userId: string; lastSeenAt?: Date | null }>;
    },
    viewerId: string,
  ) {
    if (message.senderId !== viewerId) {
      return {
        delivered: false,
        seen: false,
        deliveredAt: '',
        seenAt: '',
      };
    }

    const others = thread.participants.filter((p) => p.userId !== viewerId);
    if (!others.length) {
      return {
        delivered: false,
        seen: false,
        deliveredAt: '',
        seenAt: '',
      };
    }

    const deliveredToAll = others.every((p) => !!p.lastSeenAt);
    const seenToAll = others.every(
      (p) =>
        !!p.lastSeenAt && new Date(String(p.lastSeenAt)) >= message.createdAt,
    );

    const deliveredAtSource = others
      .map((p) => p.lastSeenAt)
      .filter((v): v is Date => v instanceof Date)
      .sort((a, b) => a.getTime() - b.getTime())[0];

    const seenAtSource = others
      .map((p) => p.lastSeenAt)
      .filter((v): v is Date => v instanceof Date)
      .filter((v) => v.getTime() >= message.createdAt.getTime())
      .sort((a, b) => a.getTime() - b.getTime())[0];

    return {
      delivered: deliveredToAll,
      seen: seenToAll,
      deliveredAt: deliveredAtSource ? this.formatTime(deliveredAtSource) : '',
      seenAt: seenAtSource ? this.formatTime(seenAtSource) : '',
    };
  }

  private viewerRequestState(
    thread: {
      type: DmThreadType;
      participants: Array<{ userId: string; state: DmParticipantState }>;
    },
    viewerId: string,
  ) {
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
    return viewer?.state === DmParticipantState.ACCEPTED ||
        viewer?.state === DmParticipantState.PENDING_OUTGOING;
  }

  private async userMapForIds(userIds: string[]) {
    const ids = Array.from(
      new Set(userIds.map((v) => String(v).trim()).filter((v) => v.length > 0)),
    );
    if (!ids.length)
      return new Map<
        string,
        { id: string; name: string; displayName: string | null }
      >();

    const rows = await this.prisma.user.findMany({
      where: { id: { in: ids } },
      select: { id: true, name: true, displayName: true },
    });

    return new Map(rows.map((row) => [row.id, row]));
  }

  async fetchSameSchoolPeople(user: AppUser) {
    const viewerId = this.viewerId(user);

    const viewerProfile = await this.prisma.studentProfile.findUnique({
      where: { userId: viewerId },
      select: {
        cohortId: true,
      },
    });

    if (!viewerProfile?.cohortId) {
      throw new BadRequestException('Viewer is not attached to a cohort');
    }

    const rows = await this.prisma.studentProfile.findMany({
      where: {
        cohortId: viewerProfile.cohortId,
        userId: { not: viewerId },
      },
      select: {
        userId: true,
        user: {
          select: {
            name: true,
            displayName: true,
          },
        },
      },
      orderBy: [{ userId: 'asc' }],
    });

    const existingParticipants = await this.prisma.dmParticipant.findMany({
      where: {
        userId: viewerId,
      },
      include: {
        thread: {
          select: {
            type: true,
            participants: {
              select: {
                userId: true,
              },
            },
          },
        },
      },
    });

    const existingDirectPeerIds = new Set(
      existingParticipants
        .filter((p) => p.thread?.type === DmThreadType.DIRECT)
        .flatMap((p) => p.thread?.participants ?? [])
        .map((p) => String(p.userId ?? '').trim())
        .filter((id) => id.length > 0 && id !== viewerId),
    );

    return {
      ok: true,
      items: rows
        .filter((row) => !existingDirectPeerIds.has(String(row.userId ?? '').trim()))
        .map((row) => {
          const displayName = this.displayNameOf(row.user);

          return {
            id: row.userId,
            userId: row.userId,
            name: displayName,
            displayName,
            initials: this.initialsOf(displayName),
            schoolName: '',
            gradeLabel: '',
          };
        }),
    };
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

  private async loadMessageOrThrow(
    threadId: string,
    messageId: string,
    userId: string,
  ) {
    await this.loadParticipantOrThrow(threadId, userId);

    const message = await this.prisma.dmMessage.findFirst({
      where: { id: messageId, threadId },
    });

    if (!message) {
      throw new NotFoundException('Message not found');
    }

    return message;
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

  private async threadToSummary(participant: {
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
  }) {
    const thread = participant.thread;
    const viewerId = participant.userId;
    const otherIds = thread.participants
      .filter((p) => p.userId !== viewerId)
      .map((p) => p.userId);

    const users = await this.userMapForIds([
      ...thread.participants.map((p) => p.userId),
      ...thread.messages.map((m) => m.senderId),
    ]);
    const counterpart = otherIds.length ? users.get(otherIds[0]) : null;
    const latestMessage = thread.messages.length
      ? thread.messages[thread.messages.length - 1]
      : null;

    const title =
      thread.type === DmThreadType.GROUP
        ? String(thread.title ?? '').trim() || 'Group'
        : this.displayNameOf(counterpart);

    const subtitle = latestMessage
      ? (() => {
          const body = String(latestMessage.text ?? '').trim();
          if (body) {
            if (thread.type === DmThreadType.GROUP) {
              const senderName = this.displayNameOf(
                users.get(latestMessage.senderId),
              );
              return `${senderName}: ${body}`;
            }
            return body;
          }

          const label = this.kindLabel(latestMessage.kind);
          if (thread.type === DmThreadType.GROUP) {
            const senderName = this.displayNameOf(
              users.get(latestMessage.senderId),
            );
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
            (m) =>
              m.senderId !== viewerId && m.createdAt > participant.lastSeenAt!,
          ).length;

    return {
      id: thread.id,
      type: String(thread.type).toLowerCase(),
      title,
      subtitle,
      isGroup: thread.type === DmThreadType.GROUP,
      isUnread: unreadCount > 0,
      unreadCount,
      lastMessageAt: this.formatTime(
        latestMessage?.createdAt ?? thread.updatedAt ?? thread.createdAt,
      ),
      lastMessageAtRaw: this.toIsoString(
        latestMessage?.createdAt ?? thread.updatedAt ?? thread.createdAt,
      ),
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

    const byId = new Map(thread.messages.map((m) => [m.id, m] as const));

    const previewFor = (message: any) => {
      const kind = String(message?.kind ?? 'TEXT').toUpperCase();
      const text = String(message?.text ?? '').trim();
      if (text) return text;
      if (kind == 'IMAGE') return 'Photo';
      if (kind == 'VOICE') return 'Voice note';
      if (kind == 'VIDEO') return 'Video';
      if (kind == 'FILE') return 'Attachment';
      return 'Message';
    };

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
      messages: thread.messages.map((m) => {
        const replied = m.replyToMessageId
          ? byId.get(m.replyToMessageId)
          : null;
        const delivery = this.deliveryStateForMessage(m, thread, viewerId);
        return {
          id: m.id,
          senderId: m.senderId,
          senderName: this.displayNameOf(users.get(m.senderId)),
          text: (() => { const t = String(m.text ?? '').trim(); if (t.startsWith('Forwarded\n')) return t.slice('Forwarded\n'.length); if (t === 'Forwarded') return ''; return t; })(),
          timeLabel: this.formatTime(m.createdAt),
          sentAtRaw: this.toIsoString(m.createdAt),
          createdAt: this.toIsoString(m.createdAt),
          isMine: m.senderId === viewerId,
          reaction:
            Array.isArray(m.reactions) && m.reactions.length
              ? String(m.reactions[0]?.emoji ?? '').trim() || null
              : null,
          reactions: this.mapDmReactions(m.reactions as Array<{ emoji?: string | null; userId?: string | null }>, viewerId),
          isPinned: !!m.isPinned,
          edited: !!m.editedAt,
          forwarded: !!m.forwardedFromId || (() => { const t = String(m.text ?? '').trim(); return t.startsWith('Forwarded\n') || t === 'Forwarded'; })(),
          deleteState: String(m.deleteMode ?? 'VISIBLE'),
          delivered: delivery.delivered,
          seen: delivery.seen,
          deliveredAt: delivery.deliveredAt,
          seenAt: delivery.seenAt,
          kind: String(m.kind),
          mediaUrl: m.mediaUrl ?? null,
          mediaMimeType: m.mediaMimeType ?? null,
          voiceDurationSeconds:
            String(m.kind) === 'VOICE' ? this.voiceDurationSeconds(m) : null,
          voicePlayed: false,
          replyToMessageId: m.replyToMessageId ?? null,
          replyPreview: replied
            ? {
                id: replied.id,
                senderName: this.displayNameOf(users.get(replied.senderId)),
                text: previewFor(replied),
                kind: String(replied.kind),
                mediaUrl: replied.mediaUrl ?? null,
              }
            : null,
        };
      }),
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

    const items = await Promise.all(
      participants.map((p) => this.threadToSummary(p)),
    );
    items.sort(
      (a, b) =>
        new Date(String(b.lastMessageAtRaw || 0)).getTime() -
        new Date(String(a.lastMessageAtRaw || 0)).getTime(),
    );
    return { items };
  }

  async fetchBlocked(user: AppUser) {
    const userId = this.viewerId(user);

    const threads = await this.prisma.dmThread.findMany({
      where: {
        type: DmThreadType.DIRECT,
        participants: {
          some: {
            userId,
            state: DmParticipantState.BLOCKED,
          },
        },
      },
      include: {
        participants: true,
      },
      orderBy: [{ updatedAt: 'desc' }, { id: 'desc' }],
    });

    const otherIds = Array.from(
      new Set(
        threads
          .map((thread) =>
            thread.participants.find((p) => p.userId !== userId)?.userId ?? '',
          )
          .filter((v) => String(v).trim().length > 0),
      ),
    );

    const users = otherIds.length
      ? await this.prisma.user.findMany({
          where: {
            id: { in: otherIds },
          },
          select: {
            id: true,
            name: true,
            displayName: true,
          },
        })
      : [];

    const userById = new Map(users.map((u) => [u.id, u]));

    const initialsOf = (value: string) => {
      const parts = String(value || '')
        .trim()
        .split(/\s+/)
        .filter(Boolean)
        .slice(0, 2);
      return parts.map((p) => p[0]?.toUpperCase() ?? '').join(',') || '?';
    };

    return {
      ok: true,
      items: threads
        .map((thread) => {
          const otherId =
            thread.participants.find((p) => p.userId !== userId)?.userId ?? '';
          if (!otherId) return null;
          const other = userById.get(otherId);
          const displayName = String(
            other?.displayName ?? other?.name ?? 'Unknown user',
          ).trim();
          return {
            threadId: thread.id,
            userId: otherId,
            displayName,
            initials: initialsOf(displayName),
          };
        })
        .filter(Boolean),
    };
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
    if (recipientUserId === userId) {
      throw new BadRequestException('Cannot message yourself');
    }

    await this.requireUser(userId);
    await this.requireUser(recipientUserId);

    const existing = await this.prisma.dmThread.findMany({
      where: {
        type: DmThreadType.DIRECT,
        participants: {
          some: { userId },
        },
      },
      include: {
        participants: true,
        messages: {
          orderBy: [{ createdAt: 'asc' }],
        },
      },
    });

    const exact = existing.find((thread) => {
      const ids = thread.participants.map((p) => p.userId).sort();
      return ids.length == 2 && ids[0] === [userId, recipientUserId].sort()[0] && ids[1] === [userId, recipientUserId].sort()[1];
    });

    const thread =
      exact ??
      (await this.prisma.dmThread.create({
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
        },
      }));

    if (firstMessage) {
      const participant = await this.loadParticipantOrThrow(thread.id, userId);
      const alreadyHasMessages = await this.prisma.dmMessage.count({
        where: { threadId: thread.id },
      });

      if (
        participant.state === DmParticipantState.PENDING_OUTGOING &&
        alreadyHasMessages === 0
      ) {
        await this.prisma.dmMessage.create({
          data: {
            threadId: thread.id,
            senderId: userId,
            text: firstMessage,
            kind: DmMessageKind.TEXT,
          },
        });
      }
    }

    return this.fetchThread(user, thread.id);
  }

  async approveRequest(user: AppUser, dto: ApproveMessageRequestDto) {
    const userId = this.viewerId(user);
    const threadId = String(dto.threadId ?? '').trim();
    if (!threadId) {
      throw new BadRequestException('threadId is required');
    }

    const thread = await this.loadThreadOrThrow(threadId, userId);
    const viewerParticipant = thread.participants.find(
      (p) => p.userId === userId,
    );

    if (
      !viewerParticipant ||
      viewerParticipant.state !== DmParticipantState.PENDING_INCOMING
    ) {
      throw new ForbiddenException(
        'Only the receiver can approve this request',
      );
    }

    if (thread.type === DmThreadType.GROUP) {
      await this.prisma.dmParticipant.update({
        where: {
          threadId_userId: {
            threadId,
            userId,
          },
        },
        data: { state: DmParticipantState.ACCEPTED },
      });
      return { ok: true };
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
    const viewerParticipant = thread.participants.find(
      (p) => p.userId === userId,
    );

    if (
      !viewerParticipant ||
      viewerParticipant.state !== DmParticipantState.PENDING_INCOMING
    ) {
      throw new ForbiddenException('Only the receiver can block this request');
    }

    if (thread.type === DmThreadType.GROUP) {
      await this.prisma.dmParticipant.delete({
        where: {
          threadId_userId: {
            threadId,
            userId,
          },
        },
      });
      return { ok: true };
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
              state: DmParticipantState.PENDING_INCOMING,
            })),
          ],
        },
      },
    });

    const creator = await this.requireUser(userId);
    await this.prisma.dmMessage.create({
      data: {
        threadId: thread.id,
        senderId: userId,
        kind: DmMessageKind.TEXT,
        text: `[SYSTEM] ${this.displayNameOf(creator)} created the group`,
      },
    });

    return this.fetchThread(user, thread.id);
  }

  async leaveGroup(user: AppUser, dto: BlockMessageRequestDto) {
    const userId = this.viewerId(user);
    const threadId = String(dto.threadId ?? '').trim();
    if (!threadId) {
      throw new BadRequestException('threadId is required');
    }

    const thread = await this.loadThreadOrThrow(threadId, userId);
    if (thread.type !== DmThreadType.GROUP) {
      throw new BadRequestException('Only group threads can be left');
    }

    const me = thread.participants.find((p) => p.userId === userId);
    if (!me) {
      throw new ForbiddenException('No access to this thread');
    }

    const acceptedOthers = thread.participants
      .filter((p) => p.userId !== userId && p.state === DmParticipantState.ACCEPTED)
      .sort((a, b) => String(a.userId).localeCompare(String(b.userId)));

    await this.prisma.$transaction(async (tx) => {
      if (me.role === DmParticipantRole.ADMIN && acceptedOthers.length > 0) {
        await tx.dmParticipant.update({
          where: {
            threadId_userId: {
              threadId,
              userId: acceptedOthers[0]!.userId,
            },
          },
          data: {
            role: DmParticipantRole.ADMIN,
          },
        });
      }

      await tx.dmParticipant.delete({
        where: {
          threadId_userId: {
            threadId,
            userId,
          },
        },
      });
    });

    return { ok: true };
  }
    async blockDirectThread(user: AppUser, dto: BlockMessageRequestDto) {
    const userId = this.viewerId(user);
    const threadId = String(dto.threadId ?? '').trim();
    if (!threadId) {
      throw new BadRequestException('threadId is required');
    }

    const thread = await this.loadThreadOrThrow(threadId, userId);
    if (thread.type !== DmThreadType.DIRECT) {
      throw new BadRequestException('Only direct threads can be blocked here');
    }

    await this.prisma.dmParticipant.updateMany({
      where: { threadId },
      data: { state: DmParticipantState.BLOCKED },
    });

    return { ok: true };
  }




async unblockDirectThread(user: AppUser, dto: BlockMessageRequestDto) {
    const userId = this.viewerId(user);
    const threadId = String(dto.threadId ?? '').trim();
    if (!threadId) {
      throw new BadRequestException('threadId is required');
    }

    const thread = await this.loadThreadOrThrow(threadId, userId);
    if (thread.type !== DmThreadType.DIRECT) {
      throw new BadRequestException('Only direct threads can be unblocked here');
    }

    await this.prisma.dmParticipant.updateMany({
      where: { threadId },
      data: { state: DmParticipantState.ACCEPTED },
    });

    return { ok: true };
  }

  async sendMessage(user: AppUser, dto: SendMessageDto) {
    const userId = this.viewerId(user);
    const threadId = String(dto.threadId ?? '').trim();
    const text = String(dto.text ?? '').trim();
    const mediaUrl = String(dto.mediaUrl ?? '').trim();
    const mediaMimeType = String(dto.mediaMimeType ?? '').trim();
    const rawKind = String(dto.kind ?? '')
      .trim()
      .toUpperCase();
    const kind = (rawKind || (mediaUrl ? 'FILE' : 'TEXT')) as DmMessageKind;
    const replyToMessageId = String((dto as any).replyToMessageId ?? '').trim();

    if (!threadId) {
      throw new BadRequestException('threadId is required');
    }

    const participant = await this.loadParticipantOrThrow(threadId, userId);

    if (participant.state === DmParticipantState.BLOCKED) {
      throw new ForbiddenException('Thread is blocked');
    }
    const canSendWhilePending =
      participant.thread.type === DmThreadType.DIRECT &&
      participant.state === DmParticipantState.PENDING_OUTGOING;
    if (
      participant.state !== DmParticipantState.ACCEPTED &&
      !canSendWhilePending
    ) {
      throw new ForbiddenException('Request is not approved yet');
    }

    const existingMessageCount = await this.prisma.dmMessage.count({
      where: { threadId },
    });

    if (
      participant.thread.type === DmThreadType.DIRECT &&
      existingMessageCount === 0
    ) {
      const sender = await this.requireUser(userId);
      await this.prisma.dmMessage.create({
        data: {
          threadId,
          senderId: userId,
          kind: DmMessageKind.TEXT,
          text: `[SYSTEM] ${this.displayNameOf(sender)} started the chat`,
        },
      });
    }
    if (!text && !mediaUrl) {
      throw new BadRequestException('text or mediaUrl is required');
    }

    if (replyToMessageId) {
      const replied = await this.prisma.dmMessage.findUnique({
        where: { id: replyToMessageId },
        select: { id: true, threadId: true },
      });

      if (!replied || replied.threadId !== threadId) {
        throw new BadRequestException('replyToMessageId is invalid');
      }
    }

    const created = await this.prisma.dmMessage.create({
      data: {
        threadId,
        senderId: userId,
        kind,
        text: text || null,
        mediaUrl: mediaUrl || null,
        mediaMimeType: mediaMimeType || null,
        replyToMessageId: replyToMessageId || null,
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
        sentAtRaw: this.toIsoString(created.createdAt),
        createdAt: this.toIsoString(created.createdAt),
        isMine: true,
        reaction:
          Array.isArray(created.reactions) && created.reactions.length
            ? String(created.reactions[0]?.emoji ?? '').trim() || null
            : null,
        reactions: this.mapDmReactions(created.reactions as Array<{ emoji?: string | null; userId?: string | null }>, userId),
        isPinned: !!created.isPinned,
        edited: !!created.editedAt,
        forwarded: !!created.forwardedFromId,
        deleteState: String(created.deleteMode ?? 'VISIBLE'),
        delivered: false,
        seen: false,
        deliveredAt: '',
        seenAt: '',
        kind: String(created.kind),
        mediaUrl: created.mediaUrl ?? null,
        mediaMimeType: created.mediaMimeType ?? null,
        voiceDurationSeconds:
          String(created.kind) === 'VOICE'
            ? this.voiceDurationSeconds(created)
            : null,
        voicePlayed: false,
        replyToMessageId: created.replyToMessageId ?? null,
      },
    };
  }

  async editMessage(user: AppUser, dto: EditMessageDto) {
    const userId = this.viewerId(user);
    const threadId = String(dto.threadId ?? '').trim();
    const messageId = String(dto.messageId ?? '').trim();
    const text = String(dto.text ?? '').trim();

    if (!threadId || !messageId || !text) {
      throw new BadRequestException(
        'threadId, messageId, and text are required',
      );
    }

    const message = await this.loadMessageOrThrow(threadId, messageId, userId);

    const nextText = text;
    const currentText = String(message.text ?? '').trim();

    if (nextText === currentText) {
      return { ok: true, edited: false };
    }

    if (message.mediaUrl) {
      throw new BadRequestException('Editing media messages is not supported');
    }

    await this.prisma.dmMessage.update({
      where: { id: messageId },
      data: {
        text: nextText,
        editedAt: new Date(),
      },
    });

    return { ok: true, edited: true };
  }
  async togglePin(user: AppUser, dto: TogglePinMessageDto) {
    const userId = this.viewerId(user);
    const threadId = String(dto.threadId ?? '').trim();
    const messageId = String(dto.messageId ?? '').trim();

    if (!threadId || !messageId) {
      throw new BadRequestException('threadId and messageId are required');
    }

    const participant = await this.loadParticipantOrThrow(threadId, userId);
    const message = await this.loadMessageOrThrow(threadId, messageId, userId);

    if (
      participant.thread.type !== DmThreadType.GROUP &&
      message.senderId !== userId
    ) {
      throw new ForbiddenException(
        'Only your own direct-message messages can be pinned',
      );
    }

    const updated = await this.prisma.dmMessage.update({
      where: { id: messageId },
      data: { isPinned: !message.isPinned },
      select: { isPinned: true },
    });

    return { ok: true, isPinned: updated.isPinned };
  }

  async deleteMessage(user: AppUser, dto: DeleteMessageDto) {
    const userId = this.viewerId(user);
    const threadId = String(dto.threadId ?? '').trim();
    const messageId = String(dto.messageId ?? '').trim();
    const mode = String(dto.mode ?? 'deleteForMe').trim();

    if (!threadId || !messageId) {
      throw new BadRequestException('threadId and messageId are required');
    }

    const message = await this.loadMessageOrThrow(threadId, messageId, userId);

    if (mode === 'deleteForEveryone') {
    // allow any participant to delete for self


      await this.prisma.dmMessage.update({
        where: { id: messageId },
        data: {
          text: 'This message was deleted',
          mediaUrl: null,
          mediaMimeType: null,
          deletedAt: new Date(),
          deleteMode: 'DELETED_FOR_EVERYONE',
        },
      });

      return { ok: true };
    }

    // allow any participant to delete for self

    await this.prisma.dmMessage.update({
      where: { id: messageId },
      data: {
        deletedAt: new Date(),
        deleteMode: 'DELETED_FOR_ME',
      },
    });

    return { ok: true };
  }

  async reactMessage(user: AppUser, dto: ReactMessageDto) {
    const userId = this.viewerId(user);
    const threadId = String(dto.threadId ?? '').trim();
    const messageId = String(dto.messageId ?? '').trim();
    const emoji = String(dto.emoji ?? '').trim();

    if (!threadId || !messageId) {
      throw new BadRequestException('threadId and messageId are required');
    }

    await this.loadParticipantOrThrow(threadId, userId);
    await this.loadMessageOrThrow(threadId, messageId, userId);

    const existing = await this.prisma.dmReaction.findFirst({
      where: {
        messageId,
        userId,
      },
      select: {
        id: true,
        emoji: true,
      },
    });

    if (!emoji) {
      if (existing) {
        await this.prisma.dmReaction.delete({
          where: {
            id: existing.id,
          },
        });
      }
      return { ok: true, reaction: null };
    }

    if (existing) {
      if (existing.emoji === emoji) {
        await this.prisma.dmReaction.delete({
          where: {
            id: existing.id,
          },
        });
        return { ok: true, reaction: null };
      }

      const updated = await this.prisma.dmReaction.update({
        where: {
          id: existing.id,
        },
        data: {
          emoji,
        },
        select: {
          emoji: true,
        },
      });

      return { ok: true, reaction: updated.emoji };
    }

    const created = await this.prisma.dmReaction.create({
      data: {
        messageId,
        userId,
        emoji,
      },
      select: {
        emoji: true,
      },
    });

    return { ok: true, reaction: created.emoji };
  }

  async forwardMessage(user: AppUser, dto: ForwardMessageDto) {
    const userId = this.viewerId(user);
    const fromThreadId = String(dto.fromThreadId ?? '').trim();
    const messageId = String(dto.messageId ?? '').trim();
    const targetThreadIds = Array.from(
      new Set(
        (dto.targetThreadIds ?? [])
          .map((v) => String(v ?? '').trim())
          .filter(Boolean),
      ),
    );

    if (!fromThreadId || !messageId || !targetThreadIds.length) {
      throw new BadRequestException(
        'fromThreadId, messageId, and targetThreadIds are required',
      );
    }

    const source = await this.loadMessageOrThrow(
      fromThreadId,
      messageId,
      userId,
    );

    for (const targetThreadId of targetThreadIds) {
      const sourceText = String(source.text ?? '').trim();
      const sourceMime = String(source.mediaMimeType ?? '').trim().toLowerCase();
      const taggedDuration = sourceText.match(/\[duration:(\d+)\]/i);
      const duration =
        taggedDuration && Number(taggedDuration[1] ?? 0) > 0
          ? Number(taggedDuration[1])
          : 0;
      const forwardedText =
        String(source.kind) === 'VOICE' && duration > 0
          ? (sourceText || `[VOICE] Voice message [duration:${duration}]`)
          : source.text;

      // Try DM participant first
      const dmParticipant = await this.prisma.dmParticipant.findUnique({
        where: { threadId_userId: { threadId: targetThreadId, userId } },
      });

      if (dmParticipant) {
        if (dmParticipant.state !== DmParticipantState.ACCEPTED) {
          throw new ForbiddenException('Cannot forward into a non-approved thread');
        }
        await this.prisma.dmMessage.create({
          data: {
            threadId: targetThreadId,
            senderId: userId,
            kind: source.kind,
            text: forwardedText,
            mediaUrl: source.mediaUrl,
            mediaMimeType: sourceMime || source.mediaMimeType,
            forwardedFromId: source.id,
          },
        });
        await this.prisma.dmParticipant.update({
          where: { threadId_userId: { threadId: targetThreadId, userId } },
          data: { lastSeenAt: new Date() },
        });
      } else {
        // Try classroom target
        const viewerProfile = await this.prisma.studentProfile.findUnique({
          where: { userId },
          select: { cohortId: true },
        });
        if (!viewerProfile?.cohortId) {
          throw new BadRequestException('Invalid target thread');
        }
        const course = await this.prisma.course.findFirst({
          where: { id: targetThreadId, cohortId: viewerProfile.cohortId },
          select: { id: true },
        });
        if (!course) {
          throw new BadRequestException('Invalid target thread');
        }
        await this.prisma.classroomMessage.create({
          data: {
            courseId: targetThreadId,
            senderUserId: userId,
            kind: source.kind as any,
            text: forwardedText != null ? `Forwarded\n${forwardedText}` : 'Forwarded',
            mediaUrl: source.mediaUrl ?? null,
            mediaMime: sourceMime || null,
            durationSec: duration > 0 ? duration : null,
          },
        });
      }
    }

    return { ok: true };
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

  // ── Group member management ─────────────────────────────────────────────

  async getThreadInfo(user: AppUser, threadId: string) {
    const userId = this.viewerId(user);
    const member = await this.prisma.messageThreadMember.findUnique({
      where: { threadId_userId: { threadId, userId } },
      include: {
        thread: {
          include: {
            members: {
              include: { user: { select: { id: true, name: true, displayName: true, email: true } } },
              orderBy: { joinedAt: 'asc' },
            },
          },
        },
      },
    });
    if (!member) throw new BadRequestException('Not a member of this thread');
    const thread = member.thread;
    return {
      ok: true,
      thread: {
        id: thread.id,
        type: thread.type,
        title: thread.title,
        groupAvatarUrl: (thread as any).groupAvatarUrl ?? null,
        createdAt: thread.createdAt,
        myRole: member.role,
        isMuted: member.isMuted,
        members: thread.members.map((m: any) => ({
          userId: m.userId,
          name: m.user?.displayName ?? m.user?.name ?? m.user?.email ?? '',
          role: m.role,
          joinedAt: m.joinedAt,
          isMuted: m.isMuted,
        })),
      },
    };
  }

  async addGroupMember(user: AppUser, threadId: string, body: { userId?: string; email?: string }) {
    const requesterId = this.viewerId(user);
    const member = await this.prisma.messageThreadMember.findUnique({
      where: { threadId_userId: { threadId, userId: requesterId } },
      select: { role: true },
    });
    if (!member) throw new BadRequestException('Not a member');
    if (member.role !== 'ADMIN') throw new ForbiddenException('Admin only');
    const identifier = String(body?.email ?? body?.userId ?? '').trim();
    if (!identifier) throw new BadRequestException('userId or email required');
    const targetUser = identifier.includes('@')
      ? await this.prisma.user.findUnique({ where: { email: identifier }, select: { id: true } })
      : await this.prisma.user.findUnique({ where: { id: identifier }, select: { id: true } });
    if (!targetUser) throw new BadRequestException('User not found');
    await this.prisma.messageThreadMember.upsert({
      where: { threadId_userId: { threadId, userId: targetUser.id } },
      update: {},
      create: { threadId, userId: targetUser.id, role: 'MEMBER' },
    });
    return { ok: true };
  }

  async removeGroupMember(user: AppUser, threadId: string, targetUserId: string) {
    const requesterId = this.viewerId(user);
    if (requesterId !== targetUserId) {
      const member = await this.prisma.messageThreadMember.findUnique({
        where: { threadId_userId: { threadId, userId: requesterId } },
        select: { role: true },
      });
      if (!member) throw new BadRequestException('Not a member');
      if (member.role !== 'ADMIN') throw new ForbiddenException('Admin only');
    }
    await this.prisma.messageThreadMember.deleteMany({ where: { threadId, userId: targetUserId } });
    return { ok: true };
  }

  async updateGroupMemberRole(user: AppUser, threadId: string, targetUserId: string, body: { role?: string }) {
    const requesterId = this.viewerId(user);
    const member = await this.prisma.messageThreadMember.findUnique({
      where: { threadId_userId: { threadId, userId: requesterId } },
      select: { role: true },
    });
    if (!member) throw new BadRequestException('Not a member');
    if (member.role !== 'ADMIN') throw new ForbiddenException('Admin only');
    const role = (body?.role ?? '').toUpperCase() === 'ADMIN' ? 'ADMIN' : 'MEMBER';
    await this.prisma.messageThreadMember.update({
      where: { threadId_userId: { threadId, userId: targetUserId } },
      data: { role },
    });
    return { ok: true, role };
  }

  async toggleMuteThread(user: AppUser, threadId: string) {
    const userId = this.viewerId(user);
    const member = await this.prisma.messageThreadMember.findUnique({
      where: { threadId_userId: { threadId, userId } },
      select: { isMuted: true },
    });
    if (!member) throw new BadRequestException('Not a member');
    const isMuted = !member.isMuted;
    await this.prisma.messageThreadMember.update({
      where: { threadId_userId: { threadId, userId } },
      data: { isMuted },
    });
    return { ok: true, isMuted };
  }

  async updateGroupTitle(user: AppUser, threadId: string, body: { title?: string }) {
    const userId = this.viewerId(user);
    const member = await this.prisma.messageThreadMember.findUnique({
      where: { threadId_userId: { threadId, userId } },
      select: { role: true },
    });
    if (!member) throw new BadRequestException('Not a member');
    if (member.role !== 'ADMIN') throw new ForbiddenException('Admin only');
    const title = String(body?.title ?? '').trim();
    if (!title) throw new BadRequestException('title required');
    await this.prisma.messageThread.update({ where: { id: threadId }, data: { title } });
    return { ok: true };
  }
}
