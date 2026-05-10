import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/route_manager.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/core/api/auth_api/auth_api.dart';
import 'package:greyfundr/core/api/user_api/user_api.dart';
import 'package:greyfundr/core/api/campaign_api/campaign_api.dart';
import 'package:greyfundr/core/models/notification_model.dart' as nm;
import 'package:greyfundr/core/models/user_profile_model.dart';
import 'package:greyfundr/features/auth/create_pin_screen.dart';
import 'package:greyfundr/features/auth/create_transaction_pin_screen.dart';
import 'package:greyfundr/services/local_storage.dart';
import 'package:greyfundr/services/locator.dart';
import 'package:greyfundr/shared/responsiveState/view_state.dart';
import 'package:greyfundr/shared/validator.dart';

class UserProvider extends ChangeNotifier with Validators {
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

  bool checkToDo() {
    if (_userProfileModel?.isPinSet != true) {
      Get.offAll(CreatePinScreen(), transition: Transition.rightToLeft);
      return false;
    }
    if (_userProfileModel?.wallet?.isTransactionPinSet != true) {
      Get.offAll(
        CreateTransactionPinScreen(),
        transition: Transition.rightToLeft,
      );
      return false;
    }

    return false;
  }

  Future<bool> fetchUserProfileApi({bool showLoader = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    showLoader ? EasyLoading.show() : null;
    try {
      _userProfileModel = await _userApi.fetchUserProfile();
      // if (_userProfileModel?.isPinSet != true) {}
      checkToDo();
      notifyListeners();
      return true;
    } catch (e, stack) {
      log("ERROR FETCHING USER PROFILE: $e", stackTrace: stack);
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      showLoader ? EasyLoading.dismiss() : null;
      notifyListeners();
    }
  }

  Future<bool> completeKycTemp() async {
    try {
      EasyLoading.show();
      await _authApi.completeKycApi(cacNumber: "", companyName: "", tin: "");
      // Optionally refresh profile after KYC
      await fetchUserProfileApi();
      return true;
    } catch (e, stack) {
      log("ERROR ON COMPLETE KYC: $e", stackTrace: stack);
      return false;
    } finally {
      EasyLoading.dismiss();
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
    String? dateOfBirth,
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
        dateOfBirth: dateOfBirth,
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

  Future<bool> updateProfileAvatar({required String filePath}) async {
    EasyLoading.show();
    try {
      final imageUrl = await _userApi.uploadAvatar(filePath: filePath);
      if (imageUrl != null) {
        await _userApi.updateUserProfile(image: imageUrl);
      }
      await fetchUserProfileApi();
      showSuccessToast("Profile image updated successfully");
      return true;
    } catch (e, stack) {
      log("ERROR ON UPDATE PROFILE IMAGE: $e", stackTrace: stack);
      showErrorToast("Failed to update profile image");
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<String?> createKycSession() async {
    EasyLoading.show();
    try {
      final sessionUrl = await _userApi.createKycSession();
      return sessionUrl;
    } catch (e, stack) {
      log("ERROR CREATING KYC SESSION: $e", stackTrace: stack);
      showErrorToast("Failed to create KYC session");
      return null;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> submitBvn({required String bvn}) async {
    EasyLoading.show();
    try {
      final success = await _userApi.submitBvn(bvn: bvn);
      if (success) {
        showSuccessToast("BVN submitted successfully");
        await fetchUserProfileApi(); // Refresh profile after BVN submission
      } else {
        showErrorToast("Failed to submit BVN");
      }
      return success;
    } catch (e, stack) {
      log("ERROR SUBMITTING BVN: $e", stackTrace: stack);
      showErrorToast("Failed to submit BVN");
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

  Future<Map> getCustomDynamicLinkDetails({required String shortCode}) async {
    EasyLoading.show();
    try {
      Map data = await _userApi.getCustomDynamicLinkDetails(
        shortCode: shortCode,
      );
      notifyListeners();
      return data;
    } catch (e) {
      showErrorToast("$e");
      log("$e");
    } finally {
      EasyLoading.dismiss();
    }
    return {};
  }

  ViewState usernameState = ViewState.Idle;
  bool usernameExist = false;
  Future<bool> checkIfUsernameExist({required String username}) async {
    setCustomState(ViewState state) {
      usernameState = state;
      notifyListeners();
    }

    try {
      setCustomState(ViewState.Busy);
      bool res = await _userApi.checkIfUsernameExist(username: username);
      usernameExist = res;
      setCustomState(ViewState.Success);
      notifyListeners();
      return res;
    } catch (e) {
      showErrorToast("$e");
      log("$e");
      setCustomState(ViewState.Error);
      return true;
    } finally {}
  }

  void resetUsernameState() {
    usernameState = ViewState.Idle;
    usernameExist = false;
    notifyListeners();
  }

  Future<void> updateFcmToken() async {
    String token = await localStorage.getString("fcmToken");
    if (token.isNotEmpty) {
      await _userApi.updateFcmToken(token);
      log("FCM token updated successfully");
    } else {
      log("No FCM token found to update");
      // showErrorToast("Failed to update FCM token: No token found");
    }
  }

  // ─── Notifications ─────────────────────────────────────────────
  ViewState notificationsState = ViewState.Idle;
  List<nm.Notification> notifications = [];
  int notificationsTotal = 0;
  int unreadNotificationsCount = 0;
  int notificationsPage = 1;
  int notificationsTotalPages = 1;

  void _setNotificationsState(ViewState state) {
    notificationsState = state;
    notifyListeners();
  }

  Future<void> fetchNotifications({int page = 1}) async {
    if (page == 1 && notifications.isEmpty) {
      _setNotificationsState(ViewState.Busy);
    }
    try {
      final result = await _userApi.fetchNotifications(page: page);
      notifications = result.notifications ?? [];
      notificationsTotal = result.total ?? 0;
      unreadNotificationsCount = result.unreadCount ?? 0;
      notificationsPage = result.page ?? 1;
      notificationsTotalPages = result.totalPages ?? 1;
      _setNotificationsState(
        notifications.isEmpty ? ViewState.NoDataAvailable : ViewState.Success,
      );
    } catch (e, stack) {
      log("ERROR FETCHING NOTIFICATIONS: $e", stackTrace: stack);
      _setNotificationsState(ViewState.Error);
    }
  }

  Future<bool> markNotificationsAsRead({List<String>? ids}) async {
    try {
      final ok = await _userApi.markNotificationsAsRead(ids: ids);
      if (ok) {
        if (ids == null || ids.isEmpty) {
          notifications = notifications
              .map(
                (n) => n
                  ..isRead = true
                  ..readAt = DateTime.now().toIso8601String(),
              )
              .toList();
          unreadNotificationsCount = 0;
        } else {
          final idSet = ids.toSet();
          for (final n in notifications) {
            if (n.id != null && idSet.contains(n.id) && !(n.isRead ?? false)) {
              n.isRead = true;
              n.readAt = DateTime.now().toIso8601String();
              if (unreadNotificationsCount > 0) unreadNotificationsCount--;
            }
          }
        }
        notifyListeners();
      }
      return ok;
    } catch (e, stack) {
      log("ERROR MARKING NOTIFICATIONS READ: $e", stackTrace: stack);
      return false;
    }
  }

  Future<bool> deleteNotification(String id) async {
    try {
      final removed = notifications.firstWhere(
        (n) => n.id == id,
        orElse: () => nm.Notification(),
      );
      await _userApi.deleteNotification(id);
      notifications.removeWhere((n) => n.id == id);
      if ((removed.isRead == false) && unreadNotificationsCount > 0) {
        unreadNotificationsCount--;
      }
      if (notifications.isEmpty) {
        notificationsState = ViewState.NoDataAvailable;
      }
      notifyListeners();
      return true;
    } catch (e, stack) {
      log("ERROR DELETING NOTIFICATION: $e", stackTrace: stack);
      showErrorToast("Failed to delete notification");
      return false;
    }
  }
}
