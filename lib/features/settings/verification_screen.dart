import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_app_bar.dart';
import 'package:greyfundr/components/custom_ontap.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/features/settings/didit_verification_screen.dart';
import 'package:greyfundr/features/settings/submit_bvn_screen.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: CustomAppBar(title: "Verification"),
      body: Column(
        children: [
          Gap(20),
          VerificationContainer(
            title: "Level 1",
            subtitle: "Basic Verification",
            status: "Verified",
            onTap: () {
              Get.to(SubmitBvnScreen(), transition: Transition.rightToLeft);
            },
          ),
          Gap(15),
          VerificationContainer(
            title: "Level 2",
            subtitle: "Government ID Verification",
            status: "Unverified",
            onTap: () async {
              String url = await userProvider.createKycSession() ?? "";
              if (url.isEmpty) return;
              await Permission.camera.request(); 
              await Permission.microphone.request();
              Get.to(DiditVerificationScreen(sessionUrl: url));
            },
          ),
        ],
      ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
    );
  }
}

class VerificationContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final VoidCallback onTap;
  const VerificationContainer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomOnTap(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$title", style: txStyle20SemiBold),
                  Text(
                    "${subtitle}",
                    style: txStyle12.copyWith(color: greyTextColor),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: appPrimaryColor.withOpacity(.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "$status",
                style: txStyle12.copyWith(color: appPrimaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
