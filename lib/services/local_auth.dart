import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

import 'package:local_auth_darwin/types/auth_messages_ios.dart';

class LocalAuth {
  static final _localAuth = LocalAuthentication();

  static Future<bool> canAuthenticate() async =>
      await _localAuth.canCheckBiometrics ||
      await _localAuth.isDeviceSupported();

  static Future<bool> authenticateLogin(
    String localizedReason,
    String title,
  ) async {
    try {
      if (!await canAuthenticate()) return false;
      return await _localAuth.authenticate(
        authMessages: [
          AndroidAuthMessages(signInTitle: title, cancelButton: 'No,Thanks'),
          IOSAuthMessages(cancelButton: 'No Thanks'),
        ],
        localizedReason: localizedReason,
        // options: const AuthenticationOptions(
        //   useErrorDialogs: true,
        //   stickyAuth: true,
        // ),
      );
    } catch (e) {
      // showErrorToast("Can't proceed with biometric");
      return false;
    }
  }
}
