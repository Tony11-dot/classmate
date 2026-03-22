import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    this.replyText,
    this.onReply,
    this.onLongPress,
  });

  final String text;
  final bool isMe;
  final String? replyText;
  final VoidCallback? onReply;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe
        ? const Color(0xFF17355D)
        : Colors.white.withValues(alpha: 0.12);

    return GestureDetector(
      onLongPress: onLongPress,
      onHorizontalDragEnd: (details) {
        final v = details.primaryVelocity ?? 0;
        if (v.abs() > 250) {
          onReply?.call();
        }
      },
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          constraints: const BoxConstraints(maxWidth: 260),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (replyText != null && replyText!.trim().isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    replyText!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              Text(text, style: const TextStyle(fontSize: 14, height: 1.18)),
            ],
          ),
        ),
      ),
    );
  }
}
