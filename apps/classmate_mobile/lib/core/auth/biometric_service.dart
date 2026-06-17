import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// The biometric methods we surface in the UI. The OS ultimately decides which
/// sensor runs (local_auth can't target a specific one), but we track which the
/// user turned on so the login screen can show the matching button(s).
enum BiometricMethod { face, fingerprint }

BiometricMethod? _parseMethod(String s) => switch (s.trim()) {
      'face' => BiometricMethod.face,
      'fingerprint' => BiometricMethod.fingerprint,
      _ => null,
    };

String _methodKey(BiometricMethod m) =>
    m == BiometricMethod.face ? 'face' : 'fingerprint';

/// Opt-in Face ID / fingerprint quick sign-in. Set-up lives in Profile: the
/// user confirms their password once, we verify it against the server, and the
/// credentials are kept in the platform Keychain (iOS) / Keystore-backed
/// EncryptedSharedPreferences (Android), released only after a successful
/// biometric challenge. The login screen reads them to sign in.
class BiometricService {
  BiometricService();

  final LocalAuthentication _auth = LocalAuthentication();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _kId = 'biometric_identifier_v1';
  static const _kPw = 'biometric_password_v1';
  static const _kMethods = 'biometric_methods_v1';

  /// Biometric methods the device physically has enrolled (Face ID / Touch ID
  /// / fingerprint). Empty when there's no biometric hardware or nothing is set
  /// up in the OS settings.
  Future<Set<BiometricMethod>> availableMethods() async {
    try {
      if (!await _auth.isDeviceSupported()) return {};
      if (!await _auth.canCheckBiometrics) return {};
      final types = await _auth.getAvailableBiometrics();
      final out = <BiometricMethod>{};
      if (types.contains(BiometricType.face)) out.add(BiometricMethod.face);
      if (types.contains(BiometricType.fingerprint)) {
        out.add(BiometricMethod.fingerprint);
      }
      // Android frequently reports only the generic `strong`/`weak` classes
      // without naming the sensor. Most such devices are fingerprint, so fall
      // back to that when nothing specific was reported.
      if (out.isEmpty &&
          (types.contains(BiometricType.strong) ||
              types.contains(BiometricType.weak))) {
        out.add(BiometricMethod.fingerprint);
      }
      return out;
    } on PlatformException {
      return {};
    } catch (_) {
      return {};
    }
  }

  /// Methods the user has turned ON (and that still have stored credentials).
  Future<Set<BiometricMethod>> enabledMethods() async {
    try {
      if (!await hasStoredCredentials()) return {};
      return _readMethods();
    } catch (_) {
      return {};
    }
  }

  Future<bool> isEnabled() async => (await enabledMethods()).isNotEmpty;

  Future<bool> hasStoredCredentials() async {
    try {
      final id = await _storage.read(key: _kId);
      final pw = await _storage.read(key: _kPw);
      return id != null && id.isNotEmpty && pw != null && pw.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Show the OS biometric sheet. Returns true only on a verified challenge.
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          // Allow device-PIN fallback so a temporarily-failing sensor doesn't
          // lock the user out — still gated behind the OS sheet.
          biometricOnly: false,
        ),
      );
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Turn a method ON, persisting the verified credentials.
  Future<void> enableMethod(
    BiometricMethod method, {
    required String identifier,
    required String password,
  }) async {
    await _storage.write(key: _kId, value: identifier);
    await _storage.write(key: _kPw, value: password);
    final cur = await _readMethods();
    cur.add(method);
    await _writeMethods(cur);
  }

  /// Turn a method OFF. When no methods remain, the stored credentials are
  /// wiped entirely.
  Future<void> disableMethod(BiometricMethod method) async {
    final cur = await _readMethods();
    cur.remove(method);
    await _writeMethods(cur);
    if (cur.isEmpty) await clear();
  }

  Future<({String identifier, String password})?> readCredentials() async {
    try {
      final id = await _storage.read(key: _kId);
      final pw = await _storage.read(key: _kPw);
      if (id == null || id.isEmpty || pw == null || pw.isEmpty) return null;
      return (identifier: id, password: pw);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    try {
      await _storage.delete(key: _kId);
      await _storage.delete(key: _kPw);
      await _storage.delete(key: _kMethods);
    } catch (_) {}
  }

  Future<Set<BiometricMethod>> _readMethods() async {
    final raw = await _storage.read(key: _kMethods) ?? '';
    return raw
        .split(',')
        .map(_parseMethod)
        .whereType<BiometricMethod>()
        .toSet();
  }

  Future<void> _writeMethods(Set<BiometricMethod> methods) async {
    if (methods.isEmpty) {
      await _storage.delete(key: _kMethods);
    } else {
      await _storage.write(
        key: _kMethods,
        value: methods.map(_methodKey).join(','),
      );
    }
  }
}

final biometricServiceProvider =
    Provider<BiometricService>((ref) => BiometricService());
