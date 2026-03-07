import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/components/custom_ontap.dart';

import 'package:greyfundr/features/splitbill/split_bill_screen.dart';
import 'package:greyfundr/features/fundpool/fund_pool_screen.dart';
import 'package:greyfundr/features/invoice/invoice_screen.dart';
import 'package:greyfundr/features/event/event_screen.dart';
import 'package:greyfundr/features/giveaway/give_away_screen.dart';
import 'package:greyfundr/features/campaign/campaign_option_screen.dart';

class CreateNewScreen extends StatelessWidget {
  const CreateNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC), // light bg like many fintech apps
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Create New',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.widthOf(5),
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intro text
              Text(
                'Start something new — just fill in a few details to get going.',
                style: txStyle12?.copyWith(   // adjust to your actual small text style
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Gap(24),

              // Cards
              _buildOptionCard(
                iconPath: 'assets/images/split.png',
                iconBg: const Color(0xFFE3F2FD),
                title: 'Split A Bill',
                description: 'Enter the bill amount and choose how to split it with others.',
                onTap: () => Get.to(
                  () => SplitBillScreen(),
                  transition: Transition.rightToLeft,
                ),
              ),
              Gap(16),

              _buildOptionCard(
                iconPath: 'assets/images/porsh.png',
                iconBg: const Color(0xFFE1F5FE),
                title: 'Start A Fund Pool',
                description: 'Pool money together with friends, community or the public.',
                onTap: () => Get.to(
                  () => const FundPoolScreen(),
                  transition: Transition.rightToLeft,
                ),
              ),
              Gap(16),

              _buildOptionCard(
                iconPath: 'assets/images/porsh.png',
                iconBg: const Color(0xFFE1F5FE),
                title: 'Create An Invoice',
                description: 'Create a detailed invoice for your records or clients.',
                onTap: () => Get.to(
                  () => const InvoiceScreen(),
                  transition: Transition.rightToLeft,
                ),
              ),
              Gap(16),

              _buildOptionCard(
                iconPath: 'assets/images/giveaway.png',
                iconBg: const Color(0xFFFFEBEE),
                title: 'Start A Campaign',
                description: 'Set up your campaign, tell your story, and raise funds.',
                onTap: () => Get.to(
                  () => const CampaignOptionScreen(),
                  transition: Transition.rightToLeft,
                ),
              ),
              Gap(16),

              _buildOptionCard(
                iconPath: 'assets/images/giveaway.png',
                iconBg: const Color(0xFFFFEBEE),
                title: 'Create An Event',
                description: 'Create an event and let guests donate toward your goal.',
                onTap: () => Get.to(
                  () => EventScreen(),
                  transition: Transition.rightToLeft,
                ),
              ),
              Gap(16),

              _buildOptionCard(
                iconPath: 'assets/images/giveaway.png',
                iconBg: const Color(0xFFFFEBEE),
                title: 'Start A Giveaway',
                description: 'Set up a giveaway to thank supporters or engage your community.',
               onTap: () => Get.to(
                  () => GiveAwayScreen(),
                  transition: Transition.rightToLeft,
                ),
              ),

              Gap(32), // breathing room at bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String iconPath,
    required Color iconBg,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return CustomOnTap(                       // ← using your app's tap component
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Image.asset(
                    iconPath,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: txStyle14SemiBold?.copyWith(   // adjust to your semi-bold style
                        color: Colors.black87,
                      ) ?? const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Gap(6),
                    Text(
                      description,
                      style: txStyle12?.copyWith(          // small descriptive text
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ) ?? const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}