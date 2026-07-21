import 'package:flutter/material.dart';

import '../../../core/http/cm_api.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_error_state.dart';

/// Friendly full-area error state for a conversation that failed its initial
/// load. Delegates to the shared illustrated [CmErrorState] so the character
/// matches the failure (offline / busy / server / permission) and offers a
/// Retry — the raw error is never rendered.
class ChatLoadErrorView extends StatelessWidget {
  const ChatLoadErrorView({super.key, required this.error, required this.onRetry});

  final Object error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final kind = cmErrorKindOf(error);
    final isBusy = error is CMApiException && (error as CMApiException).statusCode == 429;

    return CmErrorState(
      kind: kind,
      // Keep the conversation-specific headline; the body still explains the
      // actual failure so the two never contradict each other.
      title: l.chatThreadLoadFailedTitle,
      message: switch (kind) {
        CmErrorKind.timeout when isBusy => l.chatThreadLoadFailedBusy,
        CmErrorKind.generic => l.chatThreadLoadFailedBody,
        _ => null,
      },
      onRetry: onRetry,
    );
  }
}
