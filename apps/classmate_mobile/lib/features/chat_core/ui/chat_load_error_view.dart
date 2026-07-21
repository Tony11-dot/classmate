import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/classmate_error_view.dart';

/// Friendly full-area error state for a conversation that failed its initial
/// load. Delegates to the shared [ClassMateErrorView], which shows the little
/// ClassMate mascot whose mood + sign match the failure (offline, busy, …) and
/// offers a Retry — the raw error is never rendered.
class ChatLoadErrorView extends StatelessWidget {
  const ChatLoadErrorView({super.key, required this.error, required this.onRetry});

  final Object error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ClassMateErrorView(
      error: error,
      // Keep the conversation-specific title; the mascot/body come from the
      // classified error kind.
      title: l.chatThreadLoadFailedTitle,
      onRetry: () => onRetry(),
    );
  }
}
