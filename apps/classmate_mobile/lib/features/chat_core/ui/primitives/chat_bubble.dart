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
    return Container(
      margin: EdgeInsetsDirectional.only(
        top: isFirst ? 6 : 2,
        bottom: isLast ? 6 : 2,
        start: isMe ? 48 : 8,
        end: isMe ? 8 : 48,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isMe
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF0A1730)
                : const Color(0xFF2D4A7A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}
