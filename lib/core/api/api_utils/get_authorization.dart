// import 'dart:developer';

// import 'package:get/get.dart';
// import 'package:payrit_mobile_app/core/api/api_utils/network_exception.dart';
// import 'package:payrit_mobile_app/core/storage/jwt_storage.dart';
// import 'package:payrit_mobile_app/core/api/user_api/user_api.dart';
// import 'package:payrit_mobile_app/features/sign_in/sing_in_screen.dart';
// import 'package:payrit_mobile_app/shared/locator.dart';
// import 'package:payrit_mobile_app/utilities/custom_snackbars.dart';
// import 'package:payrit_mobile_app/utilities/ui_helpers.dart';

// Future<String> getAuthorization() async {
//   final JwtStorage jwtStorage = JwtStorage();
//   final userApi = locator<UserApi>();

//   try {
//     if (await jwtStorage.isExpired()) {
//       if (await jwtStorage.isRefreshExpired()) {
//         log("Refresh token expired");
//         showErrorToast('Session timeout');
//         logOut(fromRetry: true);
//         // Get.offAll(() => SignInScreen()); 
//         Get.offAll(() => SignInScreen());
//         return "";
//       } else {
//         log("Refreshing tokens");
//         await userApi.refreshToken();
//         log("Tokens refreshed successfully");
//         return jwtStorage.authorization();
//       }
//     } else {
//       return jwtStorage.authorization();
//     }
//   } on NetworkException {
//     showErrorToast("Please check your internet connection");
//     return "";
//   } catch (e) {
//     log("Error getting token: $e");
//     showErrorToast('Session timeout');
//     logOut(fromRetry: true);
//     Get.offAll(() => SignInScreen());
//     return "";
//   }
// }
