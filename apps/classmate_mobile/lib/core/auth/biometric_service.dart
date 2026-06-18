import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// The biometric methods we surface in the UI. The OS ultimately decides which
/// sensor runs, but we track which the user turned on so the UI can reflect it.
enum BiometricMethod { face, fingerprint }

BiometricMethod? _parseMethod(String s) => switch (s.trim()) {
      'face' => BiometricMethod.face,
      'fingerprint' => BiometricMethod.fingerprint,
      _ => null,
    };

String _methodKey(BiometricMethod m) =>
    m == BiometricMethod.face ? 'face' : 'fingerprint';

/// Opt-in Face ID / fingerprint quick sign-in.
///
/// IMPORTANT: biometric data is **per account**, keyed by the account's stable
/// user id — NOT per device. So two users on the SAME phone each have their own
/// independent on/off state: User A attaching Face ID does not make User B's
/// switch appear on. The biometric itself never leaves the phone's secure chip
/// (we can't read it or match it server-side); what we store, behind the OS
/// challenge, is the account's credentials in the Keychain/Keystore.
///
/// A single device-level "active account" pointer records which account the
/// login screen should sign into when biometrics succeed there (the last
/// account to attach biometrics on this device).
class BiometricService {
  BiometricService();

  final LocalAuthentication _auth = LocalAuthentication();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Per-account keys (namespaced by the account id).
  String _idKey(String acct) => 'biometric_v2_id_$acct';
  String _pwKey(String acct) => 'biometric_v2_pw_$acct';
  String _methodsKey(String acct) => 'biometric_v2_methods_$acct';
  // Device-level pointer: which account the LOGIN screen unlocks.
  static const _kActiveAccount = 'biometric_v2_active_account';

  // ── Device capability (sensor-level, account-independent) ──────────────────

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

  /// Whether the device can do a biometric / device-credential challenge at all.
  Future<bool> deviceSupported() async {
    try {
      if (await _auth.isDeviceSupported()) return true;
      return await _auth.canCheckBiometrics;
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
          biometricOnly: false,
        ),
      );
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  // ── Per-account state (Profile, while logged in) ───────────────────────────

  /// Methods THIS account has turned on (and that still have stored creds).
  Future<Set<BiometricMethod>> enabledMethodsForAccount(String acct) async {
    if (acct.isEmpty) return {};
    try {
      if (!await _hasCredentials(acct)) return {};
      return _readMethods(acct);
    } catch (_) {
      return {};
    }
  }

  /// Turn a method ON for [acct], persisting the verified credentials, and make
  /// this account the one the login screen unlocks on this device.
  Future<void> enableMethod(
    String acct,
    BiometricMethod method, {
    required String identifier,
    required String password,
  }) async {
    if (acct.isEmpty) return;
    await _storage.write(key: _idKey(acct), value: identifier);
    await _storage.write(key: _pwKey(acct), value: password);
    final cur = await _readMethods(acct);
    cur.add(method);
    await _writeMethods(acct, cur);
    await _storage.write(key: _kActiveAccount, value: acct);
  }

  /// Turn a method OFF for [acct]. When none remain, its credentials are wiped,
  /// and if it was the active login account that pointer is cleared too.
  Future<void> disableMethod(String acct, BiometricMethod method) async {
    if (acct.isEmpty) return;
    final cur = await _readMethods(acct);
    cur.remove(method);
    await _writeMethods(acct, cur);
    if (cur.isEmpty) {
      await _clearAccount(acct);
      if ((await _storage.read(key: _kActiveAccount)) == acct) {
        await _storage.delete(key: _kActiveAccount);
      }
    }
  }

  /// This account's stored credentials (so a 2nd method can reuse them).
  Future<({String identifier, String password})?> accountCredentials(
      String acct) async {
    if (acct.isEmpty) return null;
    return _readCredentials(acct);
  }

  // ── Login screen (no current user) ─────────────────────────────────────────

  /// Methods the login screen can offer = the active account's methods.
  Future<Set<BiometricMethod>> loginMethods() async {
    final acct = await _activeAccount();
    if (acct.isEmpty) return {};
    return enabledMethodsForAccount(acct);
  }

  Future<bool> isLoginEnabled() async => (await loginMethods()).isNotEmpty;

  Future<({String identifier, String password})?> loginCredentials() async {
    final acct = await _activeAccount();
    if (acct.isEmpty) return null;
    return _readCredentials(acct);
  }

  /// Forget the active account's biometric login (e.g. its password changed).
  Future<void> clearLogin() async {
    final acct = await _activeAccount();
    if (acct.isNotEmpty) await _clearAccount(acct);
    await _storage.delete(key: _kActiveAccount);
  }

  // ── internals ──────────────────────────────────────────────────────────────

  Future<String> _activeAccount() async {
    try {
      return (await _storage.read(key: _kActiveAccount) ?? '').trim();
    } catch (_) {
      return '';
    }
  }

  Future<bool> _hasCredentials(String acct) async {
    final id = await _storage.read(key: _idKey(acct));
    final pw = await _storage.read(key: _pwKey(acct));
    return id != null && id.isNotEmpty && pw != null && pw.isNotEmpty;
  }

  Future<({String identifier, String password})?> _readCredentials(
      String acct) async {
    try {
      final id = await _storage.read(key: _idKey(acct));
      final pw = await _storage.read(key: _pwKey(acct));
      if (id == null || id.isEmpty || pw == null || pw.isEmpty) return null;
      return (identifier: id, password: pw);
    } catch (_) {
      return null;
    }
  }

  Future<void> _clearAccount(String acct) async {
    try {
      await _storage.delete(key: _idKey(acct));
      await _storage.delete(key: _pwKey(acct));
      await _storage.delete(key: _methodsKey(acct));
    } catch (_) {}
  }

  Future<Set<BiometricMethod>> _readMethods(String acct) async {
    final raw = await _storage.read(key: _methodsKey(acct)) ?? '';
    return raw
        .split(',')
        .map(_parseMethod)
        .whereType<BiometricMethod>()
        .toSet();
  }

  Future<void> _writeMethods(String acct, Set<BiometricMethod> methods) async {
    if (methods.isEmpty) {
      await _storage.delete(key: _methodsKey(acct));
    } else {
      await _storage.write(
        key: _methodsKey(acct),
        value: methods.map(_methodKey).join(','),
      );
    }
  }
}

final biometricServiceProvider =
    Provider<BiometricService>((ref) => BiometricService());
