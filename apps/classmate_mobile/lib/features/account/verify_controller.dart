import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/http/cm_api.dart';

/// Snapshot of the user's email/phone + verification timestamps. Loaded from
/// `/me/verify/status` on profile open and after every confirm.
class VerifyStatus {
  const VerifyStatus({
    this.email,
    this.emailVerifiedAt,
    this.phone,
    this.phoneVerifiedAt,
    this.loading = false,
  });

  final String? email;
  final DateTime? emailVerifiedAt;
  final String? phone;
  final DateTime? phoneVerifiedAt;
  final bool loading;

  bool get emailVerified => emailVerifiedAt != null;
  bool get phoneVerified => phoneVerifiedAt != null;

  VerifyStatus copyWith({
    Object? email = _sentinel,
    Object? emailVerifiedAt = _sentinel,
    Object? phone = _sentinel,
    Object? phoneVerifiedAt = _sentinel,
    bool? loading,
  }) {
    return VerifyStatus(
      email: email == _sentinel ? this.email : email as String?,
      emailVerifiedAt: emailVerifiedAt == _sentinel ? this.emailVerifiedAt : emailVerifiedAt as DateTime?,
      phone: phone == _sentinel ? this.phone : phone as String?,
      phoneVerifiedAt: phoneVerifiedAt == _sentinel ? this.phoneVerifiedAt : phoneVerifiedAt as DateTime?,
      loading: loading ?? this.loading,
    );
  }
}

const _sentinel = Object();

final verifyControllerProvider =
    NotifierProvider<VerifyController, VerifyStatus>(VerifyController.new);

class VerifyController extends Notifier<VerifyStatus> {
  @override
  VerifyStatus build() => const VerifyStatus();

  CMApi get _api {
    final token = (ref.read(authSessionProvider).token ?? '').trim();
    return CMApi(token: token);
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true);
    try {
      final raw = await _api.getJson('/me/verify/status');
      final m = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
      state = state.copyWith(
        email: m['email']?.toString(),
        phone: m['phone']?.toString(),
        emailVerifiedAt: _parseDate(m['emailVerifiedAt']),
        phoneVerifiedAt: _parseDate(m['phoneVerifiedAt']),
        loading: false,
      );
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  /// Returns the masked target the server claims to have sent to (e.g.
  /// `t•••y@classmateapp.org`). Throws on bad-request / cooldown errors.
  Future<String> startVerify(String channel, {String? newValue}) async {
    final raw = await _api.postJson('/me/verify/$channel/start', body: {
      if (newValue != null && newValue.trim().isNotEmpty) 'newValue': newValue.trim(),
    });
    final m = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    return m['target']?.toString() ?? '';
  }

  /// Returns true when the channel was just changed to a new value (so the
  /// caller should also push the new value into AuthSession + the screen),
  /// false when this was a verify-current confirm.
  Future<bool> confirmVerify(String channel, {required String code, String? newValue}) async {
    final raw = await _api.postJson('/me/verify/$channel/confirm', body: {
      'code': code.trim(),
      if (newValue != null && newValue.trim().isNotEmpty) 'newValue': newValue.trim(),
    });
    await refresh();
    final m = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    return m['changed'] == true;
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw == null) return null;
    final s = raw.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }
}
