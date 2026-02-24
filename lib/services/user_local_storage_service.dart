import 'dart:convert';
import 'dart:developer';

import 'package:greyfundr/core/models/login_response_model.dart';
import 'package:greyfundr/core/models/user_profile_model.dart';
import 'package:greyfundr/services/shared_preference_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLocalStorageService {
  static final UserLocalStorageService _userInfo =
      UserLocalStorageService._internal();
  static final SharedPreferences _prefs = SharedPreferenceService.prefs;

  factory UserLocalStorageService() {
    return _userInfo;
  }

  static Future<void> initSharedPreferences() async {
    return SharedPreferenceService.initSharedPreferences();
  }

  bool isActivated() => _prefs.containsKey('user');

  void setUser(String user) async {
    try {
      bool res = await _prefs.setString('user', user);
      if (res) {
        log("USER PROFILE SET IN SP:::::::::$user");
      } else {
        log("FAILED TO SET USER PROFILE IN SP");
      }
    } catch (e) {
      log("Error setting user data in local storage: $e");
    }
  }

  void setUserId(String userId) async {
    bool res = await _prefs.setString('user_id', userId);
    if (res) {
      log("USER ID SET IN SIGN IN::::::$userId");
    }
  }

  void FCMUpdated() {
    _prefs.setBool('fcm_updated', true);
  }

  void setUserBiometric(bool biometric) async {
    bool res = await _prefs.setBool('user_biometric', biometric);
  }

  void setHapticFeedback(bool haptic) async {
    bool res = await _prefs.setBool('user_haptic_feedback', haptic);
  }

  bool getUserBiometric() {
    return _prefs.getBool('user_biometric') ?? false;
  }

  bool getUserHapticFeedback() {
    return _prefs.getBool('user_haptic_feedback') ?? true;
  }

  String getUserId() {
    return _prefs.getString('user_id') ?? "";
  }

  String getAuthId() {
    return _prefs.getString('auth_id') ?? "";
  }

  String getAccessToken() {
    return _prefs.getString('access_token') ?? "";
  }

  bool hasUpdatedFCM() {
    return _prefs.getBool('fcm_updated') ?? false;
  }

  void clearUserData() async {
    bool res = await _prefs.clear();
  }

  UserProfileModel? getUserData() {
    var response = _prefs.getString("user");
    if (response?.isNotEmpty ?? false) {
      try {
        return userProfileModelFromJson(response!);
      } catch (e) {
        log("Error retrieving user data from local storage: $e");
        return null;
      }
    } else {
      log(":::::No user data found in local storage:::::");
      return null;
    }
  }

  UserLocalStorageService._internal();
}
