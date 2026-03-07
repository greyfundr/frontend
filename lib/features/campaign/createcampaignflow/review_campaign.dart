import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:greyfundr/core/models/campaign_model.dart';
import 'package:greyfundr/core/models/budget_model.dart';

import 'package:greyfundr/core/api/auth_api/auth_api.dart';
import 'package:greyfundr/core/api/auth_api/auth_api_impl.dart'; // adjust path if needed

import 'package:greyfundr/widgets/reviewcampaign/campaign_image_carousel.dart';
import 'package:greyfundr/widgets/reviewcampaign/campaign_info_card.dart';
import 'package:greyfundr/widgets/reviewcampaign/organizers_section.dart';
import 'package:greyfundr/widgets/reviewcampaign/campaign_tabs_section.dart';
import 'package:greyfundr/widgets/reviewcampaign/action_buttons_row.dart';

import 'package:greyfundr/bottomsheets/reviewcampaign/team_members_bottom_sheet.dart';

import 'package:greyfundr/features/campaign/createcampaignflow/edit_campaign.dart';
import 'package:greyfundr/features/campaign/createcampaignflow/campaignapproval.dart';

class ReviewCampaignScreen extends StatefulWidget {
  final Campaign campaign;
  const ReviewCampaignScreen({super.key, required this.campaign});

  @override
  State<ReviewCampaignScreen> createState() => _ReviewCampaignScreenState();
}

class _ReviewCampaignScreenState extends State<ReviewCampaignScreen> {
  Map<String, dynamic>? currentUser;
  int selectedTab = 0;

  // Editable/review content (kept in sync if edited)
  late String description;
  late List<Expense> budgetItems;
  late List<Map<String, String>> offers;

  final AuthApi _authApi = AuthApiImpl(); // ← consistent with your new structure

  @override
  void initState() {
    super.initState();
    description = widget.campaign.description;
    budgetItems = List.from(widget.campaign.budgets);
    offers = [
      ...widget.campaign.savedAutoOffers,
      ...widget.campaign.savedManualOffers,
    ];
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      // Option A: If you already have a method to get current user profile
      final response = await _authApi.userProfileApi();

      // Assuming userProfileApi returns JSON string or decoded map
      final decoded = response is String ? jsonDecode(response) : response;

      // Adjust based on your actual response shape
      final userData = decoded is Map
          ? decoded['data'] ?? decoded['user'] ?? decoded
          : decoded;

      if (mounted) {
        setState(() {
          currentUser = userData is Map<String, dynamic> ? userData : null;
        });
      }
    } catch (e) {
      debugPrint('Failed to load user profile: $e');
      // Optional: show snackbar or fallback UI
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load user info: $e')),
        );
      }
    }
  }

  void _updateCampaign(Campaign updated) {
    setState(() {
      widget.campaign
        ..title = updated.title
        ..description = updated.description
        ..images = updated.images
        ..participants = updated.participants
        ..savedAutoOffers = updated.savedAutoOffers
        ..savedManualOffers = updated.savedManualOffers
        ..budgets = updated.budgets;

      description = updated.description;
      budgetItems = updated.budgets;
      offers = [...updated.savedAutoOffers, ...updated.savedManualOffers];
    });
  }

  Future<void> _submitForApproval() async {
    // Optional: real API call here in the future
    // await _campaignApi.submitCampaign(widget.campaign);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Campaign submitted successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CampaignApprovalPage(campaign: widget.campaign),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Loading state while user is fetched
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final daysLeft = _calculateDaysLeft();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background
          Container(color: Colors.white),

          // Carousel on top
          CampaignImageCarousel(images: widget.campaign.images),

          // Scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 205),

                CampaignInfoCard(campaign: widget.campaign, daysLeft: daysLeft),

                const SizedBox(height: 10),

                OrganizersSection(
                  campaign: widget.campaign,
                  user: currentUser!,
                  onSeeAll: () => TeamMembersBottomSheet.show(
                    context,
                    widget.campaign,
                    currentUser!,
                  ),
                ),

                const SizedBox(height: 20),

                CampaignTabsSection(
                  selectedTab: selectedTab,
                  onTabChanged: (i) => setState(() => selectedTab = i),
                  description: description,
                  budgetItems: budgetItems,
                  offers: offers,
                ),

                const SizedBox(height: 10),

                ActionButtonsRow(
                  onEdit: () async {
                    final updated = await Navigator.push<Campaign>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditCampaignScreen(campaign: widget.campaign),
                      ),
                    );
                    if (updated != null && mounted) {
                      _updateCampaign(updated);
                    }
                  },
                  onSubmit: _submitForApproval,
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _calculateDaysLeft() {
    try {
      final start = DateFormat('dd/MM/yyyy').parse(widget.campaign.startDate);
      final end = DateFormat('dd/MM/yyyy').parse(widget.campaign.endDate);
      return end.difference(start).inDays;
    } catch (e) {
      debugPrint('Date parsing error: $e');
      return 0;
    }
  }
}