import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'app_locale';

class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getString(_kLocaleKey);
    if (v == null || v.isEmpty) return;
    state = Locale(v);
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final sp = await SharedPreferences.getInstance();
    if (locale == null) {
      await sp.remove(_kLocaleKey);
    } else {
      await sp.setString(_kLocaleKey, locale.languageCode);
    }
  }
}

final localeControllerProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);
