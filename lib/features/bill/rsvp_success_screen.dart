import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/features/bill/rsvp_details_screen.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:lottie/lottie.dart';

class RsvpSuccessScreen extends StatelessWidget {
  final String eventName;
  final String nameUsedForRsvp;
  final String eventId;
  const RsvpSuccessScreen({
    super.key,
    required this.eventName,
    required this.nameUsedForRsvp,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            "assets/lottie/Success.json",
            height: 150,
            width: 150,
            repeat: false,
          ),

          Gap(20),
          Text("RSVP successful", style: txStyle30SemiBold),
          Gap(10),
          Text(
            "You have successfully RSVP'd to $eventName as $nameUsedForRsvp. We look forward to your participation!",
            style: txStyle14.copyWith(color: greyTextColor),
            textAlign: TextAlign.center,
          ),
          Gap(20),
          CustomButton(
            onTap: () {
              Get.close(1);
              Get.off(
                RsvpDetailsScreen(eventId: eventId),
                transition: Transition.rightToLeft,
              );
            },
            label: "Proceed to Event Details",
          ),
        ],
      ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
    );
  }
}
