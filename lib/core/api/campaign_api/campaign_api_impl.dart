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

  @override
  Future<Map<String, dynamic>> donateToCampaign(String campaignId, Map<String, dynamic> payload) async {
    final url = ApiRoute.donateToCampaignRoute.replaceAll('{id}', campaignId);
    final response = await _apiClient.post(url, body: payload, requiresToken: true);
    return jsonDecode(response) as Map<String, dynamic>;
      return response as Map<String, dynamic>;
  }

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
                          '',
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
      final response = await _apiClient.get(
        '${ApiRoute.createCampaignRoute}/$campaignId',
        requiresToken: true,
      );

      final data = jsonDecode(response);

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
      final url = ApiRoute.updateCampaignRoute.replaceAll('{id}', campaignId);
      final responseBody = await _apiClient.patch(
        url,
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
      // Build payload using the backend's expected field names.
      final Map<String, dynamic> payload = {
        'amount': amount,
        // isAnonymous will be set by caller via nickname/anonymous logic; default false
      };

      // include username field when nickname provided
      if (nickname != null && nickname.isNotEmpty) {
        payload['username'] = nickname;
        payload['isAnonymous'] = false;
      } else {
        // if no nickname passed, mark anonymous
        payload['isAnonymous'] = true;
        // backend may still expect a generated username, but leave it absent
      }

      // onBehalfOf and related fields
      if (behalfUserId != null && behalfUserId.isNotEmpty) {
        // donating on behalf of a registered user
        // mark as a user-based on-behalf so backend uses the provided user id
        payload['onBehalfOf'] = 'user';
        payload['onBehalfOfUserId'] = behalfUserId;
      } else if (externalName != null && externalName.isNotEmpty) {
        // donating on behalf of an external person
        payload['onBehalfOf'] = 'external';
        payload['onBehalfOfExternal'] = {
          'fullName': externalName,
          'phoneNumber': externalContact ?? '',
        };
      } else {
        // default: donating for self (the authenticated user)
        payload['onBehalfOf'] = 'self';
        payload['onBehalfOfUserId'] = userId;
      }

      if (comments != null && comments.isNotEmpty) {
        payload['comment'] = comments;
      }

      // include linkage fields so backend can attribute donation
      payload['user_id'] = userId;
      payload['creator_id'] = creatorId;
      payload['campaign_id'] = campaignId;

      final donationsUrl = '${ApiRoute.baseUrl}/donations';
      try {
        final responseBody = await _apiClient.post(
          donationsUrl,
          headers: header,
          body: payload,
          requiresToken: true,
        );

        final decoded = jsonDecode(responseBody);
        if (!decoded.toString().contains('error')) {
          return true;
        }
      } catch (e) {
        // If donations endpoint is not found (404) or fails, we'll attempt
        // to use the campaign-specific donate endpoint as a fallback.
        log('donations endpoint failed, attempting campaign-specific donate: $e');
      }

      // Fallback to campaign-specific donate endpoint (avoid sending username)
      try {
        final donateUrl = ApiRoute.donateToCampaignRoute.replaceAll('{id}', campaignId);
        // Build a conservative payload that avoids `username` to prevent
        // server-side validation errors on the campaign donate endpoint.
        final Map<String, dynamic> fallback = {
          'amount': amount,
        };

        if (comments != null && comments.isNotEmpty) fallback['comment'] = comments;

        if (behalfUserId != null && behalfUserId.isNotEmpty) {
          // Same as above: indicate this is on behalf of another registered user
          fallback['onBehalfOf'] = 'user';
          fallback['onBehalfOfUserId'] = behalfUserId;
        } else if (externalName != null && externalName.isNotEmpty) {
          fallback['onBehalfOf'] = 'external';
          fallback['onBehalfOfExternal'] = {
            'fullName': externalName,
            'phoneNumber': externalContact ?? '',
          };
        } else {
          fallback['onBehalfOf'] = 'self';
          fallback['onBehalfOfUserId'] = userId;
        }

        final resp = await _apiClient.post(
          donateUrl,
          headers: header,
          body: fallback,
          requiresToken: true,
        );

        final decoded2 = jsonDecode(resp);
        return !decoded2.toString().contains('error');
      } catch (e, st) {
        log('Fallback donateToCampaign failed: $e', stackTrace: st);
        return false;
      }
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

        final String mimeType = lookupMimeType(fileName) ?? 'image/jpeg';

        // Only add if path is valid
        if (imageFile.path.isNotEmpty) {
          multipartImages.add(
            await MultipartFile.fromFile(
              imageFile.path,
              filename: fileName,
              contentType: MediaType(
                mimeType.split('/')[0],
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
          decodedCat = jsonDecode(catResp);
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

      
      final sanitizedBudgets = <Map<String, dynamic>>[];
      for (final b in campaign.budgets) {
        try {
          final item = b.name ?? '';
          final cost = (b.cost is num) ? b.cost : double.tryParse(b.cost.toString()) ?? 0.0;
          if (item.isEmpty || cost <= 0) continue;
          sanitizedBudgets.add({
            'item': item,
            'cost': cost,
            // Backend requires an 'image' string, even if empty.
            'image': (b.file?.path?.startsWith('http') ?? false) ? b.file!.path! : '',
          });
        } catch (e) {
          log('Skipping invalid budget item: $e');
        }
      }

     
      final sanitizedOffers = <Map<String, dynamic>>[];

      // DEBUG: log offers received on Campaign model before sanitization
      try {
        log('createCampaignApi - campaign.savedManualOffers: ${campaign.savedManualOffers}');
        log('createCampaignApi - campaign.savedAutoOffers: ${campaign.savedAutoOffers}');
      } catch (_) {}

      // Process 'manual' offers (assuming from campaign.moffers)
      if (campaign.savedManualOffers.isNotEmpty) {
        for (final offer in campaign.savedManualOffers) {
          
          final condition = offer['condition'] ?? offer['name'] ?? '';
          final reward = offer['reward'] ?? offer['description'] ?? '';
          if (condition.isNotEmpty) {
            sanitizedOffers.add({
              'type': 'manual',
              'condition': condition,
              'reward': reward,
            });
          }
        }
      }

      // Process 'auto' offers (assuming from campaign.aoffers)
      if (campaign.savedAutoOffers.isNotEmpty) {
        for (final offer in campaign.savedAutoOffers) {
          final condition = offer['condition'] ?? offer['name'] ?? '';
          final reward = offer['reward'] ?? offer['description'] ?? '';
          if (condition.isNotEmpty) {
            sanitizedOffers.add(
                {'type': 'auto', 'condition': condition, 'reward': reward});
          }
        }
      }

      // DEBUG: log sanitizedOffers before sending
      try {
        log('createCampaignApi - sanitizedOffers: $sanitizedOffers');
      } catch (_) {}

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
        if (sanitizedOffers.isNotEmpty) 'offers': sanitizedOffers,
      };

      final bodyToSend = jsonEncode(payload);
      log('createCampaignApi - JSON payload: $bodyToSend');
      final response = await _apiClient.post(
        ApiRoute.createCampaignRoute,
        headers: header,
        body: bodyToSend,
        requiresToken: true,
      );

      return jsonDecode(response);
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
    final decoded = jsonDecode(response);
    // Match your old code: return the "campaign" key if present
    return decoded is Map<String, dynamic> ? decoded['campaign'] : decoded;
  
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
        '${ApiRoute.createCampaignRoute}?page=$page',
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
      // Use queryParameters map for cleaner URL construction and safe encoding
      final Map<String, dynamic> queryParams = {'page': page};
      if (category != null && category != "All" && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      final responseBody = await _apiClient.get(
        ApiRoute.createCampaignRoute,
        queryParameters: queryParams,
        requiresToken: true,
      );

      final decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded is List) {
        // Wrap the list in a map with a 'data' key so the UI can consume it consistently
        return {'data': decoded};
      }

      return {'data': []};
    } catch (e, stack) {
      log('getCampaigns failed (page $page, category: $category): $e', stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMyCampaigns() async {
    try {
      final response = await _apiClient.get(
        ApiRoute.getMyCampaignsRoute,
        requiresToken: true,
      );

      final data = jsonDecode(response);

      if (data is Map<String, dynamic>) {
        final list = data['data'] ?? data['campaigns'] ?? data['payload'];
        if (list is List) {
          return list.cast<Map<String, dynamic>>();
        }
      }

      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }

      log('Unexpected response format for user campaigns: $data');
      return []; // Return empty list on unexpected format
    } catch (e, stack) {
      log('Error fetching my campaigns: $e', stackTrace: stack);
      rethrow;
    }
  }


  


   // ──────────────────────────────────────────────────────────────
  // Get Campaigns by Category (specific method)
  // ──────────────────────────────────────────────────────────────


  @override
Future<Map<String, dynamic>> getCampaignsByCategory(String category, int page) async {
  try {
    // Using query params ensures the category string is properly encoded
    final queryParams = {'page': page, 'category': category};

    final responseBody = await _apiClient.get(
      ApiRoute.createCampaignRoute,
      queryParameters: queryParams,
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