import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_session.dart';
import '../data/messages_repository.dart';
import '../domain/message_thread_models.dart';

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  final session = ref.watch(authSessionProvider);
  return ApiMessagesRepository(token: session.token ?? '');
});

final messagesInboxProvider = FutureProvider<List<MessageThreadSummary>>((ref) {
  final repo = ref.read(messagesRepositoryProvider);
  return repo.fetchInbox();
});

final messageThreadProvider =
    FutureProvider.family<MessageThreadDetail, String>((ref, threadId) {
      final repo = ref.read(messagesRepositoryProvider);
      return repo.fetchThread(threadId: threadId);
    });

final messageRequestProvider =
    FutureProvider.family<MessageThreadDetail, String>((ref, threadId) {
      final repo = ref.read(messagesRepositoryProvider);
      return repo.fetchRequest(threadId: threadId);
    });
