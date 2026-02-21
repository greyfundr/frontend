import 'dart:developer';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:greyfundr/core/api/user_api/user_api.dart';
import 'package:greyfundr/core/models/user_profile_model.dart';
import 'package:greyfundr/services/locator.dart';
import 'package:greyfundr/shared/responsiveState/base_view_model.dart';

class UserProvider extends BaseNotifier {
  var userApi = locator<UserApi>();

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
      // log("ERROR ON COMPLETE KYC $e ");
      // showErrorToast("${e}");
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

}