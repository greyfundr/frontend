import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greyfundr/core/models/user_event_model.dart';
import 'package:greyfundr/features/bill/rsvp_details_screen.dart';
import 'package:greyfundr/features/campaign/createcampaignflow/campaign_details_screen.dart';
import 'package:greyfundr/features/event/event_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/responsiveState/view_state.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/features/settings/edit_profile_screen.dart';
import 'package:greyfundr/components/custom_network_image.dart';
import 'package:intl/intl.dart';

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
      userProvider.fetchUserCampaigns();
      Provider.of<EventProvider>(context, listen: false).getMyEvents();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    await userProvider.fetchUserProfileApi();
    await userProvider.fetchUserCampaigns();
    await eventProvider.getMyEvents();
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
        top: false,
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
                        height: 350,
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
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
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
      return _buildMyEventsTab();
    } else if (_selectedMainTab == 2) {
      return const Center(child: Text("Listings coming soon"));
    } else {
      return _buildAboutSection(userProvider);
    }
  }

  Widget _buildAboutSection(UserProvider userProvider) {
    final user = userProvider.userProfileModel;
    final profile = user?.profile;
    final bio = (profile?.bio ?? '').trim();
    final interests = (profile?.interests ?? const <String>[])
        .where((i) => i.trim().isNotEmpty)
        .toList();
    final location = [
      profile?.city,
      profile?.state,
      profile?.country,
    ].whereType<String>().where((p) => p.trim().isNotEmpty).join(', ');

    final isEmpty =
        bio.isEmpty && interests.isEmpty && location.isEmpty;

    if (isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_outline,
                size: 56,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              const Text(
                "Nothing to show yet",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                "Add a bio and interests from your profile to introduce yourself",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Complete profile"),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        if (bio.isNotEmpty) ...[
          _AboutCard(
            icon: Icons.format_quote_rounded,
            title: 'Bio',
            child: Text(
              bio,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (location.isNotEmpty) ...[
          _AboutCard(
            icon: Icons.location_on_outlined,
            title: 'Location',
            child: Text(
              location,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (interests.isNotEmpty)
          _AboutCard(
            icon: Icons.interests_outlined,
            title: 'Interests',
            trailing: SizedBox(),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: interests
                  .map(
                    (interest) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.teal.withOpacity(0.25),
                        ),
                      ),
                      child: Text(
                        interest,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
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
    final money = NumberFormat('#,##0');
    final raisedLabel = '$currency${money.format(raised.round())}';
    final goalLabel = '$currency${money.format(goal.round())}';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final id = campaign is Map<String, dynamic>
            ? (campaign['id'] ?? campaign['_id'])?.toString()
            : null;
        if (id == null || id.isEmpty) return;
        Get.to(
          () => CampaignDetailsScreen(campaignId: id),
          transition: Transition.rightToLeft,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: SizedBox(
                    width: double.infinity,
                    child: LayoutBuilder(
                      builder: (ctx, constraints) => CustomNetworkImage(
                        imageUrl: image,
                        radius: constraints.maxHeight,
                        width: constraints.maxWidth,
                        borderRadius: 0,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      percent,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? "Untitled Campaign",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        appPrimaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        raisedLabel,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: appPrimaryColor,
                        ),
                      ),
                      Text(
                        goalLabel,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Colors.grey.shade600,
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

  Widget _buildMyEventsTab() {
    final eventProvider = Provider.of<EventProvider>(context);
    final state = eventProvider.myEventsState;
    if (state == ViewState.Busy || state == ViewState.Idle) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state == ViewState.Error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Couldn't load your events"),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => eventProvider.getMyEvents(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    final events = eventProvider.myEvents ?? [];
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_outlined,
                  size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              const Text(
                "You haven't created any events yet",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return _buildEventCard(events[index]);
      },
    );
  }

  Widget _buildEventCard(EventDatum event) {
    final cover =
        (event.coverImages?.isNotEmpty ?? false) ? event.coverImages!.first : '';
    final name = (event.name ?? event.title?.toString() ?? '').trim();
    final start = event.startDateTime;
    final dateLabel = start != null
        ? DateFormat('MMM dd, yyyy').format(start)
        : 'Date TBA';
    final venue = (event.venueName ?? '').trim();
    final raised = (event.amountRaised ?? 0).toDouble();
    final target = (event.targetAmount ?? 0).toDouble();
    final acceptDonations = event.acceptDonations ?? false;
    final progress =
        target > 0 ? (raised / target).clamp(0.0, 1.0) : 0.0;
    final money = NumberFormat('#,##0');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final id = event.id;
        if (id == null || id.isEmpty) return;
        Get.to(
          () => RsvpDetailsScreen(eventId: id),
          transition: Transition.rightToLeft,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: SizedBox(
                    width: double.infinity,
                    child: LayoutBuilder(
                      builder: (ctx, constraints) => CustomNetworkImage(
                        imageUrl: cover,
                        radius: constraints.maxHeight,
                        width: constraints.maxWidth,
                        borderRadius: 0,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 11, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          dateLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? 'Untitled Event' : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  if (venue.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            venue,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (acceptDonations && target > 0) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor: Colors.grey.shade200,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(appPrimaryColor),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₦${money.format(raised.round())} of ₦${money.format(target.round())}',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: appPrimaryColor,
                      ),
                    ),
                  ],
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

class _AboutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

  const _AboutCard({
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: Colors.teal.shade700),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
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
