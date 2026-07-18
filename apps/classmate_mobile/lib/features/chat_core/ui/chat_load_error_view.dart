import 'package:flutter/material.dart';

import '../../../core/http/cm_api.dart';
import '../../../l10n/app_localizations.dart';

/// Friendly full-area error state for a conversation that failed its initial
/// load. Maps the failure to short localized copy (rate-limit vs generic) and
/// offers a Retry — the raw error is never rendered.
class ChatLoadErrorView extends StatelessWidget {
  const ChatLoadErrorView({super.key, required this.error, required this.onRetry});

  final Object error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final isBusy = error is CMApiException && (error as CMApiException).statusCode == 429;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isBusy ? Icons.hourglass_top_rounded : Icons.cloud_off_rounded,
              size: 52,
              color: cs.outline,
            ),
            const SizedBox(height: 14),
            Text(
              l.chatThreadLoadFailedTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              isBusy ? l.chatThreadLoadFailedBusy : l.chatThreadLoadFailedBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => onRetry(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
