import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/features/shared/bottom_nav.dart';
import 'package:greyfundr/core/providers/wallet_provider.dart';
import 'package:greyfundr/components/custom_app_bar.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_num_pad.dart';
import 'package:greyfundr/features/auth/auth_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:provider/provider.dart';

class CreateTransactionPinScreen extends StatefulWidget {
  const CreateTransactionPinScreen({super.key});

  @override
  State<CreateTransactionPinScreen> createState() =>
      _CreateTransactionPinScreenState();
}

class _CreateTransactionPinScreenState
    extends State<CreateTransactionPinScreen> {
  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AuthProvider>(context, listen: false).disposePin();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xffD9F1F3),
      appBar: const CustomAppBar(title: "", leading: SizedBox()),
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
                        const Gap(20),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            'Create Transaction PIN',
                            textAlign: TextAlign.center,
                            style: txStyle32Bold.copyWith(
                              color: appPrimaryColor,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Set a secure PIN to authorize your transactions',
                            style: txStyle14,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Gap(64),
                        PinCodeText(pin: authProvider.newPin, pinLength: 4, ),
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
                            enabled: authProvider.newPin.length == 4,
                            onTap: () async {
                              Get.to(
                                ConfirmTransactionPinScreen(),
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

class ConfirmTransactionPinScreen extends StatefulWidget {
  const ConfirmTransactionPinScreen({super.key});

  @override
  State<ConfirmTransactionPinScreen> createState() =>
      _ConfirmTransactionPinScreenState();
}

class _ConfirmTransactionPinScreenState
    extends State<ConfirmTransactionPinScreen> {
  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AuthProvider>(context, listen: false).disposePin();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xffD9F1F3),
      appBar: const CustomAppBar(title: ""),
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
                        const Gap(20),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            'Confirm Transaction PIN',
                            textAlign: TextAlign.center,
                            style: txStyle32Bold.copyWith(
                              color: appPrimaryColor,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Please re-enter your transaction PIN to confirm',
                            style: txStyle14,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Gap(64),
                        PinCodeText(pin: authProvider.confirmNewPin, pinLength: 4,),
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
                                authProvider.newPin.length == 4 &&
                                authProvider.newPin ==
                                    authProvider.confirmNewPin,
                            onTap: () async {
                              bool res = await walletProvider.setTransactionPin(
                                pin: authProvider.newPin,
                                confirmPin: authProvider.confirmNewPin,
                              );
                              if (res) {
                                // Refresh profile to reflect the changes
                                await userProvider.fetchUserProfileApi();
                                Get.offAll(
                                  () => const BottomNav(),
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
