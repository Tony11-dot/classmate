import '../../chat_core/domain/chat_request_state.dart';
import '../../chat_core/domain/chat_thread_type.dart';
import '../domain/message_thread_models.dart';

abstract class MessagesRepository {
  Future<List<MessageThreadSummary>> fetchInbox();

  Future<MessageThreadDetail> fetchThread({
    required String threadId,
  });

  Future<MessageThreadDetail> fetchRequest({
    required String threadId,
  });

  Future<void> createDirectRequest({
    required String recipientUserId,
    required String firstMessage,
  });

  Future<void> approveRequest({
    required String threadId,
  });

  Future<void> blockRequest({
    required String threadId,
  });

  Future<void> createGroup({
    required String title,
    required List<String> memberIds,
  });
}

class DemoMessagesRepository implements MessagesRepository {
  const DemoMessagesRepository();

  @override
  Future<List<MessageThreadSummary>> fetchInbox() async {
    return const [
      MessageThreadSummary(
        id: 'rachel-req',
        type: ChatThreadType.direct,
        title: 'Rachel Haddad',
        subtitle: 'Sent you a message request',
        isGroup: false,
        isUnread: true,
        unreadCount: 1,
        lastMessageAt: '2:10 PM',
        requestState: ChatRequestState.pendingIncoming,
        initials: 'RH',
      ),
      MessageThreadSummary(
        id: 'omar-thread',
        type: ChatThreadType.direct,
        title: 'Omar Nassar',
        subtitle: 'Can you send the physics file?',
        isGroup: false,
        isUnread: false,
        unreadCount: 0,
        lastMessageAt: '2:14 PM',
        requestState: ChatRequestState.approved,
        initials: 'ON',
      ),
      MessageThreadSummary(
        id: 'math-group',
        type: ChatThreadType.group,
        title: 'Math Study Group',
        subtitle: 'Tony: I uploaded the sheet',
        isGroup: true,
        isUnread: false,
        unreadCount: 0,
        lastMessageAt: '1:42 PM',
        requestState: ChatRequestState.none,
        initials: 'MG',
        groupAvatarUrl: null,
      ),
    ];
  }

  @override
  Future<MessageThreadDetail> fetchThread({
    required String threadId,
  }) async {
    switch (threadId) {
      case 'math-group':
        return const MessageThreadDetail(
          id: 'math-group',
          title: 'Math Study Group',
          subtitle: '6 members',
          isGroup: true,
          requestState: ChatRequestState.none,
          participants: [
            MessageParticipant(userId: 'u1', displayName: 'Tony Aboud', initials: 'TA'),
            MessageParticipant(userId: 'u2', displayName: 'Omar Nassar', initials: 'ON'),
            MessageParticipant(userId: 'u3', displayName: 'Rachel Haddad', initials: 'RH'),
          ],
          messages: [
            MessageItem(
              id: 'm1',
              senderId: 'u2',
              senderName: 'Omar Nassar',
              text: 'Did anyone solve question 4?',
              timeLabel: '1:40 PM',
              isMine: false,
            ),
            MessageItem(
              id: 'm2',
              senderId: 'u1',
              senderName: 'Tony Aboud',
              text: 'Yes, I uploaded the sheet',
              timeLabel: '1:42 PM',
              isMine: true,
              reaction: '👍',
              isPinned: true,
            ),
          ],
        );
      case 'omar-thread':
      default:
        return const MessageThreadDetail(
          id: 'omar-thread',
          title: 'Omar Nassar',
          subtitle: 'online',
          isGroup: false,
          requestState: ChatRequestState.approved,
          participants: [
            MessageParticipant(userId: 'u1', displayName: 'Tony Aboud', initials: 'TA'),
            MessageParticipant(userId: 'u2', displayName: 'Omar Nassar', initials: 'ON'),
          ],
          messages: [
            MessageItem(
              id: 'm1',
              senderId: 'u2',
              senderName: 'Omar Nassar',
              text: 'Hey Tony, can you send the notes?',
              timeLabel: '2:11 PM',
              isMine: false,
            ),
            MessageItem(
              id: 'm2',
              senderId: 'u1',
              senderName: 'Tony Aboud',
              text: 'Yes, I’ll send them here.',
              timeLabel: '2:12 PM',
              isMine: true,
              reaction: '👍',
            ),
            MessageItem(
              id: 'm3',
              senderId: 'u2',
              senderName: 'Omar Nassar',
              text: 'Perfect',
              timeLabel: '2:13 PM',
              isMine: false,
            ),
          ],
        );
    }
  }

  @override
  Future<MessageThreadDetail> fetchRequest({
    required String threadId,
  }) async {
    return const MessageThreadDetail(
      id: 'rachel-req',
      title: 'Rachel Haddad',
      subtitle: 'Message request',
      isGroup: false,
      requestState: ChatRequestState.pendingIncoming,
      participants: [
        MessageParticipant(userId: 'u3', displayName: 'Rachel Haddad', initials: 'RH'),
      ],
      messages: [
        MessageItem(
          id: 'r1',
          senderId: 'u3',
          senderName: 'Rachel Haddad',
          text: 'Hey, can we talk about the assignment?',
          timeLabel: '2:10 PM',
          isMine: false,
        ),
      ],
    );
  }

  @override
  Future<void> createDirectRequest({
    required String recipientUserId,
    required String firstMessage,
  }) async {}

  @override
  Future<void> approveRequest({
    required String threadId,
  }) async {}

  @override
  Future<void> blockRequest({
    required String threadId,
  }) async {}

  @override
  Future<void> createGroup({
    required String title,
    required List<String> memberIds,
  }) async {}
}
