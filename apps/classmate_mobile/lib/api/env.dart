import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class Env {
  /// Provide full root (recommended):
  ///   flutter run --dart-define=API_ROOT=http://192.168.33.22:3010/api
  static const String _apiRootFromDefine = String.fromEnvironment(
    'API_ROOT',
    defaultValue: '',
  );

  /// Provide base URL (we append /api):
  ///   flutter run --dart-define=API_BASE_URL=http://192.168.33.22:3010
  static const String _apiBaseFromDefine = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get apiRoot {
    final r = _apiRootFromDefine.trim();
    if (r.isNotEmpty) {
      if (r.endsWith('/api')) return r;
      if (r.endsWith('/')) return '${r}api';
      return '$r/api';
    }

    final b0 = _apiBaseFromDefine.trim();
    if (b0.isNotEmpty) {
      final b = b0.endsWith('/') ? b0.substring(0, b0.length - 1) : b0;
      return '$b/api';
    }

    // Debug defaults:
    // - Android emulator uses 10.0.2.2 to reach host machine
    // - iOS simulator / macOS can use localhost
    if (kDebugMode) {
      if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:3010/api';
      return 'http://localhost:3010/api';
    }

    // Release fallback (change later)
    return 'https://api.classmate.app/api';
  }
}
