import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_app_bar.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_network_image.dart';
import 'package:greyfundr/components/custom_num_pad.dart';
import 'package:greyfundr/components/custom_ontap.dart';
import 'package:greyfundr/core/models/user_profile_model.dart';
import 'package:greyfundr/features/auth/auth_provider.dart';
import 'package:greyfundr/features/shared/bottom_nav.dart';
import 'package:greyfundr/features/shared/bottom_sheets.dart';
import 'package:greyfundr/services/user_local_storage_service.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';

import 'package:provider/provider.dart';

class SignInWithPinScreen extends StatefulWidget {
  const SignInWithPinScreen({super.key});

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
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authProvider?.disposePin();
    });
    super.dispose();
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
                          CustomNetworkImage(imageUrl: "imageUrl", radius: 40),
                          Gap(10),
        
                          Text(
                            '${user?.firstName ?? ""} ${user?.lastName ?? ""}',
                            style: txStyle27Bold.copyWith(color: appPrimaryColor),
                          ),
                          Gap(50),
                          PinCodeText(pin: authProvider.newPin),
                          Spacer(),
                          NumPad(
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
                                    BottomNav(),
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
                                  userName: "${user?.firstName ?? ""}",
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
