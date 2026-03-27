import { Injectable } from '@nestjs/common';

import { ApproveMessageRequestDto } from './dto/approve-message-request.dto';
import { BlockMessageRequestDto } from './dto/block-message-request.dto';
import { CreateDirectRequestDto } from './dto/create-direct-request.dto';
import { CreateGroupThreadDto } from './dto/create-group-thread.dto';

@Injectable()
export class MessagesService {
  async getInbox(userId: string) {
    return {
      ok: true,
      items: [
        {
          id: 'rachel-req',
          type: 'DIRECT',
          title: 'Rachel Haddad',
          subtitle: 'Sent you a message request',
          isGroup: false,
          isUnread: true,
          unreadCount: 1,
          lastMessageAt: '2:10 PM',
          requestState: 'PENDING_INCOMING',
          initials: 'RH',
        },
        {
          id: 'omar-thread',
          type: 'DIRECT',
          title: 'Omar Nassar',
          subtitle: 'Can you send the physics file?',
          isGroup: false,
          isUnread: false,
          unreadCount: 0,
          lastMessageAt: '2:14 PM',
          requestState: 'APPROVED',
          initials: 'ON',
        },
        {
          id: 'math-group',
          type: 'GROUP',
          title: 'Math Study Group',
          subtitle: 'Tony: I uploaded the sheet',
          isGroup: true,
          isUnread: false,
          unreadCount: 0,
          lastMessageAt: '1:42 PM',
          requestState: 'NONE',
          initials: 'MG',
        },
      ],
      viewerUserId: userId,
    };
  }

  async getThread(userId: string, threadId: string) {
    if (threadId === 'math-group') {
      return {
        ok: true,
        thread: {
          id: 'math-group',
          title: 'Math Study Group',
          subtitle: '6 members',
          isGroup: true,
          requestState: 'NONE',
          participants: [
            { userId: 'u1', displayName: 'Tony Aboud', initials: 'TA' },
            { userId: 'u2', displayName: 'Omar Nassar', initials: 'ON' },
            { userId: 'u3', displayName: 'Rachel Haddad', initials: 'RH' },
          ],
          messages: [
            {
              id: 'm1',
              senderId: 'u2',
              senderName: 'Omar Nassar',
              text: 'Did anyone solve question 4?',
              timeLabel: '1:40 PM',
              isMine: false,
            },
            {
              id: 'm2',
              senderId: 'u1',
              senderName: 'Tony Aboud',
              text: 'Yes, I uploaded the sheet',
              timeLabel: '1:42 PM',
              isMine: true,
              reaction: '👍',
              isPinned: true,
            },
          ],
        },
        viewerUserId: userId,
      };
    }

    return {
      ok: true,
      thread: {
        id: threadId,
        title: 'Omar Nassar',
        subtitle: 'online',
        isGroup: false,
        requestState: 'APPROVED',
        participants: [
          { userId: 'u1', displayName: 'Tony Aboud', initials: 'TA' },
          { userId: 'u2', displayName: 'Omar Nassar', initials: 'ON' },
        ],
        messages: [
          {
            id: 'm1',
            senderId: 'u2',
            senderName: 'Omar Nassar',
            text: 'Hey Tony, can you send the notes?',
            timeLabel: '2:11 PM',
            isMine: false,
          },
          {
            id: 'm2',
            senderId: 'u1',
            senderName: 'Tony Aboud',
            text: 'Yes, I’ll send them here.',
            timeLabel: '2:12 PM',
            isMine: true,
            reaction: '👍',
          },
          {
            id: 'm3',
            senderId: 'u2',
            senderName: 'Omar Nassar',
            text: 'Perfect',
            timeLabel: '2:13 PM',
            isMine: false,
          },
        ],
      },
      viewerUserId: userId,
    };
  }

  async getRequest(userId: string, threadId: string) {
    return {
      ok: true,
      request: {
        id: threadId,
        title: 'Rachel Haddad',
        subtitle: 'Message request',
        isGroup: false,
        requestState: 'PENDING_INCOMING',
        participants: [
          { userId: 'u3', displayName: 'Rachel Haddad', initials: 'RH' },
        ],
        messages: [
          {
            id: 'r1',
            senderId: 'u3',
            senderName: 'Rachel Haddad',
            text: 'Hey, can we talk about the assignment?',
            timeLabel: '2:10 PM',
            isMine: false,
          },
        ],
      },
      viewerUserId: userId,
    };
  }

  async createDirectRequest(userId: string, dto: CreateDirectRequestDto) {
    return {
      ok: true,
      threadId: `direct-${userId}-${dto.recipientUserId}`,
      requestState: 'PENDING_OUTGOING',
    };
  }

  async approveRequest(userId: string, dto: ApproveMessageRequestDto) {
    return {
      ok: true,
      threadId: dto.threadId,
      requestState: 'APPROVED',
      actedByUserId: userId,
    };
  }

  async blockRequest(userId: string, dto: BlockMessageRequestDto) {
    return {
      ok: true,
      threadId: dto.threadId,
      requestState: 'BLOCKED',
      actedByUserId: userId,
    };
  }

  async createGroup(userId: string, dto: CreateGroupThreadDto) {
    return {
      ok: true,
      threadId: `group-${Date.now()}`,
      title: dto.title,
      memberIds: dto.memberIds,
      createdByUserId: userId,
    };
  }
}
