import 'package:classmate_mobile/core/theme/cm_tokens.dart';
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

    final t = Theme.of(context).textTheme;
    final dark = cs.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withValues(alpha: dark ? 0.2 : 0.1),
            cs.surfaceContainerLow,
          ],
        ),
        borderRadius: BorderRadius.circular(CmTokens.radiusXl),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35), width: 0.8),
        boxShadow: CmTokens.of(context).shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: cs.primary,
                child: Text(
                  data.senderInitials.trim().isEmpty ? '?' : data.senderInitials,
                  style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.senderName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      data.isIncoming
                          ? l.messagesRequestBannerIncoming
                          : l.messagesRequestBannerOutgoing,
                      style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // The first message, shown like an incoming chat bubble.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: dark ? cs.surfaceContainerHigh : cs.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Text(data.firstMessage, style: t.bodyMedium?.copyWith(height: 1.4)),
          ),
          const SizedBox(height: 16),
          if (data.isIncoming)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: cs.error,
                      side: BorderSide(color: cs.error.withValues(alpha: 0.5)),
                    ),
                    onPressed: onBlock,
                    icon: const Icon(Icons.block_rounded, size: 18),
                    label: Text(l.messagesBlockAction),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(l.messagesApproveAction),
                  ),
                ),
              ],
            )
          else
            Text(
              l.messagesRequestUnlockHint,
              style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}
