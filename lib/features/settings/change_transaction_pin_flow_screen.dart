import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_app_bar.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_num_pad.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/core/providers/wallet_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ChangeTransactionPinOldScreen extends StatefulWidget {
  const ChangeTransactionPinOldScreen({super.key});

  @override
  State<ChangeTransactionPinOldScreen> createState() =>
      _ChangeTransactionPinOldScreenState();
}

class _ChangeTransactionPinOldScreenState
    extends State<ChangeTransactionPinOldScreen> {
  String oldPin = "";

  void addToPin(String value) {
    if (oldPin.length < 4) {
      setState(() => oldPin += value);
    }
    if (oldPin.length == 4) {
      Get.to(
        () => ChangeTransactionPinNewScreen(oldPin: oldPin),
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
      appBar: const CustomAppBar(title: "Change Transaction PIN"),
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
                    'Please enter your current transaction PIN to continue.',
                    style: txStyle14,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              PinCodeText(pin: oldPin, pinLength: 4),
              NumPad(onValue: addToPin, onDelete: deleteFromPin),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangeTransactionPinNewScreen extends StatefulWidget {
  final String oldPin;
  const ChangeTransactionPinNewScreen({super.key, required this.oldPin});

  @override
  State<ChangeTransactionPinNewScreen> createState() =>
      _ChangeTransactionPinNewScreenState();
}

class _ChangeTransactionPinNewScreenState
    extends State<ChangeTransactionPinNewScreen> {
  String newPin = "";

  void addToPin(String value) {
    if (newPin.length < 4) {
      setState(() => newPin += value);
    }
    if (newPin.length == 4) {
      Get.to(
        () => ChangeTransactionPinConfirmScreen(
          oldPin: widget.oldPin,
          newPin: newPin,
        ),
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
                    'Enter a new 4-digit transaction PIN.',
                    style: txStyle14,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              PinCodeText(pin: newPin, pinLength: 4),
              NumPad(onValue: addToPin, onDelete: deleteFromPin),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangeTransactionPinConfirmScreen extends StatefulWidget {
  final String oldPin;
  final String newPin;
  const ChangeTransactionPinConfirmScreen({
    super.key,
    required this.oldPin,
    required this.newPin,
  });

  @override
  State<ChangeTransactionPinConfirmScreen> createState() =>
      _ChangeTransactionPinConfirmScreenState();
}

class _ChangeTransactionPinConfirmScreenState
    extends State<ChangeTransactionPinConfirmScreen> {
  String confirmPin = "";

  void addToPin(String value) {
    if (confirmPin.length < 4) {
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

    final provider = Provider.of<WalletProvider>(context, listen: false);
    bool success = await provider.changeTransactionPin(
      currentPin: widget.oldPin,
      newPin: widget.newPin,
      confirmPin: confirmPin,
    );

    if (success) {
      Get.close(3);
      Get.to(
        () => const TransactionPinChangeSuccessScreen(),
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
                    'Re-enter your new 4-digit transaction PIN to confirm.',
                    style: txStyle14,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              PinCodeText(pin: confirmPin, pinLength: 4),
              NumPad(onValue: addToPin, onDelete: deleteFromPin),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: CustomButton(
                  onTap: confirmPin.length == 4 ? handleSubmit : () {},
                  label: "Change PIN",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TransactionPinChangeSuccessScreen extends StatelessWidget {
  const TransactionPinChangeSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffD9F1F3),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(20),
            Text(
              "Success!",
              style: txStyle32Bold.copyWith(color: appPrimaryColor),
            ),
            Text("PIN Changed", style: txStyle30SemiBold),

            Gap(SizeConfig.heightOf(15)),
            Center(
              child: Lottie.asset(
                "assets/lottie/Success.json",
                height: 150,
                width: 150,
                repeat: false,
              ),
            ),
            Center(
              child: Text(
                "Your transaction PIN",
                style: txStyle30SemiBold.copyWith(fontSize: 25),
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                "has been changed",
                style: txStyle30SemiBold.copyWith(
                  color: appPrimaryColor,
                  fontSize: 25,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                "successfully",
                style: txStyle30SemiBold.copyWith(fontSize: 25),
                textAlign: TextAlign.center,
              ),
            ),
            const Gap(20),
            const Spacer(),

            CustomButton(
              onTap: () {
                Get.close(1);
              },
              label: "Okay",
            ),
            const Gap(20),
          ],
        ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
      ),
    );
  }
}
