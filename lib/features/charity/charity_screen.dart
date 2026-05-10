import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_network_image copy.dart';
import 'package:greyfundr/core/models/all_campaign_response_model.dart';
import 'package:greyfundr/features/campaign/createcampaignflow/campaign_details_screen.dart';
import 'package:greyfundr/features/charity/charity_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/responsiveState/responsive_state.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:greyfundr/widgets/campaigndetails/donation_bottom_sheet.dart';
import 'package:greyfundr/widgets/charity/tab_selector.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CharityComponent extends StatefulWidget {
  const CharityComponent({super.key});

  @override
  State<CharityComponent> createState() => _CharityComponentState();
}

class _CharityComponentState extends State<CharityComponent> {
  String selectedTab = 'Explore';
  final formatter = NumberFormat('#,##0');
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CharityProvider>(
        context,
        listen: false,
      ).getAllCampaigns(refresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        Provider.of<CharityProvider>(
          context,
          listen: false,
        ).loadMoreCampaigns();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CharityProvider>(context);

    return Column(
      children: [
        TabSelector(
          selectedTab: selectedTab,
          onTabChanged: (tab) => setState(() => selectedTab = tab),
        ),
        Expanded(
          child: RefreshIndicator(
            color: appPrimaryColor,
            onRefresh: () async {
              await provider.getAllCampaigns(refresh: true);
            },
            child: ResponsiveState(
              state: provider.campaignsState,
              busyWidget: UiBusyWidget(),
              noDataAvailableWidget: UiNoDataAvailableWidget(
                height: SizeConfig.heightOf(40),
                message: "No campaigns yet",
                subtitle: "Campaigns will show up here once available",
              ),
              successWidget: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: provider.campaigns.length,
                itemBuilder: (context, index) {
                  return _CampaignCard(
                    campaign: provider.campaigns[index],
                    formatter: formatter,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final CampaignDatum campaign;
  final NumberFormat formatter;

  const _CampaignCard({required this.campaign, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final target = (campaign.target ?? 0).toDouble();
    final current = (campaign.currentAmount ?? 0).toDouble();
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final percent = (progress * 100).round();

    final daysLeft = campaign.endDate?.difference(DateTime.now()).inDays;
    final timeLeft = (daysLeft ?? 0) > 0
        ? "$daysLeft Days left"
        : (daysLeft == 0 ? "Today" : "Ended");

    final imageUrl = (campaign.images?.isNotEmpty ?? false)
        ? (campaign.images!.first.imageUrl ?? '')
        : '';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final id = campaign.id;
        if (id == null || id.isEmpty) return;
        Get.to(
          () => CampaignDetailsScreen(campaignId: id),
          transition: Transition.rightToLeft,
        );
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image with days-left chip
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: CustomNetworkImageSqr(
                    imageUrl: imageUrl,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    padding: 0,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeLeft,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Donate button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        campaign.title ?? 'Untitled Campaign',
                        style: txStyle14SemiBold,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 110,
                      height: 35,
                      child: CustomButton(
                        onTap: () {
                          showCustomBottomSheet(
                            DonationBottomSheet(campaign: campaign),
                            context,
                          );
                        },
                        label: 'Donate',
                        backgroundColor: appPrimaryColor,
                        borderColor: appPrimaryColor,
                        height: 35,
                        fontSize: 14,
                        enabled: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Raised of target
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    children: [
                      TextSpan(
                        text: '₦${formatter.format(current)}',
                        style: const TextStyle(
                          color: appSecondaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(
                        text: ' raised of ',
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextSpan(
                        text: '₦${formatter.format(target)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Progress + percent
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: progress,
                          backgroundColor: appPrimaryColor.withValues(
                            alpha: 0.12,
                          ),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            appPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$percent%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Donors + Champions
                Row(
                  children: [
                    _IconStat(icon: Icons.groups_outlined, label: '${campaign.donorsCount} Donors'),
                    const SizedBox(width: 24),
                    _IconStat(
                      icon: Icons.shield_outlined,
                      label: '0 Champions',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _IconStat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _IconStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
