import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Optional Face ID / fingerprint quick sign-in. The user's login credentials
/// are kept in the platform Keychain (iOS) / Keystore-backed EncryptedShared‑
/// Preferences (Android) and only handed back after a successful biometric
/// (or device-credential) challenge. Entirely opt-in — nothing is stored
/// unless the user explicitly enables it.
class BiometricService {
  BiometricService();

  final LocalAuthentication _auth = LocalAuthentication();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _kId = 'biometric_identifier_v1';
  static const _kPw = 'biometric_password_v1';

  /// True when the device has biometric hardware the user has enrolled.
  Future<bool> isAvailable() async {
    try {
      if (!await _auth.isDeviceSupported()) return false;
      if (!await _auth.canCheckBiometrics) return false;
      final enrolled = await _auth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// True when we have credentials saved for biometric unlock.
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
          // Allow device-PIN fallback so users without/temporarily-failing
          // biometrics can still get in — still gated behind the OS sheet.
          biometricOnly: false,
        ),
      );
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> saveCredentials({
    required String identifier,
    required String password,
  }) async {
    await _storage.write(key: _kId, value: identifier);
    await _storage.write(key: _kPw, value: password);
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
    } catch (_) {}
  }
}

final biometricServiceProvider =
    Provider<BiometricService>((ref) => BiometricService());
