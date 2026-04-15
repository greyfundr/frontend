import 'dart:convert';
// for log()

import 'package:greyfundr/core/api/api_utils/api_route.dart';
import 'package:greyfundr/core/api/api_utils/app_client.dart';
import 'package:greyfundr/core/api/auth_api/auth_api.dart';
import 'package:greyfundr/core/models/login_response_model.dart' as loginModels;
import 'package:greyfundr/services/local_storage.dart';

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
    final data = {"emailOrPhone": emailOrPhone, "password": password};
    final response = await _apiClient.post(
      ApiRoute.loginRoute,
      headers: header,
      body: data,
    );

    final decoded = jsonDecode(response);
    final loginResponse = loginModels.loginResponseModelFromJson(response);

    if (loginResponse.data?.hasVerifiedPhone != false) {
      localStorage.setString("access_token", decoded["accessToken"]);
      localStorage.setString("refresh_token", decoded["refreshToken"]);
    }

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
    return _apiClient.post(ApiRoute.signupRoute, headers: header, body: data);
  }

  // @override
  // Future<dynamic> verifyOtpApi({
  //   String? emailOrPhone,
  //   required String otp,
  // }) async {
  //   final data = {"emailOrPhone": emailOrPhone, "otp": otp};
  //   final responseBody = await _apiClient.patch(
  //     ApiRoute.verifyOtpRoute,
  //     headers: header,
  //     body: data,
  //   );

  //   final decoded = jsonDecode(responseBody);
  //   localStorage.setString("access_token", decoded["accessToken"]);
  //   localStorage.setString("refresh_token", decoded["refreshToken"]);
  //   return responseBody;
  // }

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
  Future<dynamic> forgotPasswordApi({required String emailOrPhone}) async {
    final data = {"emailOrPhone": emailOrPhone};
    return _apiClient.patch(
      ApiRoute.forgotPasswordRoute,
      headers: header,
      body: data,
    );
  }

  // @override
  // Future<dynamic> createPasswordApi({required String password}) async {
  //   final data = {"password": password};
  //   return _apiClient.post(
  //     ApiRoute.createPasswordRoute,
  //     headers: header,
  //     body: data,
  //     requiresToken: true,
  //   );
  // }

  @override
  Future createPasswordApi({required String password}) async {
    // Map<String, dynamic> data = {"password": password};
    // final response = await _apiClient.post(
    Map<String, dynamic> data = {
      "resetToken": await localStorage.getString("temp_access_token"),
      "newPassword": password,
      "confirmNewPassword": password,
    };
    final response = await _apiClient.patch(
      ApiRoute.createPasswordRoute,
      headers: header,
      body: data,
      requiresToken: false,
    );
    return response;
  }

  @override
  Future changePasswordApi({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    Map<String, dynamic> data = {
      "currentPassword": currentPassword,
      "newPassword": newPassword,
      "confirmNewPassword": confirmNewPassword,
    };
    final response = await _apiClient.post(
      ApiRoute.changePasswordRoute,
      headers: header,
      body: data,
      requiresToken: true,
    );
    return response;
  }

  @override
  Future changePinApi({
    required String currentPin,
    required String newPin,
  }) async {
    Map<String, dynamic> data = {"currentPin": currentPin, "newPin": newPin};
    final response = await _apiClient.post(
      ApiRoute.changePinRoute,
      headers: header,
      body: data,
      requiresToken: true,
    );
    return response;
  }

  @override
  Future submitBasicInfoApi({
    required String firstName,
    required String lastName,
    required String username,
    required bool agreeToTerms,
  }) async {
    Map<String, dynamic> data = {
      "firstName": firstName,
      "lastName": lastName,
      "username": username,
      "agreeToTerms": true,
    };
    final response = await _apiClient.post(
      ApiRoute.submitBasicInfoRoute,
      headers: header,
      body: data,
      requiresToken: true,
    );
    return response;
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
    localStorage.setString("user_id", decoded["data"]["id"]);

    return responseBody;
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
  Future<dynamic> refreshTokenApi() async {
    return _apiClient.post(
      ApiRoute.refreshTokenRoute,
      headers: header,
      body: {},
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Two-Factor Authentication
  // ──────────────────────────────────────────────────────────────

  @override
  Future<dynamic> generateTwoFactorApi() async {
    return _apiClient.get(ApiRoute.generateTwoFactorRoute, headers: header);
  }

  @override
  Future verifyOtpApi({String? emailOrPhone, required String otp}) async {
    Map<String, dynamic> data = {"emailOrPhone": emailOrPhone, "otp": otp};
    final response = await _apiClient.patch(
      ApiRoute.verifyOtpRoute,
      headers: header,
      body: data,
    );
    var decodedResponse = jsonDecode(response);
    localStorage.setString("access_token", decodedResponse["accessToken"]);
    localStorage.setString("refresh_token", decodedResponse["refreshToken"]);
    return response;
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
  // User Profile & Settings
  // ──────────────────────────────────────────────────────────────

  @override
  Future<dynamic> userProfileApi() async {
    return _apiClient.get(ApiRoute.userProfileRoute, headers: header);
  }

  @override
  Future<dynamic> getSettingsApi() async {
    return _apiClient.get(ApiRoute.getSettingsRoute, headers: header);
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
}
