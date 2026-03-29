import 'dart:developer';

import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

import 'package:local_auth_darwin/types/auth_messages_ios.dart';

class LocalAuth {
  static final _localAuth = LocalAuthentication();

  static Future<bool> canAuthenticate() async =>
      await _localAuth.canCheckBiometrics ||
      await _localAuth.isDeviceSupported();

  static Future<bool> hasEnrolledBiometrics() async {
    if (!await canAuthenticate()) return false;
    final available = await _localAuth.getAvailableBiometrics();
    return available.isNotEmpty;
  }

  static Future<bool> authenticateLogin(
    String localizedReason,
    String title,
  ) async {
    try {
      if (!await hasEnrolledBiometrics()) return false;
      return await _localAuth.authenticate(
        authMessages: [
          AndroidAuthMessages(signInTitle: title, cancelButton: 'No,Thanks'),
          IOSAuthMessages(cancelButton: 'No Thanks'),
        ],
        localizedReason: localizedReason,
        biometricOnly: true,
      );
    } catch (e) {
      // showErrorToast("Can't proceed with biometric");
      log("Error during biometric authentication: $e");
      return false;
    }
  }
}
