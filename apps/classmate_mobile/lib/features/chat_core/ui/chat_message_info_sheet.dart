import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../models/chat_message_info.dart';

class ChatMessageInfoSheet extends StatelessWidget {
  const ChatMessageInfoSheet({super.key, required this.info});

  final ChatMessageInfo info;

  Widget _row(BuildContext context, String label, String value) {
    final l = AppLocalizations.of(context)!;
    final text = value.trim().isEmpty ? l.profileEmptyValue : value.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
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
              info.title.trim().isEmpty
                  ? l.classroomDetailMessageInfoTitle
                  : info.title.trim(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            _row(context, l.chatMessageInfoSent, info.sentAt),
            if (info.isMine)
              _row(
                context,
                l.chatMessageInfoDelivered,
                info.delivered
                    ? (info.deliveredAt.isEmpty
                          ? l.chatMessageInfoDelivered
                          : info.deliveredAt)
                    : l.chatMessageInfoPending,
              ),
            if (info.isMine)
              _row(
                context,
                l.chatMessageInfoSeen,
                info.seen
                    ? (info.seenAt.isEmpty ? l.chatMessageInfoSeen : info.seenAt)
                    : l.chatMessageInfoNotSeen,
              ),
            if (info.messageType.trim().isNotEmpty)
              _row(context, l.chatMessageInfoType, info.messageType),
            if (info.voiceDuration.trim().isNotEmpty)
              _row(context, l.chatMessageInfoDuration, info.voiceDuration),
            _row(
              context,
              l.chatMessageInfoEdited,
              info.edited ? l.chatMessageInfoYes : l.chatMessageInfoNo,
            ),
            _row(
              context,
              l.chatMessageInfoForwarded,
              info.forwarded ? l.chatMessageInfoYes : l.chatMessageInfoNo,
            ),
            _row(context, l.chatMessageInfoDeleteState, info.deleteState),
          ],
        ),
      ),
    );
  }
}
