import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/core/api/auth_api/auth_api.dart';
import 'package:greyfundr/core/api/user_api/user_api.dart';
import 'package:greyfundr/core/api/campaign_api/campaign_api.dart';
import 'package:greyfundr/core/models/user_profile_model.dart';
import 'package:greyfundr/services/locator.dart';

class UserProvider with ChangeNotifier {
  // Services
  final UserApi _userApi = locator<UserApi>();
  final AuthApi _authApi = locator<AuthApi>();
  final CampaignApi _campaignApi = locator<CampaignApi>();

  // ─── Profile Data ──────────────────────────────────────────────
  UserProfileModel? _userProfileModel;
  bool _isLoading = false;
  String? _error;

  // ─── Campaigns (if you want to show them in profile) ───────────
  List<dynamic> _userCampaigns = [];
  bool _isLoadingCampaigns = false;
  String? _campaignsError;

  // ─── Navigation / UI State ─────────────────────────────────────
  int _selectedIndex = 0;
  bool _suppressAppNav = false;

  // ─── Getters ────────────────────────────────────────────────────
  UserProfileModel? get userProfileModel => _userProfileModel;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<dynamic> get userCampaigns => _userCampaigns;
  bool get isLoadingCampaigns => _isLoadingCampaigns;
  String? get campaignsError => _campaignsError;

  int get selectedIndex => _selectedIndex;
  bool get suppressAppNav => _suppressAppNav;

  // ─── Methods ────────────────────────────────────────────────────
  void updateSelectedIndex(int index) {
    _selectedIndex = index;
    log("Selected Index: $index");
    notifyListeners();
  }

  void setSuppressAppNav(bool value) {
    if (_suppressAppNav == value) return;
    _suppressAppNav = value;
    notifyListeners();
  }

  Future<bool> fetchUserProfileApi() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userProfileModel = await _userApi.fetchUserProfile();
      notifyListeners();
      return true;
    } catch (e, stack) {
      log("ERROR FETCHING USER PROFILE: $e", stackTrace: stack);
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeKycTemp() async {
    try {
      await _authApi.completeKycApi(cacNumber: "", companyName: "", tin: "");
      // Optionally refresh profile after KYC
      await fetchUserProfileApi();
      return true;
    } catch (e, stack) {
      log("ERROR ON COMPLETE KYC: $e", stackTrace: stack);
      return false;
    }
  }

  Future<bool> editProfile({
    String? firstName,
    String? lastName,
    String? username,
    String? bio,
    String? country,
    String? state,
    String? city,
    String? address,
    List<String>? interests,
  }) async {
    EasyLoading.show();
    try {
      await _userApi.updateUserProfile(
        firstName: firstName ?? "",
        lastName: lastName ?? "",
        username: username,
        bio: bio,
        country: country,
        state: state,
        city: city,
        address: address,
        interest: interests,
      );
      // Refresh profile after edit
      await fetchUserProfileApi();
      showSuccessToast("Profile updated successfully");
      return true;
    } catch (e, stack) {
      log("ERROR ON EDIT PROFILE: $e", stackTrace: stack);
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> editInterest({required List<String> interests}) async {
    EasyLoading.show();
    try {
      await _userApi.updateUserProfile(interest: interests);
      // Refresh profile after edit
      await fetchUserProfileApi();
      return true;
    } catch (e, stack) {
      log("ERROR ON EDIT PROFILE: $e", stackTrace: stack);
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> updateUserNotificationPreference(
    Map<String, dynamic> payload,
  ) async {
    try {
      await _userApi.updateUserNotificationPreference(payload: payload);
      notifyListeners();
      return true;
    } catch (e, stack) {
      log("ERROR ON UPDATE NOTIFICATION PREFERENCE: $e", stackTrace: stack);
      return false;
    }
  }

  // ─── Optional: Fetch user campaigns (for profile tab) ───────────
  Future<void> fetchUserCampaigns() async {
    _isLoadingCampaigns = true;
    _campaignsError = null;
    notifyListeners();

    try {
      // Use CampaignApi to fetch the current user's campaigns
      final List<Map<String, dynamic>> list = await _campaignApi
          .getMyCampaigns();
      _userCampaigns = list;
    } catch (e, stack) {
      log("ERROR FETCHING CAMPAIGNS: $e", stackTrace: stack);
      _campaignsError = e.toString();
    } finally {
      _isLoadingCampaigns = false;
      notifyListeners();
    }
  }
}
