import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_restart.dart';
// These four hold STATIC / in-memory caches that survive an AppRestart, so we
// clear them explicitly on every account change.
import '../../features/chat_core/controllers/classroom_chat_thread_controller.dart';
import '../../features/chat_core/controllers/dm_chat_thread_controller.dart';
import '../../features/lifedoc/data/exams_repository.dart';
import '../../features/lifedoc/data/forms_repository.dart';
import '../../features/practice/data/practice_generator.dart';
import '../../features/admin/ui/admin_schedule_screen.dart' show resetAdminScheduleCaches;
import 'auth_session.dart';
import 'accounts_store.dart';
export 'auth_session.dart' show authSessionProvider, AuthSession;

final authControllerProvider = Provider<AuthController>(
  (ref) => AuthController(ref),
);

class AuthController {
  AuthController(this.ref);
  final Ref ref;

  /// Clears the NON-Riverpod state that would otherwise survive an account
  /// change on the same device: `static`/in-memory caches and global (not
  /// user-keyed) SharedPreferences entries. Riverpod provider state itself is
  /// wiped wholesale by the [AppRestart.restart] that follows — this handles
  /// only what a scope restart does NOT reach.
  Future<void> _clearNonProviderCaches() async {
    ClassroomChatThreadController.clearAllSessionCaches();
    DmChatThreadController.clearAllSessionCaches();
    resetStudentExamsCache();
    resetStudentFormsCache();
    PracticeGenerator.resetRecentPrompts();
    resetAdminScheduleCaches();
    await _clearUserScopedPrefs();
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

  /// Switch to another remembered account (no password). Persists the target
  /// as the active account + its token, then hard-restarts the whole provider
  /// tree so the app comes up as a completely fresh world for that account —
  /// no chance of the previous account's data lingering in any cache. The
  /// previous account stays remembered (and still receives push — the backend
  /// keys the device token per (user, token)).
  Future<void> switchAccount(StoredAccount account) async {
    if (account.userId == ref.read(authSessionProvider).userId) return;
    // 1. Wipe non-Riverpod caches (static fields + global prefs) — a scope
    //    restart alone would leave these holding the outgoing account's data.
    await _clearNonProviderCaches();
    // 2. Make the target the active account and persist its token so the fresh
    //    AuthSession created by the restart adopts it on boot.
    final store = ref.read(accountsStoreProvider);
    await store.setActive(account.userId);
    await ref.read(authSessionProvider).setToken(account.token);
    // 3. Blow the whole tree away and rebuild. The splash shows briefly while
    //    the new session validates /auth/me, then the router lands the user on
    //    their role home — exactly like a cold launch into that account.
    AppRestart.restart();
  }

  /// Sign the ACTIVE account out. If other accounts remain, switch to one of
  /// them; otherwise fall back to a full logout to /login.
  Future<void> signOutActiveAccount() async {
    final session = ref.read(authSessionProvider);
    final store = ref.read(accountsStoreProvider);
    final leavingId = session.userId;
    await session.unregisterPushForCurrent();
    if (leavingId.isNotEmpty) await store.remove(leavingId);
    final remaining = (await store.all()).where((a) => a.userId != leavingId).toList();
    if (remaining.isNotEmpty) {
      await switchAccount(remaining.first);
      return;
    }
    await logout();
  }

  Future<void> logout() async {
    await _clearNonProviderCaches();
    // Drop every remembered account on a full logout.
    await ref.read(accountsStoreProvider).clear();
    // Tell AuthSession to wipe its own state (token, name, school…).
    await ref.read(authSessionProvider).logout();
    // Hard-restart into a pristine tree. With no token the fresh session is
    // logged-out, so the router lands on /login — no stale providers survive.
    AppRestart.restart();
  }

  /// Best-effort sweep of GLOBAL (not user-keyed) SharedPreferences entries
  /// that hold user-scoped data. These survive a [AppRestart] scope restart —
  /// worse, the fresh providers re-hydrate FROM them, so without this wipe the
  /// next account would silently inherit the previous account's chats, saved
  /// questions, NOVA usage, profile, read-state, etc. Keys/prefixes below were
  /// enumerated by an audit of every `prefs.set*` call site in the app.
  Future<void> _clearUserScopedPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      const prefixes = [
        // Chat (classroom + DM) — the real per-thread keys.
        'classroom_chat:',
        'classroom_chat_seen_',
        'classroom_pinned_ids_',
        'classroom_last_seen_',
        'dm_deleted:',
        'dm_sent_urls:',
        'dm_media:',
        'dm_local_media:',
        'dm_media_url_cache:',
        // Notifications + announcements read-state / known-ids. Without these
        // the next user re-fires every one of their notifications on first
        // sync (the known-ids set still holds the previous user's IDs).
        'lifedoc_',
        // NOVA plan choice + usage counters + renamed/hidden tutor sessions.
        'nova_',
        // Profile email / username / birthday.
        'profile_',
        // Per-form submitted answers.
        'form_submitted:',
      ];
      const exactKeys = [
        'practice_saved_questions_v1',
        'practice_history_sessions_v1',
        'parent_selected_student_id_v1',
        'student_classrooms_custom_order_v1',
        'shown_notification_ids_v1',
      ];
      for (final k in keys) {
        if (prefixes.any((p) => k.startsWith(p)) || exactKeys.contains(k)) {
          await prefs.remove(k);
        }
      }
    } catch (_) {
      // best effort — never block logout on prefs IO
    }
  }
}
