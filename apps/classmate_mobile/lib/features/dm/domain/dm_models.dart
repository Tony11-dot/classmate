enum DmRequestState {
  none,
  pendingIncoming,
  pendingOutgoing,
  accepted,
  blocked,
}

class DmProfileLite {
  final String id;
  final String fullName;
  final String handle;
  final String avatarText;
  final String? status;

  const DmProfileLite({
    required this.id,
    required this.fullName,
    required this.handle,
    required this.avatarText,
    this.status,
  });
}

class DmInboxItem {
  final String id;
  final bool isGroup;
  final String title;
  final String subtitle;
  final DateTime updatedAt;
  final int unreadCount;
  final DmRequestState requestState;
  final DmProfileLite otherUser;

  const DmInboxItem({
    required this.id,
    required this.isGroup,
    required this.title,
    required this.subtitle,
    required this.updatedAt,
    required this.unreadCount,
    required this.requestState,
    required this.otherUser,
  });
}

class DmMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final List<String> reactions;
  final bool mine;

  const DmMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.reactions,
    required this.mine,
  });
}
