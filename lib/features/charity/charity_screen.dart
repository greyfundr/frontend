import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:greyfundr/core/api/campaign_api/campaign_api.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/services/locator.dart';
import 'package:greyfundr/features/home/home_screen.dart';
import 'package:greyfundr/features/profile/profile_screen.dart';

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

  // Helper to map global provider index (0..4) into the compact 3-tab index
  // used by this screen when it renders its own bottom nav.
  int _mapTo3TabIndex(int globalIndex) {
    // map global indices: 0 -> Home (0), 1 -> Bills (1), 4 -> Profile (2)
    if (globalIndex == 0) return 0;
    if (globalIndex == 1) return 1;
    if (globalIndex == 4) return 2;
    return 0; // default to Home
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

  bool _campaignMatchesCategory(Map<String, dynamic> campaign, String selectedCategory) {
    final lower = selectedCategory.toLowerCase();

    // Common direct string fields
    final possibleStringKeys = ['category', 'category_name', 'categoryName', 'category_title', 'categoryTitle'];
    for (final k in possibleStringKeys) {
      final v = campaign[k];
      if (v is String && v.toLowerCase() == lower) return true;
    }

    // If category is an object/map with a name/title
    final catObj = campaign['category'];
    if (catObj is Map<String, dynamic>) {
      final name = (catObj['name'] ?? catObj['title'] ?? catObj['label'])?.toString() ?? '';
      if (name.toLowerCase() == lower) return true;
    }

    // If categories is a list of objects
    final cats = campaign['categories'];
    if (cats is List) {
      for (final item in cats) {
        if (item is Map) {
          final name = (item['name'] ?? item['title'] ?? item['label'])?.toString() ?? '';
          if (name.toLowerCase() == lower) return true;
        } else if (item is String && item.toLowerCase() == lower) {
          return true;
        }
      }
    }

    // No match found
    // Keyword-based heuristics per category to improve matches when backend omits metadata
    final Map<String, List<String>> categoryKeywords = {
      'medical': ['medical', 'hospital', 'surgery', 'health', 'doctor', 'nurse', 'clinic', 'treatment'],
      'education': ['education', 'school', 'tuition', 'teacher', 'student', 'students', 'scholarship', 'learning'],
      'travel': ['travel', 'trip', 'flight', 'journey', 'transport'],
      'nature': ['nature', 'environment', 'tree', 'farming', 'farm', 'conservation'],
      'animal': ['animal', 'pet', 'dog', 'cat', 'rescue', 'vet'],
      'social': ['community', 'social', 'group', 'people'],
      'disaster': ['disaster', 'flood', 'earthquake', 'storm', 'relief', 'emergency'],
      'religion': ['church', 'mosque', 'temple', 'religion', 'faith'],
      'business': ['business', 'company', 'enterprise', 'shop', 'trade'],
      'all': [],
    };

    final title = (campaign['title'] ?? campaign['name'] ?? '').toString().toLowerCase();
    final desc = (campaign['description'] ?? campaign['desc'] ?? '').toString().toLowerCase();

    final keywords = categoryKeywords[lower];
    if (keywords != null && keywords.isNotEmpty) {
      for (final kw in keywords) {
        if (title.contains(kw) || desc.contains(kw)) return true;
      }
    }

    // Final fallback: direct substring match against title/description
    if (title.contains(lower) || desc.contains(lower)) return true;

    return false;
  }

  Future<void> _loadInitialCampaigns() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _allCampaigns.clear();
      _pageNumber = 1;
    });

    try {
        // Fetch campaigns without sending `category` to the backend (some APIs reject this query param).
        final payload = await locator<CampaignApi>().getCampaigns(page: _pageNumber);

        final List<dynamic> rawList = payload['data'] ?? payload['campaigns'] ?? payload['payload'] ?? [];
        final List<Map<String, dynamic>> campaignsAll = rawList.cast<Map<String, dynamic>>();

        // If a category is selected (other than 'All'), do client-side filtering.
        final List<Map<String, dynamic>> campaigns = (_selectedCategory != 'All')
          ? campaignsAll.where((c) => _campaignMatchesCategory(c, _selectedCategory)).toList()
          : campaignsAll;

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
        // Fetch next page without sending `category` param; filter client-side if needed.
        final payload = await locator<CampaignApi>().getCampaigns(page: nextPage);

        final List<dynamic> rawList = payload['data'] ?? payload['campaigns'] ?? payload['payload'] ?? [];
        final List<Map<String, dynamic>> newCampaignsAll = rawList.cast<Map<String, dynamic>>();
        final List<Map<String, dynamic>> newCampaigns = (_selectedCategory != 'All')
          ? newCampaignsAll.where((c) => _campaignMatchesCategory(c, _selectedCategory)).toList()
          : newCampaignsAll;

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

  final bool noAncestorNav = context.findAncestorWidgetOfExactType<BottomNavigationBar>() == null;
  userProvider.setSuppressAppNav(noAncestorNav);

  return Scaffold(
    backgroundColor: Colors.grey[100],
    // If an ancestor BottomNavigationBar is present (app-level BottomNav),
    // we should not render another one here. Detect and render a 3-item
    // bottom nav only when no ancestor BottomNavigationBar exists.
    bottomNavigationBar: noAncestorNav
        ? BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
            showSelectedLabels: true,
            elevation: 0,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            unselectedLabelStyle: const TextStyle(
              color: greyTextColor,
              fontWeight: FontWeight.w500,
            ),
            selectedLabelStyle: const TextStyle(
              color: appPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
            currentIndex: _mapTo3TabIndex(userProvider.selectedIndex),
            selectedItemColor: appPrimaryColor,
            unselectedItemColor: greyTextColor,
            onTap: (i) {
              doHepticFeedback();
              // Map 3-tab taps back to global provider indices and
              // navigate to Home or Profile when this screen is standalone.
              if (i == 0) {
                userProvider.updateSelectedIndex(0);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
                return;
              }

              if (i == 1) {
                // Bills: update provider to Bills index
                userProvider.updateSelectedIndex(1);
                return;
              }

              if (i == 2) {
                userProvider.updateSelectedIndex(4);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
                return;
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: SvgPicture.asset(
                      'assets/svgs/home.svg',
                      colorFilter: ColorFilter.mode(
                        _mapTo3TabIndex(userProvider.selectedIndex) == 0 ? appPrimaryColor : greyTextColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: SvgPicture.asset(
                      'assets/svgs/bills.svg',
                      colorFilter: ColorFilter.mode(
                        _mapTo3TabIndex(userProvider.selectedIndex) == 1 ? appPrimaryColor : greyTextColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                label: 'Bills',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: SvgPicture.asset(
                      'assets/svgs/profile.svg',
                      colorFilter: ColorFilter.mode(
                        _mapTo3TabIndex(userProvider.selectedIndex) == 2 ? appPrimaryColor : greyTextColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                label: 'Profile',
              ),
            ],
          )
        : null,
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