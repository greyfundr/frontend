import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/features/auth/create_pin_screen.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:lottie/lottie.dart';

class SignupSuccessScreen extends StatelessWidget {
  final String name;
  const SignupSuccessScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffD9F1F3),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Gap(20),
            Text("Hi!", style: txStyle32Bold.copyWith(color: appPrimaryColor)),
            Text(name, style: txStyle30SemiBold),

            // Spacer(),
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
                "Welcome to",
                style: txStyle30SemiBold,
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                "GreyFundr",
                style: txStyle30SemiBold.copyWith(color: appPrimaryColor),
                textAlign: TextAlign.center,
              ),
            ),
            Gap(20),
            Spacer(),

            CustomButton(
              onTap: () {
                // Get.close(1);
                Get.offAll(
                  CreatePinScreen(),
                  transition: Transition.rightToLeft,
                );
              },
              label: "Set up PIN",
            ),
          ],
        ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
      ),
    );
  }
}
