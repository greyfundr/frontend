import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:lottie/lottie.dart';

class PasswordChangeSuccessScreen extends StatelessWidget {
  const PasswordChangeSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset("assets/lottie/Success.json", height: 150, width: 150, repeat: false),

          Gap(20),
          Text("Password Changed", style: txStyle30SemiBold),
          Gap(10),
          Text(
            "Your password has been successfully changed. You can now use your new password to sign in.",
            style: txStyle14.copyWith(color: greyTextColor),
            textAlign: TextAlign.center,
          ),
          Gap(20),
          CustomButton(onTap: () {
            Get.close(1);
          }, label: "Proceed to Sign In"),
        ],
      ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
    );
  }
}
