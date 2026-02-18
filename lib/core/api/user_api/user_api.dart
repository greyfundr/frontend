import 'package:greyfundr/core/models/user_profile_model.dart';

abstract class UserApi {
  Future <UserProfileModel> fetchUserProfile();

  Future fetchUserSettings();

}