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
import 'package:intl/intl.dart';


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
                name: map['firstName'] as String? ?? map['name'] as String? ?? '',
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
  Future<List<Map<String, dynamic>>> uploadImage(List<File> imageFiles) async {
    try {
      final List<MultipartFile> multipartFiles = [];
      
      for (final imageFile in imageFiles) {
        final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
        multipartFiles.add(
          await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      final formData = FormData.fromMap({
        'files': multipartFiles,
      });

      final responseBody = await _apiClient.post(
        ApiRoute.uploadImageRoute,
        headers: header,
        body: formData,
        requiresToken: true,
      );

      final decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic> && decoded.containsKey('data') && decoded['data'] is List) {
        final List<dynamic> dataList = decoded['data'] as List<dynamic>;
        return dataList
            .whereType<Map<String, dynamic>>()
            .map((item) => {
                  'imageUrl': item['imageUrl'] as String? ?? '',
                  'providerId': item['providerId'] as String? ?? '',
                })
            .where((map) => (map['imageUrl'] as String).isNotEmpty)
            .toList();
      }

      log('Unexpected upload response format: $decoded');
      return [];
    } catch (e, stack) {
      log('Error uploading images: $e', stackTrace: stack);
      return [];
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

      // Convert provided date strings (likely dd/MM/yyyy) into ISO8601
      String? toIso(String? dateStr) {
        if (dateStr == null || dateStr.trim().isEmpty) return null;
        try {
          // Try common dd/MM/yyyy first
          final dt = DateFormat('dd/MM/yyyy').parseLoose(dateStr);
          return dt.toUtc().toIso8601String();
        } catch (e) {
          try {
            final dt = DateTime.parse(dateStr);
            return dt.toUtc().toIso8601String();
          } catch (_) {
            return dateStr; // fallback: send raw
          }
        }
      }

      final isoStart = toIso(campaign.startDate);
      final isoEnd = toIso(campaign.endDate);

      // If there are images, upload them all at once and collect URLs
      final List<Map<String, dynamic>> imageUrls = [];
      if (campaign.images.isNotEmpty) {
        try {
          final uploaded = await uploadImage(campaign.images);
          // Only add valid URLs
          for (final img in uploaded) {
            final url = img['imageUrl'] as String?;
            if (url != null && url.isNotEmpty) {
              imageUrls.add(img);
            }
          }
        } catch (e) {
          log('Warning: failed to upload images: $e');
        }
      }

      // Resolve category id: backend expects category ID, not display name.
      String? categoryId;
      try {
        final catResp = await _apiClient.get(
          ApiRoute.getCampaignCategories,
          requiresToken: false,
        );

        dynamic decodedCat;
        try {
          decodedCat = catResp is String ? jsonDecode(catResp) : catResp;
        } catch (_) {
          decodedCat = catResp;
        }

        List<dynamic> catList = [];
        if (decodedCat is Map<String, dynamic>) {
          catList = decodedCat['data'] as List<dynamic>? ?? decodedCat['categories'] as List<dynamic>? ?? [];
        } else if (decodedCat is List) {
          catList = decodedCat;
        }

        if (catList.isNotEmpty && campaign.category.isNotEmpty) {
          final match = catList.cast<Map<String, dynamic>>().firstWhere(
            (m) {
              final name = (m['name'] ?? m['title'] ?? m['label'] ?? '').toString();
              final id = m['id']?.toString() ?? m['_id']?.toString() ?? '';
              return id == campaign.category || name.toLowerCase() == campaign.category.toLowerCase();
            },
            orElse: () => {},
          );
          if (match.isNotEmpty) {
            categoryId = (match['id'] ?? match['_id'])?.toString();
          }
        }
      } catch (e) {
        log('Could not resolve category id: $e');
      }

      // Build JSON payload with properly typed fields
      // Build payload matching backend validation: remove 'id', 'stakeholders',
      // 'moffers', 'aoffers', and 'sharetitle' which the server rejects.
      // Map budgets to expected keys: use 'item' and 'image' (server expects 'item' and 'image').
      // Sanitize budgets: ensure numeric 'cost' and remove invalid keys
      final sanitizedBudgets = <Map<String, dynamic>>[];
      for (final b in campaign.budgets) {
        try {
          final item = b.name ?? '';
          final cost = (b.cost is num) ? b.cost : double.tryParse(b.cost.toString()) ?? 0.0;
          if (item.isEmpty || cost <= 0) continue;
          sanitizedBudgets.add({
            'item': item,
            'cost': cost,
            // only include image if it's an http(s) URL
            if (b.file != null && b.file!.path != null)
              'image': (b.file!.path!.startsWith('http') ? b.file!.path! : ''),
          });
        } catch (e) {
          log('Skipping invalid budget item: $e');
        }
      }

      final payload = <String, dynamic>{
        'title': campaign.title,
        'description': campaign.description,
        // Always include category as a string; prefer resolved id, fall back to provided name
        'category': (categoryId != null && categoryId.isNotEmpty) ? categoryId : campaign.category,
        'startDate': isoStart,
        'endDate': isoEnd,
        'target': campaign.amount.toInt(),
        'budget': sanitizedBudgets,
        if (imageUrls.isNotEmpty) 'images': imageUrls,
      };

      final bodyToSend = jsonEncode(payload);
      log('createCampaignApi - JSON payload: $bodyToSend');
      final response = await _apiClient.post(
        ApiRoute.createCampaignRoute,
        headers: header,
        body: bodyToSend,
        requiresToken: true,
      );

      if (response is String) {
        return jsonDecode(response);
      }
    } catch (e, stackTrace) {
      log('createCampaignApi failed: $e  :::::: $stackTrace');
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
    try {
      final responseBody = await _apiClient.get(
        '/campaigns?page=$page',
        requiresToken: true,
      );

      // Try decode JSON; if it fails, log and return an empty data list
      try {
        final decoded = jsonDecode(responseBody);

        if (decoded is Map<String, dynamic>) return decoded;

        if (decoded is List) return {'data': decoded};

        // unexpected root type -> wrap as data or return empty
        return {'data': []};
      } catch (e) {
        print('getAllCampaigns: failed to parse response JSON: $e');
        print('Raw response: $responseBody');
        return {'data': []};
      }
    } catch (e, stack) {
      print('getAllCampaigns failed: $e');
      print('Stack: $stack');
      return {'data': []};
    }
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