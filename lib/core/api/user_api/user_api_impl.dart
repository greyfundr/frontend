import 'package:greyfundr/core/api/api_utils/api_route.dart';
import 'package:greyfundr/core/api/api_utils/app_client.dart';
import 'package:greyfundr/core/api/user_api/user_api.dart';
import 'package:greyfundr/core/models/user_profile_model.dart';
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
  Future fetchUserSettings() {
    // TODO: implement fetchUserSettings
    throw UnimplementedError();
  }
}
