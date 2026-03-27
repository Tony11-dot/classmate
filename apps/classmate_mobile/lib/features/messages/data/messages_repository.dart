import '../domain/message_thread_models.dart';

abstract class MessagesRepository {
  Future<List<MessageThreadSummary>> fetchInbox();
  Future<void> createDirectRequest({
    required String recipientUserId,
    required String firstMessage,
  });
  Future<void> approveRequest({
    required String threadId,
  });
  Future<void> blockRequest({
    required String threadId,
  });
  Future<void> createGroup({
    required String title,
    required List<String> memberIds,
  });
}
