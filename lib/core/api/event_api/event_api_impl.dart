import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:greyfundr/core/api/api_utils/api_route.dart';
import 'package:greyfundr/core/api/api_utils/app_client.dart';
import 'package:greyfundr/core/api/event_api/event_api.dart';
import 'package:greyfundr/core/models/campaign_category_model.dart';
import 'package:greyfundr/core/models/event_details_model.dart';
import 'package:greyfundr/core/models/google_place_autocomplete_model.dart';
import 'package:greyfundr/core/models/user_event_model.dart';
import 'package:greyfundr/core/models/user_search_model.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class EventApiImpl implements EventApi {
  final ApiClient _apiClient = ApiClient();

  Map<String, String> get header => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  @override
  Future<List<CampaignCategoryModel>> getEventCategories() async {
    final response = await _apiClient.get(
      ApiRoute.getCampaignCategories,
      headers: header,
    );
    return campaignCategoryModelFromJson(response);
  }

  @override
  Future<PlaceAutocompleteModel> getAddressSuggestion({String? query}) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=${dotenv.env['GOOGLE_PLACE_API_KEY']}";
    final response = await _apiClient.get(
      url,
      headers: header,
      requiresToken: false,
    );

    return placeAutocompleteModelFromJson(response);
  }

  @override
  Future<List<UserSearchModel>> searchUserViaPhone({String? phone}) async {
    final response = await _apiClient.get(
      ApiRoute.searchUserRoute,
      headers: header,
      queryParameters: {"phoneNumber": phone},
    );
    return userSearchModelFromJson(response);
  }

  @override
  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      ApiRoute.createEventRoute,
      headers: header,
      body: payload,
    );
    return jsonDecode(response);
  }

  @override
  Future<void> updateEventDraft({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    await _apiClient.patch(
      ApiRoute.updateEventDraftRoute(id),
      headers: header,
      body: payload,
    );
  }

  @override
  Future<AllEventModel> getMyEvents() async {
    final response = await _apiClient.get(
      ApiRoute.getMyEventsRoute,
      headers: header,
    );
    return allEventModelFromJson(response);
  }

  @override
  Future<EventDetailsModel> getEventById(String id) async {
    final response = await _apiClient.get(
      ApiRoute.getEventByIdRoute(id),
      headers: header,
    );
    return eventDetailsModelFromJson(response);
  }

  @override
  Future<void> contributeToEvent({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    await _apiClient.post(
      ApiRoute.contributeToEventRoute(id),
      headers: header,
      body: payload,
    );
  }

  @override
  Future<List<dynamic>> getEventLeaderboard(String id) async {
    final response = await _apiClient.get(
      ApiRoute.getEventLeaderboardRoute(id),
      headers: header,
    );
    return jsonDecode(response);
  }

  @override
  Future<String?> uploadSingleImage(String filePath) async {
    try {
      final file = File(filePath);
      final multipart = await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
        contentType: lookupMimeType(file.path) != null
            ? MediaType.parse(lookupMimeType(file.path)!)
            : MediaType('image', 'jpeg'),
      );

      final formData = FormData.fromMap({'file': multipart});

      final responseBody = await _apiClient.post(
        ApiRoute.uploadSingleImageRoute,
        headers: header,
        formData: formData,
        requiresToken: true,
      );

      var decodedResponse = jsonDecode(responseBody);
      return decodedResponse['data']['imageUrl'];
    } catch (e) {
      log('Error uploading image: $e');
      return null;
    }
  }

  @override
  Future<AllEventModel> getAllEvents() async {
    final response = await _apiClient.get(
      ApiRoute.getAllEventsRoute,
      headers: header,
    );
    return allEventModelFromJson(response);
  }

  @override
  Future<AllEventModel> getMyRsvpedEvents() async {
    final response = await _apiClient.get(
      ApiRoute.getMyRsvpedEventsRoute,
      headers: header,
    );
    return allEventModelFromJson(response);
  }

  @override
  Future<void> rsvpToEvent({
    required String eventId,
    required Map<String, dynamic> payload,
  }) async {
    await _apiClient.post(
      ApiRoute.rsvpToEventRoute(eventId),
      headers: header,
      body: payload,
    );
  }

  @override
  Future<void> rsvpGuestToEvent({
    required String eventId,
    required Map<String, dynamic> payload,
  }) async {
    await _apiClient.post(
      ApiRoute.rsvpGuestToEventRoute(eventId),
      headers: header..remove('Authorization'), // Guests don't use auth
      body: payload,
    );
  }

  @override
  Future<void> updateRsvp({
    required String eventId,
    required String rsvpId,
    required Map<String, dynamic> payload,
  }) async {
    await _apiClient.patch(
      ApiRoute.updateRsvpRoute(eventId, rsvpId),
      headers: header,
      body: payload,
    );
  }

  @override
  Future<void> deleteRsvp({
    required String eventId,
    required String rsvpId,
  }) async {
    await _apiClient.delete(
      ApiRoute.deleteRsvpRoute(eventId, rsvpId),
      headers: header,
    );
  }

  @override
  Future<dynamic> getMyRsvp(String eventId) async {
    final response = await _apiClient.get(
      ApiRoute.getMyRsvpRoute(eventId),
      headers: header,
    );
    return response;
  }

  @override
  Future<dynamic> getAllRsvps(String eventId) async {
    final response = await _apiClient.get(
      ApiRoute.getAllRsvpsRoute(eventId),
      headers: header,
    );
    return response;
  }
}
