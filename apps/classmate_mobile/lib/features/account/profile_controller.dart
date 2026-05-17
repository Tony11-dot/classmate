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
    required this.birthday,
  });

  final String email;
  final String username;
  final String? birthday; // stored as 'YYYY-MM-DD'

  ProfileState copyWith({
    String? email,
    String? username,
    Object? birthday = _sentinel,
  }) {
    return ProfileState(
      email: email ?? this.email,
      username: username ?? this.username,
      birthday: birthday == _sentinel ? this.birthday : birthday as String?,
    );
  }
}

const _sentinel = Object();

class ProfileController extends Notifier<ProfileState> {
  static const _kEmail = 'profile_email';
  static const _kUsername = 'profile_username';
  static const _kBirthday = 'profile_birthday';

  @override
  ProfileState build() {
    _load();
    return const ProfileState(
      email: '',
      username: '',
      birthday: null,
    );
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = ProfileState(
      email: prefs.getString(_kEmail) ?? '',
      username: prefs.getString(_kUsername) ?? '',
      birthday: prefs.getString(_kBirthday),
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

  Future<void> setBirthday(String? value) async {
    state = state.copyWith(birthday: value);
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_kBirthday);
    } else {
      await prefs.setString(_kBirthday, value);
    }
  }

  /// Returns null on success, or an error message string on failure.
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
      if (msg.contains('400') || msg.contains('WRONG_PASSWORD')) {
        return profilePasswordErrorWrongPassword;
      }
      return profilePasswordErrorGeneric;
    }
  }
}
