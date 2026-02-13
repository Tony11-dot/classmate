import 'dart:io' show Platform;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'prefs.dart';

/// Session storage:
/// - iOS/Android: flutter_secure_storage (Keychain/Keystore)
/// - macOS: SharedPreferences (avoids Keychain entitlement issues in dev)
class Session {
  static const String _kToken = 'classmate_token';
  static const String _kRole  = 'classmate_role';
  static const String _kEmail = 'classmate_email';
  static const String _kName  = 'classmate_name';

  static const FlutterSecureStorage _secure = FlutterSecureStorage();

  static bool get _usePrefs => Platform.isMacOS;

  static Future<void> saveAuth({
    required String token,
    String? role,
    String? email,
    String? name,
  }) async {
    if (_usePrefs) {
      await Prefs.setString(_kToken, token);
      if (role != null && role.isNotEmpty) await Prefs.setString(_kRole, role);
      if (email != null && email.isNotEmpty) await Prefs.setString(_kEmail, email);
      if (name != null && name.isNotEmpty) await Prefs.setString(_kName, name);
      return;
    }

    await _secure.write(key: _kToken, value: token);
    if (role != null && role.isNotEmpty) await _secure.write(key: _kRole, value: role);
    if (email != null && email.isNotEmpty) await _secure.write(key: _kEmail, value: email);
    if (name != null && name.isNotEmpty) await _secure.write(key: _kName, value: name);
  }

  static Future<String?> getToken() async {
    if (_usePrefs) return Prefs.getString(_kToken);
    return _secure.read(key: _kToken);
  }

  static Future<String?> getRole() async {
    if (_usePrefs) return Prefs.getString(_kRole);
    return _secure.read(key: _kRole);
  }

  static Future<String?> getEmail() async {
    if (_usePrefs) return Prefs.getString(_kEmail);
    return _secure.read(key: _kEmail);
  }

  static Future<String?> getName() async {
    if (_usePrefs) return Prefs.getString(_kName);
    return _secure.read(key: _kName);
  }

  static Future<void> clearAll() async {
    // Clear prefs (macOS)
    await Prefs.remove(_kToken);
    await Prefs.remove(_kRole);
    await Prefs.remove(_kEmail);
    await Prefs.remove(_kName);

    // Clear secure (iOS/Android) - safe to ignore failures on macOS
    try {
      await _secure.deleteAll();
    } catch (_) {}
  }

  // backward-compatible aliases
  static Future<void> clear() => clearAll();
  static Future<String?> token() => getToken();
  static Future<String?> role() => getRole();
  static Future<String?> email() => getEmail();
  static Future<String?> name() => getName();
}
