import 'dart:io' show Platform;

class Env {
  static late final String apiBaseUrl;
  static late final String schoolId;
  static late final String autoLoginEmail;
  static late final String autoLoginPassword;
  static late final bool clearSession;

  static void init() {
    final rawBase = const String.fromEnvironment('CM_API_BASE_URL');
    apiBaseUrl = rawBase.trim().isEmpty
      ? _defaultApiBaseUrl()
      : normalizeApiBaseUrl(rawBase.trim());

    final rawSchool = const String.fromEnvironment('CM_SCHOOL_ID');
    schoolId = rawSchool.trim();

    autoLoginEmail = const String.fromEnvironment('CM_AUTO_LOGIN_EMAIL').trim();
    autoLoginPassword = const String.fromEnvironment('CM_AUTO_LOGIN_PASSWORD').trim();
    clearSession = const String.fromEnvironment('CM_CLEAR_SESSION').trim() == 'true';
  }

  static String stripApiSuffix(String baseUrl) {
    final trimmed = baseUrl.trim();
    if (trimmed.endsWith('/api')) {
      return trimmed.substring(0, trimmed.length - 4);
    }
    return trimmed;
  }

  static String ensureApiSuffix(String baseUrl) {
    final trimmed = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    if (trimmed.endsWith('/api')) return trimmed;
    return '$trimmed/api';
  }

  static String normalizeApiBaseUrl(String baseUrl) {
    final trimmed = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    if (trimmed.isEmpty) return _defaultApiBaseUrl();

    if (!Platform.isIOS) return trimmed;

    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.host.isEmpty) return trimmed;

    final host = uri.host.toLowerCase();
    if (host != '127.0.0.1' && host != 'localhost') return trimmed;

    final fallback = Uri.parse(_defaultApiBaseUrl());
    return Uri(
      scheme: uri.scheme.isEmpty ? fallback.scheme : uri.scheme,
      host: fallback.host,
      port: uri.hasPort ? uri.port : (fallback.hasPort ? fallback.port : null),
      path: uri.path,
      query: uri.hasQuery ? uri.query : null,
    ).toString();
  }

  static String _defaultApiBaseUrl() {
    // Physical iPhones cannot reach the host machine through 127.0.0.1.
    // Use the Mac's local hostname for iOS device builds unless the user
    // overrides it with --dart-define=CM_API_BASE_URL=...
    if (Platform.isIOS) {
      return 'http://Tonys-MacBook-Air.local:3001';
    }
    return 'http://127.0.0.1:3001';
  }
}
