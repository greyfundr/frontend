import 'package:greyfundr/core/models/campaign_model.dart';
import 'package:greyfundr/core/models/participants_model.dart';

abstract class CampaignApi {

  Future<List<Participant>> getUsers();

  

  // ──────────────────────────────────────────────────────────────
  // Campaign Creation (new)
  // ──────────────────────────────────────────────────────────────

  Future<dynamic> createCampaignApi({
    required Campaign campaign,
    required String userId,
  });

  // NEW: Get campaign approval status
  Future<dynamic> getCampaignApprovalApi(String campaignId);
}