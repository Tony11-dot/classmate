import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/messages/providers/messages_repository_provider.dart';
import '../auth/auth_controller.dart';
import '../locale/locale_controller.dart';
import 'realtime_service.dart';
export 'realtime_service.dart' show RealtimeEvent;

// ── Provider that exposes latest event (screens can watch/listen to this) ──
// Using a simple notifier to avoid StateProvider generic issues.
class _RealtimeNotifier extends Notifier<RealtimeEvent?> {
  @override
  RealtimeEvent? build() => null;
  void emit(RealtimeEvent event) => state = event;
}

final realtimeEventProvider = NotifierProvider<_RealtimeNotifier, RealtimeEvent?>(
  _RealtimeNotifier.new,
);

/// Widget that must live near the app root.
/// It connects SSE when the user is authenticated and disconnects on logout.
/// It also propagates events to [realtimeEventProvider] so any screen can react.
class RealtimeListener extends ConsumerStatefulWidget {
  const RealtimeListener({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<RealtimeListener> createState() => _RealtimeListenerState();
}

class _RealtimeListenerState extends ConsumerState<RealtimeListener> {
  StreamSubscription<RealtimeEvent>? _eventSub;
  String? _connectedToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  void _sync() {
    final session = ref.read(authSessionProvider);
    final token = session.token ?? '';
    if (token == _connectedToken) return;

    // Always cancel the old subscription first, then disconnect the old connection,
    // BEFORE starting a new one — prevents duplicate SSE streams.
    _eventSub?.cancel();
    _eventSub = null;
    if (_connectedToken != null && _connectedToken!.isNotEmpty) {
      RealtimeService.instance.disconnect();
    }
    _connectedToken = token;

    if (token.isEmpty) return;

    // PARENT users need a second SSE channel — /parent/notifications
    // pushes parent-specific events that don't go through the main
    // /realtime stream. enableParentStream() is idempotent and a no-op
    // for other roles.
    if (session.primaryRole == 'PARENT') {
      RealtimeService.instance.enableParentStream();
    }

    RealtimeService.instance.connect(token);

    // Mirror the chosen UI language to the server on (re)login so the
    // notification hub can localize copy for this account.
    pushLocaleToServer(token, ref.read(localeControllerProvider)?.languageCode);

    _eventSub = RealtimeService.instance.events.listen((event) {
      if (!mounted) return;
      ref.read(realtimeEventProvider.notifier).emit(event);
      _ackDelivery(event);
    });
  }

  /// A DM that reaches this device IS delivered, whatever screen the user is
  /// on. Acking here (rather than only when the inbox or the thread opens) is
  /// what makes the sender's second tick appear in real time instead of
  /// whenever the recipient next happens to look at their chats.
  void _ackDelivery(RealtimeEvent event) {
    if (event.type != 'dm_message') return;
    final threadId = event.threadId;
    if (threadId == null || threadId.isEmpty) return;
    if (!_ackedThreads.add(threadId)) return;
    unawaited(
      ref
          .read(messagesRepositoryProvider)
          .markThreadDelivered(threadId: threadId)
          .whenComplete(() => _ackedThreads.remove(threadId)),
    );
  }

  /// In-flight acks, so a burst of messages in one thread sends one receipt.
  final Set<String> _ackedThreads = <String>{};

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Re-sync when auth state changes
    ref.listen(authSessionProvider, (_, __) => _sync());
    return widget.child;
  }
}
