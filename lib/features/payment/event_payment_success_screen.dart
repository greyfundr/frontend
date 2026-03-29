import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/features/bill/rsvp_details_screen.dart';
import 'package:greyfundr/features/event/event_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class EventPaymentSuccessScreen extends StatelessWidget {
  final String eventId;
  final String type;
  final double amount;

  const EventPaymentSuccessScreen({
    super.key,
    required this.eventId,
    required this.type,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/Success.json',
            height: 150,
            width: 150,
            repeat: false,
          ),
          const Gap(20),
          Text('Payment successful', style: txStyle30SemiBold),
          const Gap(10),
          Text(
            'You have successfully completed a ${type.toLowerCase()} payment of ${convertStringToCurrency(amount.toStringAsFixed(0))}.',
            style: txStyle14.copyWith(color: greyTextColor),
            textAlign: TextAlign.center,
          ),
          const Gap(20),
          CustomButton(
            onTap: () {
              eventProvider.getEventById(eventId);
              Get.close(1);
            },
            label: 'Proceed to Event Details',
          ),
        ],
      ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
    );
  }
}
