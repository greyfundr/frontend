import 'dart:convert';
import 'dart:developer'; // for log()
import 'dart:io';

import 'package:greyfundr/core/api/api_utils/api_route.dart';
import 'package:greyfundr/core/api/api_utils/app_client.dart';
import 'package:greyfundr/core/api/auth_api/auth_api.dart';

import 'package:greyfundr/core/models/participants_model.dart';
import 'package:greyfundr/core/models/login_response_model.dart' as loginModels;
import 'package:greyfundr/core/models/split_user_model.dart' as splitUser;
import 'package:greyfundr/core/models/split_bill_model.dart' as splitBill;

import 'package:greyfundr/services/local_storage.dart';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class AuthApiImpl implements AuthApi {
  final ApiClient _apiClient = ApiClient();

  Map<String, String> get header => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  // ──────────────────────────────────────────────────────────────
  // Authentication / Registration
  // ──────────────────────────────────────────────────────────────

  @override
  Future<loginModels.LoginResponseModel> signInApi({
    required String emailOrPhone,
    required String password,
  }) async {
    final data = {
      "emailOrPhone": emailOrPhone,
      "password": password,
    };
    final response = await _apiClient.post(
      ApiRoute.loginRoute,
      headers: header,
      body: data,
    );

    final decoded = jsonDecode(response);
    final loginResponse = loginModels.loginResponseModelFromJson(response);

    localStorage.setString("access_token", decoded["accessToken"]);
    localStorage.setString("refresh_token", decoded["refreshToken"]);

    return loginResponse;
  }

  @override
  Future<dynamic> signUpApi({
    required String email,
    required String phoneNumber,
    required String password,
    String? accountType,
  }) async {
    final data = {
      "email": email,
      "phoneNumber": phoneNumber,
      "password": password,
      "accountType": accountType,
    };
    return _apiClient.post(
      ApiRoute.signupRoute,
      headers: header,
      body: data,
    );
  }

  @override
  Future<Map<String, dynamic>> getSplitBillDetails(String splitBillId) async {
    final responseBody = await _apiClient.get(
      '/split-bill/$splitBillId',
      requiresToken: true,
    );

    final decoded = jsonDecode(responseBody);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception('Invalid split bill response format');
  }

  @override
  Future<dynamic> completeKycApi({
    required String cacNumber,
    required String companyName,
    required String tin,
  }) async {
    final data = {
      "cacNumber": cacNumber,
      "companyName": companyName,
      "tin": tin,
    };
    return _apiClient.patch(
      ApiRoute.completeKycRoute,
      headers: header,
      body: data,
      requiresToken: true,
    );
  }

  @override
  Future<dynamic> createPasswordApi({required String password}) async {
    final data = {"password": password};
    return _apiClient.post(
      ApiRoute.createPasswordRoute,
      headers: header,
      body: data,
      requiresToken: true,
    );
  }

  @override
  Future<dynamic> forgotPasswordApi({required String emailOrPhone}) async {
    final data = {"emailOrPhone": emailOrPhone};
    return _apiClient.patch(
      ApiRoute.forgotPasswordRoute,
      headers: header,
      body: data,
    );
  }

  @override
  Future<dynamic> generateTwoFactorApi() async {
    return _apiClient.get(
      ApiRoute.generateTwoFactorRoute,
      headers: header,
    );
  }

  @override
  Future<dynamic> loginPinApi({String? pin, String? emailOrPhone}) async {
    final data = {"pin": pin, "emailOrPhone": emailOrPhone};
    final responseBody = await _apiClient.post(
      ApiRoute.loginPinRoute,
      headers: header,
      body: data,
    );

    final decoded = jsonDecode(responseBody);
    localStorage.setString("access_token", decoded["accessToken"]);
    localStorage.setString("refresh_token", decoded["refreshToken"]);
    return responseBody;
  }

  @override
  Future<dynamic> refreshTokenApi() async {
    return _apiClient.post(
      ApiRoute.refreshTokenRoute,
      headers: header,
      body: {},
    );
  }

  @override
  Future<dynamic> resendOtpApi({required String emailOrPhone}) async {
    final data = {"emailOrPhone": emailOrPhone};
    return _apiClient.patch(
      ApiRoute.resendOtpRoute,
      headers: header,
      body: data,
    );
  }

  @override
  Future<dynamic> setPinApi({required String pin}) async {
    final data = {"pin": pin};
    return _apiClient.post(
      ApiRoute.setPinRoute,
      headers: header,
      body: data,
      requiresToken: true,
    );
  }

  @override
  Future<dynamic> submitBasicInfoApi({
    required String firstName,
    required String lastName,
    required String username,
    required bool agreeToTerms,
  }) async {
    final data = {
      "firstName": firstName,
      "lastName": lastName,
      "username": username,
      "agreeToTerms": agreeToTerms,
    };
    return _apiClient.post(
      ApiRoute.submitBasicInfoRoute,
      headers: header,
      body: data,
      requiresToken: true,
    );
  }

  @override
  Future<dynamic> verifyOtpApi({String? emailOrPhone, required String otp}) async {
    final data = {"emailOrPhone": emailOrPhone, "otp": otp};
    final responseBody = await _apiClient.patch(
      ApiRoute.verifyOtpRoute,
      headers: header,
      body: data,
    );

    final decoded = jsonDecode(responseBody);
    localStorage.setString("access_token", decoded["accessToken"]);
    localStorage.setString("refresh_token", decoded["refreshToken"]);
    return responseBody;
  }

  @override
  Future<dynamic> verifyTwoFactorApi({required String code}) async {
    final data = {"code": code};
    return _apiClient.post(
      ApiRoute.verifyTwoFactorRoute,
      headers: header,
      body: data,
    );
  }

  @override
  Future<dynamic> validateTwoFactorApi({required String code}) async {
    final data = {"code": code};
    return _apiClient.post(
      ApiRoute.validateTwoFactorRoute,
      headers: header,
      body: data,
    );
  }

  @override
  Future<dynamic> disableTwoFactorApi() async {
    return _apiClient.post(
      ApiRoute.disableTwoFactorRoute,
      headers: header,
      body: {},
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Campaign Management
  // ──────────────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> getCampaignDetails(String campaignId) async {
    try {
      final responseBody = await _apiClient.get(
        '/campaign/getcampaign/$campaignId',
        requiresToken: true,
      );

      final data = jsonDecode(responseBody);

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid campaign response format: expected Map');
      }

      return data['payload'] ?? data['data'] ?? data;
    } catch (e, stack) {
      log('Error fetching campaign $campaignId: $e', stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateCampaign(String campaignId, Map<String, dynamic> payload) async {
    try {
      final responseBody = await _apiClient.put(
        '/campaign/update/$campaignId',
        body: payload,
        requiresToken: true,
      );

      final decoded = jsonDecode(responseBody);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid update response format');
      }

      return decoded;
    } catch (e, stack) {
      log('Error updating campaign $campaignId: $e', stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<String?> uploadImage(File imageFile) async {
    try {
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
          contentType: MediaType.parse(mimeType),
        ),
      });

      final responseBody = await _apiClient.post(
        ApiRoute.uploadImageRoute,
        headers: header,
        body: formData,
        requiresToken: true,
      );

      final decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic> && decoded.containsKey('url')) {
        return decoded['url'] as String?;
      } else if (decoded is Map<String, dynamic> && decoded.containsKey('data') && decoded['data'] is Map) {
        return decoded['data']['url'] as String?;
      }

      log('Unexpected upload response format: $decoded');
      return null;
    } catch (e, stack) {
      log('Error uploading image: $e', stackTrace: stack);
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Donation Creation (NEW IMPLEMENTATION)
  // ──────────────────────────────────────────────────────────────

  @override
  Future<bool> createDonation({
    required String userId,
    required String creatorId,
    required String campaignId,
    required int amount,
    String? nickname,
    String? comments,
    String? behalfUserId,
    String? externalName,
    String? externalContact,
  }) async {
    try {
      final payload = {
        'user_id': userId,
        'creator_id': creatorId,
        'campaign_id': campaignId,
        'amount': amount,
        if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
        if (comments != null && comments.isNotEmpty) 'comments': comments,
        if (behalfUserId != null && behalfUserId.isNotEmpty) 'behalf_user_id': behalfUserId,
        if (externalName != null && externalName.isNotEmpty) 'external_name': externalName,
        if (externalContact != null && externalContact.isNotEmpty) 'external_contact': externalContact,
      };

      final responseBody = await _apiClient.post(
        '/donations',  // ← IMPORTANT: CHANGE THIS to your actual donation endpoint!
        // Common alternatives: '/campaigns/$campaignId/donate', '/donate', '/funds/donate'
        headers: header,
        body: payload,
        requiresToken: true,
      );

      final decoded = jsonDecode(responseBody);

      // Adjust success condition based on your actual backend response
      // Examples:
      // - if (decoded['success'] == true) return true;
      // - if (decoded['status'] == 'success') return true;
      // - if (decoded['message'] == 'Donation created') return true;

      // For now assuming 200/201 + no error key = success
      return responseBody != null && !decoded.toString().contains('error');
    } catch (e, stack) {
      log('createDonation failed: $e', stackTrace: stack);
      return false;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // User Profile & Settings
  // ──────────────────────────────────────────────────────────────

  @override
  Future<dynamic> userProfileApi() async {
    return _apiClient.get(
      ApiRoute.userProfileRoute,
      headers: header,
    );
  }

  @override
  Future<dynamic> getSettingsApi() async {
    return _apiClient.get(
      ApiRoute.getSettingsRoute,
      headers: header,
    );
  }

  @override
  Future<dynamic> updateSettingsApi({
    required String key,
    required String value,
  }) async {
    final data = {"key": key, "value": value};
    return _apiClient.patch(
      ApiRoute.updateSettingsRoute,
      headers: header,
      body: data,
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Participants / Users List
  // ──────────────────────────────────────────────────────────────

  @override
  Future<List<splitUser.User>> getUsers() async {
    try {
      final responseBody = await _apiClient.get(
        ApiRoute.getUserRoute,
        headers: header,
        requiresToken: true,
      );

      final dynamic decoded = jsonDecode(responseBody);

      List<dynamic> rawList;

      if (decoded is List<dynamic>) {
        rawList = decoded;
      } else if (decoded is Map<String, dynamic>) {
        rawList = decoded['data'] as List<dynamic>? ??
                  decoded['users'] as List<dynamic>? ??
                  decoded['results'] as List<dynamic>? ??
                  decoded['members'] as List<dynamic>? ??
                  (throw Exception('No user list found in response'));
      } else {
        throw Exception('Unexpected root type: ${decoded.runtimeType}');
      }

      return rawList
          .whereType<Map<String, dynamic>>()
          .map((map) => splitUser.User.fromJson(map))
          .toList();
    } catch (e, stack) {
      log('Error in getUsers(): $e', stackTrace: stack);
      rethrow;
    }
  }

  // ────────────────────────────────────────────────
  // Bill Receipt Upload
  // ────────────────────────────────────────────────
  @override
  Future<String?> uploadBillReceipt(File file) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
          contentType: lookupMimeType(file.path) != null
              ? MediaType.parse(lookupMimeType(file.path)!)
              : MediaType('image', 'jpeg'),
        ),
      });

      final responseBody = await _apiClient.post(
        ApiRoute.uploadBillReceiptRoute,
        headers: header,
        body: formData,
        requiresToken: true,
      );

      final decoded = responseBody is String ? jsonDecode(responseBody) : responseBody;

      return decoded is Map ? decoded['url'] as String? : null;
    } catch (e) {
      log('uploadBillReceipt failed: $e');
      return null;
    }
  }

  // ────────────────────────────────────────────────
  // Create EVEN Split Bill
  // ────────────────────────────────────────────────
  @override
  Future<Map<String, dynamic>?> createEvenSplitBill({
    required String title,
    required String description,
    required double totalAmount,
    required String? imageUrl,
    required String dueDateIso8601,
    required List<splitUser.User> participants,
  }) async {
    try {
      final amountPerPerson = totalAmount / participants.length;

      final payload = {
        "title": title.trim().isEmpty ? "Even Split Bill" : title.trim(),
        "description": description.trim(),
        "currency": "NGN",
        "amount": totalAmount.toInt(),
        "imageUrl": imageUrl ?? "",
        "splitMethod": "EVEN",
        "dueDate": dueDateIso8601,
        "participants": participants.map((user) {
          final isGuest = user.id.toString().length < 5 || user.id.toString().length > 10;
          return {
            "type": isGuest ? "GUEST" : "USER",
            if (isGuest) ...{
              "name": user.displayName?.trim() ?? "",
              "phone": user.phoneNumber?.trim() ?? "",
            } else ...{
              "userId": user.id,
            },
            "amount": amountPerPerson,
          };
        }).toList(),
      };

      final responseBody = await _apiClient.post(
        ApiRoute.createSplitBillRoute,
        headers: header,
        body: payload,
        requiresToken: true,
      );

      final decoded = responseBody is String ? jsonDecode(responseBody) : responseBody;

      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e) {
      log('createEvenSplitBill failed: $e');
      return null;
    }
  }

  // ────────────────────────────────────────────────
  // Create MANUAL Split Bill
  // ────────────────────────────────────────────────
  @override
  Future<Map<String, dynamic>?> createManualSplitBill({
    required String title,
    required String description,
    required double totalAmount,
    required String? imageUrl,
    required String dueDateIso8601,
    required Map<String, double> userAmounts,
    required List<splitUser.User> participants,
  }) async {
    try {
      final participantList = <Map<String, dynamic>>[];

      for (final user in participants) {
        final assignedAmount = userAmounts[user.id.toString()] ?? 0.0;
        if (assignedAmount <= 0) continue;

        final isGuest = user.id.toString().length < 5 || user.id.toString().length > 10;

        participantList.add({
          "type": isGuest ? "GUEST" : "USER",
          if (isGuest) ...{
            "name": user.displayName?.trim() ?? "",
            "phone": user.phoneNumber?.trim() ?? "",
          } else ...{
            "userId": user.id,
          },
          "amount": assignedAmount,
        });
      }

      if (participantList.isEmpty) return null;

      final payload = {
        "title": title.trim().isEmpty ? "Manual Split Bill" : title.trim(),
        "description": description.trim(),
        "currency": "NGN",
        "amount": totalAmount.toInt(),
        "imageUrl": imageUrl ?? "",
        "splitMethod": "MANUAL",
        "dueDate": dueDateIso8601,
        "participants": participantList,
      };

      final responseBody = await _apiClient.post(
        ApiRoute.createSplitBillRoute,
        headers: header,
        body: payload,
        requiresToken: true,
      );

      final decoded = responseBody is String ? jsonDecode(responseBody) : responseBody;

      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e) {
      log('createManualSplitBill failed: $e');
      return null;
    }
  }

  // ────────────────────────────────────────────────
  // Update Split Bill
  // ────────────────────────────────────────────────
  @override
  Future<Map<String, dynamic>?> updateSplitBill({
    required String splitBillId,
    required Map<String, dynamic> updatedData,
  }) async {
    try {
      final responseBody = await _apiClient.put(
        '/split-bills/$splitBillId',
        body: updatedData,
        requiresToken: true,
      );

      final decoded = jsonDecode(responseBody is String ? responseBody : jsonEncode(responseBody));

      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e) {
      log('updateSplitBill failed: $e');
      return null;
    }
  }

  // ────────────────────────────────────────────────
  // Get My Split Bills
  // ────────────────────────────────────────────────
  @override
  Future<List<splitBill.SplitBill>> getMySplitBills() async {
    try {
      final responseBody = await _apiClient.get(
        '/split-bill?role=participant',
        requiresToken: true,
      );

      final decoded = jsonDecode(responseBody is String ? responseBody : jsonEncode(responseBody));

      final List<dynamic> billList = (decoded['data'] as List?) ?? [];

      return billList
          .whereType<Map<String, dynamic>>()
          .map((item) => splitBill.SplitBill.fromJson(item))
          .toList();
    } catch (e) {
      log('getMySplitBills failed: $e');
      rethrow;
    }
  }
}