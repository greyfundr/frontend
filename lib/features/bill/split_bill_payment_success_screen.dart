import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/features/new_split_bill/split_bill_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class SplitBillPaymentSuccessScreen extends StatelessWidget {
  final double amount;

  const SplitBillPaymentSuccessScreen({
    super.key,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NewSplitBillProvider>(context, listen: false);
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
            'You have successfully paid your split bill share of ${convertStringToCurrency(amount.toStringAsFixed(0))}.',
            style: txStyle14.copyWith(color: greyTextColor),
            textAlign: TextAlign.center,
          ),
          const Gap(20),
          CustomButton(
            onTap: () {
              provider.getMySplitBills();
              provider.getSplitBillInvites();
              Get.close(1);
            },
            label: 'Back to Bills',
          ),
        ],
      ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
    );
  }
}
