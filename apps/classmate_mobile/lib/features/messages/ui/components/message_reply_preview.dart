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
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey.withOpacity(0.2),
      child: Row(
        children: [
          Expanded(child: Text(text, maxLines: 1)),
          IconButton(icon: const Icon(Icons.close), onPressed: onCancel),
        ],
      ),
    );
  }
}
