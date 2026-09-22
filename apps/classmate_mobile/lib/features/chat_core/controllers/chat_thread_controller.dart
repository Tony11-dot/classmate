import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../classrooms/ui/classroom_detail_screen.dart';
import '../../messages/ui/message_thread_screen.dart';
import '../domain/chat_delete_mode.dart';
import '../domain/chat_message.dart';
import '../domain/chat_thread_type.dart';
import '../domain/forward_target.dart';
import '../domain/outgoing_media.dart';

abstract class ChatThreadController {
  String get threadId;
  
  ChatThreadType get threadType;
  
  String get currentUserId;
  
  AsyncValue<List<ChatMessage>> watchMessages(WidgetRef ref);
  
  Future<void> sendText(
    String text, {
    String? replyToMessageId,
  });
  
  Future<void> sendMedia(
    List<OutgoingMedia> files, {
    String? caption,
    String? replyToMessageId,
  });
  
  Future<void> sendVoice(
    File file,
    Duration duration, {
    String? replyToMessageId,
  });
  
  Future<void> editMessage(String messageId, String newText);
  
  Future<void> deleteMessage(
    String messageId, {
    required ChatDeleteMode mode,
  });
  
  Future<void> togglePin(String messageId);

  Future<void> react(String messageId, String? emoji);

  /// Files a user-report against a message. Required by Play policy. The
  /// default implementation is a no-op so classroom chats (which currently
  /// have no report endpoint) don't break — only the DM controller actually
  /// wires this through to the backend.
  Future<void> reportMessage(String messageId, {String? reason}) async {}

  Future<void> markRead();

  /// Re-triggers the initial thread fetch after a load failure (drives the
  /// Retry button on the thread error state). Default no-op; controllers
  /// backed by a provider invalidate it so the next watch refetches.
  Future<void> retryInitialLoad() async {}

  Future<void> markVoicePlayed(String messageId) async {}

  AsyncValue<bool> watchTyping(WidgetRef ref) => const AsyncValue.data(false);

  /// Called (already debounced by the view) while the user is typing in the
  /// composer. Default no-op; the DM controller pushes a typing signal so the
  /// other side's thread shows the live "typing…" bubble.
  void notifyTyping() {}

  Future<List<ForwardTarget>?> showForwardPicker(
    BuildContext context,
    WidgetRef ref,
  );

  Future<void> forwardMessages(
    List<String> messageIds,
    List<ForwardTarget> targets,
  );

  /// Navigate to a forwarded target after a successful forward send.
  /// Uses the root Navigator so the new screen sits above the shell without
  /// touching the go_router page-key list (avoids duplicate-key crashes).
  void openForwardedTarget(BuildContext context, ForwardTarget target) {
    if (target.id == threadId) return;
    final nav = Navigator.of(context, rootNavigator: true);
    if (target is ForwardTargetClassroom) {
      nav.push(
        MaterialPageRoute<void>(
          builder: (_) => ClassroomDetailScreen(courseId: target.courseId),
        ),
      );
    } else if (target is ForwardTargetDm) {
      nav.push(
        MaterialPageRoute<void>(
          builder: (_) => MessageThreadScreen(threadId: target.threadId),
        ),
      );
    }
  }

  void invalidate();

  /// Pagination hooks for loading older messages on scroll. Default no-ops so
  /// controllers that load full history (e.g. classroom) need no changes; the
  /// DM controller overrides these to page older messages in on demand.
  bool get hasMoreOlder => false;
  bool get isLoadingOlder => false;
  Future<void> loadOlder() async {}
}
