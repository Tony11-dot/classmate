import 'package:flutter/material.dart';

import '../../../chat_core/ui/primitives/chat_bubble.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.child,
    required this.isMine,
    this.startsGroup = true,
    this.endsGroup = true,
    this.showTimestamp = false,
    this.timestamp,
    this.status,
    this.maxWidth,
  });

  final Widget child;
  final bool isMine;
  final bool startsGroup;
  final bool endsGroup;
  final bool showTimestamp;
  final String? timestamp;
  final String? status;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final bubble = ChatBubble(
      isMe: isMine,
      isFirst: startsGroup,
      isLast: endsGroup,
      child: child,
    );

    if (maxWidth == null) return bubble;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth!),
      child: bubble,
    );
  }
}
