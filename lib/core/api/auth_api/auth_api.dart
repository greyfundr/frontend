import 'dart:async';

// Import the model (adjust path if needed)
import 'package:greyfundr/core/models/login_response_model.dart';

abstract class AuthApi {
  // ──────────────────────────────────────────────────────────────
  // Authentication / Registration
  // ──────────────────────────────────────────────────────────────

  Future<LoginResponseModel> signInApi({
    required String emailOrPhone,
    required String password,
  });

  Future<dynamic> signUpApi({
    required String email,
    required String phoneNumber,
    required String password,
    String? accountType,
  });

  Future<dynamic> verifyOtpApi({
    String? emailOrPhone,
    required String otp,
  });

  Future<dynamic> resendOtpApi({required String emailOrPhone});

  Future<dynamic> forgotPasswordApi({required String emailOrPhone});

  Future<dynamic> createPasswordApi({required String password});

   Future changePasswordApi({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  });

  Future<dynamic> submitBasicInfoApi({
    required String firstName,
    required String lastName,
    required String username,
    required bool agreeToTerms,
  });

  Future<dynamic> completeKycApi({
    required String cacNumber,
    required String companyName,
    required String tin,
  });

  Future<dynamic> loginPinApi({
    String? pin,
    String? emailOrPhone,
  });

  Future changePinApi({required String currentPin, required String newPin});

  Future<dynamic> setPinApi({required String pin});

  Future<dynamic> refreshTokenApi();



  // ──────────────────────────────────────────────────────────────
  // Two-Factor Authentication
  // ──────────────────────────────────────────────────────────────

  Future<dynamic> generateTwoFactorApi();

  Future<dynamic> verifyTwoFactorApi({required String code});

  Future<dynamic> validateTwoFactorApi({required String code});

  Future<dynamic> disableTwoFactorApi();

  // ──────────────────────────────────────────────────────────────
  // User Profile & Settings
  // ──────────────────────────────────────────────────────────────

  Future<dynamic> userProfileApi();

  Future<dynamic> getSettingsApi();

  Future<dynamic> updateSettingsApi({
    required String key,
    required String value,
  });
}
