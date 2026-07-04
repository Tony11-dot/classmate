import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/realtime/realtime_service.dart';
import '../data/messages_repository.dart';
import '../domain/message_thread_models.dart';

/// How many recent messages a thread loads per page. The thread view fetches
/// this most-recent window on open / refresh (instead of the entire history)
/// and pages older messages in on demand as the user scrolls up. Keeps every
/// fetch small → faster opens, cheaper bandwidth, lighter DB load.
const int kDmPageSize = 40;

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  final session = ref.watch(authSessionProvider);
  return ApiMessagesRepository(token: session.token ?? '');
});

final messagesInboxProvider = FutureProvider<List<MessageThreadSummary>>((ref) {
  final repo = ref.watch(messagesRepositoryProvider);
  return repo.fetchInbox();
});

final messageThreadProvider =
    FutureProvider.family<MessageThreadDetail, String>((ref, threadId) {
      final repo = ref.read(messagesRepositoryProvider);
      // Load only the most-recent window; older pages are fetched on scroll.
      return repo.fetchThread(threadId: threadId, limit: kDmPageSize);
    });

final messageRequestProvider =
    FutureProvider.family<MessageThreadDetail, String>((ref, threadId) {
      final repo = ref.read(messagesRepositoryProvider);
      return repo.fetchRequest(threadId: threadId);
    });

/// True while the OTHER side of [threadId] is typing. Fed by the `dm_typing`
/// SSE event; flips back to false 4s after the last signal or as soon as
/// their message actually lands (`dm_message`).
final dmPeerTypingProvider =
    StreamProvider.autoDispose.family<bool, String>((ref, threadId) {
  final controller = StreamController<bool>();
  Timer? expiry;
  controller.add(false);
  final sub = RealtimeService.instance.events.listen((event) {
    if (controller.isClosed || event.threadId != threadId) return;
    if (event.type == 'dm_typing') {
      controller.add(true);
      expiry?.cancel();
      expiry = Timer(const Duration(seconds: 4), () {
        if (!controller.isClosed) controller.add(false);
      });
    } else if (event.type == 'dm_message') {
      // Their message landed — the composer bubble is obsolete.
      expiry?.cancel();
      controller.add(false);
    }
  });
  ref.onDispose(() {
    expiry?.cancel();
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

/// Total unread message count across all threads (for badge on nav tab).
final unreadMessagesCountProvider = Provider<int>((ref) {
  final inbox = ref.watch(messagesInboxProvider);
  return inbox.maybeWhen(
    data: (threads) => threads.fold<int>(0, (sum, t) => sum + t.unreadCount),
    orElse: () => 0,
  );
});

