import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/features/charity/campaigndetails.dart';
import 'package:greyfundr/features/settings/edit_profile_screen.dart';
import 'package:greyfundr/components/custom_network_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  int _selectedMainTab = 0;
  int _selectedPostSubTab = 0; // 0 = My Post, 1 = Likes

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      // Assuming UserProvider has a method to fetch the user's campaigns
      userProvider.fetchUserCampaigns();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchUserProfileApi();
    // Also refresh the user's campaigns
    await userProvider.fetchUserCampaigns();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.userProfileModel;

    
   
 
    if (userProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Failed to load profile"),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _onRefresh, child: const Text("Retry")),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          header: const WaterDropHeader(),
          onRefresh: _onRefresh,
          child: CustomScrollView(
            slivers: [
              // Header (unchanged – but fixed your CustomNetworkImage calls)
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipPath(
                      clipper: HeaderCurveClipper(),
                      child: Container(
                        height: 280,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/onboarding_1.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.65),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 55,
                      left: 20,
                      right: 20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: ClipOval(
                              child: CustomNetworkImage(
                                imageUrl: "${user.profile?.image}",
                                radius: 40,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${user.firstName} ${user.lastName}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "@${user.username ?? 'username'}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildStat("0", "Followers"),
                                    const SizedBox(width: 24),
                                    _buildStat("0", "Champions"),
                                    const SizedBox(width: 24),
                                    _buildStat("0", "Backers"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "EDIT PROFILE",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {
                          /* share */
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: const BorderSide(
                            color: Colors.grey,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "SHARE PROFILE",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.teal.shade600,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Main tabs
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      _buildMainTab("Campaigns", 0),
                      _buildMainTab("Events", 1),
                      _buildMainTab("Listings", 2),
                      _buildMainTab("About", 3),
                    ],
                  ),
                ),
              ),

              // Sub-tabs (only under Campaigns)
              if (_selectedMainTab == 0)
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        _buildSubTab("My Post", 0),
                        _buildSubTab("Likes", 1),
                      ],
                    ),
                  ),
                ),

              // Main content
              SliverFillRemaining(child: _buildContent(userProvider)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainTab(String title, int index) {
    final isSelected = _selectedMainTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMainTab = index;
            if (index != 0) {
              _selectedPostSubTab = 0; // reset sub-tab when leaving Campaigns
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.teal.shade600 : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubTab(String title, int index) {
    final isSelected = _selectedPostSubTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPostSubTab = index),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            if (isSelected)
              Container(
                height: 3,
                color: Colors.teal.shade600,
                width: 60, // or full width if preferred
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(UserProvider userProvider) {
    if (_selectedMainTab == 0) {
      // ─── Campaigns ───────────────────────────────────────
      if (_selectedPostSubTab == 0) {
        // My Post (your campaigns)
        if (userProvider.isLoadingCampaigns) {
          return const Center(child: CircularProgressIndicator());
        }
        if (userProvider.userCampaigns.isEmpty) {
          return const Center(
            child: Text(
              "You haven't created any campaigns yet",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return _buildCampaignGrid(userProvider.userCampaigns);
      } else {
        // Likes tab
        // TODO: Replace with real liked campaigns when you add them to provider
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "Liked campaigns coming soon",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        );
      }
    } else if (_selectedMainTab == 1) {
      return const Center(child: Text("Events coming soon"));
    } else if (_selectedMainTab == 2) {
      return const Center(child: Text("Listings coming soon"));
    } else {
      return const Center(child: Text("About section coming soon"));
    }
  }

  Widget _buildCampaignGrid(List<dynamic> campaigns) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.68,
      ),
      itemCount: campaigns.length,
      itemBuilder: (context, index) {
        // The provider returns a list of dynamic, which are Maps from JSON
        final campaign = campaigns[index] as Map<String, dynamic>;

        // Robust image URL extraction, similar to CampaignCard
        String? imageUrl;
        final rawImages = campaign['images'] ?? campaign['image'];
        if (rawImages is List && rawImages.isNotEmpty) {
          final firstImage = rawImages.first;
          if (firstImage is Map<String, dynamic>) {
            imageUrl = firstImage['imageUrl']?.toString();
          } else if (firstImage is String) {
            imageUrl = firstImage;
          }
        } else if (rawImages is String) {
          imageUrl = rawImages;
        }

        final hasImage =
            imageUrl != null && imageUrl.isNotEmpty && imageUrl != 'null';
        const defaultUrl =
            "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=1000&auto=format&fit=crop";
        const cdnBaseUrl =
            "https://pub-bcb5a51a1259483e892a2c2993882380.r2.dev/";

        String finalUrl = defaultUrl;
        if (hasImage) {
          if (imageUrl.startsWith('http')) {
            finalUrl = imageUrl;
          } else {
            finalUrl = "$cdnBaseUrl$imageUrl";
          }
        }

        return _buildCampaignCard(
          image: finalUrl,
          title: campaign['title'] as String? ?? "Untitled Campaign",
          // Use the same logic as other parts of the app for amounts
          raised:
              (double.tryParse(
                    (campaign['current_amount'] ?? campaign['currentAmount'])
                            ?.toString() ??
                        '0.0',
                  ) ??
                  0.0) *
              100,
          goal: double.tryParse(campaign['target']?.toString() ?? '1.0') ?? 1.0,
          currency: '₦',
          campaign: campaign,
        );
      },
    );
  }

  // Your existing _buildCampaignCard (fixed image)
  Widget _buildCampaignCard({
    required String image,
    required String? title,
    required double raised,
    required double goal,
    required String currency,
    required dynamic campaign,
  }) {
    final progress = goal > 0 ? (raised / goal).clamp(0.0, 1.0) : 0.0;
    final percent = "${(progress * 100).toStringAsFixed(0)}%";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CampaignDetails(id: campaign['id'].toString()),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : Container(color: Colors.grey[200]),
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? "Untitled Campaign",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.teal,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        percent,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal.shade800,
                        ),
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

  Widget _buildStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}

class HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
