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
  final String schoolName;
  final String gradeLabel;

  const MessageParticipant({
    required this.userId,
    required this.displayName,
    required this.initials,
    this.isAdmin = false,
    this.isBlocked = false,
    this.schoolName = '',
    this.gradeLabel = '',
  });
}

class MessageReplyRef {
  final String id;
  final String senderName;
  final String text;
  final String kind;
  final String? mediaUrl;

  const MessageReplyRef({
    required this.id,
    required this.senderName,
    required this.text,
    required this.kind,
    this.mediaUrl,
  });
}

class MessageItem {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final String timeLabel;
  final bool isMine;
  final String? reaction;
  final bool isPinned;
  final bool edited;
  final bool forwarded;
  final String deleteState;
  final bool delivered;
  final bool seen;
  final String deliveredAt;
  final String seenAt;
  final String kind;
  final String? mediaUrl;
  final String? mediaMimeType;
  final int? voiceDurationSeconds;
  final bool voicePlayed;
  final String? replyToMessageId;
  final MessageReplyRef? replyPreview;

  const MessageItem({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timeLabel,
    required this.isMine,
    this.reaction,
    this.isPinned = false,
    this.edited = false,
    this.forwarded = false,
    this.deleteState = 'VISIBLE',
    this.delivered = false,
    this.seen = false,
    this.deliveredAt = '',
    this.seenAt = '',
    this.kind = 'TEXT',
    this.mediaUrl,
    this.mediaMimeType,
    this.voiceDurationSeconds,
    this.voicePlayed = false,
    this.replyToMessageId,
    this.replyPreview,
  });
}

class MessageThreadDetail {
  final String id;
  final String title;
  final String subtitle;
  final bool isGroup;
  final ChatRequestState requestState;
  final List<MessageParticipant> participants;
  final List<MessageItem> messages;
  final bool canSend;

  const MessageThreadDetail({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isGroup,
    required this.requestState,
    required this.participants,
    required this.messages,
    this.canSend = true,
  });
}

class MessageDraftAttachment {
  final String path;
  final String name;
  final String kind;

  const MessageDraftAttachment({
    required this.path,
    required this.name,
    required this.kind,
  });
}
