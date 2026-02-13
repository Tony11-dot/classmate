import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static Future<SharedPreferences> get _sp async =>
      SharedPreferences.getInstance();

  static Future<void> setString(String key, String value) async {
    final sp = await _sp;
    await sp.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final sp = await _sp;
    return sp.getString(key);
  }
  static Future<void> remove(String key) async {
    final sp = await _sp;
    await sp.remove(key);
  }
}
