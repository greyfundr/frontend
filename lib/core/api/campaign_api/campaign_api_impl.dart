import 'dart:convert';
import 'dart:io';
import 'dart:developer'; // for log()

import 'package:dio/dio.dart';
import 'package:greyfundr/core/api/api_utils/api_route.dart';
import 'package:greyfundr/core/api/api_utils/app_client.dart';
import 'package:greyfundr/core/api/campaign_api/campaign_api.dart';
import 'package:greyfundr/core/models/campaign_model.dart';
import 'package:greyfundr/core/models/participants_model.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';


extension FilePathSafety on File {
  String get safeFileName {
    final path = this.path;
    if (path.isEmpty) return 'unnamed_image.jpg';
    return path.split('/').last;
  }
}



class CampaignApiImpl implements CampaignApi {
  final ApiClient _apiClient = ApiClient();

  Map<String, String> get header => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  @override
  Future<List<Participant>> getUsers() async {
    try {
      final response = await _apiClient.get(
        ApiRoute.getUserRoute,
        headers: header,
        requiresToken: true,
      );

      final dynamic decoded = jsonDecode(response);

      List<dynamic> rawList;

      if (decoded is List<dynamic>) {
        rawList = decoded;
      } else if (decoded is Map<String, dynamic>) {
        rawList = decoded['data'] as List<dynamic>? ??
                  decoded['users'] as List<dynamic>? ??
                  decoded['results'] as List<dynamic>? ??
                  decoded['members'] as List<dynamic>? ??
                  (throw Exception('No user list found in response'));
      } else {
        throw Exception('Unexpected root type: ${decoded.runtimeType}');
      }

      return rawList
          .whereType<Map<String, dynamic>>()
          .map((map) => Participant(
                id: map['id']?.toString() ?? map['_id']?.toString() ?? '',
                name: map['first_name'] as String? ?? map['name'] as String? ?? '',
                username: map['username'] as String? ?? map['email'] as String? ?? '',
                imageUrl: map['profile_pic'] as String? ??
                          map['avatar'] as String? ??
                          map['photo'] as String? ??
                          'assets/images/avatar.png',
              ))
          .toList();
    } catch (e, stack) {
      print('Error in getUsers(): $e');
      print('Stack: $stack');
      rethrow;
    }
  }


  @override
  Future<Map<String, dynamic>> getCampaignDetails(String campaignId) async {
    try {
      final responseBody = await _apiClient.get(
        '/campaign/getcampaign/$campaignId',
        requiresToken: true,
      );

      final data = jsonDecode(responseBody);

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid campaign response format: expected Map');
      }

      return data['payload'] ?? data['data'] ?? data;
    } catch (e, stack) {
      log('Error fetching campaign $campaignId: $e', stackTrace: stack);
      rethrow;
    }
  }




  @override
  Future<Map<String, dynamic>> updateCampaign(String campaignId, Map<String, dynamic> payload) async {
    try {
      final responseBody = await _apiClient.put(
        '/campaign/update/$campaignId',
        body: payload,
        requiresToken: true,
      );

      final decoded = jsonDecode(responseBody);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid update response format');
      }

      return decoded;
    } catch (e, stack) {
      log('Error updating campaign $campaignId: $e', stackTrace: stack);
      rethrow;
    }
  }



   @override
  Future<String?> uploadImage(File imageFile) async {
    try {
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
          contentType: MediaType.parse(mimeType),
        ),
      });

      final responseBody = await _apiClient.post(
        ApiRoute.uploadImageRoute,
        headers: header,
        body: formData,
        requiresToken: true,
      );

      final decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic> && decoded.containsKey('url')) {
        return decoded['url'] as String?;
      } else if (decoded is Map<String, dynamic> && decoded.containsKey('data') && decoded['data'] is Map) {
        return decoded['data']['url'] as String?;
      }

      log('Unexpected upload response format: $decoded');
      return null;
    } catch (e, stack) {
      log('Error uploading image: $e', stackTrace: stack);
      return null;
    }
  }



   @override
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
  }) async {
    try {
      final payload = {
        'user_id': userId,
        'creator_id': creatorId,
        'campaign_id': campaignId,
        'amount': amount,
        if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
        if (comments != null && comments.isNotEmpty) 'comments': comments,
        if (behalfUserId != null && behalfUserId.isNotEmpty) 'behalf_user_id': behalfUserId,
        if (externalName != null && externalName.isNotEmpty) 'external_name': externalName,
        if (externalContact != null && externalContact.isNotEmpty) 'external_contact': externalContact,
      };

      final responseBody = await _apiClient.post(
        '/donations',
        headers: header,
        body: payload,
        requiresToken: true,
      );

      final decoded = jsonDecode(responseBody);
      return responseBody != null && !decoded.toString().contains('error');
    } catch (e, stack) {
      log('createDonation failed: $e', stackTrace: stack);
      return false;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Campaign Creation
  // ──────────────────────────────────────────────────────────────

  @override
  Future<dynamic> createCampaignApi({
    required Campaign campaign,
    required String userId,
  }) async {
    try {
      // Prepare image files
      final List<MultipartFile> multipartImages = [];

      for (final File imageFile in campaign.images) {
        // Use the safe extension – completely null-safe
        final String fileName = imageFile.safeFileName;

        final String? mimeType = lookupMimeType(fileName) ?? 'image/jpeg';

        // Only add if path is valid
        if (imageFile.path.isNotEmpty) {
          multipartImages.add(
            await MultipartFile.fromFile(
              imageFile.path,
              filename: fileName,
              contentType: MediaType(
                mimeType!.split('/')[0],
                mimeType.split('/')[1],
              ),
            ),
          );
        }
      }

      // Build form data
      final formData = FormData.fromMap({
        "image": multipartImages.isNotEmpty ? multipartImages : null,

        'title': campaign.title ?? '',
        'description': campaign.description ?? '',
        'category': campaign.category ?? '',
        'startDate': campaign.startDate ?? '',
        'endDate': campaign.endDate ?? '',
        'amount': campaign.amount?.toString() ?? '0',
        'id': userId,
        'stakeholders': jsonEncode(campaign.participants ?? []),
        'budget': jsonEncode(campaign.budgets ?? []),
        'moffers': jsonEncode(campaign.savedManualOffers ?? []),
        'aoffers': jsonEncode(campaign.savedAutoOffers ?? []),
        'sharetitle': campaign.sharetitle ?? '',
      });

      // Clean up empty values
      formData.fields.removeWhere((e) => e.value.isEmpty);

      // Send request
      final response = await _apiClient.post(
        ApiRoute.createCampaignRoute,
        headers: header,
        body: formData,
        requiresToken: true,
      );

      // Handle response
      if (response is String) {
        return jsonDecode(response);
      }
      return response;
    } catch (e, stackTrace) {
      print('createCampaignApi failed: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }



  @override
 Future<dynamic> getCampaignApprovalApi(String campaignId) async {
  try {
    final response = await _apiClient.get(
      '${ApiRoute.getCampaignApprovalRoute}/$campaignId',
      headers: header,
      requiresToken: true,
    );

    // If _apiClient returns raw String (JSON), decode it
    if (response is String) {
      final decoded = jsonDecode(response);
      // Match your old code: return the "campaign" key if present
      return decoded is Map<String, dynamic> ? decoded['campaign'] : decoded;
    }

    // If already decoded map/list
    return response;
  } catch (e, stackTrace) {
    print('getCampaignApprovalApi failed: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}




// ──────────────────────────────────────────────────────────────
  // Get All Campaigns (paginated)
  // ──────────────────────────────────────────────────────────────

 @override
  Future<Map<String, dynamic>> getAllCampaigns({required int page}) async {
    final responseBody = await _apiClient.get(
      '/campaigns?page=$page',
      requiresToken: true,
    );
    return jsonDecode(responseBody);
  }

  // ──────────────────────────────────────────────────────────────
  // Get Campaigns (with optional category filter)
  // ──────────────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> getCampaigns({
    required int page,
    String? category,
  }) async {
    try {
      String url = '/campaigns?page=$page';
      if (category != null && category != "All" && category.isNotEmpty) {
        url += '&category=$category';
      }

      final responseBody = await _apiClient.get(
        url,
        requiresToken: false,
      );

      return jsonDecode(responseBody);
    } catch (e, stack) {
      log('getCampaigns failed (page $page, category: $category): $e', stackTrace: stack);
      rethrow;
    }
  }


  


   // ──────────────────────────────────────────────────────────────
  // Get Campaigns by Category (specific method)
  // ──────────────────────────────────────────────────────────────


  @override
Future<Map<String, dynamic>> getCampaignsByCategory(String category, int page) async {
  try {
    final url = '/campaigns?page=$page&category=$category';

    final responseBody = await _apiClient.get(
      url,
      requiresToken: false, // change to true if needed
    );

    final decoded = jsonDecode(responseBody);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid response format from getCampaignsByCategory');
    }

    return decoded;
  } catch (e, stack) {
    log('getCampaignsByCategory failed (page: $page, category: $category): $e', stackTrace: stack);
    rethrow;
  }
}




}