import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:greyfundr/core/api/auth_api/auth_api.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/services/locator.dart';
import 'package:greyfundr/widgets/campaigndetails/withdrawal_bottom_sheet.dart';
import 'package:greyfundr/widgets/campaigndetails/manage_campaign_bottom_sheet.dart';
import 'package:greyfundr/widgets/campaigndetails/campaignprogress.dart';
import 'package:greyfundr/widgets/campaigndetails/add_money_bottom_sheet.dart';
import 'package:greyfundr/services/custom_alert.dart';

class CampaignDetails extends StatefulWidget {
  final String id;

  const CampaignDetails({super.key, required this.id});

  @override
  State<CampaignDetails> createState() => _CampaignDetailsState();
}

class _CampaignDetailsState extends State<CampaignDetails> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  late PageController _pageController;
  int _currentImageIndex = 0;

  int _selectedTabIndex = 0;
  int _financingSubTabIndex = 0;
  int _donationSubTabIndex = 0;

  bool _isLoading = true;
  String? _errorMessage;

  // Campaign data
  Map<String, dynamic>? campaign;
  List<String> campaignImages = [];
  List<dynamic> donations = [];
  List<dynamic> moffer = [];
  List<dynamic> aoffer = [];
  List<dynamic> expenses = [];

  double totalExpense = 0.0;
  int documentCount = 0;

  bool get isCampaignLive => campaign != null && campaign!['creator_id'] != null;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadCampaign();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _loadCampaign();
    _refreshController.refreshCompleted();
  }

  Future<void> _loadCampaign() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final payload = await locator<AuthApi>().getCampaignDetails(widget.id);
      final campaignData = payload['campaigns'] ?? payload;

      final rawDonors = payload['donors'] ?? [];
      final rawImages = campaignData['images'] ?? campaignData['image'] ?? '';

      List<String> parsedImages = [];

      if (rawImages is List) {
        parsedImages = rawImages.cast<String>().map((e) => e.replaceAll('\\', '/')).toList();
      } else if (rawImages is String && rawImages.isNotEmpty) {
        try {
          parsedImages = (jsonDecode(rawImages) as List).cast<String>().map((e) => e.replaceAll('\\', '/')).toList();
        } catch (_) {
          parsedImages = rawImages.split(',').map((e) => e.trim().replaceAll('\\', '/')).toList();
        }
      }

      // Fallbacks
      if (parsedImages.isEmpty && campaignData['image'] != null) {
        parsedImages.add(campaignData['image'].toString().replaceAll('\\', '/'));
      }
      if (parsedImages.isEmpty) {
        parsedImages.add('https://pub-bcb5a51a1259483e892a2c2993882380.r2.dev/default-campaign.jpg');
      }

      setState(() {
        campaign = campaignData;
        campaignImages = parsedImages;
        donations = rawDonors.cast<Map<String, dynamic>>();
        moffer = (campaignData['moffer'] ?? []).cast<dynamic>();
        aoffer = (campaignData['aoffer'] ?? []).cast<dynamic>();
        expenses = jsonDecode(campaignData['budget'] ?? '[]').cast<dynamic>();

        totalExpense = expenses.fold<double>(0.0, (sum, item) => sum + (double.tryParse(item['cost']?.toString() ?? '0') ?? 0));
        documentCount = expenses.where((e) => e['file'] != null && e['file'].toString().isNotEmpty).length;

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      CustomMessageModal.show(
        context: context,
        message: "Failed to load campaign: $e",
        isSuccess: false,
      );
    }
  }

  String _formatCurrency(String? amount) {
    final number = double.tryParse(amount ?? '0') ?? 0.0;
    return NumberFormat("#,##0", "en_US").format(number);
  }

  String _formatTimeAgo(String? dateString) {
    if (dateString == null) return 'Just now';
    try {
      final date = DateTime.parse(dateString);
      final diff = DateTime.now().difference(date);

      if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
      if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
      if (diff.inDays >= 1) return '${diff.inDays}d ago';
      if (diff.inHours >= 1) return '${diff.inHours}h ago';
      if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (_) {
      return 'Recently';
    }
  }

  int _calculateDaysLeft() {
  final endDateStr = campaign?['end_date']?.toString();
  if (endDateStr == null || endDateStr.isEmpty) return 0;

  try {
    final end = DateTime.parse(endDateStr).copyWith(hour: 23, minute: 59, second: 59);
    final now = DateTime.now();
    if (now.isAfter(end)) return 0;
    return end.difference(now).inDays;
  } catch (_) {
    return 0;
  }
}

  void _showSuccessDonationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/animations/success.gif', height: 140),
            const SizedBox(height: 20),
            const Text("Thank You!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF007A74))),
            const SizedBox(height: 12),
            const Text("Your donation was successful!", textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _loadCampaign();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007A74)),
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMoneyModal() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userProfileModel?.id?.toString() ?? '0';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddMoneyBottomSheet(
        userId: userId,
        creatorId: campaign?['creator_id']?.toString() ?? '0',
        campaignId: widget.id,
        campaign: campaign,
        onDonationSuccess: () {
          _showSuccessDonationDialog();
          _loadCampaign();
        },
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0: // About
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            campaign?['description'] ?? "No description available.",
            style: const TextStyle(height: 1.5, fontSize: 16),
          ),
        );

      case 1: // Financing
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildSubTab("Budgeting", 0, _financingSubTabIndex, (i) => setState(() => _financingSubTabIndex = i)),
                  _buildSubTab("Expenditure", 1, _financingSubTabIndex, (i) => setState(() => _financingSubTabIndex = i)),
                ],
              ),
            ),
            if (_financingSubTabIndex == 0)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text("Overall budget: ₦${_formatCurrency(campaign?['goal_amount']?.toString())}"),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(flex: 2, child: Text("Expense", style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text("Cost", style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text("Document", style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const Divider(),
                    ...expenses.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Text(item['name'] ?? '')),
                              Expanded(child: Text("₦${_formatCurrency(item['cost']?.toString())}")),
                              Expanded(child: Text(item['file'] != null ? "View" : "None")),
                            ],
                          ),
                        )),
                    const Divider(),
                    Text("Total: ₦${_formatCurrency(totalExpense.toString())} • $documentCount docs"),
                  ],
                ),
              ),
          ],
        );

      case 2: // Offers
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Manual Offers", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ...moffer.map((o) => ListTile(
                    title: Text(o['condition'] ?? 'N/A'),
                    subtitle: Text(o['reward'] ?? 'N/A'),
                  )),
              const SizedBox(height: 16),
              const Text("Auto Offers", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ...aoffer.map((o) => ListTile(
                    title: Text(o['condition'] ?? 'N/A'),
                    subtitle: Text(o['reward'] ?? 'N/A'),
                  )),
            ],
          ),
        );

      case 3: // Donations
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildSubTab("All Donors", 0, _donationSubTabIndex, (i) => setState(() => _donationSubTabIndex = i)),
                  _buildSubTab("Top Donors", 1, _donationSubTabIndex, (i) => setState(() => _donationSubTabIndex = i)),
                ],
              ),
            ),
            if (_donationSubTabIndex == 0)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: donations.length,
                itemBuilder: (context, index) {
                  final donor = donations[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        donor['profile_pic']?.isNotEmpty == true
                            ? "https://pub-bcb5a51a1259483e892a2c2993882380.r2.dev/${donor['profile_pic']}"
                            : 'assets/images/personal.png',
                      ),
                    ),
                    title: Text(donor['name'] ?? 'Anonymous'),
                    subtitle: Text("₦${_formatCurrency(donor['amount']?.toString())}"),
                    trailing: Text(_formatTimeAgo(donor['created_at'])),
                  );
                },
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: donations.length,
                itemBuilder: (context, index) {
                  final donor = donations[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        donor['profile_pic']?.isNotEmpty == true
                            ? "https://pub-bcb5a51a1259483e892a2c2993882380.r2.dev/${donor['profile_pic']}"
                            : 'assets/images/personal.png',
                      ),
                    ),
                    title: Text(donor['name'] ?? 'Anonymous'),
                    subtitle: Text("₦${_formatCurrency(donor['amount']?.toString())}"),
                  );
                },
              ),
          ],
        );

      case 4: // Comments
        return const Center(child: Text("Comments section coming soon"));

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSubTab(String title, int index, int currentIndex, Function(int) onTap) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF007A74) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFF007A74) : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.userProfileModel;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF007A74))),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Error: $_errorMessage", style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _onRefresh,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isCampaignLive)
              Expanded(
                child: FloatingActionButton.extended(
                  heroTag: "donate",
                  backgroundColor: const Color(0xFF007A74),
                  label: const Text("DONATE"),
                  onPressed: _showAddMoneyModal,
                ),
              )
            else ...[
              Expanded(
                child: FloatingActionButton.extended(
                  heroTag: "manage",
                  backgroundColor: const Color(0xFFFF6B35),
                  label: const Text("MANAGE CAMPAIGN"),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => ManageCampaignBottomSheet(
                        campaignId: widget.id,
                        campaign: campaign,
                        onRefreshNeeded: _loadCampaign,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FloatingActionButton.extended(
                  heroTag: "withdraw",
                  backgroundColor: const Color(0xFF007A74),
                  label: const Text("WITHDRAW"),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => WithdrawalBottomSheet(
                        raisedAmount: campaign?['current_amount']?.toString() ?? '0',
                        goalAmount: campaign?['goal_amount']?.toString() ?? '0',
                        donors: campaign?['donors']?.toString() ?? '0',
                        champions: campaign?['champions']?.toString() ?? '0',

                        
                        campaignId: widget.id,
                        budgetsRaw: expenses,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        header: const WaterDropHeader(),
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (campaignImages.isNotEmpty)
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) => setState(() => _currentImageIndex = index),
                        itemCount: campaignImages.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            campaignImages[index],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                          );
                        },
                      )
                    else
                      Container(color: Colors.grey[300]),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.7)],
                        ),
                      ),
                    ),
                    if (campaignImages.length > 1)
                      Positioned(
                        bottom: 32,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(campaignImages.length, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              width: _currentImageIndex == index ? 24 : 8,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign?['title'] ?? "Loading...",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    CampaignProgressShowcase(
                      currentAmount: campaign?['current_amount']?.toString() ?? '0',
                      goalAmount: campaign?['goal_amount']?.toString() ?? '0',
                      percentage: (double.tryParse(campaign?['current_amount']?.toString() ?? '0') ?? 0) /
                          (double.tryParse(campaign?['goal_amount']?.toString() ?? '1') ?? 1),
                     daysLeft: _calculateDaysLeft(),  // ← now using the real calculation
                      donors: campaign?['donors']?.toString() ?? '0',
                      champions: campaign?['champions']?.toString() ?? '0',
                    ),
                    const SizedBox(height: 24),
                    // Main Tabs
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: ['About', 'Financing', 'Offers', 'Donations', 'Comments'].length,
                        itemBuilder: (context, index) {
                          final titles = ['About', 'Financing', 'Offers', 'Donations', 'Comments'];
                          final isSelected = _selectedTabIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 24),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTabIndex = index),
                              child: Column(
                                children: [
                                  Text(
                                    titles[index],
                                    style: TextStyle(
                                      color: isSelected ? const Color(0xFF007A74) : Colors.grey,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      height: 3,
                                      width: 40,
                                      margin: const EdgeInsets.only(top: 4),
                                      color: const Color(0xFF007A74),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTabContent(),
                    const SizedBox(height: 80), // space for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}