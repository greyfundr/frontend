import 'dart:io';

import 'package:greyfundr/core/models/campaign_model.dart';
import 'package:greyfundr/core/models/participants_model.dart';

abstract class CampaignApi {
  // ──────────────────────────────────────────────────────────────
  // Users / Participants (used in campaign creation, split bill, etc.)
  // ──────────────────────────────────────────────────────────────

  Future<List<Participant>> getUsers();

  // ──────────────────────────────────────────────────────────────
  // Get All Campaigns (paginated, no filter)
  // ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAllCampaigns({
    required int page,
  });

  // ──────────────────────────────────────────────────────────────
  // Get Campaigns (paginated + optional category filter)
  // ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getCampaigns({
    required int page,
    String? category, // optional – e.g. "Education", "Health", "All"
  });

  // ──────────────────────────────────────────────────────────────
  // Get Single Campaign Details
  // ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getCampaignDetails(String campaignId);

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
  // Get Campaigns by Category
  // ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getCampaignsByCategory(String category, int page);
}