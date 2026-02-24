abstract class AuthApi {
  Future signInApi({required String emailOrPhone, required String password});

  Future signUpApi({
    required String email,
    required String phoneNumber,
    required String password,
    String? accountType,
  });

  Future verifyOtpApi({String? emailOrPhone, required String otp});

  Future resendOtpApi({required String emailOrPhone});

  Future forgotPasswordApi({required String emailOrPhone});

  Future createPasswordApi({required String password});

  Future submitBasicInfoApi({
    required String firstName,
    required String lastName,
    required String username,
    required bool agreeToTerms,
  });

  Future completeKycApi({
    required String cacNumber,
    required String companyName,
    required String tin,
  });

  Future loginPinApi({String? pin, String? emailOrPhone});

  Future setPinApi({required String pin});

  Future refreshTokenApi();

  Future generateTwoFactorApi();

  Future verifyTwoFactorApi({required String code});

  Future validateTwoFactorApi({required String code});

  Future disableTwoFactorApi();

  Future getSettingsApi();

  Future updateSettingsApi({required String key, required String value});

  Future userProfileApi();
}
