enum DmThreadType { direct, group }

enum DmRequestState {
  none,
  pendingIncoming,
  pendingOutgoing,
  accepted,
  blocked,
}

enum DmMediaMode { once, replay, keep }

enum DmMessageKind { text, image, voice, system }

class DmUserLite {
  final String id;
  final String name;
  final String avatarText;
  final bool isBlocked;
  final bool canMessage;

  const DmUserLite({
    required this.id,
    required this.name,
    required this.avatarText,
    this.isBlocked = false,
    this.canMessage = true,
  });
}

class DmThread {
  final String id;
  final DmThreadType type;
  final String title;
  final String subtitle;
  final String avatarText;
  final DmRequestState requestState;
  final bool isGroup;
  final bool isBlocked;
  final int unreadCount;
  final DateTime updatedAt;
  final List<DmUserLite> participants;

  const DmThread({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.avatarText,
    required this.requestState,
    required this.isGroup,
    required this.isBlocked,
    required this.unreadCount,
    required this.updatedAt,
    required this.participants,
  });
}

class DmMessage {
  final String id;
  final String senderId;
  final String senderName;
  final bool isMine;
  final DmMessageKind kind;
  final String text;
  final String? mediaUrl;
  final DmMediaMode? mediaMode;
  final Duration? voiceDuration;
  final DateTime createdAt;
  final List<String> reactions;

  const DmMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.isMine,
    required this.kind,
    required this.text,
    required this.mediaUrl,
    required this.mediaMode,
    required this.voiceDuration,
    required this.createdAt,
    required this.reactions,
  });
}
