import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../l10n/app_localizations.dart';
import '../../data/messages_repository.dart';

/// Maps any messages-layer error into a short, human-friendly, SANITIZED
/// string. Never exposes raw server bodies, internal endpoint paths, or
/// exception/stack text.
///
/// This is the guard for the bug a tester hit on v1.0.8: tapping a
/// rate-limited conversation surfaced a raw `429` dump with backend paths.
/// A 429 now reads as a calm "slow down and retry" message instead.
String messagesFriendlyError(BuildContext context, Object error) {
  final l = AppLocalizations.of(context)!;
  if (error is MessagesApiException) {
    if (error.isRateLimited) return l.messagesErrorRateLimited;
    if (error.isUnauthorized) return l.messagesErrorSignedOut;
    if (error.isServerError) return l.messagesErrorServer;
    return l.messagesErrorGeneric;
  }
  if (error is SocketException ||
      error is TimeoutException ||
      error is http.ClientException) {
    return l.messagesErrorOffline;
  }
  return l.messagesErrorGeneric;
}

/// Like [messagesFriendlyError] but for one-off action feedback (snackbars,
/// inline form errors). Preserves an explicit, safe server `message` — e.g.
/// "That invite code is invalid" — for ordinary 4xx failures, while still
/// hiding raw 429/5xx bodies and internal exception/stack text.
String messagesActionError(BuildContext context, Object error) {
  final l = AppLocalizations.of(context)!;
  if (error is MessagesApiException) {
    if (error.isRateLimited) return l.messagesErrorRateLimited;
    if (error.isUnauthorized) return l.messagesErrorSignedOut;
    if (error.isServerError) return l.messagesErrorServer;
    final msg = error.serverMessage;
    if (msg != null && msg.trim().isNotEmpty) return msg.trim();
    return l.messagesErrorGeneric;
  }
  if (error is SocketException ||
      error is TimeoutException ||
      error is http.ClientException) {
    return l.messagesErrorOffline;
  }
  // Plain Exception carrying a domain message (e.g. from joinGroupByCode).
  final text = error.toString().replaceFirst('Exception: ', '').trim();
  if (text.isNotEmpty && !text.startsWith('MessagesApiException')) {
    return text;
  }
  return l.messagesErrorGeneric;
}

/// A centered, friendly error state with an icon, a sanitized message, and a
/// Retry button. Shared by the thread, request, and inbox screens so every
/// messaging failure looks the same and always offers a way forward.
class MessagesErrorView extends StatelessWidget {
  const MessagesErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  bool get _isRateLimited =>
      error is MessagesApiException &&
      (error as MessagesApiException).isRateLimited;

  bool get _isOffline =>
      error is SocketException ||
      error is TimeoutException ||
      error is http.ClientException;

  IconData get _icon {
    if (_isRateLimited) return Icons.hourglass_top_rounded;
    if (_isOffline) return Icons.wifi_off_rounded;
    return Icons.error_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 48, color: cs.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              messagesFriendlyError(context, error),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.35,
                  ),
            ),
            const SizedBox(height: 20),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
