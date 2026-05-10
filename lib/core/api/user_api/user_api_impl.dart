import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:greyfundr/core/api/api_utils/api_route.dart';
import 'package:greyfundr/core/api/api_utils/app_client.dart';
import 'package:greyfundr/core/api/user_api/user_api.dart';
import 'package:greyfundr/core/models/notification_model.dart';
import 'package:greyfundr/core/models/user_profile_model.dart';
import 'package:greyfundr/core/models/user_settings_model.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
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
      hideLog: false
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
    String? image,
    String? dateOfBirth,
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
        "image": image,
        "dateOfBirth": dateOfBirth,
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

  @override
  Future<String?> uploadAvatar({required String filePath}) async {
    try {
      final file = File(filePath);
      final multipart = await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
        contentType: lookupMimeType(file.path) != null
            ? MediaType.parse(lookupMimeType(file.path)!)
            : MediaType('image', 'jpeg'),
      );

      final formData = FormData.fromMap({'file': multipart});

      final responseBody = await _apiClient.post(
        ApiRoute.uploadAvatarRoute,
        headers: {'Accept': 'application/json'},
        formData: formData,
        requiresToken: true,
      );

      final decoded = jsonDecode(responseBody);
      final data = decoded is Map<String, dynamic> ? decoded['data'] : null;

      if (data is Map<String, dynamic>) {
        return (data['imageUrl'] ?? data['url'] ?? data['image'])?.toString();
      }

      if (data is String && data.isNotEmpty) {
        return data;
      }

      return null;
    } catch (e, stack) {
      log('ERROR UPLOADING AVATAR: $e', stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<Map> getCustomDynamicLinkDetails({String? shortCode}) async {
    String url = "https://free-dynamic-link.onrender.com/api/links/$shortCode";

    log("::::::::$url");
    var responsebody = await _apiClient.get(
      url,
      headers: header,
      hideLog: false,
    );
    Map<String, dynamic> responseMap = jsonDecode(responsebody);

    return responseMap["data"];
  }

  @override
  Future<String> createKycSession() async {
    final response = await _apiClient.post(
      ApiRoute.kycSessionRoute,
      headers: header,
      hideLog: false,
    );
    final decoded = jsonDecode(response);
    final sessionUrl = decoded['data']?['url'];
    if (sessionUrl != null && sessionUrl is String) {
      return sessionUrl;
    } else {
      return "";
    }
  }

  @override
  Future<bool> submitBvn({required String bvn}) async {
    try {
      await _apiClient.post(
        ApiRoute.submitBvnRoute,
        headers: header,
        body: {"bvn": bvn},
      );
      return true;
    } catch (e) {
      log('ERROR SUBMITTING BVN: $e');
      return false;
    }
  }

  @override
  Future<bool> checkIfUsernameExist({required String username}) async {
    try {
      var res = await _apiClient.get(
        "${ApiRoute.checkIfUsernameExist}/?username=$username",
        headers: header,
      );
      var decodedResponse = jsonDecode(res);
      return decodedResponse['exists'] == true;
    } catch (e) {
      log('ERROR SUBMITTING BVN: $e');
      return false;
    }
  }

  @override
  Future<void> updateFcmToken(String token) async {
    Map<String, dynamic> body = {"fcmToken": token};
    log("Updating FCM Token: $body");
    await _apiClient.patch(ApiRoute.updateFcmToke, headers: header, body: body);
  }

  @override
  Future<NotificationModel> fetchNotifications({
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _apiClient.get(
      "${ApiRoute.notificationsRoute}?page=$page&limit=$limit",
      headers: header,
    );
    final decoded = jsonDecode(response);
    final payload = decoded is Map<String, dynamic> && decoded['data'] != null
        ? decoded['data']
        : decoded;
    return NotificationModel.fromJson(
      payload is Map<String, dynamic> ? payload : {},
    );
  }

  @override
  Future<bool> markNotificationsAsRead({List<String>? ids}) async {
    final body = <String, dynamic>{};
    if (ids != null && ids.isNotEmpty) body['ids'] = ids;
    await _apiClient.patch(
      ApiRoute.markNotificationsReadRoute,
      headers: header,
      body: body,
    );
    return true;
  }

  @override
  Future<bool> deleteNotification(String id) async {
    await _apiClient.delete(
      ApiRoute.deleteNotificationRoute(id),
      headers: header,
    );
    return true;
  }
}
