import 'dart:io';

import 'package:greyfundr/core/models/all_campaign_response_model.dart';
import 'package:greyfundr/core/models/campaign_comment_model.dart';
import 'package:greyfundr/core/models/campaign_details_model.dart';
import 'package:greyfundr/core/models/campaign_donations_response_model.dart';
import 'package:greyfundr/core/models/campaign_model.dart';
import 'package:greyfundr/core/models/participants_model.dart';
import 'package:greyfundr/core/models/top_donors_response_model.dart';

abstract class CampaignApi {
  // ──────────────────────────────────────────────────────────────
  // Users / Participants (used in campaign creation, split bill, etc.)
  // ──────────────────────────────────────────────────────────────

  Future<List<Participant>> getUsers();

  // Categories list for the create-campaign flow
  Future<List<Map<String, String>>> getCategories();

  // ──────────────────────────────────────────────────────────────
  // Get All Campaigns (paginated + optional category filter)
  // ──────────────────────────────────────────────────────────────

  Future<AllCampaignResponseModel> getAllCampaigns({
    required int page,
    String? category, // optional – e.g. "Education", "Health", "All"
  });

  // ──────────────────────────────────────────────────────────────
  // Get Single Campaign Details
  // ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getCampaignDetails(String campaignId);

  // Typed details for the new details screen
  Future<CampaignDetailsModel> getCampaignDetailsTyped(String campaignId);

  // ──────────────────────────────────────────────────────────────
  // Campaign Creation
  // ──────────────────────────────────────────────────────────────

  Future<dynamic> createCampaignApi({
    required Campaign campaign,
    required String userId,
  });

  // ──────────────────────────────────────────────────────────────
  // Update Existing Campaign
  // ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> updateCampaign(
    String campaignId,
    Map<String, dynamic> payload,
  );

  // ──────────────────────────────────────────────────────────────
  // Upload Campaign Image
  // ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> uploadImage(List<File> imageFiles);

  // ──────────────────────────────────────────────────────────────
  // Create Donation (campaign-related)
  // ──────────────────────────────────────────────────────────────

  Future<bool> createDonation({
    required String userId,
    required String creatorId,
    required String campaignId,
    required int amount,
    String? nickname,
    String? comments,
    String? behalfUserId,
    String? externalName,
    String? externalContact,
  });

  // ──────────────────────────────────────────────────────────────
  // Get Campaign Approval Status
  // ──────────────────────────────────────────────────────────────

  Future<dynamic> getCampaignApprovalApi(String campaignId);

  // ──────────────────────────────────────────────────────────────
  // Donate To Campaign (New Endpoint)
  // ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getMyCampaigns();

  Future<Map<String, dynamic>> donateToCampaign(String campaignId, Map<String, dynamic> payload);

  // ──────────────────────────────────────────────────────────────
  // Get Campaign Donations (paginated)
  // ──────────────────────────────────────────────────────────────

  Future<CampaignDonationsResponseModel> getCampaignDonations({
    required String campaignId,
    required int page,
    int limit = 10,
  });

  // ──────────────────────────────────────────────────────────────
  // Get Top Donors (campaign leaderboard)
  // ──────────────────────────────────────────────────────────────

  Future<List<TopDonor>> getCampaignTopDonors(String campaignId);

  // ──────────────────────────────────────────────────────────────
  // Campaign Like / Unlike
  // ──────────────────────────────────────────────────────────────

  Future<bool> likeCampaign(String campaignId);
  Future<bool> unlikeCampaign(String campaignId);

  // ──────────────────────────────────────────────────────────────
  // Campaign Comments
  // ──────────────────────────────────────────────────────────────

  Future<List<CampaignComment>> getCampaignComments(String campaignId);
  Future<CampaignComment?> addCampaignComment({
    required String campaignId,
    required String content,
  });

  // ──────────────────────────────────────────────────────────────
  // Get Campaigns by Category
  // ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getCampaignsByCategory(String category, int page);
}