import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_app_bar.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_num_pad.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/features/auth/auth_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ChangePinOldScreen extends StatefulWidget {
  const ChangePinOldScreen({super.key});

  @override
  State<ChangePinOldScreen> createState() => _ChangePinOldScreenState();
}

class _ChangePinOldScreenState extends State<ChangePinOldScreen> {
  String oldPin = "";

  void addToPin(String value) {
    if (oldPin.length < 6) {
      setState(() => oldPin += value);
    }
    if (oldPin.length == 6) {
      Get.to(
        () => ChangePinNewScreen(oldPin: oldPin),
        transition: Transition.rightToLeft,
      );
    }
  }

  void deleteFromPin() {
    if (oldPin.isNotEmpty) {
      setState(() => oldPin = oldPin.substring(0, oldPin.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffD9F1F3),
      appBar: const CustomAppBar(title: "Change PIN"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const Gap(20),
                  Text(
                    'Enter Old PIN',
                    style: txStyle32Bold.copyWith(color: appPrimaryColor),
                  ),
                  const Gap(10),
                  Text(
                    'Please enter your current PIN to continue.',
                    style: txStyle14,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              PinCodeText(pin: oldPin),
              NumPad(onValue: addToPin, onDelete: deleteFromPin),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangePinNewScreen extends StatefulWidget {
  final String oldPin;
  const ChangePinNewScreen({super.key, required this.oldPin});

  @override
  State<ChangePinNewScreen> createState() => _ChangePinNewScreenState();
}

class _ChangePinNewScreenState extends State<ChangePinNewScreen> {
  String newPin = "";

  void addToPin(String value) {
    if (newPin.length < 6) {
      setState(() => newPin += value);
    }
    if (newPin.length == 6) {
      Get.to(
        () => ChangePinConfirmScreen(oldPin: widget.oldPin, newPin: newPin),
        transition: Transition.rightToLeft,
      );
    }
  }

  void deleteFromPin() {
    if (newPin.isNotEmpty) {
      setState(() => newPin = newPin.substring(0, newPin.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffD9F1F3),
      appBar: const CustomAppBar(title: ""),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const Gap(20),
                  Text(
                    'Create New PIN',
                    style: txStyle32Bold.copyWith(color: appPrimaryColor),
                  ),
                  const Gap(10),
                  Text(
                    'Enter a new 6-digit PIN.',
                    style: txStyle14,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              PinCodeText(pin: newPin),
              NumPad(onValue: addToPin, onDelete: deleteFromPin),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangePinConfirmScreen extends StatefulWidget {
  final String oldPin;
  final String newPin;
  const ChangePinConfirmScreen({
    super.key,
    required this.oldPin,
    required this.newPin,
  });

  @override
  State<ChangePinConfirmScreen> createState() => _ChangePinConfirmScreenState();
}

class _ChangePinConfirmScreenState extends State<ChangePinConfirmScreen> {
  String confirmPin = "";

  void addToPin(String value) {
    if (confirmPin.length < 6) {
      setState(() => confirmPin += value);
    }
  }

  void deleteFromPin() {
    if (confirmPin.isNotEmpty) {
      setState(
        () => confirmPin = confirmPin.substring(0, confirmPin.length - 1),
      );
    }
  }

  void handleSubmit() async {
    if (confirmPin != widget.newPin) {
      showErrorToast("New Pins do not match");
      return;
    }

    final provider = Provider.of<AuthProvider>(context, listen: false);
    bool success = await provider.changePin(
      currentPin: widget.oldPin,
      newPin: widget.newPin,
    );

    if (success) {
      // Pop 3 times to return to Settings then push success screen
      Get.close(3);
      Get.to(
        () => const PinChangeSuccessScreen(),
        transition: Transition.fadeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffD9F1F3),
      appBar: const CustomAppBar(title: ""),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const Gap(20),
                  Text(
                    'Confirm New PIN',
                    style: txStyle32Bold.copyWith(color: appPrimaryColor),
                  ),
                  const Gap(10),
                  Text(
                    'Re-enter your new 6-digit PIN to confirm.',
                    style: txStyle14,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              PinCodeText(pin: confirmPin),
              NumPad(onValue: addToPin, onDelete: deleteFromPin),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: CustomButton(
                  onTap: confirmPin.length == 6 ? handleSubmit : () {},
                  label: "Change Pin",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PinChangeSuccessScreen extends StatelessWidget {
  const PinChangeSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                "assets/lottie/Success.json",
                height: 150,
                width: 150,
                repeat: false,
              ),
              const Gap(20),
              Text("PIN Changed", style: txStyle30SemiBold),
              const Gap(10),
              Text(
                "Your PIN has been successfully changed. You can now use your new PIN to authorize transactions.",
                style: txStyle14.copyWith(color: greyTextColor),
                textAlign: TextAlign.center,
              ),
              const Gap(40),
              CustomButton(
                onTap: () {
                  Get.close(1);
                },
                label: "Okay",
              ),
            ],
          ),
        ),
      ),
    );
  }
}