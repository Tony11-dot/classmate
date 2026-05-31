import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/chat_core/controllers/classroom_chat_thread_controller.dart';
import '../../features/chat_core/controllers/dm_chat_thread_controller.dart';
import '../../features/messages/providers/messages_repository_provider.dart';
import '../../features/classrooms/providers/classrooms_providers.dart';
import 'auth_session.dart';
export 'auth_session.dart' show authSessionProvider, AuthSession;

final authControllerProvider = Provider<AuthController>(
  (ref) => AuthController(ref),
);

class AuthController {
  AuthController(this.ref);
  final Ref ref;

  Future<void> logout(BuildContext context) async {
    // 1. Clear all static caches that hold the previous user's data.
    //    Without this the next user logging in on the same device sees
    //    leaked chat previews, optimistic messages, and CDN URL caches.
    ClassroomChatThreadController.clearAllSessionCaches();
    DmChatThreadController.clearAllSessionCaches();
    await _clearUserScopedPrefs();

    // 2. Invalidate every long-lived provider that holds a cached
    //    payload keyed by user (DM inbox, classroom chat lists,
    //    classroom rosters). Without this the next user on the same
    //    device sees the previous user's threads on the Messages tab
    //    for one render before the new fetch lands.
    ref.invalidate(messagesInboxProvider);
    ref.invalidate(classroomChatProvider);
    ref.invalidate(studentClassroomsProvider);
    ref.invalidate(orderedStudentClassroomsProvider);

    // 3. Tell AuthSession to wipe its own state (token, name, school…).
    await ref.read(authSessionProvider).logout();

    // 4. Navigate to login. Riverpod providers that depend on the
    //    auth token rebuild automatically once the token flips to
    //    empty — autoDispose ones tear down, the rest re-emit with
    //    the new (unauth) state.
    if (context.mounted) context.go('/login');
  }

  /// Best-effort sweep of SharedPreferences keys known to hold
  /// user-scoped data. The chat controllers persist message caches
  /// under `classroom_chat:$courseId:$userId:…` and `dm_*:…`; those
  /// stay because they're keyed by user, but the legacy not-keyed
  /// variants (e.g. `classroom_pinned_ids_*`, `dm_deleted:*`,
  /// `dm_sent_urls:*`) need an explicit wipe.
  Future<void> _clearUserScopedPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      const prefixes = [
        'classroom_chat:',
        'classroom_pinned_ids_',
        'dm_deleted:',
        'dm_sent_urls:',
        'dm_media:',
        // Without these, the next user on the same device sees every
        // one of their notifications fire as a fresh push the first
        // time the inbox syncs — because the known-ids set still
        // contains the previous user's IDs.
        'lifedoc_notifications_',
      ];
      for (final k in keys) {
        if (prefixes.any((p) => k.startsWith(p))) {
          await prefs.remove(k);
        }
      }
    } catch (_) {
      // best effort — never block logout on prefs IO
    }
  }
}
