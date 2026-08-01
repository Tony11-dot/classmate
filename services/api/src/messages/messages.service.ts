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
import { RealtimeService } from '../realtime/realtime.service';
import { NotificationsHubService } from '../notifications/notifications-hub.service';

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
  /// How many recent messages the inbox loads per thread. Big enough that an
  /// unread badge is exact in practice, small enough that a large inbox stays
  /// one bounded query.
  private static readonly INBOX_MESSAGE_WINDOW = 30;

  constructor(
    private readonly prisma: PrismaService,
    private readonly realtime: RealtimeService,
    private readonly hub: NotificationsHubService,
  ) {}

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
      select: { id: true, name: true } as any,
    });
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return user;
  }

  private displayNameOf(
    user: { name?: string | null } | null | undefined,
  ) {
    // `name` is the single full-name source of truth now.
    const n = String(user?.name ?? '').trim();
    return n.length > 0 ? n : 'Unknown';
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

  /// The ONE label for a non-text message, used everywhere a message is
  /// summarised: the inbox subtitle, the reply quote, and the push
  /// notification. These used to be three separate switch statements that had
  /// drifted apart — the inbox said "File", the reply quote said "Attachment",
  /// and only the push had emoji — so the same photo read differently
  /// depending on where you looked at it. Emoji is the notification set, which
  /// was the one users already saw on their lock screen.
  private kindLabel(kind: DmMessageKind | string | null | undefined) {
    switch (String(kind ?? 'TEXT').toUpperCase()) {
      case 'IMAGE':
        return '📷 Photo';
      case 'VOICE':
        return '🎤 Voice message';
      case 'VIDEO':
        return '🎥 Video';
      case 'FILE':
        return '📎 Attachment';
      default:
        return '💬 Message';
    }
  }

  /// Inbox/reply/push preview for a message: its text when it has any,
  /// otherwise the kind label. Mirrors `messagePreviewText` on the client
  /// (apps/classmate_mobile/lib/features/chat_core/utils/chat_reply_codec.dart)
  /// so a classroom row and a DM row describe the same attachment identically.
  private previewOf(message: {
    kind?: DmMessageKind | string | null;
    text?: string | null;
  }) {
    const text = String(message?.text ?? '').trim();
    if (text) return text;
    return this.kindLabel(message?.kind);
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

  /**
   * WhatsApp tick semantics, computed per viewer:
   *   ✓      sent      — the row exists (implicit; every message we return)
   *   ✓✓     delivered — every other participant's client has had it in hand
   *   ✓✓ blue seen      — every other participant has opened the thread since
   *
   * "delivered" reads lastDeliveredAt, NOT lastSeenAt. Deriving it from
   * lastSeenAt meant "delivered" really said "has opened this thread at least
   * once", so a first message to someone sat on a single tick indefinitely and
   * then jumped straight to blue — never showing the double-grey state at all.
   */
  private deliveryStateForMessage(
    message: { senderId: string; createdAt: Date },
    thread: {
      type: DmThreadType;
      participants: Array<{
        userId: string;
        lastSeenAt?: Date | null;
        lastDeliveredAt?: Date | null;
      }>;
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

    // A participant counts as having received this message once their client
    // checked in at/after it was created — by either receipt, since opening
    // the thread necessarily means it arrived.
    const receivedAt = (p: {
      lastSeenAt?: Date | null;
      lastDeliveredAt?: Date | null;
    }): Date | null => {
      const candidates = [p.lastDeliveredAt, p.lastSeenAt].filter(
        (v): v is Date => v instanceof Date,
      );
      if (!candidates.length) return null;
      const newest = candidates.sort((a, b) => b.getTime() - a.getTime())[0];
      return newest.getTime() >= message.createdAt.getTime() ? newest : null;
    };

    const deliveredToAll = others.every((p) => receivedAt(p) != null);
    // new Date(value), not new Date(String(value)) — stringifying a Date
    // drops the milliseconds, which misread same-second receipts as unseen.
    const seenToAll = others.every(
      (p) =>
        !!p.lastSeenAt &&
        new Date(p.lastSeenAt).getTime() >= message.createdAt.getTime(),
    );

    const deliveredAtSource = others
      .map((p) => receivedAt(p))
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
      return new Map<string, { id: string; name: string }>();

    const rows = (await this.prisma.user.findMany({
      where: { id: { in: ids } },
      select: { id: true, name: true } as any,
    })) as unknown as Array<{ id: string; name: string }>;

    return new Map(rows.map((row) => [row.id, row]));
  }

  async fetchSameSchoolPeople(user: AppUser) {
    const viewerId = this.viewerId(user);
    const schoolId = (user as any)?.schoolId ?? null;

    const viewerRoles = ((user as any)?.roles ?? []).map((r: any) =>
      String(r ?? '').toUpperCase(),
    );
    const isStudentOnly =
      viewerRoles.includes('STUDENT') &&
      !viewerRoles.includes('TEACHER') &&
      !viewerRoles.includes('ADMIN') &&
      !viewerRoles.includes('SECRETARY');
    const isParentOnly =
      viewerRoles.includes('PARENT') &&
      !viewerRoles.includes('TEACHER') &&
      !viewerRoles.includes('ADMIN') &&
      !viewerRoles.includes('SECRETARY');

    // Students can only DM (a) other students same school, (b) teachers,
    // (c) secretaries, (d) their OWN parents — never other students'
    // parents. Parents are the mirror: they can DM (a) other parents,
    // (b) teachers, (c) secretaries, (d) admins, and (e) their OWN
    // children — never other people's children. Same parent-child link
    // lookup, different direction.
    let ownParentIds: string[] = [];
    let ownChildIds: string[] = [];
    if (isStudentOnly) {
      const links = await this.prisma.parentChild.findMany({
        where: { childId: viewerId, status: 'APPROVED' as any },
        select: { parentId: true },
      });
      ownParentIds = links.map((l) => l.parentId);
    } else if (isParentOnly) {
      const links = await this.prisma.parentChild.findMany({
        where: { parentId: viewerId, status: 'APPROVED' as any },
        select: { childId: true },
      });
      ownChildIds = links.map((l) => l.childId);
    }

    let roleFilter: any = { roles: { some: {} } };
    if (isStudentOnly) {
      roleFilter = {
        OR: [
          // Non-parents: include all (subject to school + viewer-exclude).
          {
            roles: {
              some: {
                role: { in: ['STUDENT', 'TEACHER', 'SECRETARY', 'ADMIN'] as any },
              },
            },
          },
          // Parents: only the ones linked to this student.
          ...(ownParentIds.length
            ? [
                {
                  AND: [
                    { roles: { some: { role: 'PARENT' as any } } },
                    { id: { in: ownParentIds } },
                  ],
                },
              ]
            : []),
        ],
      };
    } else if (isParentOnly) {
      roleFilter = {
        OR: [
          // Non-students: every parent / teacher / secretary / admin.
          {
            roles: {
              some: {
                role: { in: ['PARENT', 'TEACHER', 'SECRETARY', 'ADMIN'] as any },
              },
            },
          },
          // Students: only the parent's OWN children.
          ...(ownChildIds.length
            ? [
                {
                  AND: [
                    { roles: { some: { role: 'STUDENT' as any } } },
                    { id: { in: ownChildIds } },
                  ],
                },
              ]
            : []),
        ],
      };
    }
    const studentRoleFilter = roleFilter;

    // Fetch users in the same school (excluding viewer)
    const schoolUsers = await this.prisma.user.findMany({
      where: {
        id: { not: viewerId },
        // A caller with no schoolId (e.g. a platform manager) must NOT fall
        // through to an unfiltered query that returns every user on the
        // platform. Match a sentinel that no real school id equals → empty.
        schoolId: schoolId ?? '__no_school__',
        ...studentRoleFilter,
      },
      select: {
        id: true,
        name: true,
        roles: { select: { role: true }, take: 1 },
        studentProfile: {
          select: {
            cohortId: true,
            cohort: { select: { name: true, grade: true } },
          },
        },
      },
      orderBy: { name: 'asc' },
    });

    const existingParticipants = await this.prisma.dmParticipant.findMany({
      where: { userId: viewerId },
      include: {
        thread: {
          select: {
            type: true,
            participants: { select: { userId: true } },
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
      items: schoolUsers
        .filter((u) => !existingDirectPeerIds.has(String(u.id ?? '').trim()))
        .map((u) => {
          const displayName = this.displayNameOf(u);
          const primaryRole = u.roles?.[0]?.role ?? 'STUDENT';
          const cohort = u.studentProfile?.cohort;
          const cohortShortName = cohort?.name?.replace(/^\d+\s*-\s*/, '') ?? '';
          const gradeLabel = cohort?.grade ? `Grade ${cohort.grade}${cohortShortName ? ' · ' + cohortShortName : ''}` : '';

          return {
            id: u.id,
            userId: u.id,
            name: displayName,
            displayName,
            initials: this.initialsOf(displayName),
            role: primaryRole.toLowerCase(),
            schoolName: '',
            gradeLabel,
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

  private async loadThreadOrThrow(
    threadId: string,
    userId: string,
    opts?: { limit?: number; beforeId?: string },
  ) {
    const viewer = await this.loadParticipantOrThrow(threadId, userId);
    // "Clear messages" / "delete chat": the viewer's copy of the history
    // starts after their clearedAt — older rows stay for everyone else.
    const clearedAt = (viewer as any)?.clearedAt as Date | null | undefined;
    const messageWhere = {
      threadId,
      ...(clearedAt ? { createdAt: { gt: clearedAt } } : {}),
      // "Delete for me" is per-viewer — the row survives for everyone else.
      NOT: { deletedForUserIds: { has: userId } },
      // Legacy globally-stamped "delete for me" rows (see fetchInbox).
      deleteMode: { not: 'DELETED_FOR_ME' as const },
    };

    const base = await this.prisma.dmThread.findUnique({
      where: { id: threadId },
      include: {
        participants: {
          orderBy: { createdAt: 'asc' },
        },
      },
    });

    if (!base) {
      throw new NotFoundException('Thread not found');
    }

    const reactionInclude = {
      reactions: { orderBy: { createdAt: 'asc' as const }, take: 1 },
    };
    // Cap the window so a malicious/oversized limit can't pull the whole thread.
    const limit =
      opts?.limit && opts.limit > 0 ? Math.min(Math.floor(opts.limit), 100) : null;

    let messages;
    let hasMoreOlder = false;
    if (limit) {
      // Newest-first window. Fetch one extra to detect whether older pages
      // exist, then reverse to chronological (ascending) for the client.
      const rows = await this.prisma.dmMessage.findMany({
        where: messageWhere,
        orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
        take: limit + 1,
        ...(opts?.beforeId ? { cursor: { id: opts.beforeId }, skip: 1 } : {}),
        include: reactionInclude,
      });
      hasMoreOlder = rows.length > limit;
      messages = (hasMoreOlder ? rows.slice(0, limit) : rows).reverse();
    } else {
      // Legacy / no-pagination path: full history, ascending.
      messages = await this.prisma.dmMessage.findMany({
        where: messageWhere,
        orderBy: { createdAt: 'asc' },
        include: reactionInclude,
      });
    }

    // A reply may quote a message older than the loaded window. Fetch those
    // targets so the quoted preview still renders (they're NOT added to the
    // returned message list, only used to resolve previews).
    const have = new Set<string>(messages.map((m: any) => String(m.id)));
    const missingReplyIds: string[] = Array.from(
      new Set<string>(
        messages
          .map((m: any) => m.replyToMessageId as string | null)
          .filter((id): id is string => !!id && !have.has(id)),
      ),
    );
    const replyTargets = missingReplyIds.length
      ? await this.prisma.dmMessage.findMany({
          where: { id: { in: missingReplyIds } },
          include: reactionInclude,
        })
      : [];

    return { ...base, messages, hasMoreOlder, replyTargets };
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
        lastSeenAt?: Date | null;
        lastDeliveredAt?: Date | null;
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
    isMuted?: boolean;
    pinnedAt?: Date | null;
    markedUnreadAt?: Date | null;
    clearedAt?: Date | null;
  }) {
    const thread = participant.thread;
    const viewerId = participant.userId;
    // The inbox include fetches newest-first; everything below reads this list
    // as chronological, so normalise once here.
    thread.messages = [...thread.messages].sort(
      (a, b) => a.createdAt.getTime() - b.createdAt.getTime(),
    );
    // "Clear messages": anything at/before clearedAt no longer exists for ME.
    // (Per-viewer deletes are already excluded by the query.)
    if (participant.clearedAt) {
      thread.messages = thread.messages.filter(
        (m) => m.createdAt > participant.clearedAt!,
      );
    }
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
          const body = this.previewOf(latestMessage);
          if (thread.type === DmThreadType.GROUP) {
            const senderName = this.displayNameOf(
              users.get(latestMessage.senderId),
            );
            return `${senderName}: ${body}`;
          }
          return body;
        })()
      : participant.state === DmParticipantState.PENDING_INCOMING
        ? 'Sent you a message request'
        : participant.state === DmParticipantState.PENDING_OUTGOING
          ? 'Waiting for approval'
          : 'No messages yet';

    // Counted from the loaded window, so it is exact up to
    // INBOX_MESSAGE_WINDOW and saturates beyond it — the extra row fetched by
    // the query is what lets us tell "exactly N" from "at least N".
    const unreadCount = thread.messages.filter(
      (m) =>
        m.senderId !== viewerId &&
        (participant.lastSeenAt == null ||
          m.createdAt > participant.lastSeenAt),
    ).length;

    // The delivery state of the viewer's own last message, for the inbox row's
    // tick (WhatsApp shows ✓/✓✓ in front of "you said..." previews).
    const lastDelivery =
      latestMessage && latestMessage.senderId === viewerId
        ? this.deliveryStateForMessage(latestMessage, thread, viewerId)
        : null;

    return {
      id: thread.id,
      type: String(thread.type).toLowerCase(),
      title,
      subtitle,
      // Structured preview. `subtitle` above is a pre-rendered ENGLISH string
      // and is kept only for older clients — new clients compose the preview
      // from these fields so "🎤 Voice message" localizes with the app.
      lastMessage: latestMessage
        ? {
            kind: String(latestMessage.kind ?? 'TEXT'),
            text: String(latestMessage.text ?? ''),
            senderName: this.displayNameOf(users.get(latestMessage.senderId)),
            isOwn: latestMessage.senderId === viewerId,
            delivered: lastDelivery?.delivered ?? false,
            seen: lastDelivery?.seen ?? false,
            // A delete-for-everyone tombstone rewrites `text` to an ENGLISH
            // sentence — the client needs the mode to localize the preview.
            deleteMode: String((latestMessage as any).deleteMode ?? 'VISIBLE'),
          }
        : null,
      isGroup: thread.type === DmThreadType.GROUP,
      isUnread: unreadCount > 0 || participant.markedUnreadAt != null,
      unreadCount,
      isPinned: participant.pinnedAt != null,
      isMuted: participant.isMuted === true,
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
    // Reply targets outside the loaded window (see loadThreadOrThrow) let us
    // resolve quoted previews without adding them to the visible message list.
    const replyTargets = (thread as any).replyTargets ?? [];
    const users = await this.userMapForIds([
      ...thread.participants.map((p) => p.userId),
      ...thread.messages.map((m) => m.senderId),
      ...replyTargets.map((m: any) => m.senderId),
    ]);

    const byId = new Map(
      [...thread.messages, ...replyTargets].map((m) => [m.id, m] as const),
    );

    const previewFor = (message: any) => this.previewOf(message);

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
      // True when older messages exist before the loaded window (pagination).
      hasMoreOlder: (thread as any).hasMoreOlder ?? false,
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
            // A window, not just the newest row. Two reasons:
            //  • the newest row may be invisible to THIS viewer (cleared, or
            //    deleted-for-me), in which case the subtitle must fall back to
            //    the newest one they can still see — taking 1 was why a chat
            //    the user had emptied still showed its old last message.
            //  • unreadCount is counted from these rows, so take:1 capped
            //    every badge at 1 no matter how many were actually unread.
            messages: {
              where: {
                NOT: { deletedForUserIds: { has: userId } },
                // Legacy rows: "delete for me" used to stamp the SHARED row
                // with this mode, so pre-fix deletions are invisible in the
                // thread but would otherwise still surface as the subtitle.
                deleteMode: { not: 'DELETED_FOR_ME' },
              },
              take: MessagesService.INBOX_MESSAGE_WINDOW + 1,
              orderBy: { createdAt: 'desc' },
            },
          },
        },
      },
      orderBy: { updatedAt: 'desc' },
    });

    // "Delete chat" (hiddenAt) removes the thread from MY inbox until someone
    // sends something newer — then it reappears with only the new history.
    const visible = participants.filter((p: any) => {
      if (!p.hiddenAt) return true;
      const latest = p.thread.messages[0];
      return !!latest && latest.createdAt > p.hiddenAt;
    });

    // Loading the inbox proves this device now holds these messages, which is
    // exactly what the sender's second tick means. Ack the threads that have
    // something newer than our last receipt, so ticks advance even for chats
    // the user never opens.
    const undelivered = visible
      .filter((p: any) =>
        p.thread.messages.some(
          (m: any) =>
            m.senderId !== userId &&
            (p.lastDeliveredAt == null || m.createdAt > p.lastDeliveredAt),
        ),
      )
      .map((p: any) => p.threadId);
    if (undelivered.length) {
      // Best-effort and off the response path — the inbox must not wait on it.
      void this.markThreadsDelivered(userId, undelivered).catch(() => {});
    }

    const items = await Promise.all(
      visible.map((p) => this.threadToSummary(p)),
    );
    // Pinned chats float to the top (newest-first within each section).
    items.sort((a, b) => {
      const pin = (b.isPinned ? 1 : 0) - (a.isPinned ? 1 : 0);
      if (pin !== 0) return pin;
      return (
        new Date(String(b.lastMessageAtRaw || 0)).getTime() -
        new Date(String(a.lastMessageAtRaw || 0)).getTime()
      );
    });
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
          const displayName = String(other?.name ?? 'Unknown user').trim();
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

  async fetchThread(
    user: AppUser,
    threadId: string,
    opts?: { limit?: number; beforeId?: string },
  ) {
    const userId = this.viewerId(user);
    const thread = await this.loadThreadOrThrow(threadId, userId, opts);
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

    await Promise.all([
      this.requireUser(userId),
      this.requireUser(recipientUserId),
    ]);
    // Enforce same-school messaging — look up schoolIds directly
    const [senderRow, recipientRow] = await Promise.all([
      this.prisma.user.findUnique({
        where: { id: userId },
        select: { schoolId: true, roles: { select: { role: true } } },
      }),
      this.prisma.user.findUnique({
        where: { id: recipientUserId },
        select: { schoolId: true, roles: { select: { role: true } } },
      }),
    ]);
    if (senderRow?.schoolId && recipientRow?.schoolId && senderRow.schoolId !== recipientRow.schoolId) {
      throw new ForbiddenException('Cannot message users from a different school');
    }

    // Role-based DM restriction (defense-in-depth — mirrors the
    // fetchSameSchoolPeople filter so a crafted POST can't bypass the UI):
    // STUDENT viewers can only DM (a) other students same school,
    // (b) teachers, (c) secretaries, (d) their OWN approved parents.
    // Other students' parents are off-limits.
    const senderRoles = (senderRow?.roles ?? []).map((r) => String(r.role).toUpperCase());
    const recipientRoles = (recipientRow?.roles ?? []).map((r) => String(r.role).toUpperCase());
    const isStudentOnly =
      senderRoles.includes('STUDENT') &&
      !senderRoles.includes('TEACHER') &&
      !senderRoles.includes('ADMIN') &&
      !senderRoles.includes('SECRETARY');
    if (isStudentOnly && recipientRoles.includes('PARENT')) {
      const link = await this.prisma.parentChild.findFirst({
        where: {
          parentId: recipientUserId,
          childId: userId,
          status: 'APPROVED' as any,
        },
        select: { id: true },
      });
      if (!link) {
        throw new ForbiddenException('Students can only message their own parents');
      }
    }

    // Mirror rule for parents: a parent can DM a student ONLY if it's
    // their own approved child.
    const isParentOnly =
      senderRoles.includes('PARENT') &&
      !senderRoles.includes('TEACHER') &&
      !senderRoles.includes('ADMIN') &&
      !senderRoles.includes('SECRETARY');
    if (isParentOnly && recipientRoles.includes('STUDENT')) {
      const link = await this.prisma.parentChild.findFirst({
        where: {
          parentId: userId,
          childId: recipientUserId,
          status: 'APPROVED' as any,
        },
        select: { id: true },
      });
      if (!link) {
        throw new ForbiddenException('Parents can only message their own children');
      }
    }

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

    // Notify all participants (including the requester) that the request was approved
    // so their inbox/thread list updates immediately
    try {
      const participants = await this.prisma.dmParticipant.findMany({
        where: { threadId },
        select: { userId: true },
      });
      this.realtime.emitToUsers(
        participants.map((p) => p.userId),
        { type: 'dm_message', threadId },
      );
    } catch (_) {}

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
    // A group needs the creator + at least 2 other members (1-on-1 chats use
    // the direct-message flow). Kept consistent with CreateGroupThreadDto's
    // ArrayMinSize(2) — the DTO validates the raw payload, this re-checks after
    // self/duplicate filtering.
    if (memberIds.length < 2) {
      throw new BadRequestException('A group needs at least 2 other members');
    }

    await this.requireUser(userId);
    for (const memberId of memberIds) {
      await this.requireUser(memberId);
    }

    // Enforce same-school membership — mirrors createDirectRequest. Without
    // this, a cross-school user could be seeded into the group and (since
    // PENDING_INCOMING participants can already read the thread) immediately
    // read its messages. Only enforce between accounts that both carry a
    // schoolId, consistent with the direct-message path.
    const creatorRow = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { schoolId: true },
    });
    const creatorSchoolId = creatorRow?.schoolId ?? null;
    if (creatorSchoolId) {
      const memberRows = await this.prisma.user.findMany({
        where: { id: { in: memberIds } },
        select: { id: true, schoolId: true },
      });
      const crossSchool = memberRows.some(
        (m) => m.schoolId && m.schoolId !== creatorSchoolId,
      );
      if (crossSchool) {
        throw new ForbiddenException('Cannot add users from a different school');
      }
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
    // If the client didn't tag the message kind explicitly, derive it from
    // the media mime so images/videos/voice each land in the correct enum
    // bucket and downstream renderers don't have to special-case "FILE with
    // an image/* mime."
    const inferredKind = ((): string => {
      if (!mediaUrl) return 'TEXT';
      const m = mediaMimeType.toLowerCase();
      if (m.startsWith('image/')) return 'IMAGE';
      if (m.startsWith('video/')) return 'VIDEO';
      if (m.startsWith('audio/')) return 'VOICE';
      return 'FILE';
    })();
    const kind = (rawKind || inferredKind) as DmMessageKind;
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

    // Push real-time event + persistent notification to every other
    // participant. We send a fan-out of `notification` events too so
    // their bell-icon badge bumps even if they're not on the thread
    // screen at that moment.
    try {
      const participants = await this.prisma.dmParticipant.findMany({
        where: { threadId, userId: { not: userId } },
        select: { userId: true },
      });
      const peerIds = participants.map((p) => p.userId);
      this.realtime.emitToUsers(peerIds, { type: 'dm_message', threadId });

      if (peerIds.length > 0) {
        const senderName = this.displayNameOf((await this.userMapForIds([userId])).get(userId));
        const preview = this.previewOf({ kind, text }).slice(0, 120);
        // fanOutToParents: false — a parent DM'd directly is the
        // direct recipient. If a STUDENT happens to be the peer, we
        // do want their parents notified, but that's handled inside
        // the hub: it fan-outs only when the recipient is a student
        // (via ParentChild lookup). The flag here is only "should the
        // hub even attempt fan-out" — keep it ON.
        await this.hub.notify({
          recipientUserIds: peerIds,
          type: 'NEW_MESSAGE',
          title: `${senderName} sent you a message`,
          body: preview,
          template: {
            key: 'message',
            args: { sender: senderName, preview },
          },
          data: { threadId, messageId: created.id },
        });
      }
    } catch (_) {}

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

    // Only the original author may rewrite a message. loadMessageOrThrow only
    // proves the caller is a thread participant, so without this any member
    // could edit anyone else's text (siblings togglePin / deleteForEveryone
    // enforce the same sender-ownership guard).
    if (message.senderId !== userId) {
      throw new ForbiddenException('Only the sender can edit this message');
    }

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

    void this.emitDmChanged(threadId, userId);
    return { ok: true, edited: true };
  }
  /// Realtime nudge to every OTHER participant after a message mutation
  /// (delete-for-everyone, edit, react, pin). Their open thread and inbox
  /// invalidate on `dm_message`, so the change lands instantly instead of on
  /// the next foreground poll — a WhatsApp-grade "delete means deleted NOW".
  /// Fire-and-forget: a realtime hiccup must never fail the mutation itself.
  private async emitDmChanged(threadId: string, actorId: string) {
    try {
      const participants = await this.prisma.dmParticipant.findMany({
        where: { threadId, userId: { not: actorId } },
        select: { userId: true },
      });
      this.realtime.emitToUsers(
        participants.map((p) => p.userId),
        { type: 'dm_message', threadId },
      );
    } catch (_) {
      // Best-effort only.
    }
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

    if (participant.thread.type === DmThreadType.GROUP) {
      // In group threads, only admins can pin any message
      if (participant.role !== DmParticipantRole.ADMIN) {
        throw new ForbiddenException('Only group admins can pin messages');
      }
    } else {
      // In direct threads, only the sender can pin their own message
      if (message.senderId !== userId) {
        throw new ForbiddenException('Only your own direct messages can be pinned');
      }
    }

    const updated = await this.prisma.dmMessage.update({
      where: { id: messageId },
      data: { isPinned: !message.isPinned },
      select: { isPinned: true },
    });

    void this.emitDmChanged(threadId, userId);
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
      // Only the original sender may delete for everyone
      if (message.senderId !== userId) {
        throw new ForbiddenException('Only the sender can delete a message for everyone');
      }

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

      // Push the tombstone to the other side IMMEDIATELY — before this, peers
      // only noticed a delete-for-everyone on their next foreground poll,
      // which is exactly the kind of "did it really delete?" doubt an urgent
      // retraction cannot afford.
      void this.emitDmChanged(threadId, userId);
      return { ok: true };
    }

    // Any participant may delete for themselves. This must NOT touch the
    // shared row's deletedAt/deleteMode: doing so removed the message from
    // everyone's thread, and left the inbox subtitle still quoting it because
    // nothing read those columns back. Record the viewer instead — every read
    // path filters on deletedForUserIds.
    await this.prisma.dmMessage.update({
      where: { id: messageId },
      data: { deletedForUserIds: { push: userId } },
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
        void this.emitDmChanged(threadId, userId);
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
        void this.emitDmChanged(threadId, userId);
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

      void this.emitDmChanged(threadId, userId);
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

    void this.emitDmChanged(threadId, userId);
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
        // Notify all other participants in the DM thread that a message arrived
        try {
          const dmParticipants = await this.prisma.dmParticipant.findMany({
            where: { threadId: targetThreadId, userId: { not: userId } },
            select: { userId: true },
          });
          this.realtime.emitToUsers(
            dmParticipants.map((p) => p.userId),
            { type: 'dm_message', threadId: targetThreadId },
          );
        } catch (_) {}
      } else {
        // Try classroom target (classrooms replaced old cohort-based rooms)
        const classroom = await this.prisma.classroom.findUnique({
          where: { id: targetThreadId },
          select: { id: true, teacherId: true },
        });
        if (!classroom) {
          // Skip invalid targets silently rather than throwing — the picker
          // may mix DM and classroom IDs and we want partial success.
          continue;
        }
        // Authorization: the forwarder must belong to this classroom (its
        // teacher or an enrolled member) — without this, any user could inject
        // a message into any classroom by id.
        if (classroom.teacherId !== userId) {
          const membership = await this.prisma.classroomMember.findUnique({
            where: { classroomId_studentId: { classroomId: targetThreadId, studentId: userId } },
            select: { studentId: true },
          });
          if (!membership) continue; // not a member — skip this target silently
        }
        await this.prisma.classroomMessage.create({
          data: {
            classroomId: targetThreadId,
            senderUserId: userId,
            kind: source.kind as any,
            text: forwardedText != null ? `Forwarded\n${forwardedText}` : 'Forwarded',
            mediaUrl: source.mediaUrl ?? null,
            mediaMime: sourceMime || null,
            durationSec: duration > 0 ? duration : null,
          },
        });
        // Notify classroom participants of the forwarded message
        try {
          const classroomMembers = await this.prisma.classroomMember.findMany({
            where: { classroomId: targetThreadId },
            select: { studentId: true },
          });
          this.realtime.emitToUsers(
            classroomMembers.map((m) => m.studentId),
            { type: 'classroom_message', classroomId: targetThreadId },
          );
        } catch (_) {}
      }
    }

    return { ok: true };
  }

  /// Files a user-report against a chat message. Required for Google Play
  /// policy compliance (any app with user messaging must let users report
  /// content). Idempotent — re-reporting the same message just updates the
  /// reason. Admins triage via /admin/reports.
  async reportMessage(
    user: AppUser,
    dto: { threadId: string; messageId: string; reason?: string },
  ) {
    const userId = this.viewerId(user);
    const threadId = String(dto.threadId ?? '').trim();
    const messageId = String(dto.messageId ?? '').trim();
    const reason = (dto.reason ?? '').trim().slice(0, 500) || null;

    if (!threadId || !messageId) {
      throw new BadRequestException('threadId and messageId are required');
    }

    // Must be a participant of the thread + message must exist in it.
    await this.loadParticipantOrThrow(threadId, userId);
    const message = await this.loadMessageOrThrow(threadId, messageId, userId);

    // Can't report your own messages — that's not abuse, it's just delete.
    if (message.senderId === userId) {
      throw new BadRequestException('Cannot report your own message');
    }

    await this.prisma.dmMessageReport.upsert({
      where: { messageId_reporterId: { messageId, reporterId: userId } },
      update: { reason: reason ?? undefined },
      create: { messageId, reporterId: userId, reason: reason ?? undefined },
    });

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
        // Reading implies delivery — keep the two receipts consistent so a
        // message can never be "seen" without also being "delivered".
        lastDeliveredAt: new Date(),
        // Opening the thread cancels a manual "mark as unread".
        markedUnreadAt: null,
      },
    });

    // Push a real-time read receipt to the other participants so an open
    // "message info" screen updates its Seen/Delivered state live.
    try {
      const others = await this.prisma.dmParticipant.findMany({
        where: { threadId, userId: { not: userId } },
        select: { userId: true },
      });
      const peerIds = others.map((p) => p.userId);
      if (peerIds.length > 0) {
        this.realtime.emitToUsers(peerIds, { type: 'dm_read', threadId });
      }
    } catch {
      // Read receipts are best-effort; never fail the mark-read call.
    }

    return { ok: true };
  }

  /**
   * Records that this user's device now holds the thread's messages — the
   * second (grey) tick for whoever sent them. Called when a client receives a
   * push/SSE message for a thread it isn't currently reading, and in bulk
   * whenever the inbox loads.
   *
   * Emits `dm_delivered` so a sender sitting in the chat sees the tick flip
   * without waiting for their next poll.
   */
  async markThreadsDelivered(userId: string, threadIds: string[]) {
    const ids = [...new Set(threadIds.filter(Boolean))];
    if (!ids.length) return { ok: true };

    await this.prisma.dmParticipant.updateMany({
      where: { userId, threadId: { in: ids } },
      data: { lastDeliveredAt: new Date() },
    });

    try {
      const peers = await this.prisma.dmParticipant.findMany({
        where: { threadId: { in: ids }, userId: { not: userId } },
        select: { userId: true, threadId: true },
      });
      for (const threadId of ids) {
        const peerIds = peers
          .filter((p) => p.threadId === threadId)
          .map((p) => p.userId);
        if (peerIds.length) {
          this.realtime.emitToUsers(peerIds, { type: 'dm_delivered', threadId });
        }
      }
    } catch {
      // Delivery receipts are best-effort; never fail the caller.
    }

    return { ok: true };
  }

  async markThreadDelivered(user: AppUser, threadId: string) {
    const userId = this.viewerId(user);
    const id = String(threadId ?? '').trim();
    if (!id) throw new BadRequestException('threadId is required');
    await this.loadParticipantOrThrow(id, userId);
    return this.markThreadsDelivered(userId, [id]);
  }

  // ── Group member management ─────────────────────────────────────────────

  // ── Helpers for group management (uses DmThread / DmParticipant) ────────────

  private async _assertDmMember(threadId: string, userId: string) {
    const p = await this.prisma.dmParticipant.findUnique({
      where: { threadId_userId: { threadId, userId } },
      select: { role: true, state: true },
    });
    if (!p || p.state === 'BLOCKED') throw new BadRequestException('Not a member of this thread');
    return p;
  }

  private async _assertDmAdmin(threadId: string, userId: string) {
    const p = await this._assertDmMember(threadId, userId);
    if (p.role !== 'ADMIN') throw new ForbiddenException('Admin only');
  }

  async getThreadInfo(user: AppUser, threadId: string) {
    const userId = this.viewerId(user);
    const meRaw = await this.prisma.dmParticipant.findUnique({
      where: { threadId_userId: { threadId, userId } },
      select: { role: true, state: true, isMuted: true },
    });
    if (!meRaw || meRaw.state === 'BLOCKED') throw new BadRequestException('Not a member of this thread');

    const thread = await this.prisma.dmThread.findUnique({
      where: { id: threadId },
      include: {
        participants: {
          where: { state: { not: 'BLOCKED' as any } },
          orderBy: { createdAt: 'asc' },
        },
      },
    });
    if (!thread) throw new BadRequestException('Thread not found');

    // Fetch user info for each participant separately (DmParticipant has no user relation).
    // Also pull the user's primary platform role (STUDENT / TEACHER / etc.)
    // so the client can render a RoleBadge next to each member — distinct
    // from the per-thread `role` ('ADMIN' / 'MEMBER') used for group admin
    // status.
    const userIds = (thread as any).participants.map((p: any) => p.userId as string);
    const users = await this.prisma.user.findMany({
      where: { id: { in: userIds } },
      select: {
        id: true,
        name: true,
        email: true,
        roles: { select: { role: true } },
      } as any,
    });
    const rolePriority: Record<string, number> = {
      TEACHER: 5,
      ADMIN: 4,
      SECRETARY: 3,
      PARENT: 2,
      STUDENT: 1,
    };
    const userMap = new Map(users.map((u) => {
      const primary = ((u as any).roles ?? [])
        .map((r: any) => String(r.role).toUpperCase())
        .sort((a: string, b: string) => (rolePriority[b] ?? 0) - (rolePriority[a] ?? 0))[0] ?? 'STUDENT';
      return [u.id, { ...u, _primaryRole: primary }];
    }));

    return {
      ok: true,
      thread: {
        id: thread.id,
        type: thread.type,
        title: thread.title ?? null,
        groupAvatarUrl: null,
        createdAt: thread.createdAt,
        inviteCode: thread.inviteCode ?? null,
        myRole: meRaw.role,
        isMuted: meRaw.isMuted,
        members: (thread as any).participants.map((p: any) => {
          const u: any = userMap.get(p.userId);
          return {
            userId: p.userId,
            name: u?.name ?? u?.email ?? '',
            role: p.role,
            userRole: u?._primaryRole ?? 'STUDENT',
            joinedAt: p.createdAt,
            isMuted: false,
            // Receipts, so the message-info sheet can place each member into
            // seen/delivered/pending truthfully. These were simply missing —
            // the client read them, got nothing, and filed everyone under
            // "pending" even while the bubble showed blue ticks.
            lastSeenAt: p.lastSeenAt ?? null,
            lastDeliveredAt: p.lastDeliveredAt ?? null,
          };
        }),
      },
    };
  }

  async addGroupMember(user: AppUser, threadId: string, body: { userId?: string; email?: string }) {
    const requesterId = this.viewerId(user);
    await this._assertDmAdmin(threadId, requesterId);

    const identifier = String(body?.email ?? body?.userId ?? '').trim();
    if (!identifier) throw new BadRequestException('userId or email required');
    const targetUser = identifier.includes('@')
      ? await this.prisma.user.findUnique({ where: { email: identifier }, select: { id: true, schoolId: true } })
      : await this.prisma.user.findUnique({ where: { id: identifier }, select: { id: true, schoolId: true } });
    if (!targetUser) throw new BadRequestException('User not found');

    // Same-school membership — the admin must not pull a cross-school account
    // into the group (mirrors createGroup / createDirectRequest). Enforced only
    // between accounts that both carry a schoolId.
    const requesterRow = await this.prisma.user.findUnique({
      where: { id: requesterId },
      select: { schoolId: true },
    });
    if (
      requesterRow?.schoolId &&
      targetUser.schoolId &&
      requesterRow.schoolId !== targetUser.schoolId
    ) {
      throw new ForbiddenException('Cannot add users from a different school');
    }

    // Blocked members cannot be re-added
    const existing = await this.prisma.dmParticipant.findUnique({
      where: { threadId_userId: { threadId, userId: targetUser.id } },
      select: { state: true },
    });
    if (existing?.state === 'BLOCKED') throw new ForbiddenException('This user is blocked from the group');

    await this.prisma.dmParticipant.upsert({
      where: { threadId_userId: { threadId, userId: targetUser.id } },
      update: { state: 'ACCEPTED' as any },
      create: { threadId, userId: targetUser.id, role: 'MEMBER' as any, state: 'ACCEPTED' as any },
    });
    return { ok: true };
  }

  async removeGroupMember(user: AppUser, threadId: string, targetUserId: string) {
    const requesterId = this.viewerId(user);
    if (requesterId !== targetUserId) {
      await this._assertDmAdmin(threadId, requesterId);
    }
    await this.prisma.dmParticipant.deleteMany({ where: { threadId, userId: targetUserId } });
    return { ok: true };
  }

  async updateGroupMemberRole(user: AppUser, threadId: string, targetUserId: string, body: { role?: string }) {
    const requesterId = this.viewerId(user);
    await this._assertDmAdmin(threadId, requesterId);
    const role = (body?.role ?? '').toUpperCase() === 'ADMIN' ? 'ADMIN' : 'MEMBER';

    // Prevent demoting the last admin — would leave the group unmanageable
    if (role === 'MEMBER') {
      const adminCount = await this.prisma.dmParticipant.count({
        where: { threadId, role: 'ADMIN' as any, state: { not: 'BLOCKED' as any } },
      });
      if (adminCount <= 1) {
        throw new BadRequestException(
          'Cannot remove the only admin. Promote another member first.',
        );
      }
    }

    await this.prisma.dmParticipant.update({
      where: { threadId_userId: { threadId, userId: targetUserId } },
      data: { role: role as any },
    });
    return { ok: true, role };
  }

  async toggleMuteThread(user: AppUser, threadId: string) {
    const userId = this.viewerId(user);
    await this._assertDmMember(threadId, userId);
    const current = await this.prisma.dmParticipant.findUnique({
      where: { threadId_userId: { threadId, userId } },
      select: { isMuted: true },
    });
    const isMuted = !(current?.isMuted ?? false);
    await this.prisma.dmParticipant.update({
      where: { threadId_userId: { threadId, userId } },
      data: { isMuted },
    });
    return { ok: true, isMuted };
  }

  // ── Inbox long-press actions (all per-participant — never touch the other
  //    side's copy of the thread) ────────────────────────────────────────────

  async togglePinThread(user: AppUser, threadId: string) {
    const userId = this.viewerId(user);
    await this._assertDmMember(threadId, userId);
    const current = await this.prisma.dmParticipant.findUnique({
      where: { threadId_userId: { threadId, userId } },
      select: { pinnedAt: true },
    });
    const pinnedAt = current?.pinnedAt ? null : new Date();
    await this.prisma.dmParticipant.update({
      where: { threadId_userId: { threadId, userId } },
      data: { pinnedAt },
    });
    return { ok: true, isPinned: pinnedAt != null };
  }

  async markThreadUnread(user: AppUser, threadId: string) {
    const userId = this.viewerId(user);
    await this._assertDmMember(threadId, userId);
    await this.prisma.dmParticipant.update({
      where: { threadId_userId: { threadId, userId } },
      data: { markedUnreadAt: new Date() },
    });
    return { ok: true };
  }

  /** "Clear messages" hides everything at/before now from MY view only.
   *  With hide=true the thread also leaves my inbox ("delete chat") until a
   *  newer message arrives — the other side keeps their full history. */
  async clearThread(user: AppUser, threadId: string, hide: boolean) {
    const userId = this.viewerId(user);
    await this._assertDmMember(threadId, userId);
    const now = new Date();
    await this.prisma.dmParticipant.update({
      where: { threadId_userId: { threadId, userId } },
      data: {
        clearedAt: now,
        markedUnreadAt: null,
        ...(hide ? { hiddenAt: now } : {}),
      },
    });
    return { ok: true };
  }

  /** Push a typing signal to the other participants. Deliberately does not
   *  persist anything — pure SSE fan-out, throttled client-side. */
  async notifyTyping(user: AppUser, threadId: string) {
    const userId = this.viewerId(user);
    await this._assertDmMember(threadId, userId);
    const others = await this.prisma.dmParticipant.findMany({
      where: {
        threadId,
        userId: { not: userId },
        state: DmParticipantState.ACCEPTED,
      },
      select: { userId: true },
    });
    if (others.length) {
      this.realtime.emitToUsers(
        others.map((p) => p.userId),
        { type: 'dm_typing', threadId, userId },
      );
    }
    return { ok: true };
  }

  async blockGroupMember(user: AppUser, threadId: string, targetUserId: string) {
    const requesterId = this.viewerId(user);
    await this._assertDmAdmin(threadId, requesterId);
    // Set the target's state to BLOCKED so they can't see messages
    await this.prisma.dmParticipant.update({
      where: { threadId_userId: { threadId, userId: targetUserId } },
      data: { state: 'BLOCKED' as any },
    });
    return { ok: true };
  }

  async generateGroupInviteCode(user: AppUser, threadId: string) {
    const userId = this.viewerId(user);
    const me = await this._assertDmMember(threadId, userId);
    if (me.role !== 'ADMIN') throw new ForbiddenException('Admin only');

    const thread = await this.prisma.dmThread.findUnique({
      where: { id: threadId },
      select: { type: true, inviteCode: true },
    });
    if (!thread) throw new BadRequestException('Thread not found');
    if (thread.type !== 'GROUP') throw new BadRequestException('Only groups have invite codes');

    // Return existing code or generate a new 8-char alphanumeric one
    if (thread.inviteCode) return { ok: true, inviteCode: thread.inviteCode };

    const code = Array.from({ length: 8 }, () =>
      'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789'[
        Math.floor(Math.random() * 55)
      ],
    ).join('');

    await this.prisma.dmThread.update({ where: { id: threadId }, data: { inviteCode: code } });
    return { ok: true, inviteCode: code };
  }

  async joinGroupByCode(user: AppUser, body: { code?: string }) {
    const userId = this.viewerId(user);
    const code = String(body?.code ?? '').trim();
    if (!code) throw new BadRequestException('code is required');

    const thread = await (this.prisma as any).dmThread.findUnique({
      where: { inviteCode: code },
      select: { id: true, type: true, title: true, createdById: true },
    });
    if (!thread) throw new BadRequestException('Invalid or expired invite code');
    if (thread.type !== 'GROUP') throw new BadRequestException('This code is not for a group');

    // Same-school guard — mirrors createGroup / createDirectRequest. The invite
    // code is a shareable, forwardable 8-char string; without this check anyone
    // who obtains it could join a group in a DIFFERENT school and immediately
    // read its history. Only enforce between accounts that both carry a
    // schoolId, consistent with the other membership paths.
    const [joinerRow, creatorRow] = await Promise.all([
      this.prisma.user.findUnique({ where: { id: userId }, select: { schoolId: true } }),
      thread.createdById
        ? this.prisma.user.findUnique({
            where: { id: thread.createdById },
            select: { schoolId: true },
          })
        : Promise.resolve(null),
    ]);
    const joinerSchoolId = joinerRow?.schoolId ?? null;
    const groupSchoolId = creatorRow?.schoolId ?? null;
    if (joinerSchoolId && groupSchoolId && joinerSchoolId !== groupSchoolId) {
      throw new ForbiddenException('This group belongs to a different school');
    }

    // Blocked users cannot rejoin
    const existing = await this.prisma.dmParticipant.findUnique({
      where: { threadId_userId: { threadId: thread.id, userId } },
      select: { state: true },
    });
    if (existing?.state === 'BLOCKED') throw new ForbiddenException('You have been removed from this group');

    await this.prisma.dmParticipant.upsert({
      where: { threadId_userId: { threadId: thread.id, userId } },
      update: { state: 'ACCEPTED' as any },
      create: { threadId: thread.id, userId, role: 'MEMBER' as any, state: 'ACCEPTED' as any },
    });

    return { ok: true, threadId: thread.id, title: thread.title };
  }

  async updateGroupTitle(user: AppUser, threadId: string, body: { title?: string }) {
    const userId = this.viewerId(user);
    await this._assertDmAdmin(threadId, userId);
    const thread = await this.prisma.dmThread.findUnique({ where: { id: threadId }, select: { type: true } });
    if (thread?.type !== 'GROUP') throw new BadRequestException('Only group threads can have their title updated');
    const title = String(body?.title ?? '').trim();
    if (!title) throw new BadRequestException('title required');
    await this.prisma.dmThread.update({ where: { id: threadId }, data: { title } });
    return { ok: true };
  }
}
