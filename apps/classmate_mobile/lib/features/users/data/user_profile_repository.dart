import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/http/cm_api.dart';
import 'user_profile.dart';

/// Thin wrapper around GET /users/:id/profile. The server enforces
/// same-school + 404 / 403 errors propagate as CMApiException, which
/// the sheet UI catches and renders an inline error.
class UserProfileRepository {
  UserProfileRepository(this._token);
  final String? _token;

  Future<UserProfile> fetch(String userId) async {
    final api = CMApi(token: _token);
    try {
      final raw = await api.getJson('/users/$userId/profile');
      final m = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
      final p = m['profile'];
      if (p is! Map) throw const FormatException('Malformed profile response');
      return UserProfile.fromJson(Map<String, dynamic>.from(p));
    } finally {
      api.dispose();
    }
  }
}

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final session = ref.watch(authSessionProvider);
  return UserProfileRepository(session.token);
});

final userProfileProvider =
    FutureProvider.family<UserProfile, String>((ref, userId) async {
  return ref.read(userProfileRepositoryProvider).fetch(userId);
});
