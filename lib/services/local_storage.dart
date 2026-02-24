import 'package:shared_preferences/shared_preferences.dart';

class localStorage {
  static final Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance();

  static Future<bool> contains(String key) async {
    final prefs = await _prefs;
    return prefs.containsKey(key);
  }

  static Future<void> setString(String key, String value) async {
    final prefs = await _prefs;
    prefs.setString(key, value);
  }

  static Future<void> setBool(String key, bool value) async {
    final prefs = await _prefs;
    prefs.setBool(key, value);
  }

  static Future<String> getString(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key) ?? "";
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await _prefs;
    return prefs.getBool(key);
  }

  static Future<void> clearValue(String key) async {
    final prefs = await _prefs;
    prefs.remove(key);
  }

  static Future<void> clear() async {
    final prefs = await _prefs;
    prefs.clear();
  }
}
