import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/http/cm_api.dart';

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(
  ProfileController.new,
);

const profilePasswordErrorNotAuthenticated = 'not_authenticated';
const profilePasswordErrorWrongPassword = 'wrong_password';
const profilePasswordErrorGeneric = 'generic_error';

class ProfileState {
  const ProfileState({
    required this.email,
    required this.username,
  });

  final String email;
  final String username;

  ProfileState copyWith({
    String? email,
    String? username,
  }) {
    return ProfileState(
      email: email ?? this.email,
      username: username ?? this.username,
    );
  }
}

class ProfileController extends Notifier<ProfileState> {
  static const _kEmail = 'profile_email';
  static const _kUsername = 'profile_username';

  @override
  ProfileState build() {
    _load();
    // Clear any legacy birthday stash on first build — feature removed.
    SharedPreferences.getInstance()
        .then((p) => p.remove('profile_birthday'))
        .ignore();
    return const ProfileState(
      email: '',
      username: '',
    );
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = ProfileState(
      email: prefs.getString(_kEmail) ?? '',
      username: prefs.getString(_kUsername) ?? '',
    );
  }

  /// Local-only stash for the email field. Email CHANGES now flow through
  /// the verify controller so the server can validate global uniqueness and
  /// require a code sent to the OLD address — this method is kept just to
  /// rehydrate the cached display value after server confirms.
  Future<void> setEmail(String value) async {
    final v = value.trim();
    state = state.copyWith(email: v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kEmail, v);
  }

  /// Server-backed username update with global uniqueness. Throws if the
  /// chosen username is already taken by another account; the profile screen
  /// surfaces the error to the user. On success the cached display value is
  /// rehydrated and the AuthSession is reloaded so every other surface
  /// (drawer chip, profile header, etc.) picks up the new value.
  Future<void> setUsername(String value) async {
    final v = value.trim();
    final session = ref.read(authSessionProvider);
    final token = (session.token ?? '').trim();
    if (token.isEmpty) throw Exception('Not authenticated');
    final api = CMApi(token: token);
    try {
      await api.patchJson('/me/username', body: {'username': v.isEmpty ? null : v});
    } finally {
      api.dispose();
    }
    state = state.copyWith(username: v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsername, v);
    // Refresh /auth/me so the cached username in AuthSession (used by the
    // drawer/profile header) matches.
    await session.reloadFromMe();
  }

  /// Returns null on success, or an error message string on failure. We
  /// surface server-provided messages verbatim when we have them (e.g.
  /// "New password must be at least 8 characters") so the user can see what
  /// went wrong — previous "Something went wrong" swallow made testing
  /// painful.
  Future<String?> changePassword({
    required String current,
    required String next,
  }) async {
    final session = ref.read(authSessionProvider);
    final token = (session.token ?? '').trim();
    if (token.isEmpty) return profilePasswordErrorNotAuthenticated;
    final api = CMApi(token: token);
    try {
      await api.postJson(
        '/me/password',
        body: {'currentPassword': current, 'newPassword': next},
      );
      return null;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('WRONG_PASSWORD')) {
        return profilePasswordErrorWrongPassword;
      }
      // Pull the server's `message` out of the JSON body if present
      // (`HTTP 400 .../me/password :: {"message":"..."}`). Falls back to the
      // raw exception string so admins debugging see SOMETHING actionable.
      final m = RegExp(r'"message":"([^"]+)"').firstMatch(msg);
      if (m != null) return m.group(1);
      return msg.replaceFirst(RegExp(r'^Exception: '), '');
    } finally {
      api.dispose();
    }
  }
}
