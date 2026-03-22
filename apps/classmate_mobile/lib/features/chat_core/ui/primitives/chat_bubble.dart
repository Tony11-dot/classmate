import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.child,
    required this.isMe,
    required this.isFirst,
    required this.isLast,
  });

  final Widget child;
  final bool isMe;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(14);

    return Container(
      margin: EdgeInsets.only(
        top: isFirst ? 6 : 2,
        bottom: isLast ? 6 : 2,
        left: isMe ? 48 : 8,
        right: isMe ? 8 : 48,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isMe
            ? const Color(0xFF2A6DF4)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.only(
          topLeft: radius,
          topRight: radius,
          bottomLeft: isMe ? radius : (isLast ? radius : Radius.circular(4)),
          bottomRight: isMe ? (isLast ? radius : Radius.circular(4)) : radius,
        ),
      ),
      child: child,
    );
  }
}
