import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
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
  bool isConfirming = false;
  String firstPin = "";

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
      appBar: AppBar(elevation: 0, backgroundColor: const Color(0xffD9F1F3)),
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
                        const Gap(0),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            isConfirming ? 'Confirm PIN' : 'Create PIN',
                            style: txStyle32Bold.copyWith(
                              color: appPrimaryColor,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            isConfirming
                                ? 'Please re-enter your PIN to confirm'
                                : 'Enable faster sign in and transaction completion with PIN',
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
                              if (!isConfirming) {
                                setState(() {
                                  firstPin = authProvider.newPin;
                                  isConfirming = true;
                                });
                                authProvider.disposePin();
                              } else {
                                if (authProvider.newPin == firstPin) {
                                  bool res = await authProvider.createPin(
                                    pin: authProvider.newPin,
                                  );
                                  if (res) {
                                    Get.offAll(
                                      const BottomNav(),
                                      transition: Transition.rightToLeft,
                                    );
                                  }
                                } else {
                                  Get.snackbar(
                                    "Error",
                                    "PINs do not match",
                                    backgroundColor: Colors.red.withOpacity(
                                      0.7,
                                    ),
                                    colorText: Colors.white,
                                    margin: const EdgeInsets.all(15),
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  authProvider.disposePin();
                                  setState(() {
                                    isConfirming = false;
                                    firstPin = "";
                                  });
                                }
                              }
                            },
                            label: isConfirming ? "Confirm PIN" : "Continue",
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
