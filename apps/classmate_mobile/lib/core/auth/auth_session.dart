import 'package:flutter/foundation.dart';

import '../config/env.dart';
import '../contracts/auth_contracts.dart';
import '../http/cm_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String _kDevToken = String.fromEnvironment('CM_DEV_TOKEN');

class AuthSession extends ChangeNotifier {
  static const _kToken = 'auth_token_v2';
  static const _kDisplayName = 'auth_display_name_v1';
  static const _kRoles = 'auth_roles_v1';
  static const _kEmail = 'auth_email_v1';
  static const _kSchoolId = 'auth_school_id_v1';
  static const _kCohortId = 'auth_cohort_id_v1';
  static const _kSchoolName = 'auth_school_name_v1';
  static const _kSchoolLogoUrl = 'auth_school_logo_url_v1';

  AuthSession() {
    _init();
  }

  bool _ready = false;
  bool get ready => _ready;

  String? _token;
  String? _displayName;
  String? _email;
  String? _schoolId;
  String? _cohortId;
  String? _schoolName;
  String? _schoolLogoUrl;
  List<String> _roles = const <String>[];

  String? get token {
    final dt = _kDevToken.trim();
    if (kDebugMode && dt.isNotEmpty) return dt;
    if (_token != null && _token!.isNotEmpty) return _token;
    return null;
  }

  String get displayName => (_displayName ?? '').trim();
  String get email => (_email ?? '').trim();
  String get schoolId => (_schoolId ?? '').trim();
  String get cohortId => (_cohortId ?? '').trim();
  String get schoolName => (_schoolName ?? '').trim();
  String get schoolLogoUrl => (_schoolLogoUrl ?? '').trim();
  List<String> get roles => List<String>.unmodifiable(_roles);

  String get primaryRole {
    const priority = <String>['TEACHER', 'ADMIN', 'SECRETARY', 'PARENT', 'STUDENT'];
    for (final role in priority) {
      if (_roles.contains(role)) return role;
    }
    return 'STUDENT';
  }

  bool get isTeacherLike => _roles.contains('TEACHER') || _roles.contains('ADMIN');

  bool get isLoggedIn => (token != null && token!.isNotEmpty);

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    _displayName = (prefs.getString(_kDisplayName) ?? '').trim();
    _email = (prefs.getString(_kEmail) ?? '').trim();
    _schoolId = (prefs.getString(_kSchoolId) ?? '').trim();
    _cohortId = (prefs.getString(_kCohortId) ?? '').trim();
    _schoolName = (prefs.getString(_kSchoolName) ?? '').trim();
    _schoolLogoUrl = (prefs.getString(_kSchoolLogoUrl) ?? '').trim();
    _roles = (prefs.getStringList(_kRoles) ?? const <String>[])
        .map((role) => role.trim().toUpperCase())
        .where((role) => role.isNotEmpty)
        .toList(growable: false);

    final saved = prefs.getString(_kToken);
    if (saved != null) {
      final s = saved.trim();
      final isJwtish = s.split('.').length >= 3;
      final isEmailish = s.contains('@') && s.contains('.');
      if (isEmailish && !isJwtish) {
        await prefs.remove(_kToken);
        _token = null;
      } else {
        _token = s;
      }
    } else {
      _token = null;
    }

    // DEV: auto-fill token from CM_DEV_TOKEN.
    // Accepts full JWTs (3 dot-separated segments) AND dev-token-* prefixed
    // tokens (accepted by the backend when ALLOW_DEV_TOKEN=1).
    if (_token == null || _token!.isEmpty || _token == 'SIM_TOKEN') {
      final dt = Env.devToken.trim();
      final dtIsJwtish = dt.split('.').length >= 3;
      final dtIsEmailish = dt.contains('@') && dt.contains('.');
      final dtIsDevToken = dt.startsWith('dev-token-');
      if (dt.isNotEmpty && ((dtIsJwtish && !dtIsEmailish) || dtIsDevToken)) {
        _token = dt;
        await prefs.setString(_kToken, _token!);
      } else {
        _token = null;
        await prefs.remove(_kToken);
      }
    }

    if ((_token ?? '').isNotEmpty && _token != 'SIM_TOKEN') {
      await _refreshAuthMe(clearUnauthorizedToken: true);
    }

    _ready = true;
    // ignore: avoid_print
    notifyListeners();
  }

  Future<void> setToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await prefs.remove(_kToken);
      _token = null;
    } else {
      await prefs.setString(_kToken, token);
      _token = token;
    }
    notifyListeners();
  }

  Future<void> setRoles(List<String> roles) async {
    final prefs = await SharedPreferences.getInstance();
    _roles = roles
        .map((role) => role.trim().toUpperCase())
        .where((role) => role.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (_roles.isEmpty) {
      await prefs.remove(_kRoles);
    } else {
      await prefs.setStringList(_kRoles, _roles);
    }
    notifyListeners();
  }

  Future<void> setDisplayName(String? name) async {
    final prefs = await SharedPreferences.getInstance();
    final v = (name ?? '').trim();
    _displayName = v;
    if (v.isEmpty) {
      await prefs.remove(_kDisplayName);
    } else {
      await prefs.setString(_kDisplayName, v);
    }
    notifyListeners();
  }

  Future<void> setEmail(String? email) async {
    final prefs = await SharedPreferences.getInstance();
    final value = (email ?? '').trim();
    _email = value;
    if (value.isEmpty) {
      await prefs.remove(_kEmail);
    } else {
      await prefs.setString(_kEmail, value);
    }
    notifyListeners();
  }

  Future<void> setSchoolId(String? schoolId) async {
    final prefs = await SharedPreferences.getInstance();
    final value = (schoolId ?? '').trim();
    _schoolId = value;
    if (value.isEmpty) {
      await prefs.remove(_kSchoolId);
    } else {
      await prefs.setString(_kSchoolId, value);
    }
    notifyListeners();
  }

  Future<void> setSchoolName(String? name) async {
    final prefs = await SharedPreferences.getInstance();
    final value = (name ?? '').trim();
    _schoolName = value;
    if (value.isEmpty) {
      await prefs.remove(_kSchoolName);
    } else {
      await prefs.setString(_kSchoolName, value);
    }
    notifyListeners();
  }

  Future<void> setSchoolLogoUrl(String? url) async {
    final prefs = await SharedPreferences.getInstance();
    final value = (url ?? '').trim();
    _schoolLogoUrl = value;
    if (value.isEmpty) {
      await prefs.remove(_kSchoolLogoUrl);
    } else {
      await prefs.setString(_kSchoolLogoUrl, value);
    }
    notifyListeners();
  }

  Future<void> setCohortId(String? cohortId) async {
    final prefs = await SharedPreferences.getInstance();
    final value = (cohortId ?? '').trim();
    _cohortId = value;
    if (value.isEmpty) {
      await prefs.remove(_kCohortId);
    } else {
      await prefs.setString(_kCohortId, value);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await setToken(null);
    await setDisplayName(null);
    await setEmail(null);
    await setSchoolId(null);
    await setCohortId(null);
    await setSchoolName(null);
    await setSchoolLogoUrl(null);
    await setRoles(const <String>[]);
  }

  // dev helper
  Future<void> simLogin({List<String> roles = const <String>['STUDENT']}) async {
    await setToken('SIM_TOKEN');
    await setRoles(roles);
  }

  Future<void> devSetToken(String token) => setToken(token);

  Future<void> login({required String email, required String password}) async {
    final api = CMApi();
    try {
      final raw = await api.postJson(
        '/auth/login',
        body: <String, dynamic>{'email': email.trim(), 'password': password},
      );
      final token = (raw is Map ? raw['token'] : null)?.toString().trim() ?? '';
      if (token.isEmpty) {
        throw Exception('Login did not return a token');
      }

      await setToken(token);
      await _refreshAuthMe(clearUnauthorizedToken: true);

      if (displayName.isEmpty) {
        await setDisplayName(_displayNameFromEmail(email));
      }
    } finally {
      api.dispose();
    }
  }

  Future<void> _refreshAuthMe({bool clearUnauthorizedToken = false}) async {
    final currentToken = (_token ?? '').trim();
    if (currentToken.isEmpty || currentToken == 'SIM_TOKEN') return;

    final api = CMApi(token: currentToken);
    try {
      final raw = await api.getJson('/auth/me');
      if (raw is! Map<String, dynamic>) return;
      final me = AuthMe.fromJson(raw);
      await setRoles(me.roles);
      await setEmail(me.email);
      await setSchoolId(me.schoolId);
      await setCohortId(me.cohortId);
      await setSchoolName(me.schoolName);
      await setSchoolLogoUrl(me.schoolLogoUrl);
      if ((_displayName ?? '').trim().isEmpty && (me.email ?? '').trim().isNotEmpty) {
        await setDisplayName(_displayNameFromEmail(me.email!));
      }
    } on CMApiException catch (error) {
      if (clearUnauthorizedToken && error.statusCode == 401) {
        await logout();
        return;
      }
    } catch (_) {
      // Keep the saved token if profile refresh is temporarily unavailable.
    } finally {
      api.dispose();
    }
  }

  String _displayNameFromEmail(String email) {
    final local = email.trim().split('@').first;
    if (local.isEmpty) return 'ClassMate';
    return local
        .split(RegExp(r'[._-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}

// DEV DEBUG
int devTokenLen() => _kDevToken.trim().length;

// Riverpod provider for app-wide auth session

// Riverpod provider for app-wide auth session

// Riverpod provider for app-wide auth session

// Riverpod provider for app-wide auth session
final authSessionProvider = Provider<AuthSession>((ref) {
  final s = AuthSession();
  ref.onDispose(s.dispose);
  return s;
});
