class ChatMessageInfo {
  final String title;
  final String sentAt;
  final String deliveredAt;
  final String seenAt;
  final bool edited;
  final bool forwarded;
  final String deleteState;

  const ChatMessageInfo({
    required this.title,
    this.sentAt = '',
    this.deliveredAt = '',
    this.seenAt = '',
    this.edited = false,
    this.forwarded = false,
    this.deleteState = '',
  });
}
