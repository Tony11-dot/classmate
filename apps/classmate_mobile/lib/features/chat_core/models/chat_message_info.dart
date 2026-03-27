class ChatMessageInfo {
  final String title;
  final String sentAt;
  final String deliveredAt;
  final String seenAt;
  final bool delivered;
  final bool seen;
  final bool edited;
  final bool forwarded;
  final String deleteState;
  final bool isMine;
  final String messageType;
  final String voiceDuration;

  const ChatMessageInfo({
    required this.title,
    this.sentAt = '',
    this.deliveredAt = '',
    this.seenAt = '',
    this.delivered = false,
    this.seen = false,
    this.edited = false,
    this.forwarded = false,
    this.deleteState = '',
    this.isMine = false,
    this.messageType = '',
    this.voiceDuration = '',
  });
}
