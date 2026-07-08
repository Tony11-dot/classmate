import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/env.dart';
import '../contracts/auth_contracts.dart';
import '../http/cm_api.dart';
import 'accounts_store.dart';

class AuthSession extends ChangeNotifier {
  static const _kToken = 'auth_token_v2';
  static const _kFullName = 'auth_full_name_v1';
  static const _kRoles = 'auth_roles_v1';
  static const _kEmail = 'auth_email_v1';
  static const _kUsername = 'auth_username_v1';
  static const _kSchoolId = 'auth_school_id_v1';
  static const _kCohortId = 'auth_cohort_id_v1';
  static const _kCohortName = 'auth_cohort_name_v1';
  static const _kSchoolName = 'auth_school_name_v1';
  static const _kSchoolLogoUrl = 'auth_school_logo_url_v1';

  AuthSession() {
    _init();
  }

  bool _ready = false;
  bool get ready => _ready;

  String? _token;
  String? _fullName; // the user's single full name from backend
  String? _email;
  String? _username;
  String? _schoolId;
  String? _cohortId;
  String? _cohortName;
  String? _schoolName;
  String? _schoolLogoUrl;
  int? _schoolMinGrade;
  int? _schoolMaxGrade;
  String? _schoolGradeRanges;
  String? _schoolSemesters;
  int? _grade; // the user's own current grade (students); null for staff
  // Consent (Israel Privacy Amendment 13): true when the user hasn't yet
  // accepted the current Privacy Policy/Terms — the shell shows a one-time
  // consent gate. Server-driven via /auth/me.consentRequired.
  bool _consentRequired = false;
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

  /// Name to display everywhere (drawer/profile headers, avatars, greetings).
  /// One full name, everywhere, in every language — the old per-language
  /// localized names and the admin "short name" override were removed.
  String get displayName => (_fullName ?? '').trim();

  /// The user's full name (alias of [displayName] now).
  String get fullName => (_fullName ?? '').trim();

  String get email => (_email ?? '').trim();
  String get username => (_username ?? '').trim();
  String get schoolId => (_schoolId ?? '').trim();
  String get cohortId => (_cohortId ?? '').trim();
  String get cohortName => (_cohortName ?? '').trim();
  String get schoolName => (_schoolName ?? '').trim();
  String get schoolLogoUrl => (_schoolLogoUrl ?? '').trim();
  int get schoolMinGrade => _schoolMinGrade ?? 5;
  int get schoolMaxGrade => _schoolMaxGrade ?? 12;
  /// The user's own current grade level (students); null for staff.
  int? get grade => _grade;
  bool get consentRequired => _consentRequired;
  /// Raw multi-range string, e.g. "4-6,9-12". Empty/null = single min..max range.
  String get schoolGradeRanges => _schoolGradeRanges ?? '';
  /// Raw semester month-ranges, e.g. "9-1,2-6". Empty = school has no semesters.
  String get schoolSemesters => _schoolSemesters ?? '';
  void setSchoolSemesters(String? raw) {
    final v = (raw ?? '').trim();
    final next = v.isEmpty ? null : v;
    if (next == _schoolSemesters) return;
    _schoolSemesters = next;
    notifyListeners();
  }
  /// Every grade the school covers. Supports MULTIPLE ranges (e.g. 4-6 and
  /// 9-12 when 7-8 don't exist). Falls back to the single min..max range.
  List<int> get schoolGrades {
    final ranges = parseGradeRanges(_schoolGradeRanges ?? '');
    if (ranges.isNotEmpty) {
      final set = <int>{};
      for (final r in ranges) {
        for (int g = r.$1; g <= r.$2; g++) {
          set.add(g);
        }
      }
      final list = set.toList()..sort();
      return list;
    }
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

    // CM_CLEAR_SESSION=true wipes credentials so the next launch lands on
    // login (used by the `cmr` dev script). We deliberately preserve the
    // school identity (name + logo) — those are non-sensitive branding
    // pulled from /auth/me anyway, and wiping them caused the drawer to
    // flash blank on every cmr run until the next /auth/me landed. The
    // fresh /auth/me after login still re-validates them, so a school
    // rename/relogo on the server takes effect at most one launch later.
    if (Env.clearSession) {
      const preserve = <String>{_kSchoolName, _kSchoolLogoUrl};
      final saved = <String, Object>{};
      for (final k in preserve) {
        final v = prefs.get(k);
        if (v != null) saved[k] = v;
      }
      await prefs.clear();
      for (final entry in saved.entries) {
        final v = entry.value;
        if (v is String) await prefs.setString(entry.key, v);
      }
    }

    _fullName = (prefs.getString(_kFullName) ?? '').trim();
    _email = (prefs.getString(_kEmail) ?? '').trim();
    _username = (prefs.getString(_kUsername) ?? '').trim();
    _schoolId = (prefs.getString(_kSchoolId) ?? '').trim();
    _cohortId = (prefs.getString(_kCohortId) ?? '').trim();
    _cohortName = (prefs.getString(_kCohortName) ?? '').trim();
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
    final previousToken = _token;
    if (token == null || token.isEmpty) {
      await prefs.remove(_kToken);
      _token = null;
    } else {
      await prefs.setString(_kToken, token);
      _token = token;
    }
    notifyListeners();
    // Keep RevenueCat's app_user_id in sync with our JWT subject so
    // every store purchase routes to the right user on the server.
    // Fire-and-forget — no awaiting; the SDK call queues internally
    // and the next purchase blocks on its own identify under the hood
    // if this hasn't completed yet.
    _syncRevenueCatIdentity();
    // FCM token registration. On login: register the device's push
    // token with the backend so notifications fan out to this phone.
    // On logout: tell the backend to forget this device. The push
    // service is no-op when Firebase isn't configured.
    _syncPushRegistration(previousToken: previousToken);
  }

  Future<void> _syncPushRegistration({String? previousToken}) async {
    try {
      final svc = _pushService;
      if (svc == null) return;
      final current = _token;
      if (current != null && current.isNotEmpty && current != 'SIM_TOKEN') {
        // Cast through dynamic so this file doesn't import firebase_messaging.
        // ignore: avoid_dynamic_calls
        await (svc as dynamic).registerForUser(authToken: current);
      } else if (previousToken != null && previousToken.isNotEmpty && previousToken != 'SIM_TOKEN') {
        // ignore: avoid_dynamic_calls
        await (svc as dynamic).unregisterForUser(authToken: previousToken);
      }
    } catch (_) {
      // Push is non-essential — never block login on a registration failure.
    }
  }

  static dynamic _pushService;
  /// main.dart calls this once on startup to register the
  /// PushNotificationsService singleton without auth_session needing
  /// to import firebase_messaging directly.
  static void registerPushService(dynamic svc) {
    _pushService = svc;
  }

  /// Best-effort identity sync with RevenueCat. Lazy-loaded to avoid
  /// pulling the RC SDK into every test that touches AuthSession (and
  /// to keep this file's dependency surface small).
  Future<void> _syncRevenueCatIdentity() async {
    try {
      // Late import to avoid a cycle: auth_session is imported by main.dart
      // which also imports the RC service. Using a top-level import here
      // is fine because RevenueCatService itself doesn't touch AuthSession.
      // ignore: avoid_dynamic_calls
      final svc = await _loadRcService();
      if (svc == null) return;
      final id = userId;
      if (id.isEmpty) {
        await svc.reset();
      } else {
        await svc.identify(id);
      }
    } catch (_) {
      // RC is non-essential — never let a sync failure break login.
    }
  }

  Future<dynamic> _loadRcService() async {
    // Use a deferred import would be cleanest, but Dart's deferred
    // imports only work for web. Direct import is fine here — the
    // service is a tiny singleton and only configures once.
    final mod = await Future<dynamic>.value(_rcServiceLoader());
    return mod;
  }

  /// Indirection point so a test can stub the RC service if needed.
  /// Returns the singleton; non-overridable in production.
  dynamic _rcServiceLoader() {
    // The RC service is intentionally lazy-loaded via a function ref
    // so this file doesn't have a hard import on purchases_flutter.
    // Replaced at runtime by `wireRevenueCatToAuthSession()` in main.dart.
    return _rcServiceFactory?.call();
  }

  static dynamic Function()? _rcServiceFactory;
  /// main.dart calls this once on startup to register the RC singleton
  /// without auth_session needing to import the SDK directly.
  static void registerRcServiceFactory(dynamic Function() factory) {
    _rcServiceFactory = factory;
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

  /// Sets the user's full name (the single name source of truth). Kept under
  /// the old name for call-site compatibility.
  Future<void> setDisplayName(String? name) async {
    final prefs = await SharedPreferences.getInstance();
    final v = (name ?? '').trim();
    _fullName = v;
    if (v.isEmpty) {
      await prefs.remove(_kFullName);
    } else {
      await prefs.setString(_kFullName, v);
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

  Future<void> setUsername(String? username) async {
    final prefs = await SharedPreferences.getInstance();
    final value = (username ?? '').trim();
    _username = value;
    if (value.isEmpty) {
      await prefs.remove(_kUsername);
    } else {
      await prefs.setString(_kUsername, value);
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

  void setSchoolGradeRange(int? min, int? max, {String? ranges}) {
    final normalizedRanges = (ranges ?? '').trim();
    final changed = _schoolMinGrade != min ||
        _schoolMaxGrade != max ||
        (_schoolGradeRanges ?? '') != normalizedRanges;
    _schoolMinGrade = min;
    _schoolMaxGrade = max;
    _schoolGradeRanges = normalizedRanges.isEmpty ? null : normalizedRanges;
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
    await setUsername(null);
    await setSchoolId(null);
    await setCohortId(null);
    await setSchoolName(null);
    await setSchoolLogoUrl(null);
    await setRoles(const <String>[]);
    // Clear the full name
    await _setFullName(null);
    final prefs = await SharedPreferences.getInstance();
    // Per-user device caches that would otherwise leak across logins on the
    // same phone. The classroom "hide-after-leave" set is the obvious one —
    // without this, user A leaving a classroom would suppress it for user B
    // who logs in afterwards on the same device.
    await prefs.remove('hidden_classrooms_v1');
    _fullName = null;
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

  /// Instantly adopt a remembered account's token + cached profile so the UI
  /// (drawer header, role-gated shell) flips immediately on an account switch,
  /// before the background `/auth/me` refresh lands. Setting the token also
  /// re-registers this device's push under the new account.
  Future<void> applyStoredAccount({
    required String token,
    String? displayName,
    List<String>? roles,
    String? schoolName,
  }) async {
    await setToken(token);
    if (roles != null && roles.isNotEmpty) await setRoles(roles);
    if (displayName != null && displayName.isNotEmpty) await setDisplayName(displayName);
    if (schoolName != null) await setSchoolName(schoolName);
  }

  /// Best-effort: tell the backend to drop THIS device's push registration for
  /// the currently-active account (used when signing one account out of the
  /// multi-account switcher without touching the others).
  Future<void> unregisterPushForCurrent() async {
    try {
      final svc = _pushService;
      final current = _token;
      if (svc == null || current == null || current.isEmpty || current == 'SIM_TOKEN') return;
      // ignore: avoid_dynamic_calls
      await (svc as dynamic).unregisterForUser(authToken: current);
    } catch (_) {}
  }

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
      // Username comes from /auth/me — defending against transient empty
      // responses (same pattern as the school identity fields below): a
      // null wipe was the reason the profile screen flashed "—" on
      // accounts that have a server-side username but never edited it
      // through the profile flow (which is the only path that
      // previously populated the local cache).
      final serverUsername = (me.username ?? '').trim();
      if (serverUsername.isNotEmpty || (_username ?? '').trim().isEmpty) {
        await setUsername(me.username);
      }
      await setSchoolId(me.schoolId);
      await setCohortId(me.cohortId);
      // School identity fields (name, logo) are defended against transient
      // empty responses: the /auth/me handler swallows DB lookup errors and
      // returns null on partial failures (see auth.controller.ts:183), and
      // a null wipe would briefly flash a blank drawer. Keep the cached
      // value when the server says empty AND we have something cached; an
      // explicit clear (logout / Remove logo in School Settings) still
      // goes through setSchoolName(null) / setSchoolLogoUrl(null) directly.
      final serverName = (me.schoolName ?? '').trim();
      if (serverName.isNotEmpty || (_schoolName ?? '').trim().isEmpty) {
        await setSchoolName(me.schoolName);
      }
      final serverLogo = (me.schoolLogoUrl ?? '').trim();
      if (serverLogo.isNotEmpty || (_schoolLogoUrl ?? '').trim().isEmpty) {
        await setSchoolLogoUrl(me.schoolLogoUrl);
      }
      setSchoolGradeRange(me.schoolMinGrade, me.schoolMaxGrade, ranges: me.schoolGradeRanges);
      setSchoolSemesters(me.schoolSemesters);
      _grade = me.grade;
      _consentRequired = raw['consentRequired'] == true;
      // Cohort display name
      final cn = (raw['cohortName'] ?? '').toString().trim();
      if (cn.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kCohortName, cn);
        _cohortName = cn;
      }
      // Store the user's full name (the single name source of truth). Falls
      // back to a name derived from the email only when the server has none.
      final serverFullName =
          (raw['fullName'] ?? raw['displayName'] ?? '').toString().trim();
      if (serverFullName.isNotEmpty) {
        await _setFullName(serverFullName);
      } else if ((_fullName ?? '').trim().isEmpty && (me.email ?? '').trim().isNotEmpty) {
        await _setFullName(_displayNameFromEmail(me.email!));
      }
    } on CMApiException catch (error) {
      if (clearUnauthorizedToken && error.statusCode == 401) {
        // A 401 on /auth/me means this token is no longer valid — the account
        // was deleted/disabled server-side (e.g. an admin removed it), or the
        // password/session was revoked. Purge it from the on-device account
        // switcher so a deleted account leaves NO trace (previously it lingered
        // in the switcher and just bounced the user to /login on tap).
        final deadId = userId;
        if (deadId.isNotEmpty) {
          try {
            await AccountsStore().remove(deadId);
          } catch (_) {/* best-effort — never block logout on store IO */}
        }
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

  /// Update the user's full name on the server and locally.
  Future<void> updateFullName(String name) async {
    final currentToken = (_token ?? '').trim();
    if (currentToken.isEmpty) return;
    final api = CMApi(token: currentToken);
    try {
      final v = name.trim();
      await api.patchJson('/auth/profile/name', body: <String, dynamic>{'name': v});
      await _setFullName(v);
    } finally {
      api.dispose();
    }
  }

  /// Record the user's acceptance of the Privacy Policy + Terms (Israel Privacy
  /// Amendment 13). Clears the one-time consent gate locally on success.
  Future<void> acceptConsent({bool guardianConsent = false}) async {
    final currentToken = (_token ?? '').trim();
    if (currentToken.isEmpty) return;
    final api = CMApi(token: currentToken);
    try {
      await api.postJson('/account/consent', body: <String, dynamic>{
        'guardianConsent': guardianConsent,
      });
      _consentRequired = false;
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

/// Parses a multi-range grade string like "4-6,9-12" (also accepts ";" or
/// space separators, single grades like "5", and reversed bounds) into a list
/// of inclusive (lo, hi) ranges. Returns empty for blank input.
List<(int, int)> parseGradeRanges(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return const <(int, int)>[];
  final out = <(int, int)>[];
  for (final part in s.split(RegExp(r'[,;\s]+'))) {
    final p = part.trim();
    if (p.isEmpty) continue;
    final m = RegExp(r'^(\d+)-(\d+)$').firstMatch(p);
    if (m != null) {
      var lo = int.parse(m.group(1)!);
      var hi = int.parse(m.group(2)!);
      if (lo > hi) {
        final t = lo;
        lo = hi;
        hi = t;
      }
      out.add((lo, hi));
    } else {
      final single = int.tryParse(p);
      if (single != null) out.add((single, single));
    }
  }
  return out;
}
