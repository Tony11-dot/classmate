import 'package:flutter/material.dart';

class MessageReplyPreview extends StatelessWidget {
  final String text;
  final VoidCallback onCancel;

  const MessageReplyPreview({
    super.key,
    required this.text,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          IconButton(onPressed: onCancel, icon: const Icon(Icons.close)),
        ],
      ),
    );
  }
}
