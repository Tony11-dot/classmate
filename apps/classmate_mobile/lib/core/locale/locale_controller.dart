import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeControllerProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);

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
  }
}
