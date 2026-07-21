import '../../chat_core/domain/chat_request_state.dart';
import '../../chat_core/domain/chat_thread_type.dart';
import '../../chat_core/utils/chat_time.dart';

/// The newest visible message of a thread, as structured data — kind, raw
/// text, sender — so the inbox row can compose a LOCALIZED preview
/// ("🎤 Voice message" in the app's language, "You:" prefix, delivery ticks)
/// instead of printing the server's pre-rendered English `subtitle`.
class InboxLastMessage {
  final String kind;
  final String text;
  final String senderName;
  final bool isOwn;
  final bool delivered;
  final bool seen;

  const InboxLastMessage({
    required this.kind,
    required this.text,
    required this.senderName,
    required this.isOwn,
    this.delivered = false,
    this.seen = false,
  });
}

class MessageThreadSummary {
  final String id;
  final ChatThreadType type;
  final String title;
  final String subtitle;

  /// Null on empty threads and on servers older than this field.
  final InboxLastMessage? lastMessage;
  final bool isGroup;
  final bool isUnread;
  final int unreadCount;
  final String lastMessageAt;
  final String lastMessageAtRaw;
  final ChatRequestState requestState;
  final String initials;
  final String? groupAvatarUrl;
  final bool isPinned;
  final bool isMuted;

  DateTime? get lastMessageDate =>
      parseFirstChatTimestamp([lastMessageAtRaw, lastMessageAt]);

  const MessageThreadSummary({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.lastMessage,
    required this.isGroup,
    required this.isUnread,
    required this.unreadCount,
    required this.lastMessageAt,
    this.lastMessageAtRaw = '',
    required this.requestState,
    required this.initials,
    this.groupAvatarUrl,
    this.isPinned = false,
    this.isMuted = false,
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

class MessageDirectoryPerson {
  final String userId;
  final String displayName;
  final String initials;
  final String schoolName;
  final String gradeLabel;
  final String role; // lowercase: 'student' | 'teacher' | 'parent' | 'admin' | etc.

  const MessageDirectoryPerson({
    required this.userId,
    required this.displayName,
    required this.initials,
    this.schoolName = '',
    this.gradeLabel = '',
    this.role = '',
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
  final String sentAtRaw;
  final bool isMine;
  final String? reaction;
  final Map<String, List<String>> reactions;
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

  DateTime? get sentAtDate => parseChatTimestamp(sentAtRaw);
  DateTime? get deliveredAtDate => parseChatTimestamp(deliveredAt);
  DateTime? get seenAtDate => parseChatTimestamp(seenAt);

  const MessageItem({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timeLabel,
    this.sentAtRaw = '',
    required this.isMine,
    this.reaction,
    this.reactions = const <String, List<String>>{},
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
  /// True when older messages exist before the loaded window (pagination).
  final bool hasMoreOlder;

  const MessageThreadDetail({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isGroup,
    required this.requestState,
    required this.participants,
    required this.messages,
    this.canSend = true,
    this.hasMoreOlder = false,
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
