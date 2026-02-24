import 'package:greyfundr/core/models/user_profile_model.dart';
import 'package:greyfundr/core/models/user_settings_model.dart';

abstract class UserApi {
  Future<UserProfileModel> fetchUserProfile();

  Future updateUserProfile({String? firstName, String? lastName});

  Future<UserSettingsModel> fetchUserSettings();

  Future updateUserNotificationPreference({
    required Map<String, dynamic> payload,
  });
}
