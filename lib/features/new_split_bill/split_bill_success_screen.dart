import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/features/shared/bottom_nav.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:lottie/lottie.dart';

class SplitBillSuccessScreen extends StatelessWidget {
  final String title;
  const SplitBillSuccessScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffD9F1F3),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(20),
            Text("Success!", style: txStyle32Bold.copyWith(color: appPrimaryColor)),
            Text("Split bill created", style: txStyle30SemiBold),

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
                "Your split bill",
                style: txStyle30SemiBold.copyWith(fontSize: 25),
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                title,
                style: txStyle30SemiBold.copyWith(color: appPrimaryColor, fontSize: 25),
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              "has been created successfully",
              style: txStyle30SemiBold.copyWith(fontSize: 25),
              textAlign: TextAlign.center,
            ),
            Gap(20),
            Spacer(),

            CustomButton(
              onTap: () {
                Get.offAll(BottomNav());
               },
              label: "Go to Home",
            ),
            Gap(20)
          ],
        ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
      ),
    );
  }
}