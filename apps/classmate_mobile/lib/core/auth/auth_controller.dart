import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/chat_core/controllers/classroom_chat_thread_controller.dart';
import '../../features/chat_core/controllers/dm_chat_thread_controller.dart';
import '../../features/messages/providers/messages_repository_provider.dart';
import '../../features/classrooms/providers/classrooms_providers.dart';
import '../../features/lifedoc/notifications_provider.dart';
import '../../features/lifedoc/data/exams_repository.dart';
import '../../features/lifedoc/data/forms_repository.dart';
import '../../features/insights/providers/insights_providers.dart';
import '../../features/insights/providers/submissions_provider.dart';
import '../../features/practice/providers/practice_providers.dart';
import '../../features/parent/data/parent_repository.dart';
import '../../features/solutions/providers/solutions_flow_provider.dart';
import 'auth_session.dart';
import 'accounts_store.dart';
export 'auth_session.dart' show authSessionProvider, AuthSession;

final authControllerProvider = Provider<AuthController>(
  (ref) => AuthController(ref),
);

class AuthController {
  AuthController(this.ref);
  final Ref ref;

  /// Clears every cache/provider that holds the outgoing account's data.
  /// Shared by full logout and the multi-account switch so a switch can NEVER
  /// leak the previous account's chats/notifications/insights into the next.
  Future<void> _resetForAccountSwap() async {
    ClassroomChatThreadController.clearAllSessionCaches();
    DmChatThreadController.clearAllSessionCaches();
    resetStudentExamsCache();
    resetStudentFormsCache();
    await _clearUserScopedPrefs();

    ref.invalidate(messagesInboxProvider);
    ref.invalidate(messageThreadProvider);
    ref.invalidate(messageRequestProvider);
    ref.invalidate(classroomChatProvider);
    ref.invalidate(studentClassroomsProvider);
    ref.invalidate(orderedStudentClassroomsProvider);
    ref.invalidate(persistedNotificationsProvider);
    ref.invalidate(localNotificationsProvider);
    ref.invalidate(notificationInboxProvider);
    ref.invalidate(unreadNotificationsCountProvider);
    ref.invalidate(examsLiveProvider);
    ref.invalidate(formsLiveProvider);
    ref.invalidate(serverInsightsProvider);
    ref.invalidate(effectiveAccuracyPercentProvider);
    ref.invalidate(effectiveTotalSessionsProvider);
    ref.invalidate(effectiveTotalAttemptsProvider);
    ref.invalidate(aiInsightsSummaryProvider);
    ref.invalidate(unifiedStudentInsightsProvider);
    ref.invalidate(submissionStatsProvider);
    ref.invalidate(practiceHistoryProvider);
    ref.invalidate(practiceAnalyticsProvider);
    ref.invalidate(parentChildrenProvider);
    ref.invalidate(parentNotificationsProvider);
    ref.invalidate(selectedChildProvider);
    ref.invalidate(liveSolutionsPreviewProvider);
  }

  /// Snapshot the currently-signed-in account into the on-device account list
  /// and mark it active. Call right after a successful login (first login OR
  /// "add account") so the switcher always knows about it.
  Future<void> rememberCurrentAccount() async {
    final session = ref.read(authSessionProvider);
    final id = session.userId;
    final token = session.token;
    if (id.isEmpty || token == null || token.isEmpty) return;
    final store = ref.read(accountsStoreProvider);
    await store.upsert(StoredAccount(
      userId: id,
      token: token,
      displayName: session.displayName,
      roleLabel: session.primaryRole,
      roles: session.roles,
      schoolName: session.schoolName,
    ));
    await store.setActive(id);
    await ref.read(accountsControllerProvider.notifier).reload();
  }

  /// Instantly switch to another remembered account (no password). The previous
  /// account stays remembered (and still receives push — the backend keys the
  /// device token per (user, token)).
  Future<void> switchAccount(BuildContext context, StoredAccount account) async {
    if (account.userId == ref.read(authSessionProvider).userId) return;
    await _resetForAccountSwap();
    // Optimistically adopt the cached profile so the shell flips immediately…
    await ref.read(authSessionProvider).applyStoredAccount(
          token: account.token,
          displayName: account.displayName,
          roles: account.roles,
          schoolName: account.schoolName,
        );
    final store = ref.read(accountsStoreProvider);
    await store.setActive(account.userId);
    await ref.read(accountsControllerProvider.notifier).reload();
    if (context.mounted) context.go('/');
    // …then refresh from the server in the background (also re-persists a fresh
    // token/profile). A 401 means the stored token expired → drop the account.
    try {
      await ref.read(authSessionProvider).reloadFromMe();
      await rememberCurrentAccount();
    } catch (_) {}
  }

  /// Sign the ACTIVE account out. If other accounts remain, switch to one of
  /// them; otherwise fall back to a full logout to /login.
  Future<void> signOutActiveAccount(BuildContext context) async {
    final session = ref.read(authSessionProvider);
    final store = ref.read(accountsStoreProvider);
    final leavingId = session.userId;
    await session.unregisterPushForCurrent();
    if (leavingId.isNotEmpty) await store.remove(leavingId);
    final remaining = (await store.all()).where((a) => a.userId != leavingId).toList();
    if (remaining.isNotEmpty) {
      await switchAccount(context, remaining.first);
      return;
    }
    await logout(context);
  }

  Future<void> logout(BuildContext context) async {
    await _resetForAccountSwap();
    // Drop every remembered account on a full logout.
    await ref.read(accountsStoreProvider).clear();
    await ref.read(accountsControllerProvider.notifier).reload();
    // Tell AuthSession to wipe its own state (token, name, school…).
    await ref.read(authSessionProvider).logout();
    // Navigate to login. Token-dependent providers rebuild automatically.
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
