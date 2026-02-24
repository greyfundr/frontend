import 'dart:developer';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:greyfundr/core/api/auth_api/auth_api.dart';
import 'package:greyfundr/core/api/user_api/user_api.dart';
import 'package:greyfundr/core/models/user_profile_model.dart';
import 'package:greyfundr/services/locator.dart';
import 'package:greyfundr/shared/responsiveState/base_view_model.dart';

class UserProvider extends BaseNotifier {
  var userApi = locator<UserApi>();
  var authApi = locator<AuthApi>();

  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void updateSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  UserProfileModel? userProfileModel;
  Future<bool> fetchUserProfileApi() async {
    EasyLoading.show();
    try {
      userProfileModel = await userApi.fetchUserProfile();
      notifyListeners();
      return true;
    } catch (e) {
      log("ERROR FETCHING USER PROFILE $e ");
      // showErrorToast("${e}");
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> completeKycTemp() async {
    EasyLoading.show();
    try {
      await authApi.completeKycApi(cacNumber: "", companyName: "", tin: "");
      notifyListeners();
      return true;
    } catch (e) {
      log("ERROR ON COMPLETE KYC $e ");
      // showErrorToast("${e}");
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> editProfile({String? firstName, String? lastName}) async {
    EasyLoading.show();
    try {
      await userApi.updateUserProfile(
        firstName: firstName ?? "",
        lastName: lastName ?? "",
      );
      notifyListeners();
      return true;
    } catch (e) {
      log("ERROR ON EDIT PROFILE $e ");
      // showErrorToast("${e}");
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> updateUserNotificationPreference(
    Map<String, dynamic> payload,
  ) async {
    // Note: User said "do it behind the scene" so we might remove EasyLoading here, but we will leave it silent since it's just toggles.
    try {
      await userApi.updateUserNotificationPreference(payload: payload);
      notifyListeners();
      return true;
    } catch (e) {
      log("ERROR ON UPDATE USER NOTIFICATION PREFERENCE $e ");
      return false;
    }
  }
}
