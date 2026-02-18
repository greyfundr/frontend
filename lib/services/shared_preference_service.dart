
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  static final SharedPreferenceService _mySharedPreference =
  SharedPreferenceService._internal();
  static bool _sharedPreferencesLoaded = false;
  static late SharedPreferences prefs;

  factory SharedPreferenceService() {
    return _mySharedPreference;
  }

  SharedPreferenceService._internal() {
    SharedPreferenceService();
  }

  static Future<void> initSharedPreferences() async {
    if (_sharedPreferencesLoaded) {
      return;
    }

    prefs = await SharedPreferences.getInstance();
    _sharedPreferencesLoaded = true;
  }
}