import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_app_bar.dart';
import 'package:greyfundr/components/custom_network_image.dart';
import 'package:greyfundr/components/custom_num_pad.dart';
import 'package:greyfundr/components/custom_ontap.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/core/api/api_utils/token_manager.dart';
import 'package:greyfundr/core/models/user_profile_model.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/core/providers/wallet_provider.dart';
import 'package:greyfundr/features/auth/auth_outlet.dart';
import 'package:greyfundr/features/auth/auth_provider.dart';
import 'package:greyfundr/features/shared/bottom_nav.dart';
import 'package:greyfundr/features/shared/bottom_sheets.dart';
import 'package:greyfundr/services/local_auth.dart';
import 'package:greyfundr/services/user_local_storage_service.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';

import 'package:provider/provider.dart';

class SignInWithPinScreen extends StatefulWidget {
  final bool fromSplash;
  const SignInWithPinScreen({super.key, this.fromSplash = true});

  @override
  State<SignInWithPinScreen> createState() => _SignInWithPinScreenState();
}

class _SignInWithPinScreenState extends State<SignInWithPinScreen> {
  AuthProvider? authProvider;
  final TextEditingController pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (UserLocalStorageService().getUseLoginBiometricValue()) {
        loginWithBiometric(triggeredAutomatically: true);
      }
    });
  }

  @override
  void dispose() {
    pinController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authProvider?.disposePin();
    });
    super.dispose();
  }

  Future<void> loginWithBiometric({bool triggeredAutomatically = false}) async {
    EasyLoading.show();
    try {
      final user = UserLocalStorageService().getUserData();
      if (user == null || (user.email?.isEmpty ?? true)) {
        if (!triggeredAutomatically) {
          showErrorToast('No active user session found');
        }
        return;
      }

      final hasBiometric = await LocalAuth.hasEnrolledBiometrics();
      if (!hasBiometric) {
        if (!triggeredAutomatically) {
          showErrorToast(
            'Biometric is unavailable or not enrolled on this device',
          );
        }
        return;
      }

      final isAuthenticated = await LocalAuth.authenticateLogin(
        'Use your biometric to login',
        'Biometric Sign In',
      );

      if (!isAuthenticated) {
        if (!triggeredAutomatically) {
          showErrorToast('Biometric authentication failed or was cancelled');
        }
        return;
      }

      if (!widget.fromSplash) {
        // In-app unlock flow: simply dismiss the lock surface.
        if (mounted) Navigator.of(context).maybePop(true);
        return;
      }

      final tokenManager = TokenManager();
      final refreshTokenExpired = await tokenManager.isRefreshTokenExpired();
      if (refreshTokenExpired) {
        if (!mounted) return;
        Get.offAll(const AuthOutlet(), transition: Transition.rightToLeft);
        return;
      }

      if (!mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final walletProvider = Provider.of<WalletProvider>(
        context,
        listen: false,
      );
      await userProvider.fetchUserProfileApi();
      await walletProvider.fetchUserWallet();
      await walletProvider.fetchTransactions();

      if (!mounted) return;
      Get.offAll(const BottomNav(), transition: Transition.rightToLeft);
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    UserProfileModel? user = UserLocalStorageService().getUserData();

    return Scaffold(
      // backgroundColor: Color(0xffD9F1F3),
      appBar: CustomAppBar(leading: SizedBox()),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Gap(0),
                          Text('Welcome Back', style: txStyle14),
                          Gap(20),
                          CustomNetworkImage(imageUrl: "${user?.profile?.image}", radius: 40),
                          Gap(10),

                          Text(
                            '${user?.firstName ?? ""} ${user?.lastName ?? ""}',
                            style: txStyle27Bold.copyWith(
                              color: appPrimaryColor,
                            ),
                          ),
                          Gap(50),
                          PinCodeText(pin: authProvider.newPin),
                          // Gap(10),
                          // TextButton.icon(
                          //   onPressed: () => loginWithBiometric(),
                          //   icon: const Icon(
                          //     Icons.fingerprint,
                          //     color: appPrimaryColor,
                          //   ),
                          //   label: Text(
                          //     'Use biometric',
                          //     style: txStyle14.copyWith(color: appPrimaryColor),
                          //   ),
                          // ),
                          Spacer(),
                          NumPad(
                            isForLogin: true,
                            onBiometricClicked: () => loginWithBiometric(),
                            onValue: (value) async {
                              authProvider.addToPin(value);
                              // log("Value: $value");
                              if (authProvider.newPin.length == 6) {
                                bool res = await authProvider.signInWithPin(
                                  emailOrPhone: user?.email ?? "",
                                  pin: authProvider.newPin,
                                );
                                if (res) {
                                  Get.offAll(
                                    const BottomNav(),
                                    transition: Transition.rightToLeft,
                                  );
                                }
                              }
                              // signInProvider.checkPinFiled();
                            },
                            onDelete: () {
                              authProvider.deleteFromPin();
                              // signInProvider.checkPinFiled();
                            },
                          ),
                          Spacer(),
                          // CustomButton(
                          //   onTap: () async {
                          //     bool res = await authProvider.signInWithPin(
                          //       emailOrPhone: user?.email ?? "",
                          //       pin: authProvider.newPin,
                          //     );
                          //     if (res) {
                          //       Get.offAll(
                          //         BottomNav(),
                          //         transition: Transition.rightToLeft,
                          //       );
                          //     }
                          //   },
                          //   label: "Sign In",
                          // ),
                          Gap(15),
                          CustomOnTap(
                            onTap: () {
                              showCustomBottomSheet(
                                LogoutAppSheet(
                                  userName: user?.firstName ?? "",
                                ),
                                context,
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Not ",
                                style: txStyle14.copyWith(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: "${user?.firstName ?? ""} ?",
                                    style: txStyle14,
                                  ),
                                  TextSpan(
                                    text: " Logout",
                                    style: txStyle14.copyWith(
                                      color: appPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Gap(10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
