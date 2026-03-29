import 'package:greyfundr/core/models/campaign_category_model.dart';
import 'package:greyfundr/core/models/event_details_model.dart';
import 'package:greyfundr/core/models/google_place_autocomplete_model.dart';
import 'package:greyfundr/core/models/user_event_model.dart';
import 'package:greyfundr/core/models/user_search_model.dart';

abstract class EventApi {
  Future<List<CampaignCategoryModel>> getEventCategories();

  Future<PlaceAutocompleteModel> getAddressSuggestion({String query});

  Future<List<UserSearchModel>> searchUserViaPhone({String phone});

  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> payload);

  Future<void> updateEventDraft({
    required String id,
    required Map<String, dynamic> payload,
  });

  Future<AllEventModel> getMyEvents();

  Future<EventDetailsModel> getEventById(String id);

  Future<void> contributeToEvent({
    required String id,
    required Map<String, dynamic> payload,
  });

  Future<List<dynamic>> getEventLeaderboard(String id);

  Future<String?> uploadSingleImage(String filePath);

  Future<AllEventModel> getAllEvents();

  Future<AllEventModel> getMyRsvpedEvents();

  Future<void> rsvpToEvent({
    required String eventId,
    required Map<String, dynamic> payload,
  });

  Future<void> rsvpGuestToEvent({
    required String eventId,
    required Map<String, dynamic> payload,
  });

  Future<void> updateRsvp({
    required String eventId,
    required String rsvpId,
    required Map<String, dynamic> payload,
  });

  Future<void> deleteRsvp({required String eventId, required String rsvpId});

  Future<dynamic> getMyRsvp(String eventId);

  Future<dynamic> getAllRsvps(String eventId);
}
