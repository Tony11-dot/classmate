import '../../chat_core/domain/chat_request_state.dart';
import '../../chat_core/domain/chat_thread_type.dart';

class MessageThreadSummary {
  final String id;
  final ChatThreadType type;
  final String title;
  final String subtitle;
  final bool isGroup;
  final bool isUnread;
  final int unreadCount;
  final String lastMessageAt;
  final ChatRequestState requestState;
  final String initials;
  final String? groupAvatarUrl;

  const MessageThreadSummary({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.isGroup,
    required this.isUnread,
    required this.unreadCount,
    required this.lastMessageAt,
    required this.requestState,
    required this.initials,
    this.groupAvatarUrl,
  });
}

class MessageParticipant {
  final String userId;
  final String displayName;
  final String initials;
  final bool isAdmin;
  final bool isBlocked;

  const MessageParticipant({
    required this.userId,
    required this.displayName,
    required this.initials,
    this.isAdmin = false,
    this.isBlocked = false,
  });
}
