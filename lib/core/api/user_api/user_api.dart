import 'package:greyfundr/core/models/user_profile_model.dart';
import 'package:greyfundr/core/models/user_settings_model.dart';

abstract class UserApi {
  Future<UserProfileModel> fetchUserProfile();

  Future updateUserProfile({
    String? firstName,
    String? lastName,
    List<String>? interest,
    String? bio,
    String? username,
    String? country,
    String? state,
    String? city,
    String? address,
    String? image,
    String? dateOfBirth,
  });

  Future<UserSettingsModel> fetchUserSettings();

  Future updateUserNotificationPreference({
    required Map<String, dynamic> payload,
  });

  Future<String?> uploadAvatar({required String filePath});

  Future<String> createKycSession();

  Future<bool> submitBvn({required String bvn});

  Future<Map> getCustomDynamicLinkDetails({String shortCode});

  Future<void> updateFcmToken(String token);
}
