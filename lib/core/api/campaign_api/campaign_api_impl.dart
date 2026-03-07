import 'dart:convert';
import 'dart:io';

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




}