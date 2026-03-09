import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:greyfundr/core/api/campaign_api/campaign_api.dart';


import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/services/locator.dart';
import 'package:greyfundr/widgets/reusable_bottom_nav.dart';

import 'package:greyfundr/features/campaign/createcampaignflow/create_campaign.dart';

import 'package:greyfundr/widgets/charity/header_section.dart';
import 'package:greyfundr/widgets/charity/feature_icons_row.dart';
import 'package:greyfundr/widgets/charity/tab_selector.dart';
import 'package:greyfundr/widgets/charity/campaign_card.dart';
import 'package:greyfundr/widgets/charity/horizontal_campaign_carousel.dart';

class CharityScreen extends StatefulWidget {
  const CharityScreen({super.key});

  @override
  State<CharityScreen> createState() => _CharityScreenState();
}

class _CharityScreenState extends State<CharityScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  late ScrollController _scrollController;

  bool _isHeaderCollapsed = true;
  String selectedTab = 'Explore';
  String _selectedCategory = "All";

  List<Map<String, dynamic>> _allCampaigns = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  int _pageNumber = 1;
  double _lastScrollPixels = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _loadInitialCampaigns();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final current = _scrollController.position.pixels;
    final delta = current - _lastScrollPixels;

    if (delta.abs() > 8) {
      setState(() {
        _isHeaderCollapsed = delta > 0;
      });
    }
    _lastScrollPixels = current;

    // Load more when near bottom
    if (current >= _scrollController.position.maxScrollExtent - 150 &&
        !_isLoadingMore &&
        !_isLoading) {
      _loadMoreCampaigns();
    }
  }

  Future<void> _loadInitialCampaigns() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _allCampaigns.clear();
      _pageNumber = 1;
    });

    try {
      final payload = await locator<CampaignApi>().getAllCampaigns(page: _pageNumber);

      final List<dynamic> rawList = payload['data'] ?? payload['campaigns'] ?? payload['payload'] ?? [];
      final List<Map<String, dynamic>> campaigns = rawList.cast<Map<String, dynamic>>();

      if (!mounted) return;

      setState(() {
        _allCampaigns = campaigns;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Failed to load campaigns: ${e.toString().split('\n').first}";
        _isLoading = false;
      });
    } finally {
      _refreshController.refreshCompleted();
    }
  }

  Future<void> _loadMoreCampaigns() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _pageNumber + 1;
      final payload = await locator<CampaignApi>().getAllCampaigns(page: nextPage);

      final List<dynamic> rawList = payload['data'] ?? payload['campaigns'] ?? payload['payload'] ?? [];
      final List<Map<String, dynamic>> newCampaigns = rawList.cast<Map<String, dynamic>>();

      if (!mounted) return;

      if (newCampaigns.isNotEmpty) {
        setState(() {
          _pageNumber = nextPage;
          _allCampaigns.addAll(newCampaigns);
        });
      }
    } catch (e) {
      debugPrint("Load more error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  // ignore: unused_element
  Future<void> _onRefresh() async {
    await _loadInitialCampaigns();
  }

  Widget _buildTabContent(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF007A74)));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(fontSize: 16, color: Colors.red)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadInitialCampaigns,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35)),
              child: const Text("Retry", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = userProvider.userProfileModel?.id?.toString();

    if (selectedTab == 'For You') {
      return _buildEmptyTab(
        icon: Icons.recommend_outlined,
        title: "No campaigns yet",
        subtitle: "Campaigns you create will appear here.\nTap the button below to start your first one!",
        buttonText: "Start a Campaign",
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CampaignScreen()),
        ),
      );
    }

    if (selectedTab == 'Following') {
      return _buildEmptyTab(
        icon: Icons.people_alt_outlined,
        title: "No Campaigns from people you follow yet",
        subtitle: "When someone you follow creates or backs a campaign, it will appear here.",
      );
    }

    // Explore tab
    if (_allCampaigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text("No campaigns available yet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text("Check back later or create your own!", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CampaignScreen()),
              ),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("Start a Campaign"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _allCampaigns.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _allCampaigns.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(color: Color(0xFF007A74))),
          );
        }

        final campaign = _allCampaigns[index];
        return CampaignCard(
          campaign: campaign,
          currentUserId: currentUserId,
          onDonationSuccess: () {
            _loadInitialCampaigns(); // Refresh after donation
          },
        );
      },
    );
  }

  Widget _buildEmptyTab({
    required IconData icon,
    required String title,
    required String subtitle,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        Center(
          child: Column(
            children: [
              Icon(icon, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700])),
              const SizedBox(height: 8),
              Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              if (buttonText != null) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.add_circle_outline),
                  label: Text(buttonText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  @override
Widget build(BuildContext context) {
  // Status bar styling
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF007A74),
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  final userProvider = Provider.of<UserProvider>(context);

  final user = userProvider.userProfileModel;

  if (user == null) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Color(0xFF007A74))),
    );
  }

  return Scaffold(
    backgroundColor: Colors.grey[100],
    bottomNavigationBar: reusableBottomNav(context), // ← added this
    body: SafeArea(
      child: Column(
        children: [
          HeaderSection(
            isCollapsed: _isHeaderCollapsed,
            onStartCampaign: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CampaignScreen()),
            ),
            onSettings: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Settings coming soon!")),
              );
            },
          ),
          FeatureIconsRow(
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
                _loadInitialCampaigns();
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(0);
                }
              });
            },
          ),
          HorizontalCampaignCarousel(isVisible: !_isHeaderCollapsed),
          TabSelector(
            selectedTab: selectedTab,
            onTabChanged: (tab) => setState(() => selectedTab = tab),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildTabContent(context),
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            ),
          ),
        ],
      ),
    ),
  );
}
}