import 'package:flutter/material.dart';

class MessageReactionBar extends StatelessWidget {
  const MessageReactionBar({
    super.key,
    required this.onReact,
  });

  final ValueChanged<String> onReact;

  @override
  Widget build(BuildContext context) {
    const reactions = ['❤️', '👍', '😂', '😮', '😢', '🙏'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final reaction in reactions)
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onReact(reaction),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                reaction,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
      ],
    );
  }
}
