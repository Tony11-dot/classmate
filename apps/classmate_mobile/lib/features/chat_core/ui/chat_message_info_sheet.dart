import 'package:flutter/material.dart';

import '../models/chat_message_info.dart';

class ChatMessageInfoSheet extends StatelessWidget {
  const ChatMessageInfoSheet({
    super.key,
    required this.info,
  });

  final ChatMessageInfo info;

  Widget _row(BuildContext context, String label, String value) {
    final text = value.trim().isEmpty ? '—' : value.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              info.title.trim().isEmpty ? 'Message info' : info.title.trim(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            _row(context, 'Sent', info.sentAt),
            _row(context, 'Delivered', info.deliveredAt),
            _row(context, 'Seen', info.seenAt),
            _row(context, 'Edited', info.edited ? 'Yes' : 'No'),
            _row(context, 'Forwarded', info.forwarded ? 'Yes' : 'No'),
            _row(context, 'Delete state', info.deleteState),
          ],
        ),
      ),
    );
  }
}
