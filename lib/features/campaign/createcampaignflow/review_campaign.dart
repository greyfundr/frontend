import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_network_image.dart';
import 'package:greyfundr/core/models/budget_model.dart';
import 'package:greyfundr/core/models/participants_model.dart';
import 'package:greyfundr/core/providers/campaign_provider.dart';
import 'package:greyfundr/features/campaign/createcampaignflow/campaign_success_screen.dart';
import 'package:greyfundr/services/user_local_storage_service.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/responsiveState/view_state.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReviewCampaignScreen extends StatefulWidget {
  const ReviewCampaignScreen({super.key});

  @override
  State<ReviewCampaignScreen> createState() => _ReviewCampaignScreenState();
}

class _ReviewCampaignScreenState extends State<ReviewCampaignScreen> {
  String selectedTab = 'ABOUT';
  final NumberFormat _money = NumberFormat('#,##0.00');
  int _heroPage = 0;
  late final PageController _heroController;

  @override
  void initState() {
    super.initState();
    _heroController = PageController();
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  Future<void> _submit(CampaignProvider provider) async {
    final userId = UserLocalStorageService().getUserData()?.id;
    if (userId == null) return;
    try {
      await provider.submitCampaign(userId);
      if (!mounted) return;
      final id = provider.createdCampaignId;
      if (id == null || id.isEmpty) return;
      Get.off(
        () => CampaignSuccessScreen(
          title: provider.titleController.text.trim(),
          campaignId: id,
        ),
        transition: Transition.rightToLeft,
      );
    } catch (_) {
      // toast surfaced by provider
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampaignProvider>(context);
    final amount =
        double.tryParse(provider.amountController.text.replaceAll(',', '')) ??
            0;
    final images = provider.selectedImages;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(images),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.titleController.text.trim().isEmpty
                          ? 'Untitled Campaign'
                          : provider.titleController.text.trim(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Gap(12),
                    if (provider.selectedCategory != null) ...[
                      _categoryChip(provider.selectedCategory!),
                      const Gap(14),
                    ],
                    _amountAndDates(provider, amount),
                    const Gap(20),
                    _statusCard(amount),
                    const Gap(22),
                    _buildTabBar(provider),
                    const Gap(16),
                    _buildTabContent(provider),
                    const Gap(20),
                    _actionButtons(provider),
                    const Gap(28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Hero Section ───────────────────────────────────────────
  Widget _buildHero(List<File> images) {
    final height = SizeConfig.heightOf(35);
    return Stack(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: images.isEmpty
              ? Container(
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                )
              : PageView.builder(
                  controller: _heroController,
                  itemCount: images.length,
                  onPageChanged: (i) => setState(() => _heroPage = i),
                  itemBuilder: (context, i) => Image.file(
                    images[i],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
        ),
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.6),
                Colors.white,
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.widthOf(4),
              vertical: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleAction(
                  icon: Icons.arrow_back,
                  onTap: () => Get.back(),
                ),
                _circleAction(
                  icon: Icons.edit_outlined,
                  onTap: () => Get.back(),
                ),
              ],
            ),
          ),
        ),
        if (images.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                final active = i == _heroPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? appPrimaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _circleAction({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
    );
  }

  // ─── Category Chip ──────────────────────────────────────────
  Widget _categoryChip(Map<String, String> category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: appPrimaryColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            category['icon'] ?? '',
            width: 16,
            height: 16,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.category_outlined,
              size: 14,
              color: appPrimaryColor,
            ),
          ),
          const Gap(6),
          Text(
            category['label'] ?? '',
            style: txStyle12.copyWith(
              fontWeight: FontWeight.w600,
              color: appPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Amount + Dates ─────────────────────────────────────────
  Widget _amountAndDates(CampaignProvider provider, double amount) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              '₦${_money.format(amount)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: appPrimaryColor,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Runs',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              provider.startDate != null && provider.endDate != null
                  ? '${dateFormat.format(provider.startDate!)} → ${dateFormat.format(provider.endDate!)}'
                  : 'N/A',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Pre-submit status card ─────────────────────────────────
  Widget _statusCard(double amount) {
    final budgetTotal = Provider.of<CampaignProvider>(context).totalExpenses;
    final breakdown = budgetTotal > 0
        ? '₦${_money.format(budgetTotal)} budgeted of ₦${_money.format(amount)}'
        : 'No budget items added';
    final budgetRatio = amount > 0
        ? (budgetTotal / amount).clamp(0.0, 1.0)
        : 0.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            appPrimaryColor.withValues(alpha: 0.16),
            appPrimaryColor.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: appPrimaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Budget Coverage',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${(budgetRatio * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: appPrimaryColor,
                ),
              ),
            ],
          ),
          const Gap(10),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: budgetRatio,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(appPrimaryColor),
            ),
          ),
          const Gap(10),
          Text(
            breakdown,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ─── Tabs ───────────────────────────────────────────────────
  Widget _buildTabBar(CampaignProvider provider) {
    final tabs = ['ABOUT', 'BUDGET', 'TEAM', 'OFFERS'];
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: tabs.map((tab) {
          final isSelected = selectedTab == tab;
          int? badge;
          if (tab == 'TEAM') badge = provider.selectedTeamMembers.length;
          if (tab == 'BUDGET') badge = provider.expenses.length;
          if (tab == 'OFFERS') badge = provider.offersCount;
          return GestureDetector(
            onTap: () => setState(() => selectedTab = tab),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                padding: EdgeInsets.all(isSelected ? 4 : 0),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xff8e96a399) : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tab,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                    ),
                    if (badge != null && badge > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(CampaignProvider provider) {
    switch (selectedTab) {
      case 'ABOUT':
        return _aboutTab(provider);
      case 'BUDGET':
        return _budgetTab(provider);
      case 'TEAM':
        return _teamTab(provider);
      case 'OFFERS':
        return _offersTab(provider);
      default:
        return const SizedBox();
    }
  }

  Widget _aboutTab(CampaignProvider provider) {
    final desc = provider.descriptionController.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: txStyle13.copyWith(fontWeight: FontWeight.w700),
        ),
        const Gap(8),
        Text(
          desc.isEmpty ? 'No description provided' : desc,
          style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5),
        ),
        const Gap(20),
        _infoRow(
          'Category',
          provider.selectedCategory?['label'] ?? 'N/A',
        ),
        _infoRow(
          'Images',
          '${provider.selectedImages.length} attached',
        ),
        _infoRow('Team', '${provider.selectedTeamMembers.length} member(s)'),
        _infoRow('Status', 'Pending approval'),
      ],
    );
  }

  Widget _budgetTab(CampaignProvider provider) {
    if (provider.expenses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'No budget items added',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...provider.expenses.map((e) => _budgetRow(e)),
        const Gap(8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: appPrimaryColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: txStyle13.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '₦${_money.format(provider.totalExpenses)}',
                style: txStyle14.copyWith(
                  fontWeight: FontWeight.w700,
                  color: appPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _budgetRow(Expense e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 18,
            color: appPrimaryColor,
          ),
          const Gap(10),
          Expanded(
            child: Text(
              e.name,
              style: txStyle13.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '₦${_money.format(e.cost)}',
            style: txStyle13.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _teamTab(CampaignProvider provider) {
    if (provider.selectedTeamMembers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'No team members added',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }
    return Column(
      children: provider.selectedTeamMembers
          .map((p) => _teamRow(p))
          .toList(),
    );
  }

  Widget _teamRow(Participant p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (p.imageUrl.isNotEmpty)
            CustomNetworkImage(imageUrl: p.imageUrl, radius: 38)
          else
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: appPrimaryColor.withValues(alpha: 0.12),
              ),
              alignment: Alignment.center,
              child: Text(
                (p.name.isNotEmpty ? p.name[0] : '?').toUpperCase(),
                style: txStyle13.copyWith(
                  fontWeight: FontWeight.bold,
                  color: appPrimaryColor,
                ),
              ),
            ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name.isEmpty ? p.username : p.name,
                  style: txStyle13.copyWith(fontWeight: FontWeight.w600),
                ),
                if (p.username.isNotEmpty)
                  Text(
                    '@${p.username}',
                    style: txStyle12.copyWith(color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: appPrimaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              p.role,
              style: txStyle12.copyWith(
                color: appPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _offersTab(CampaignProvider provider) {
    if (provider.offersCount == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'No offers added',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (provider.autoOffers.isNotEmpty) ...[
          Text(
            'Auto Offers',
            style: txStyle13.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(8),
          ...provider.autoOffers.map((o) => _offerRow(o)),
          const Gap(12),
        ],
        if (provider.manualOffers.isNotEmpty) ...[
          Text(
            'Manual Offers',
            style: txStyle13.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(8),
          ...provider.manualOffers.map((o) => _offerRow(o)),
        ],
      ],
    );
  }

  Widget _offerRow(Map<String, String> o) {
    final condition = o['condition'] ?? '';
    final reward = o['reward'] ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.card_giftcard_outlined,
            size: 18,
            color: appPrimaryColor,
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (condition.isNotEmpty)
                  Text(
                    condition,
                    style: txStyle13.copyWith(fontWeight: FontWeight.w600),
                  ),
                if (reward.isNotEmpty)
                  Text(
                    reward,
                    style: txStyle12.copyWith(color: Colors.grey[700]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Action Buttons ─────────────────────────────────────────
  Widget _actionButtons(CampaignProvider provider) {
    final isSubmitting = provider.submitState == ViewState.Busy;
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            label: 'Edit',
            backgroundColor: appSecondaryColor,
            borderColor: appSecondaryColor,
            height: 45,
            onTap: () => Get.back(),
          ),
        ),
        const Gap(10),
        Expanded(
          child: CustomButton(
            label: 'Submit',
            height: 45,
            loading: isSubmitting,
            enabled: !isSubmitting,
            onTap: () => _submit(provider),
          ),
        ),
      ],
    );
  }
}
