import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/features/campaign/createcampaignflow/campaignapproval.dart';
import 'package:greyfundr/features/shared/bottom_nav.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:lottie/lottie.dart';

class CampaignSuccessScreen extends StatelessWidget {
  final String title;
  final String campaignId;

  const CampaignSuccessScreen({
    super.key,
    required this.title,
    required this.campaignId,
  });

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
            Text("Campaign submitted", style: txStyle30SemiBold),
            Gap(SizeConfig.heightOf(12)),
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
                "Your campaign",
                style: txStyle30SemiBold.copyWith(fontSize: 25),
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                title,
                style: txStyle30SemiBold.copyWith(
                  color: appPrimaryColor,
                  fontSize: 25,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              "has been submitted for approval",
              style: txStyle30SemiBold.copyWith(fontSize: 25),
              textAlign: TextAlign.center,
            ),
            const Gap(20),
            const Spacer(),
            CustomButton(
              onTap: () => Get.off(
                () => CampaignApprovalPage(
                  campaignId: campaignId,
                  shareTitle: title,
                ),
                transition: Transition.rightToLeft,
              ),
              label: "View Approval Status",
            ),
            const Gap(12),
            CustomButton(
              onTap: () => Get.offAll(() => const BottomNav()),
              label: "Go to Home",
              backgroundColor: Colors.white,
              borderColor: appPrimaryColor,
              color: appPrimaryColor,
            ),
            const Gap(20),
          ],
        ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
      ),
    );
  }
}
