import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Session {
  static const FlutterSecureStorage _s = FlutterSecureStorage();

  static const String _kToken = 'classmate_token';
  static const String _kRole = 'classmate_role';
  static const String _kEmail = 'classmate_email';
  static const String _kName = 'classmate_name';

  static Future<void> saveAuth({
    required String token,
    String? role,
    String? email,
    String? name,
  }) async {
    await _s.write(key: _kToken, value: token);
    if (role != null && role.isNotEmpty) {
      await _s.write(key: _kRole, value: role);
    }
    if (email != null && email.isNotEmpty) {
      await _s.write(key: _kEmail, value: email);
    }
    if (name != null && name.isNotEmpty) {
      await _s.write(key: _kName, value: name);
    }
  }

  static Future<String?> getToken() => _s.read(key: _kToken);
  static Future<String?> getRole() => _s.read(key: _kRole);
  static Future<String?> getEmail() => _s.read(key: _kEmail);
  static Future<String?> getName() => _s.read(key: _kName);

  static Future<void> clearAll() => _s.deleteAll();

  // backward-compatible aliases
  static Future<void> clear() => clearAll();
  static Future<String?> token() => getToken();
  static Future<String?> role() => getRole();
  static Future<String?> email() => getEmail();
  static Future<String?> name() => getName();
}
