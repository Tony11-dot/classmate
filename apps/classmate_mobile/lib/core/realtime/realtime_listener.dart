import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
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

    RealtimeService.instance.connect(token);
    _eventSub = RealtimeService.instance.events.listen((event) {
      if (!mounted) return;
      ref.read(realtimeEventProvider.notifier).emit(event);
    });
  }

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
