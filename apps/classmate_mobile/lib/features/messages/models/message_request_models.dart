enum MessageRequestDecision {
  approve,
  block,
  pending,
}

class MessageRequestBannerData {
  final String threadId;
  final String senderName;
  final String senderInitials;
  final String firstMessage;
  final bool isIncoming;

  const MessageRequestBannerData({
    required this.threadId,
    required this.senderName,
    required this.senderInitials,
    required this.firstMessage,
    required this.isIncoming,
  });
}
