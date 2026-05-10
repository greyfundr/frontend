import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_ontap.dart';
import 'package:greyfundr/core/providers/campaign_provider.dart';
import 'package:greyfundr/features/campaign/createcampaignflow/create_campaign.dart';
import 'package:greyfundr/features/fundpool/fund_pool_screen.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:provider/provider.dart';

class CampaignOptionScreen extends StatefulWidget {
  const CampaignOptionScreen({super.key});

  @override
  State<CampaignOptionScreen> createState() => _CampaignOptionScreenState();
}

class _CampaignOptionScreenState extends State<CampaignOptionScreen> {
  CampaignProvider? _campaignProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _campaignProvider ??= Provider.of<CampaignProvider>(
      context,
      listen: false,
    );
  }

  @override
  void dispose() {
    _campaignProvider?.clearAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Start A Campaign',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
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
              Text(
                'Who are you starting this Campaign for?',
                style: txStyle12.copyWith(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(24),
              _buildOptionCard(
                iconPath: 'assets/images/personal.png',
                iconBg: const Color(0xFFE3F2FD),
                title: 'Yourself',
                description:
                    'Set up a fundraising campaign for your own cause, goal, or project. Share your story and let others support you',
                onTap: () => Get.to(
                  () => const CampaignScreen(),
                  transition: Transition.rightToLeft,
                ),
              ),
              const Gap(16),
              _buildOptionCard(
                iconPath: 'assets/images/porsh.png',
                iconBg: const Color(0xFFE1F5FE),
                title: 'Someone else/Group',
                description:
                    'Launch a campaign on behalf of a person or group you care about. Explain their need and why you’re fundraising for them.',
                onTap: () => Get.to(
                  () => const FundPoolScreen(),
                  transition: Transition.rightToLeft,
                ),
              ),
              const Gap(32),
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
    return CustomOnTap(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: txStyle14.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(6),
                    Text(
                      description,
                      style: txStyle12.copyWith(
                        color: Colors.grey.shade700,
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
