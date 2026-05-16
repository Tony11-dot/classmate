import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/env.dart';
import '../contracts/auth_contracts.dart';
import '../http/cm_api.dart';
import 'name_lang.dart';

class AuthSession extends ChangeNotifier {
  static const _kToken = 'auth_token_v2';
  static const _kDisplayName = 'auth_display_name_v1';
  static const _kFullName = 'auth_full_name_v1';
  static const _kRoles = 'auth_roles_v1';
  static const _kEmail = 'auth_email_v1';
  static const _kSchoolId = 'auth_school_id_v1';
  static const _kCohortId = 'auth_cohort_id_v1';
  static const _kCohortName = 'auth_cohort_name_v1';
  static const _kSchoolName = 'auth_school_name_v1';
  static const _kSchoolLogoUrl = 'auth_school_logo_url_v1';
  static const _kNameEn = 'auth_name_en_v1';
  static const _kNameAr = 'auth_name_ar_v1';
  static const _kNameHe = 'auth_name_he_v1';
  static const _kNameFr = 'auth_name_fr_v1';
  static const _kNameRu = 'auth_name_ru_v1';
  static const _kDisplayNameLang = 'auth_display_name_lang_v1';

  AuthSession() {
    _init();
  }

  bool _ready = false;
  bool get ready => _ready;

  String? _token;
  String? _displayName;
  String? _fullName; // first + last name from backend
  String? _email;
  String? _schoolId;
  String? _cohortId;
  String? _cohortName;
  String? _schoolName;
  String? _schoolLogoUrl;
  int? _schoolMinGrade;
  int? _schoolMaxGrade;
  String? _nameEn;
  String? _nameAr;
  String? _nameHe;
  String? _nameFr;
  String? _nameRu;
  String? _displayNameLang; // 'en'|'ar'|'he'|'fr'|'ru'|null
  List<String> _roles = const <String>[];

  String? get token {
    if (_token != null && _token!.isNotEmpty) return _token;
    return null;
  }

  /// The real database user ID (UUID) extracted from the JWT `sub` claim.
  /// This is what the server stores as `senderUserId`, `userId`, etc.
  /// Used for correct `isMine` / ownership comparisons.
  String get userId {
    final t = (_token ?? '').trim();
    if (t.isEmpty) return '';
    try {
      final parts = t.split('.');
      if (parts.length < 2) return '';
      // Base64url-decode the payload (second segment).
      final padded = base64Url.normalize(parts[1]);
      final payload = Map<String, dynamic>.from(
          jsonDecode(utf8.decode(base64Url.decode(padded))) as Map);
      return (payload['sub'] ?? payload['userId'] ?? payload['id'] ?? '')
          .toString()
          .trim();
    } catch (_) {
      return '';
    }
  }

  /// The name to display based on the user's language preference.
  /// Falls back through: localized name → displayName → fullName → email-derived.
  String get displayName {
    final lang = (_displayNameLang ?? '').trim().toLowerCase();
    final langEnum = NameLang.fromCode(lang);
    final localizedName = switch (langEnum) {
      NameLang.ar => (_nameAr ?? '').trim(),
      NameLang.he => (_nameHe ?? '').trim(),
      NameLang.fr => (_nameFr ?? '').trim(),
      NameLang.ru => (_nameRu ?? '').trim(),
      NameLang.en => (_nameEn ?? '').trim(),
      null => '',
    };
    if (localizedName.isNotEmpty) return localizedName;
    final dn = (_displayName ?? '').trim();
    if (dn.isNotEmpty) return dn;
    return (_fullName ?? '').trim();
  }

  /// Always returns the primary (server) full name regardless of display preference.
  String get fullName => (_fullName ?? (_displayName ?? '')).trim();

  String get nameEn => (_nameEn ?? '').trim();
  String get nameAr => (_nameAr ?? '').trim();
  String get nameHe => (_nameHe ?? '').trim();
  String get nameFr => (_nameFr ?? '').trim();
  String get nameRu => (_nameRu ?? '').trim();
  String get displayNameLang => (_displayNameLang ?? '').trim();

  String get email => (_email ?? '').trim();
  String get schoolId => (_schoolId ?? '').trim();
  String get cohortId => (_cohortId ?? '').trim();
  String get cohortName => (_cohortName ?? '').trim();
  String get schoolName => (_schoolName ?? '').trim();
  String get schoolLogoUrl => (_schoolLogoUrl ?? '').trim();
  int get schoolMinGrade => _schoolMinGrade ?? 5;
  int get schoolMaxGrade => _schoolMaxGrade ?? 12;
  List<int> get schoolGrades {
    final lo = schoolMinGrade;
    final hi = schoolMaxGrade;
    if (hi < lo) return const <int>[];
    return [for (int g = lo; g <= hi; g++) g];
  }
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

    // CM_CLEAR_SESSION=true wipes all stored credentials (used by cmr).
    if (Env.clearSession) {
      await prefs.clear();
    }

    _displayName = (prefs.getString(_kDisplayName) ?? '').trim();
    _fullName = (prefs.getString(_kFullName) ?? '').trim();
    _email = (prefs.getString(_kEmail) ?? '').trim();
    _schoolId = (prefs.getString(_kSchoolId) ?? '').trim();
    _cohortId = (prefs.getString(_kCohortId) ?? '').trim();
    _cohortName = (prefs.getString(_kCohortName) ?? '').trim();
    _schoolName = (prefs.getString(_kSchoolName) ?? '').trim();
    _schoolLogoUrl = (prefs.getString(_kSchoolLogoUrl) ?? '').trim();
    _nameEn = (prefs.getString(_kNameEn) ?? '').trim();
    _nameAr = (prefs.getString(_kNameAr) ?? '').trim();
    _nameHe = (prefs.getString(_kNameHe) ?? '').trim();
    _nameFr = (prefs.getString(_kNameFr) ?? '').trim();
    _nameRu = (prefs.getString(_kNameRu) ?? '').trim();
    _displayNameLang = (prefs.getString(_kDisplayNameLang) ?? '').trim();
    _roles = (prefs.getStringList(_kRoles) ?? const <String>[])
        .map((role) => role.trim().toUpperCase())
        .where((role) => role.isNotEmpty)
        .toList(growable: false);

    final saved = prefs.getString(_kToken);
    if (saved != null) {
      final s = saved.trim();
      final isJwtish = s.split('.').length >= 3;
      final isEmailish = s.contains('@') && s.contains('.');
      final isDevToken = s.startsWith('dev-token-');
      if (isEmailish && !isJwtish && !isDevToken) {
        // Bare-email format tokens are obsolete — remove them.
        await prefs.remove(_kToken);
        _token = null;
      } else {
        _token = s;
      }
    } else {
      _token = null;
    }

    if ((_token ?? '').isNotEmpty && _token != 'SIM_TOKEN') {
      final isDevToken = _token!.startsWith('dev-token-');
      // Dev-tokens are cleared on ANY validation failure (server down, 401, etc.).
      // Real JWTs are only cleared on explicit 401.
      await _refreshAuthMe(
        clearUnauthorizedToken: true,
        clearOnAnyError: isDevToken,
      );
    }

    _ready = true;
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

  void setSchoolGradeRange(int? min, int? max) {
    final changed = _schoolMinGrade != min || _schoolMaxGrade != max;
    _schoolMinGrade = min;
    _schoolMaxGrade = max;
    if (changed) notifyListeners();
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
    // Clear name fields
    await _setFullName(null);
    final prefs = await SharedPreferences.getInstance();
    for (final k in [_kNameEn, _kNameAr, _kNameHe, _kNameFr, _kNameRu, _kDisplayNameLang]) {
      await prefs.remove(k);
    }
    _nameEn = _nameAr = _nameHe = _nameFr = _nameRu = _displayNameLang = _fullName = null;
    notifyListeners();
  }

  // dev helper
  Future<void> simLogin({List<String> roles = const <String>['STUDENT']}) async {
    await setToken('SIM_TOKEN');
    await setRoles(roles);
  }

  Future<void> devSetToken(String token) => setToken(token);

  Future<void> login({String? identifier, String? email, required String password}) async {
    final id = (identifier ?? email ?? '').trim();
    final api = CMApi();
    try {
      final raw = await api.postJson(
        '/auth/login',
        body: <String, dynamic>{'identifier': id, 'password': password},
      );
      final token = (raw is Map ? raw['token'] : null)?.toString().trim() ?? '';
      if (token.isEmpty) {
        throw Exception('Login did not return a token');
      }

      await setToken(token);
      await _refreshAuthMe(clearUnauthorizedToken: true);

      if (displayName.isEmpty) {
        if (email != null) await setDisplayName(_displayNameFromEmail(email));
      }
    } finally {
      api.dispose();
    }
  }

  /// Public wrapper around _refreshAuthMe — pulls `/auth/me` and rehydrates
  /// every cached profile field. Call after any flow that changes server-side
  /// state the session caches (e.g. email/phone change via verify flow).
  Future<void> reloadFromMe() => _refreshAuthMe(clearUnauthorizedToken: false);

  Future<void> _refreshAuthMe({
    bool clearUnauthorizedToken = false,
    bool clearOnAnyError = false,
  }) async {
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
      setSchoolGradeRange(me.schoolMinGrade, me.schoolMaxGrade);
      // Cohort display name
      final cn = (raw['cohortName'] ?? '').toString().trim();
      if (cn.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kCohortName, cn);
        _cohortName = cn;
      }
      // Store full name (first + last) from backend
      final serverFullName = (raw['fullName'] ?? '').toString().trim();
      if (serverFullName.isNotEmpty) await _setFullName(serverFullName);
      // Store multi-language names
      await _setNameField(_kNameEn, raw['nameEn']);
      await _setNameField(_kNameAr, raw['nameAr']);
      await _setNameField(_kNameHe, raw['nameHe']);
      await _setNameField(_kNameFr, raw['nameFr']);
      await _setNameField(_kNameRu, raw['nameRu']);
      await _setNameField(_kDisplayNameLang, raw['displayNameLang']);
      // Update in-memory cache
      _nameEn = (raw['nameEn'] ?? '').toString().trim();
      _nameAr = (raw['nameAr'] ?? '').toString().trim();
      _nameHe = (raw['nameHe'] ?? '').toString().trim();
      _nameFr = (raw['nameFr'] ?? '').toString().trim();
      _nameRu = (raw['nameRu'] ?? '').toString().trim();
      _displayNameLang = (raw['displayNameLang'] ?? '').toString().trim();
      // Use server display name if set; otherwise fall back to email-derived
      final serverDisplayName = (raw['displayName'] ?? '').toString().trim();
      if (serverDisplayName.isNotEmpty) {
        await setDisplayName(serverDisplayName);
      } else if ((_displayName ?? '').trim().isEmpty && (me.email ?? '').trim().isNotEmpty) {
        await setDisplayName(_displayNameFromEmail(me.email!));
      }
    } on CMApiException catch (error) {
      if (clearUnauthorizedToken && error.statusCode == 401) {
        await logout();
        return;
      }
      if (clearOnAnyError) {
        await logout();
        return;
      }
    } catch (_) {
      if (clearOnAnyError) {
        await logout();
        return;
      }
      // Keep real JWT tokens if the server is temporarily unreachable.
    } finally {
      api.dispose();
    }
  }

  Future<void> _setFullName(String? name) async {
    final prefs = await SharedPreferences.getInstance();
    final v = (name ?? '').trim();
    _fullName = v;
    if (v.isEmpty) { await prefs.remove(_kFullName); } else { await prefs.setString(_kFullName, v); }
    notifyListeners();
  }

  Future<void> _setNameField(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    final v = (value ?? '').toString().trim();
    if (v.isEmpty) { await prefs.remove(key); } else { await prefs.setString(key, v); }
  }

  /// Update multi-language name fields + display preference on the server and locally.
  Future<void> updateNameFields({
    String? nameEn,
    String? nameAr,
    String? nameHe,
    String? nameFr,
    String? nameRu,
    String? displayNameLang,
    String? displayName,
  }) async {
    final currentToken = (_token ?? '').trim();
    if (currentToken.isEmpty) return;
    final api = CMApi(token: currentToken);
    try {
      await api.patchJson('/auth/profile/name', body: <String, dynamic>{
        'nameEn': ?nameEn,
        'nameAr': ?nameAr,
        'nameHe': ?nameHe,
        'nameFr': ?nameFr,
        'nameRu': ?nameRu,
        'displayNameLang': ?displayNameLang,
        'displayName': ?displayName,
      });
      // Persist locally
      final prefs = await SharedPreferences.getInstance();
      void save(String k, String? v) {
        if (v == null) return;
        if (v.trim().isEmpty) { prefs.remove(k); } else { prefs.setString(k, v.trim()); }
      }
      save(_kNameEn, nameEn); if (nameEn != null) _nameEn = nameEn.trim();
      save(_kNameAr, nameAr); if (nameAr != null) _nameAr = nameAr.trim();
      save(_kNameHe, nameHe); if (nameHe != null) _nameHe = nameHe.trim();
      save(_kNameFr, nameFr); if (nameFr != null) _nameFr = nameFr.trim();
      save(_kNameRu, nameRu); if (nameRu != null) _nameRu = nameRu.trim();
      save(_kDisplayNameLang, displayNameLang);
      if (displayNameLang != null) _displayNameLang = displayNameLang.trim();
      if (displayName != null) { save(_kDisplayName, displayName); _displayName = displayName.trim(); }
      notifyListeners();
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

final authSessionProvider = Provider<AuthSession>((ref) {
  final s = AuthSession();
  ref.onDispose(s.dispose);
  return s;
});
