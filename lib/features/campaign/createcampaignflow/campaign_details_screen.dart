import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_network_image.dart';
import 'package:greyfundr/components/custom_network_image%20copy.dart';
import 'package:greyfundr/core/models/all_campaign_response_model.dart'
    as acm;
import 'package:greyfundr/core/models/campaign_details_model.dart' as cd;
import 'package:greyfundr/core/models/campaign_donations_response_model.dart';
import 'package:greyfundr/core/models/top_donors_response_model.dart';
import 'package:greyfundr/core/providers/campaign_provider.dart';
import 'package:greyfundr/widgets/campaigndetails/campaign_comments_view.dart';
import 'package:greyfundr/widgets/campaigndetails/donation_bottom_sheet.dart';
import 'package:greyfundr/core/providers/socket_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/responsiveState/responsive_state.dart';
import 'package:greyfundr/shared/responsiveState/view_state.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class CampaignDetailsScreen extends StatefulWidget {
  final String campaignId;

  const CampaignDetailsScreen({super.key, required this.campaignId});

  @override
  State<CampaignDetailsScreen> createState() => _CampaignDetailsScreenState();
}

class _CampaignDetailsScreenState extends State<CampaignDetailsScreen> {
  String selectedTab = 'ABOUT';
  String donorsSubTab = 'ALL';
  String financingSubTab = 'BUDGET';
  final NumberFormat _money = NumberFormat('#,##0.00');
  final PageController _heroController = PageController();
  final ScrollController _scrollController = ScrollController();
  int _heroPage = 0;

  SocketProvider? _socketProvider;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final campaignProvider = Provider.of<CampaignProvider>(
        context,
        listen: false,
      );
      campaignProvider.fetchCampaignDetails(widget.campaignId);
      _socketProvider = Provider.of<SocketProvider>(context, listen: false);
      _socketProvider?.subscribe('campaign', widget.campaignId, () {
        campaignProvider.fetchCampaignDetails(
          widget.campaignId,
          force: true,
        );
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _heroController.dispose();
    _socketProvider?.unsubscribe('campaign', widget.campaignId);
    super.dispose();
  }

  void _onScroll() {
    if (selectedTab != 'DONORS' || donorsSubTab != 'ALL') return;
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      final provider = Provider.of<CampaignProvider>(context, listen: false);
      if (provider.hasMoreDonations) {
        provider.fetchMoreDonations(widget.campaignId);
      }
    }
  }

  void _openDonationSheet(cd.CampaignDetailsModel model) {
    final datum = acm.CampaignDatum(
      id: model.id,
      title: model.title,
      description: model.description,
      target: model.target,
      currentAmount: model.currentAmount,
      startDate: model.startDate,
      endDate: model.endDate,
      shareSlug: model.shareSlug,
      shareUrl: model.shareUrl,
      createdAt: model.createdAt,
      creator: model.creator == null
          ? null
          : acm.Creator(
              id: model.creator!.id,
              firstName: model.creator!.firstName,
              lastName: model.creator!.lastName,
              username: model.creator!.username,
              profileImage: model.creator!.profileImage,
            ),
    );
    showCustomBottomSheet(
      DonationBottomSheet(campaign: datum),
      context,
    );
  }

  Future<void> _shareCampaign(cd.CampaignDetailsModel model) async {
    final url = (model.shareUrl ?? '').trim();
    if (url.isEmpty) return;
    final title = (model.title ?? '').trim();
    final text = title.isEmpty
        ? 'Check out this campaign on Greyfundr! $url'
        : 'Check out "$title" on Greyfundr! $url';
    await SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampaignProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveState(
        state: provider.campaignDetailsState,
        busyWidget: const UiBusyWidget(),
        errorWidget: UiErrorWidget(
          onRetry: () => provider.fetchCampaignDetails(
            widget.campaignId,
            force: true,
          ),
        ),
        successWidget: SafeArea(
          top: false,
          child: _buildContent(provider.campaignDetails),
        ),
      ),
    );
  }

  Widget _buildContent(cd.CampaignDetailsModel? model) {
    if (model == null) {
      return const Center(child: Text('No campaign details'));
    }
    final target = (model.target ?? 0).toDouble();
    final current = (model.currentAmount ?? 0).toDouble();

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHero(model),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (model.title ?? '').isEmpty
                      ? 'Untitled Campaign'
                      : model.title!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Gap(12),
                if ((model.status ?? '').isNotEmpty) _statusChip(model.status!),
                const Gap(14),
                _amountAndDates(model, target),
                if (model.creator != null) ...[
                  const Gap(20),
                  _creatorRow(model.creator!),
                ],
                const Gap(20),
                _progressCard(target, current),
                const Gap(22),
                _organizersStrip(model),
                _buildTabBar(model),
                const Gap(16),
                _buildTabContent(model),
                const Gap(20),
                _bottomActions(model),
                const Gap(28),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Hero ───────────────────────────────────────────────────
  Widget _buildHero(cd.CampaignDetailsModel model) {
    final height = SizeConfig.heightOf(35);
    final urls = (model.images ?? [])
        .map((i) => i.imageUrl ?? '')
        .where((u) => u.isNotEmpty)
        .toList();

    return Stack(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: urls.isEmpty
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
                  itemCount: urls.length,
                  onPageChanged: (i) => setState(() => _heroPage = i),
                  itemBuilder: (context, i) => CustomNetworkImageSqr(
                    imageUrl: urls[i],
                    height: height,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    padding: 0,
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
                Row(
                  children: [
                    _loveAction(model),
                    if ((model.shareUrl ?? '').isNotEmpty) ...[
                      const Gap(8),
                      _circleAction(
                        icon: Icons.ios_share_rounded,
                        onTap: () => _shareCampaign(model),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        if (urls.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(urls.length, (i) {
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

  Widget _loveAction(cd.CampaignDetailsModel model) {
    final isLiked = model.isLiked ?? false;
    final count = model.likesCount ?? 0;
    return GestureDetector(
      onTap: () {
        final id = model.id;
        if (id == null || id.isEmpty) return;
        Provider.of<CampaignProvider>(context, listen: false)
            .toggleCampaignLike(id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        padding: EdgeInsets.symmetric(
          horizontal: count > 0 ? 12 : 0,
        ),
        constraints: BoxConstraints(minWidth: count > 0 ? 0 : 40),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                key: ValueKey<bool>(isLiked),
                color: isLiked ? const Color(0xFFE53E3E) : Colors.black87,
                size: 20,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Text(
                _formatLikeCount(count),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isLiked
                      ? const Color(0xFFE53E3E)
                      : Colors.black87,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatLikeCount(int n) {
    if (n < 1000) return '$n';
    if (n < 1000000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    return '${(n / 1000000).toStringAsFixed(1)}m';
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

  Widget _statusChip(String status) {
    final lower = status.toLowerCase();
    Color bg;
    Color fg;
    if (lower.contains('live') || lower.contains('approved')) {
      bg = const Color(0xFFE6F4EA);
      fg = const Color(0xFF188038);
    } else if (lower.contains('pending')) {
      bg = const Color(0xFFFFF4E5);
      fg = const Color(0xFFB76E00);
    } else if (lower.contains('reject') || lower.contains('cancel')) {
      bg = const Color(0xFFFCE8E6);
      fg = const Color(0xFFC5221F);
    } else {
      bg = appPrimaryColor.withValues(alpha: 0.10);
      fg = appPrimaryColor;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: txStyle12.copyWith(fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Widget _amountAndDates(cd.CampaignDetailsModel model, double target) {
    final fmt = DateFormat('MMM dd, yyyy');
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
              '₦${_money.format(target)}',
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
              model.startDate != null && model.endDate != null
                  ? '${fmt.format(model.startDate!)} → ${fmt.format(model.endDate!)}'
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

  Widget _creatorRow(cd.Creator creator) {
    final name =
        '${creator.firstName ?? ''} ${creator.lastName ?? ''}'.trim().isEmpty
            ? (creator.username ?? 'Creator')
            : '${creator.firstName ?? ''} ${creator.lastName ?? ''}'.trim();
    return Row(
      children: [
        if ((creator.profileImage ?? '').isNotEmpty)
          CustomNetworkImage(imageUrl: creator.profileImage!, radius: 40)
        else
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: appPrimaryColor.withValues(alpha: 0.10),
            ),
            alignment: Alignment.center,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'C',
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
                'Created By',
                style: txStyle11.copyWith(color: Colors.grey),
              ),
              Text(
                name,
                style: txStyle13.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _progressCard(double target, double current) {
    final ratio = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
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
                'Amount Raised',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${(ratio * 100).toStringAsFixed(0)}%',
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
              value: ratio,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(appPrimaryColor),
            ),
          ),
          const Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Raised: ₦${_money.format(current)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Target: ₦${_money.format(target)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Tabs ───────────────────────────────────────────────────
  Widget _buildTabBar(cd.CampaignDetailsModel model) {
    final tabs = [
      'ABOUT',
      'FINANCING',
      'OFFERS',
      'DONATIONS',
      'COMMENTS',
    ];
    final provider = Provider.of<CampaignProvider>(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: tabs.map((tab) {
            final isSelected = selectedTab == tab;
            int? badge;
            if (tab == 'FINANCING') badge = model.budget?.length ?? 0;
            if (tab == 'OFFERS') badge = model.offers?.length ?? 0;
            if (tab == 'DONATIONS') {
              badge = provider.donationsPagination?.total ??
                  provider.donations.length;
            }
            if (tab == 'COMMENTS') {
              badge = provider.comments.isNotEmpty
                  ? provider.comments.length
                  : (model.commentsCount ?? 0);
            }
            return GestureDetector(
              onTap: () => _onTabSelected(tab),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color:
                              isSelected ? Colors.white : Colors.grey[600],
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
      ),
    );
  }

  void _onTabSelected(String tab) {
    setState(() => selectedTab = tab);
    final provider = Provider.of<CampaignProvider>(context, listen: false);
    if (tab == 'DONATIONS') {
      provider.fetchCampaignDonations(widget.campaignId);
    } else if (tab == 'COMMENTS') {
      provider.fetchCampaignComments(widget.campaignId);
    }
  }

  Widget _buildTabContent(cd.CampaignDetailsModel model) {
    switch (selectedTab) {
      case 'ABOUT':
        return _aboutTab(model);
      case 'FINANCING':
        return _financingTab(model);
      case 'OFFERS':
        return _offersTab(model);
      case 'DONATIONS':
        return _donorsTab();
      case 'COMMENTS':
        return CampaignCommentsView(campaignId: widget.campaignId);
      default:
        return const SizedBox();
    }
  }

  Widget _aboutTab(cd.CampaignDetailsModel model) {
    final desc = (model.description ?? '').trim();
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
        _infoRow('Status', model.status ?? 'N/A'),
        _infoRow('Images', '${model.images?.length ?? 0} attached'),
        _infoRow('Organizers', '${model.participants?.length ?? 0} member(s)'),
        _infoRow(
          'Likes',
          '${model.likesCount ?? 0}',
        ),
        _infoRow(
          'Comments',
          '${model.commentsCount ?? 0}',
        ),
      ],
    );
  }

  Widget _financingTab(cd.CampaignDetailsModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _financingSubTabBar(),
        const Gap(14),
        if (financingSubTab == 'BUDGET')
          _budgetTab(model)
        else
          _expenditureTab(),
      ],
    );
  }

  Widget _financingSubTabBar() {
    const subTabs = [
      {'key': 'BUDGET', 'label': 'Budget'},
      {'key': 'EXPENDITURE', 'label': 'Expenditure'},
    ];
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: subTabs.map((t) {
          final key = t['key']!;
          final label = t['label']!;
          final isSelected = financingSubTab == key;
          return GestureDetector(
            onTap: () => setState(() => financingSubTab = key),
            child: Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          isSelected ? appPrimaryColor : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? appPrimaryColor : Colors.grey[700],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _expenditureTab() {
    return UiNoDataAvailableWidget(
      height: SizeConfig.heightOf(40),
      message: 'Expenditure tracking is coming soon',
      subtitle:
          'Soon you\'ll be able to see how each campaign\'s funds are being spent.',
    );
  }

  Widget _budgetTab(cd.CampaignDetailsModel model) {
    final budget = model.budget ?? [];
    if (budget.isEmpty) {
      return _emptyState('No budget items');
    }
    final total = budget.fold<int>(0, (sum, b) => sum + (b.cost ?? 0));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...budget.map((b) => _budgetRow(b)),
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
                '₦${_money.format(total.toDouble())}',
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

  Widget _budgetRow(cd.Budget b) {
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
              b.item ?? 'Item',
              style: txStyle13.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '₦${_money.format((b.cost ?? 0).toDouble())}',
            style: txStyle13.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  // ─── Organizers strip (above tab bar) ──────────────────────
  Widget _organizersStrip(cd.CampaignDetailsModel model) {
    final team = model.participants ?? [];
    if (team.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Organizer',
              style: txStyle14.copyWith(fontWeight: FontWeight.w700),
            ),
            if (team.length > 1)
              GestureDetector(
                onTap: () => _showAllOrganizersSheet(team),
                child: Text(
                  'See All',
                  style: txStyle13.copyWith(
                    color: appPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const Gap(10),
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: team.length,
            separatorBuilder: (_, __) => const Gap(10),
            itemBuilder: (_, i) => _organizerCard(team[i]),
          ),
        ),
        const Gap(20),
      ],
    );
  }

  Widget _organizerCard(cd.Creator p) {
    final name = ('${p.firstName ?? ''} ${p.lastName ?? ''}').trim().isEmpty
        ? (p.username ?? 'Member')
        : '${p.firstName ?? ''} ${p.lastName ?? ''}'.trim();
    final subtitle =
        (p.username ?? '').isNotEmpty ? '@${p.username}' : 'Organizer';
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffEDEFF3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          if ((p.profileImage ?? '').isNotEmpty)
            CustomNetworkImage(
              imageUrl: p.profileImage!,
              radius: 30,
              borderRadius: 25,
            )
          else
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: appPrimaryColor.withValues(alpha: 0.12),
              ),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: txStyle16.copyWith(
                  fontWeight: FontWeight.bold,
                  color: appPrimaryColor,
                ),
              ),
            ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: txStyle13.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(2),
                Text(
                  subtitle,
                  style: txStyle12.copyWith(color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Gap(8),
          GestureDetector(
            onTap: () => _showOrganizerDetails(p),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: appPrimaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'More',
                style: txStyle13.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllOrganizersSheet(List<cd.Creator> team) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const Gap(14),
                Text(
                  'All Organizers',
                  style: txStyle16.copyWith(fontWeight: FontWeight.w700),
                ),
                const Gap(12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(children: team.map(_teamRow).toList()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOrganizerDetails(cd.Creator p) {
    final name = ('${p.firstName ?? ''} ${p.lastName ?? ''}').trim().isEmpty
        ? (p.username ?? 'Member')
        : '${p.firstName ?? ''} ${p.lastName ?? ''}'.trim();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const Gap(20),
                if ((p.profileImage ?? '').isNotEmpty)
                  CustomNetworkImage(
                    imageUrl: p.profileImage!,
                    radius: 88,
                    borderRadius: 44,
                  )
                else
                  Container(
                    width: 88,
                    height: 88,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: appPrimaryColor.withValues(alpha: 0.12),
                    ),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: txStyle24Bold.copyWith(color: appPrimaryColor),
                    ),
                  ),
                const Gap(14),
                Text(
                  name,
                  style: txStyle16.copyWith(fontWeight: FontWeight.w700),
                ),
                if ((p.username ?? '').isNotEmpty) ...[
                  const Gap(4),
                  Text(
                    '@${p.username}',
                    style: txStyle13.copyWith(color: Colors.grey[600]),
                  ),
                ],
                const Gap(16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _teamRow(cd.Creator p) {
    final name =
        '${p.firstName ?? ''} ${p.lastName ?? ''}'.trim().isEmpty
            ? (p.username ?? 'Member')
            : '${p.firstName ?? ''} ${p.lastName ?? ''}'.trim();
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
          if ((p.profileImage ?? '').isNotEmpty)
            CustomNetworkImage(imageUrl: p.profileImage!, radius: 38)
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
                name.isNotEmpty ? name[0].toUpperCase() : '?',
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
                  name,
                  style: txStyle13.copyWith(fontWeight: FontWeight.w600),
                ),
                if ((p.username ?? '').isNotEmpty)
                  Text(
                    '@${p.username}',
                    style: txStyle12.copyWith(color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _offersTab(cd.CampaignDetailsModel model) {
    final offers = model.offers ?? [];
    if (offers.isEmpty) return _emptyState('No offers added');
    final auto = offers.where((o) => (o.type ?? '').toLowerCase() == 'auto');
    final manual = offers.where((o) => (o.type ?? '').toLowerCase() != 'auto');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (auto.isNotEmpty) ...[
          Text(
            'Auto Offers',
            style: txStyle13.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(8),
          ...auto.map((o) => _offerRow(o)),
          const Gap(12),
        ],
        if (manual.isNotEmpty) ...[
          Text(
            'Manual Offers',
            style: txStyle13.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(8),
          ...manual.map((o) => _offerRow(o)),
        ],
      ],
    );
  }

  Widget _offerRow(cd.Offer o) {
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
                if ((o.condition ?? '').isNotEmpty)
                  Text(
                    o.condition!,
                    style: txStyle13.copyWith(fontWeight: FontWeight.w600),
                  ),
                if ((o.reward ?? '').isNotEmpty)
                  Text(
                    o.reward!,
                    style: txStyle12.copyWith(color: Colors.grey[700]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Donors ─────────────────────────────────────────────────
  Widget _donorsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _donorsSubTabBar(),
        const Gap(14),
        if (donorsSubTab == 'ALL') _allDonorsView() else _topDonorsView(),
      ],
    );
  }

  Widget _donorsSubTabBar() {
    const subTabs = [
      {'key': 'ALL', 'label': 'All Donors'},
      {'key': 'TOP', 'label': 'Top Donors'},
    ];
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: subTabs.map((t) {
          final key = t['key']!;
          final label = t['label']!;
          final isSelected = donorsSubTab == key;
          return GestureDetector(
            onTap: () => _onDonorsSubTabSelected(key),
            child: Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          isSelected ? appPrimaryColor : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? appPrimaryColor : Colors.grey[700],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _onDonorsSubTabSelected(String key) {
    if (donorsSubTab == key) return;
    setState(() => donorsSubTab = key);
    if (key == 'TOP') {
      Provider.of<CampaignProvider>(context, listen: false)
          .fetchTopDonors(widget.campaignId);
    }
  }

  Widget _allDonorsView() {
    final provider = Provider.of<CampaignProvider>(context);
    final state = provider.donationsState;

    if (state == ViewState.Busy) {
      return UiBusyWidget();
    }

    if (state == ViewState.Error) {
      return _donorsErrorState(provider);
    }

    final donors = provider.donations;
    if (donors.isEmpty) {
      return _emptyState('No donations yet');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...donors.map((d) => _donorRow(d)),
        if (provider.donationsLoadMoreState == ViewState.Busy)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(appPrimaryColor),
                ),
              ),
            ),
          )
        else if (provider.donationsLoadMoreState == ViewState.Error)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: TextButton(
                onPressed: () =>
                    provider.fetchMoreDonations(widget.campaignId),
                child: Text(
                  'Tap to retry',
                  style: txStyle12.copyWith(
                    color: appPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
        else if (!provider.hasMoreDonations && donors.length > 4)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: Text(
                'You\'ve reached the end',
                style: txStyle11.copyWith(color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }

  Widget _topDonorsView() {
    final provider = Provider.of<CampaignProvider>(context);
    final state = provider.topDonorsState;

    if (state == ViewState.Busy) {
      return const UiBusyWidget();
    }

    if (state == ViewState.Error) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: Colors.grey[500], size: 28),
              const Gap(8),
              Text(
                'Could not load top donors',
                style: txStyle13.copyWith(color: Colors.grey[700]),
              ),
              const Gap(8),
              TextButton(
                onPressed: () => provider.fetchTopDonors(
                  widget.campaignId,
                  refresh: true,
                ),
                child: Text(
                  'Retry',
                  style: txStyle13.copyWith(
                    color: appPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final donors = provider.topDonors;
    if (donors.isEmpty) {
      return _emptyState('No top donors yet');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < donors.length; i++)
          _topDonorRow(donors[i], i + 1),
      ],
    );
  }

  Widget _topDonorRow(TopDonor donor, int rank) {
    final fullName = '${donor.donorFirstName ?? ''} ${donor.donorLastName ?? ''}'
        .trim();
    final displayName = fullName.isEmpty ? 'Donor' : fullName;
    final image = (donor.profileImage ?? '').trim();
    final amount = donor.totalDonated ?? 0;
    final initial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    Color medalBg;
    Color medalFg;
    if (rank == 1) {
      medalBg = const Color(0xFFFFF4D6);
      medalFg = const Color(0xFFB7791F);
    } else if (rank == 2) {
      medalBg = const Color(0xFFEDEFF3);
      medalFg = const Color(0xFF6B7280);
    } else if (rank == 3) {
      medalBg = const Color(0xFFFCE7D6);
      medalFg = const Color(0xFFB45309);
    } else {
      medalBg = appPrimaryColor.withValues(alpha: 0.10);
      medalFg = appPrimaryColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: medalBg,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: medalFg,
              ),
            ),
          ),
          const Gap(10),
          if (image.isNotEmpty)
            CustomNetworkImage(imageUrl: image, radius: 42)
          else
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: appPrimaryColor.withValues(alpha: 0.12),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: txStyle13.copyWith(
                  fontWeight: FontWeight.bold,
                  color: appPrimaryColor,
                ),
              ),
            ),
          const Gap(12),
          Expanded(
            child: Text(
              displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: txStyle13.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          const Gap(8),
          Text(
            '₦${_money.format(amount)}',
            style: txStyle13.copyWith(
              fontWeight: FontWeight.w800,
              color: appPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _donorsErrorState(CampaignProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                color: Colors.grey[500], size: 28),
            const Gap(8),
            Text(
              'Could not load donors',
              style: txStyle13.copyWith(color: Colors.grey[700]),
            ),
            const Gap(8),
            TextButton(
              onPressed: () => provider.fetchCampaignDonations(
                widget.campaignId,
                refresh: true,
              ),
              child: Text(
                'Retry',
                style: txStyle13.copyWith(
                  color: appPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _donorRow(DonationDatum d) {
    final donor = d.donor;
    final isAnonymous = d.isAnonymous == true;
    final fullName = donor == null
        ? ''
        : '${donor.firstName ?? ''} ${donor.lastName ?? ''}'.trim();
    final displayName = isAnonymous
        ? 'Anonymous'
        : (d.customUsername?.trim().isNotEmpty == true
            ? d.customUsername!.trim()
            : (fullName.isNotEmpty
                ? fullName
                : (donor?.username ?? 'Donor')));
    final username = isAnonymous ? null : donor?.username;
    final image = isAnonymous ? '' : (donor?.profileImage ?? '');
    final amount = (d.amount ?? 0).toDouble();
    final comment = (d.comment ?? '').trim();
    final dateLabel = _formatDonationDate(d.createdAt);
    final initial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image.isNotEmpty)
            CustomNetworkImage(imageUrl: image, radius: 42)
          else
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: appPrimaryColor.withValues(alpha: 0.12),
              ),
              alignment: Alignment.center,
              child: isAnonymous
                  ? Icon(Icons.person_outline,
                      size: 20, color: appPrimaryColor)
                  : Text(
                      initial,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: txStyle13.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          if (username != null && username.isNotEmpty)
                            Text(
                              '@$username',
                              style: txStyle11.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Gap(8),
                    Text(
                      '₦${_money.format(amount)}',
                      style: txStyle13.copyWith(
                        fontWeight: FontWeight.w700,
                        color: appPrimaryColor,
                      ),
                    ),
                  ],
                ),
                if (comment.isNotEmpty) ...[
                  const Gap(6),
                  Text(
                    comment,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      height: 1.35,
                    ),
                  ),
                ],
                const Gap(6),
                Text(
                  dateLabel,
                  style: txStyle11.copyWith(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDonationDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final local = date.toLocal();
    final diff = now.difference(local);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM dd, yyyy • HH:mm').format(local);
  }

  Widget _emptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(message, style: TextStyle(color: Colors.grey[600])),
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

  Widget _bottomActions(cd.CampaignDetailsModel model) {
    final hasShare = (model.shareUrl ?? '').isNotEmpty;
    return Row(
      children: [
        if (hasShare)
          Expanded(
            child: CustomButton(
              label: 'Share',
              backgroundColor: Colors.white,
              borderColor: appPrimaryColor,
              color: appPrimaryColor,
              height: 45,
              onTap: () => _shareCampaign(model),
            ),
          ),
        if (hasShare) const Gap(10),
        Expanded(
          child: CustomButton(
            label: 'Donate',
            height: 45,
            onTap: () => _openDonationSheet(model),
          ),
        ),
      ],
    );
  }
}
