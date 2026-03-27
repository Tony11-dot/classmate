import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/messages_repository.dart';
import '../domain/message_thread_models.dart';

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  return ApiMessagesRepository();
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
