import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/adaptive_icons.dart';
import 'package:greyfundr/components/custom_app_bar.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_num_pad.dart';
import 'package:greyfundr/features/auth/auth_provider.dart';
import 'package:greyfundr/features/shared/bottom_nav.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:provider/provider.dart';

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).disposePin();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xffD9F1F3),
      appBar: CustomAppBar(title: "", leading: SizedBox(),),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Row(
                        //   children: [
                        //     AdaptiveIcons(
                        //       iconName: ,
                        //       iconData: Icons.arrow_back_ios,
                        //       onTap: () {},
                        //     ),
                        //   ],
                        // ),
                        const Gap(20),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            'Create PIN',
                            style: txStyle32Bold.copyWith(
                              color: appPrimaryColor,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Enable faster sign in and transaction completion with PIN',
                            style: txStyle14,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Gap(64),
                        PinCodeText(pin: authProvider.newPin),
                        const Spacer(),
                        NumPad(
                          onValue: (value) {
                            authProvider.addToPin(value);
                          },
                          onDelete: () {
                            authProvider.deleteFromPin();
                          },
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: CustomButton(
                            enabled: authProvider.newPin.length == 6,
                            onTap: () async {
                              Get.to(
                                ConfirmPinScreen(),
                                transition: Transition.rightToLeft,
                              );
                            },
                            label: "Continue",
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
    );
  }
}

class ConfirmPinScreen extends StatefulWidget {
  const ConfirmPinScreen({super.key});

  @override
  State<ConfirmPinScreen> createState() => _ConfirmPinScreenState();
}

class _ConfirmPinScreenState extends State<ConfirmPinScreen> {
  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).disposePin();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xffD9F1F3),
      appBar: CustomAppBar(title: ""),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Row(
                        //   children: [
                        //     AdaptiveIcons(
                        //       iconName: ,
                        //       iconData: Icons.arrow_back_ios,
                        //       onTap: () {},
                        //     ),
                        //   ],
                        // ),
                        const Gap(20),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            'Confirm PIN',
                            style: txStyle32Bold.copyWith(
                              color: appPrimaryColor,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Please re-enter your PIN to confirm',
                            style: txStyle14,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Gap(64),
                        PinCodeText(pin: authProvider.confirmNewPin),
                        const Spacer(),
                        NumPad(
                          onValue: (value) {
                            authProvider.addToPin(value, isConfirm: true);
                          },
                          onDelete: () {
                            authProvider.deleteFromPin(isConfirm: true);
                          },
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: CustomButton(
                            enabled:
                                authProvider.newPin.length == 6 &&
                                authProvider.newPin ==
                                    authProvider.confirmNewPin,
                            onTap: () async {
                              bool res = await authProvider.createPin(
                                pin: authProvider.newPin,
                              );
                              if (res) {
                                Get.offAll(
                                  const BottomNav(),
                                  transition: Transition.rightToLeft,
                                );
                              }
                            },
                            label: "Confirm PIN",
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
    );
  }
}
