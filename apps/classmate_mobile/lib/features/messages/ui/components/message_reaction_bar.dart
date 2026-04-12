import 'package:flutter/material.dart';

class MessageReactionBar extends StatelessWidget {
  const MessageReactionBar({
    super.key,
    required this.onReact,
    required this.onOpenPicker,
  });

  final ValueChanged<String> onReact;
  final VoidCallback onOpenPicker;

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
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onOpenPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.18),
              ),
            ),
            child: Icon(
              Icons.add_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
