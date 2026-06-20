import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_session.dart';
import '../http/cm_api.dart';

final localeControllerProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);

/// Languages we both render in-app AND localize notifications for server-side.
const kSupportedLanguageCodes = {'en', 'ar', 'he', 'fr', 'ru', 'ps'};

/// Best-effort sync of the user's chosen language to the server, so it can
/// localize notification copy (in-app inbox + system push) per recipient.
/// Fire-and-forget — never blocks UI, never throws.
Future<void> pushLocaleToServer(String token, String? languageCode) async {
  if (token.isEmpty) return;
  final code = (languageCode == null || languageCode.isEmpty)
      ? PlatformDispatcher.instance.locale.languageCode
      : languageCode;
  final lang = kSupportedLanguageCodes.contains(code) ? code : 'en';
  try {
    await CMApi(token: token)
        .patchJson('/auth/me/language', body: {'language': lang});
  } catch (_) {
    // Non-fatal: notifications fall back to English if this never lands.
  }
}

/// Persists the user's chosen app language.
/// `null` means follow the system locale.
class LocaleController extends Notifier<Locale?> {
  static const _kLocale = 'app_locale';

  @override
  Locale? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocale);
    if (code != null) state = Locale(code);
  }

  Future<void> setLocale(String? languageCode) async {
    state = languageCode == null ? null : Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    if (languageCode == null) {
      await prefs.remove(_kLocale);
    } else {
      await prefs.setString(_kLocale, languageCode);
    }
    // Mirror the choice to the server so notifications arrive in this language.
    final token = ref.read(authSessionProvider).token ?? '';
    await pushLocaleToServer(token, languageCode);
  }
}
