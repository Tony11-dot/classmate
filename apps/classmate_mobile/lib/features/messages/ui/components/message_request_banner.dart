import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../models/message_request_models.dart';

class MessageRequestBanner extends StatelessWidget {
  const MessageRequestBanner({
    super.key,
    required this.data,
    this.onApprove,
    this.onBlock,
  });

  final MessageRequestBannerData data;
  final VoidCallback? onApprove;
  final VoidCallback? onBlock;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.isIncoming
                ? l.messagesRequestBannerIncoming
                : l.messagesRequestBannerOutgoing,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${data.senderName} · ${data.firstMessage}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (data.isIncoming)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onBlock,
                    child: Text(l.messagesBlockAction),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: onApprove,
                    child: Text(l.messagesApproveAction),
                  ),
                ),
              ],
            )
          else
            Text(
              l.messagesRequestUnlockHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
        ],
      ),
    );
  }
}
