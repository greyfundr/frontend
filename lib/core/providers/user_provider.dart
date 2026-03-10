import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:greyfundr/core/api/auth_api/auth_api.dart';
import 'package:greyfundr/core/api/user_api/user_api.dart';
import 'package:greyfundr/core/models/user_profile_model.dart';
import 'package:greyfundr/services/locator.dart';

class UserProvider with ChangeNotifier {
  // Services
  final UserApi _userApi = locator<UserApi>();
  final AuthApi _authApi = locator<AuthApi>();

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

  // ─── Getters ────────────────────────────────────────────────────
  UserProfileModel? get userProfileModel => _userProfileModel;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<dynamic> get userCampaigns => _userCampaigns;
  bool get isLoadingCampaigns => _isLoadingCampaigns;
  String? get campaignsError => _campaignsError;

  int get selectedIndex => _selectedIndex;

  // ─── Methods ────────────────────────────────────────────────────
  void updateSelectedIndex(int index) {
    _selectedIndex = index;
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

  Future<bool> editProfile({String? firstName, String? lastName}) async {
    try {
      await _userApi.updateUserProfile(
        firstName: firstName ?? "",
        lastName: lastName ?? "",
      );
      // Refresh profile after edit
      await fetchUserProfileApi();
      return true;
    } catch (e, stack) {
      log("ERROR ON EDIT PROFILE: $e", stackTrace: stack);
      return false;
    }
  }

  Future<bool> updateUserNotificationPreference(Map<String, dynamic> payload) async {
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
      // Replace with your real campaign API call
      // Example:
      // final response = await http.get(Uri.parse('https://api.greyfundr.com/campaigns/mine'), headers: {...});
      // final data = jsonDecode(response.body);
      // _userCampaigns = data['campaigns'] ?? [];

      // For now, placeholder data
      await Future.delayed(const Duration(seconds: 1));
      _userCampaigns = [
        {"id": "1", "title": "Sample Campaign", "image": "https://example.com/img.jpg"},
      ];
    } catch (e, stack) {
      log("ERROR FETCHING CAMPAIGNS: $e", stackTrace: stack);
      _campaignsError = e.toString();
    } finally {
      _isLoadingCampaigns = false;
      notifyListeners();
    }
  }
}
