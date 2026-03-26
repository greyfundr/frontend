import 'package:greyfundr/core/models/campaign_category_model.dart';
import 'package:greyfundr/core/models/google_place_autocomplete_model.dart';
import 'package:greyfundr/core/models/user_event_model.dart';
import 'package:greyfundr/core/models/user_search_model.dart';

abstract class EventApi {
  Future<List<CampaignCategoryModel>> getEventCategories();

  Future<PlaceAutocompleteModel> getAddressSuggestion({String query});

  Future<List<UserSearchModel>> searchUserViaPhone({String phone});

  Future<void> createEvent(Map<String, dynamic> payload);

  Future<String?> uploadSingleImage(String filePath);

  Future<List<AllEventModel>> getAllEvents();
}