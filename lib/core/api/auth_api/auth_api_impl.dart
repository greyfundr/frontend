import 'dart:convert';

import 'package:greyfundr/core/api/api_utils/api_route.dart';
import 'package:greyfundr/core/api/api_utils/app_client.dart';
import 'package:greyfundr/core/api/auth_api/auth_api.dart';
import 'package:greyfundr/core/models/login_response_model.dart';
import 'package:greyfundr/services/local_storage.dart';
import 'package:greyfundr/services/user_local_storage_service.dart';

class AuthApiImpl implements AuthApi {
  final ApiClient _apiClient = ApiClient();

  Map<String, String> get header => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  @override
  Future<LoginResponseModel> signInApi({
    required String emailOrPhone,
    required String password,
  }) async {
    Map<String, dynamic> data = {
      "emailOrPhone": emailOrPhone,
      "password": password,
    };
    final response = await _apiClient.post(
      ApiRoute.loginRoute,
      headers: header,
      body: data,
    );
    var decodedResponse = jsonDecode(response);
    var loginResponse = loginResponseModelFromJson(response);
    localStorage.setString("access_token", decodedResponse["accessToken"]);
    localStorage.setString("refresh_token", decodedResponse["refreshToken"]);
    // UserLocalStorageService().setUser(jsonEncode(loginResponse.data));
    return loginResponse;
  }

  @override
  Future signUpApi({
    required String email,
    required String phoneNumber,
    required String password,
    String? accountType,
  }) async {
    Map<String, dynamic> data = {
      "email": email,
      "phoneNumber": phoneNumber,
      "password": password,
      "accountType": accountType,
    };
    final response = await _apiClient.post(
      ApiRoute.signupRoute,
      headers: header,
      body: data,
    );
    return response;
  }

  @override
  Future completeKycApi({
    required String cacNumber,
    required String companyName,
    required String tin,
  }) async {
    Map<String, dynamic> data = {
      "cacNumber": cacNumber,
      "companyName": companyName,
      "tin": tin,
    };
    final response = await _apiClient.patch(
      ApiRoute.completeKycRoute,
      headers: header,
      body: data,
      requiresToken: true,
    );
    return response;
  }

  @override
  Future createPasswordApi({required String password}) async {
    Map<String, dynamic> data = {"password": password};
    final response = await _apiClient.post(
      ApiRoute.createPasswordRoute,
      headers: header,
      body: data,
      requiresToken: true,
    );
    return response;
  }

  @override
  Future forgotPasswordApi({required String emailOrPhone}) async {
    Map<String, dynamic> data = {"emailOrPhone": emailOrPhone};
    final response = await _apiClient.patch(
      ApiRoute.forgotPasswordRoute,
      headers: header,
      body: data,
    );
    return response;
  }

  @override
  Future generateTwoFactorApi() async {
    final response = await _apiClient.get(
      ApiRoute.generateTwoFactorRoute,
      headers: header,
    );
    return response;
  }

  @override
  Future loginPinApi({String? pin, String? emailOrPhone}) async {
    Map<String, dynamic> data = {"pin": pin, "emailOrPhone": emailOrPhone};
    final response = await _apiClient.post(
      ApiRoute.loginPinRoute,
      headers: header,
      body: data,
    );
    var decodedResponse = jsonDecode(response);
    localStorage.setString("access_token", decodedResponse["accessToken"]);
    localStorage.setString("refresh_token", decodedResponse["refreshToken"]);
    return response;
  }

  @override
  Future refreshTokenApi() async {
    final response = await _apiClient.post(
      ApiRoute.refreshTokenRoute,
      headers: header,
      body: {},
    );
    return response;
  }

  @override
  Future resendOtpApi({required String emailOrPhone}) async {
    Map<String, dynamic> data = {"emailOrPhone": emailOrPhone};
    final response = await _apiClient.patch(
      ApiRoute.resendOtpRoute,
      headers: header,
      body: data,
    );
    return response;
  }

  @override
  Future setPinApi({required String pin}) async {
    Map<String, dynamic> data = {"pin": pin};
    final response = await _apiClient.post(
      ApiRoute.setPinRoute,
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
  Future verifyTwoFactorApi({required String code}) async {
    Map<String, dynamic> data = {"code": code};
    final response = await _apiClient.post(
      ApiRoute.verifyTwoFactorRoute,
      headers: header,
      body: data,
    );
    return response;
  }

  @override
  Future validateTwoFactorApi({required String code}) async {
    Map<String, dynamic> data = {"code": code};
    final response = await _apiClient.post(
      ApiRoute.validateTwoFactorRoute,
      headers: header,
      body: data,
    );
    return response;
  }

  @override
  Future disableTwoFactorApi() async {
    final response = await _apiClient.post(
      ApiRoute.disableTwoFactorRoute,
      headers: header,
      body: {},
    );
    return response;
  }

  @override
  Future getSettingsApi() async {
    final response = await _apiClient.get(
      ApiRoute.getSettingsRoute,
      headers: header,
    );
    return response;
  }

  @override
  Future updateSettingsApi({required String key, required String value}) async {
    Map<String, dynamic> data = {"key": key, "value": value};
    final response = await _apiClient.patch(
      ApiRoute.updateSettingsRoute,
      headers: header,
      body: data,
    );
    return response;
  }

  @override
  Future userProfileApi() async {
    final response = await _apiClient.get(
      ApiRoute.userProfileRoute,
      headers: header,
    );
    return response;
  }
}
