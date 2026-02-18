import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/core/api/auth_api/auth_api.dart';
import 'package:greyfundr/services/locator.dart';
import 'package:greyfundr/shared/responsiveState/base_view_model.dart';
import 'package:greyfundr/shared/validator.dart';

class AuthProvider extends BaseNotifier with Validators {
  var authApi = locator<AuthApi>();

  PageController authPageController = PageController();
  int currentPage = 0;
  int secondsRemaining = 120;
  bool timerActive = false;
  int passwordStrength = 0;

  String newPin = "";

  void addToPin(String value) {
    newPin += value;
    notifyListeners();
  }

  void deleteFromPin() {
    newPin = newPin.substring(0, newPin.length - 1);
    notifyListeners();
  }

  void animateToNextPage(int index) async {
    currentPage = index;
    authPageController.animateToPage(
      index,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  void startTimer() {
    secondsRemaining = 60;
    timerActive = true;
    notifyListeners();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (secondsRemaining > 0) {
        secondsRemaining--;
        notifyListeners();
      }
      if (secondsRemaining == 0) {
        timerActive = false;
        notifyListeners();
        return false;
      }
      return true;
    });
  }

  void checkPasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 6) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    passwordStrength = strength;
    notifyListeners();
  }

  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void disposeSignupController() {
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    notifyListeners();
  }

  // signup logic
  String selectedRole = "";
  int currentSignupPage = 0;
  PageController signupPageController = PageController();

  void setSelectedRole(String role) {
    selectedRole = role;
    notifyListeners();
  }

  void animateToNextSignupPage(int index) async {
    currentSignupPage = index;
    signupPageController.animateToPage(
      index,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  void disposePersonalSignup() {
    // signupPageController.dispose();
    currentSignupPage = 0;
    selectedRole = "";
    notifyListeners();
  }

  // api calls
  Future<bool> signInApi({
    required String emailOrPhone,
    required String password,
  }) async {
    EasyLoading.show();
    try {
      var response = await authApi.signInApi(
        emailOrPhone: emailOrPhone,
        password: password,
      );
      notifyListeners();
      return true;
    } catch (e, stacktrace) {
      log("ERROR ON SIGN IN $e ");
      log("ERROR ON SIGN IN $stacktrace ");
      showErrorToast("${e}");
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> signUpApi({
    required String email,
    required String phoneNumber,
    required String password,
    String? accountType,
  }) async {
    EasyLoading.show();
    try {
      var response = await authApi.signUpApi(
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        accountType: accountType,
      );
      notifyListeners();
      return true;
    } catch (e) {
      log("ERROR ON SIGN UP $e ");
      showErrorToast("${e}");
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> verifyOtpApi({
    required String email,
    required String otp,
  }) async {
    EasyLoading.show();
    try {
      var response = await authApi.verifyOtpApi(emailOrPhone: email, otp: otp);
      notifyListeners();
      return true;
    } catch (e) {
      log("ERROR ON VERIFY OTP $e ");
      showErrorToast("${e}");
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> resendOtpApi({required String email}) async {
    EasyLoading.show();
    try {
      var response = await authApi.resendOtpApi(emailOrPhone: email);
      notifyListeners();
      showSuccessToast("OTP resent successfully");
      return true;
    } catch (e) {
      log("ERROR ON RESEND OTP $e ");
      showErrorToast("${e}");
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> completeKycApi({
    required String cacNumber,
    required String companyName,
    required String tin,
  }) async {
    EasyLoading.show();
    try {
      var response = await authApi.completeKycApi(
        cacNumber: cacNumber,
        companyName: companyName,
        tin: tin,
      );
      notifyListeners();
      return true;
    } catch (e) {
      log("ERROR ON COMPLETE KYC $e ");
      showErrorToast("${e}");
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> submitBasicInfoApi({
    required String firstName,
    required String lastName,
    required String username,
  }) async {
    EasyLoading.show();
    try {
      var response = await authApi.submitBasicInfoApi(
        firstName: firstName,
        lastName: lastName,
        username: username,
        agreeToTerms: true,
      );
      notifyListeners();
      return true;
    } catch (e) {
      log("ERROR ON COMPLETE KYC $e ");
      showErrorToast("${e}");
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }
}
