import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_app_bar.dart';
import 'package:greyfundr/components/custom_ontap.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/core/models/user_profile_model.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/features/settings/didit_verification_screen.dart';
import 'package:greyfundr/features/settings/submit_bvn_screen.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
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
    var kycList = userProvider.userProfileModel?.kyc;
    var level1 = kycList?.firstWhere(
      (element) => element.name == "level_1",
      orElse: () => Kyc(),
    );
    var level2 = kycList?.firstWhere(
      (element) => element.name == "level_2",
      orElse: () => Kyc(),
    );

    return Scaffold(
      appBar: CustomAppBar(title: "Verification"),
      body: RefreshIndicator(
        onRefresh: () async {
          userProvider.fetchUserProfileApi();
        },
        child: ListView(
          children: [
            Gap(20),
            VerificationContainer(
              title: "Level 1",
              subtitle: "Basic Verification",
              status: level1?.status ?? "Not Started",
              onTap: () {
                Get.to(SubmitBvnScreen(), transition: Transition.rightToLeft);
              },
            ),
            Gap(15),
            VerificationContainer(
              title: "Level 2",
              subtitle: "Government ID Verification",
              status: level2?.status ?? "Not Started",
              onTap: () async {
                if (level1?.status != "verified") {
                  showErrorToast("Please complete Level 1 verification first.");
                  return;
                }
                if (level2?.status == "pending") {
                  showErrorToast(
                    "Verification in progress. Please wait for the outcome.",
                  );
                  return;
                }
                String url = await userProvider.createKycSession() ?? "";
                if (url.isEmpty) return;
                await Permission.camera.request();
                await Permission.microphone.request();
                Get.to(DiditVerificationScreen(sessionUrl: url));
              },
            ),
          ],
        ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
      ),
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

  ({Color containerColor, Color textColor}) _statusColors() {
    switch (status.trim().toLowerCase()) {
      case "pending":
        return (
          containerColor: const Color(0xFFFFF4E5),
          textColor: const Color(0xFFC77700),
        );
      case "verified":
        return (
          containerColor: const Color(0xFFE8F7EC),
          textColor: const Color(0xFF1E8E3E),
        );
      case "rejected":
        return (
          containerColor: const Color(0xFFFDECEC),
          textColor: const Color(0xFFD93025),
        );
      default:
        return (
          containerColor: appPrimaryColor.withOpacity(.1),
          textColor: appPrimaryColor,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColors = _statusColors();
    bool isVerified = status.trim().toLowerCase() == "verified";

    return CustomOnTap(
      onTap: isVerified
          ? () {}
          : () {
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
                color: statusColors.containerColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                capitalizeFirstText("$status"),
                style: txStyle12.copyWith(color: statusColors.textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
