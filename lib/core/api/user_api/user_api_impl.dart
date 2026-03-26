import 'package:greyfundr/core/api/api_utils/api_route.dart';
import 'package:greyfundr/core/api/api_utils/app_client.dart';
import 'package:greyfundr/core/api/user_api/user_api.dart';
import 'package:greyfundr/core/models/user_profile_model.dart';
import 'package:greyfundr/core/models/user_settings_model.dart';
import 'package:greyfundr/services/user_local_storage_service.dart';

class UserApiImpl implements UserApi {
  final ApiClient _apiClient = ApiClient();

  Map<String, String> get header => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  @override
  Future<UserProfileModel> fetchUserProfile() async {
    final response = await _apiClient.get(
      ApiRoute.userProfileRoute,
      headers: header,
    );
    UserLocalStorageService().setUser(response);
    return userProfileModelFromJson(response);
  }

  @override
  Future<UserSettingsModel> fetchUserSettings() async {
    final response = await _apiClient.get(
      ApiRoute.getSettingsRoute,
      headers: header,
    );
    return userSettingsModelFromJson(response);
  }

  @override
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
  }) async {
    final response = await _apiClient.patch(
      ApiRoute.userProfileRoute,
      headers: header,
      body: {
        "firstName": firstName,
        "lastName": lastName,
        "interests": interest,
        "bio": bio,
        "username": username,
        "country": country,
        "state": state,
        "city": city,
        "address": address,
      }..removeWhere((key, value) => value == null || value == ""),
    );
    return response;
  }

  @override
  Future updateUserNotificationPreference({
    required Map<String, dynamic> payload,
  }) async {
    final response = await _apiClient.patch(
      ApiRoute.updateSettingsRoute,
      headers: header,
      body: payload,
    );
    return response;
  }
}
