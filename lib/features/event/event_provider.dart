import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/core/models/event_details_model.dart';
import 'package:greyfundr/core/models/google_place_autocomplete_model.dart';
import 'package:greyfundr/core/models/user_event_model.dart';
import 'package:greyfundr/core/models/user_search_model.dart';
import 'package:greyfundr/services/user_local_storage_service.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:greyfundr/core/api/event_api/event_api.dart';
import 'package:greyfundr/core/models/campaign_category_model.dart';
import 'package:greyfundr/services/locator.dart';
import 'package:greyfundr/shared/responsiveState/base_view_model.dart';
import 'package:greyfundr/shared/responsiveState/view_state.dart';

// Helper models

class EventDetailSection {
  // rsvp

  String title;
  String text;
  List<XFile> media; // URLs or paths
  List<String> existingMediaUrls;
  EventDetailSection({
    this.title = "",
    required this.text,
    List<XFile>? media,
    List<String>? existingMediaUrls,
  }) : media = media ?? [],
       existingMediaUrls = existingMediaUrls ?? [];

  Map<String, dynamic> toJson() => {
    "title": title,
    "text": text,
    "media": media.map((e) => e.path).toList(),
  };
}

class PurchasableItem {
  String name;
  List<XFile> images;
  List<String> existingImageUrls;
  double price;
  int quantity;
  PurchasableItem({
    required this.name,
    required this.price,
    required this.quantity,
    this.images = const [],
    this.existingImageUrls = const [],
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "images": images.map((e) => e.path).toList(),
    "price": price,
    "quantity": quantity,
  };
}

class EventActivity {
  String name;
  String description;
  XFile? image;
  String? existingImageUrl;
  double targetAmount;
  String time; // Keep as string for now or DateTime

  EventActivity({
    required this.name,
    required this.description,
    this.image,
    this.existingImageUrl,
    required this.targetAmount,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "image": image?.path,
    "description": description,
    "targetAmount": targetAmount,
    "time": time,
  };
}

class EventProvider extends BaseNotifier {
  final EventApi _eventApi = locator<EventApi>();
  List<CampaignCategoryModel> eventCategoriesList = [];

  String selectedNameToRsvp = "";
  String selectedNameValue = "";
  bool isSelected(String identity) => selectedNameToRsvp == identity;

  setNameToRsvp(String name, value) {
    selectedNameToRsvp = name;
    selectedNameValue = value;
    notifyListeners();
  }

  String? eventId;
  late final PageController pageController;
  int currentStep = 0;
  List<String> existingCoverImageUrls = [];

  EventProvider({EventDatum? draftEvent}) {
    if (draftEvent != null) {
      resumeEventDraft(draftEvent);
    }
    pageController = PageController(initialPage: currentStep);
  }

  void resumeEventDraft(EventDatum event) {
    eventId = event.id;
    // ensure pageNumber is valid
    if (event.pageNumber != null) {
      currentStep = event.pageNumber!;
      if (currentStep > 4) currentStep = 4;
    }

    nameCtrl.text = event.name ?? "";
    hashtagCtrl.text = event.hashtag ?? "";
    shortDescCtrl.text = event.shortDescription ?? "";
    categoryCtrl.text = event.category?.name ?? event.categoryId ?? "";
    visibilityStatusCtrl.text = event.visibilityStatus == "private"
        ? "Private (Invite Only)"
        : "Public (Anyone can RSVP)";

    selectedDate = event.startDateTime;
    if (event.startTime != null && event.startTime!.isNotEmpty) {
      try {
        selectedTime = DateTime.parse(event.startTime!);
      } catch (_) {}
    }
    if (event.endDateTime != null) {
      endDate = event.endDateTime;
      spanMultipleDays = true;
    }

    existingCoverImageUrls = List<String>.from(event.coverImages ?? const []);

    if ((event.detailedDescription?.isNotEmpty ?? false)) {
      for (var ctrl in detailTitleControllers) {
        ctrl.dispose();
      }
      for (var ctrl in detailControllers) {
        ctrl.dispose();
      }
      detailedDescription = [];
      detailTitleControllers = [];
      detailControllers = [];

      for (final detail in event.detailedDescription!) {
        detailedDescription.add(
          EventDetailSection(
            title: detail.title ?? "title",
            text: detail.text ?? "",
            existingMediaUrls: List<String>.from(detail.media ?? const []),
          ),
        );
        detailTitleControllers.add(TextEditingController());
        detailControllers.add(TextEditingController(text: detail.text ?? ""));
      }
    }

    purchasableItems = [];
    if ((event.purchasableItems?.isNotEmpty ?? false)) {
      for (final item in event.purchasableItems!) {
        if (item is Map<String, dynamic>) {
          purchasableItems.add(
            PurchasableItem(
              name: item['name']?.toString() ?? '',
              price: _toDouble(item['price']),
              quantity: _toInt(item['quantity']),
              existingImageUrls: _toStringList(item['images']),
            ),
          );
        }
      }
    }

    activities = [];
    if ((event.activities?.isNotEmpty ?? false)) {
      for (final activity in event.activities!) {
        if (activity is Map<String, dynamic>) {
          activities.add(
            EventActivity(
              name: activity['name']?.toString() ?? '',
              description: activity['description']?.toString() ?? '',
              targetAmount: _toDouble(activity['targetAmount']),
              time: _normalizeDateTimeString(activity['time']),
              existingImageUrl: activity['image']?.toString(),
            ),
          );
        }
      }
    }

    venueNameCtrl.text = event.venueName ?? "";
    if (event.location != null) {
      location['address'] = event.location?.address ?? "";
      location['lat'] = event.location?.lat ?? 0.0;
      location['lng'] = event.location?.lng ?? 0.0;
      locationAddressCtrl.text = event.location?.address ?? "";
      locationDescCtrl.text = event.location?.locationDescription ?? "";
    }

    targetAmountCtrl.text = event.targetAmount?.toString() ?? "";
    expectedParticipantsCtrl.text =
        event.expectedParticipants?.toString() ?? "";
    acceptDonations = event.acceptDonations ?? false;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  String _normalizeDateTimeString(dynamic value) {
    if (value == null) return DateTime.now().toIso8601String();
    final raw = value.toString();
    try {
      return DateTime.parse(raw).toIso8601String();
    } catch (_) {
      return DateTime.now().toIso8601String();
    }
  }

  Future<void> nextStep() async {
    if (currentStep < 4) {
      bool success = await processStepApi();
      if (!success) return;

      currentStep++;
      pageController.animateToPage(
        currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  Future<bool> processStepApi() async {
    try {
      if (currentStep == 0 && eventId == null) {
        return await _createInitialEvent();
      } else if (eventId != null) {
        return await _updateEventDraft();
      }
      return true;
    } catch (e) {
      log("Error processing step API: $e");
      return false;
    }
  }

  Future<bool> _createInitialEvent() async {
    try {
      EasyLoading.show(status: "Uploading images...");
      List<String> uploadedCoverUrls = [];
      for (var image in coverImages) {
        String? url = await _eventApi.uploadSingleImage(image.path);
        if (url != null) uploadedCoverUrls.add(url);
      }

      EasyLoading.show(status: "Creating event...");
      final payload = {
        "name": nameCtrl.text,
        "hashtag": hashtagCtrl.text,
        "shortDescription": shortDescCtrl.text,
        "category": categoryCtrl.text,
        // "visibilityStatus": visibilityStatusCtrl.text.toLowerCase().contains("private") ? "private" : "public",
        "coverImages": uploadedCoverUrls,
        "startDateTime": selectedDate?.toIso8601String(),
        "startTime": selectedTime?.toIso8601String(),
        "spanMultipleDays": spanMultipleDays,
        "endDateTime": endDate?.toIso8601String(),
        // "pageNumber": 1,
      };

      final response = await _eventApi.createEvent(payload);
      eventId = response['id'];
      getAllEvents();
      getMyEvents();

      notifyListeners();
      return true;
    } catch (e) {
      log("Error creating initial event: $e");
      showErrorToast("Failed to create event");
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> _updateEventDraft() async {
    if (eventId == null) return false;
    try {
      EasyLoading.show(status: "Updating draft...");
      final payload = await _generateStepPayload();
      // Skip hitting the update endpoint if no data to update (e.g. no organizers)
      if (payload == null) return true;

      payload['pageNumber'] = currentStep + 1;

      await _eventApi.updateEventDraft(id: eventId!, payload: payload);
      return true;
    } catch (e) {
      log("Error updating event draft: $e");
      showErrorToast("Failed to update event draft");
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<Map<String, dynamic>?> _generateStepPayload() async {
    switch (currentStep) {
      case 1: // Organizers
        if (organizers.isEmpty) return null;
        return {
          "internalOrganizers": organizers
              .map((o) => {"userId": o.id, "role": "co-organizer"})
              .toList(),
        };
      case 2: // Detailed Description
        List<Map<String, dynamic>> sections = [];
        for (var section in detailedDescription) {
          List<String> mediaUrls = [];
          for (var media in section.media) {
            String? url = await _eventApi.uploadSingleImage(media.path);
            if (url != null) mediaUrls.add(url);
          }
          sections.add({
            "title": section.title,
            "text": section.text,
            "media": [...section.existingMediaUrls, ...mediaUrls],
          });
        }
        return {"detailedDescription": sections};
      case 3: // Location
        return {
          "location": {
            "venueName": venueNameCtrl.text,
            "locationDescription": locationDescCtrl.text,
            "lat": location['lat'],
            "lng": location['lng'],
            "address": location['address'],
          },
        };
      case 4: // Financing
        List<Map<String, dynamic>> items = [];
        for (var item in purchasableItems) {
          List<String> itemImages = [];
          for (var img in item.images) {
            String? url = await _eventApi.uploadSingleImage(img.path);
            if (url != null) itemImages.add(url);
          }
          items.add({
            "name": item.name,
            "price": item.price,
            "quantity": item.quantity,
            "images": [...item.existingImageUrls, ...itemImages],
          });
        }

        List<Map<String, dynamic>> acts = [];
        for (var act in activities) {
          String? actImg;
          if (act.image != null) {
            actImg = await _eventApi.uploadSingleImage(act.image!.path);
          }
          acts.add({
            "name": act.name,
            "description": act.description,
            "targetAmount": act.targetAmount,
            "time": act.time,
            "image": actImg ?? act.existingImageUrl ?? "",
          });
        }

        return {
          "targetAmount":
              double.tryParse(targetAmountCtrl.text.replaceAll(',', '')) ?? 0.0,
          "expectedParticipants":
              int.tryParse(expectedParticipantsCtrl.text) ?? 0,
          "purchasableItems": items,
          "acceptDonations": acceptDonations,
          "activities": acts,
        };
      default:
        return {};
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      currentStep--;
      pageController.animateToPage(
        currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  void skipStep() {
    if (currentStep < 4) {
      currentStep++;
      pageController.animateToPage(
        currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  void setStep(int step) {
    if (step >= 0 && step <= 4) {
      currentStep = step;
      notifyListeners();
    }
  }

  late TabController billOutletTabController;

  bool get isStepValid {
    switch (currentStep) {
      case 0: // Basic Info
        return nameCtrl.text.isNotEmpty &&
            categoryCtrl.text.isNotEmpty &&
            visibilityStatusCtrl.text.isNotEmpty &&
            selectedDate != null &&
            selectedTime != null &&
            (coverImages.isNotEmpty || existingCoverImageUrls.isNotEmpty);
      case 1: // Organizers (Optional)
        return true;
      case 2: // Detailed Description (Optional)
        return true;
      case 3: // Location & Venue
        return venueNameCtrl.text.isNotEmpty &&
            locationAddressCtrl.text.isNotEmpty;
      case 4: // Financing & Activities
        return expectedParticipantsCtrl.text.isNotEmpty;
      default:
        return true;
    }
  }

  initBillOutletController(TickerProvider ticker) {
    billOutletTabController = TabController(
      length: 3,
      vsync: ticker,
      initialIndex: 0,
    );
    billOutletTabController.addListener(() {
      if (!billOutletTabController.indexIsChanging) {
        notifyListeners();
        // setState(() {});
      }
    });
  }

  // Step 1: Names and Co
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController hashtagCtrl = TextEditingController();
  final TextEditingController shortDescCtrl = TextEditingController();
  final TextEditingController categoryCtrl = TextEditingController();
  final TextEditingController visibilityStatusCtrl = TextEditingController(
    text: "Public",
  );

  void setCategory(String category) {
    categoryCtrl.text = category;
    if (category.toLowerCase() == "wedding") {
      // Clear existing sections
      detailedDescription.clear();
      for (var ctrl in detailTitleControllers) {
        ctrl.dispose();
      }
      for (var ctrl in detailControllers) {
        ctrl.dispose();
      }
      detailTitleControllers.clear();
      detailControllers.clear();

      // Add Groom section
      detailedDescription.add(EventDetailSection(title: "Groom", text: ""));
      detailTitleControllers.add(TextEditingController(text: "Groom"));
      detailControllers.add(TextEditingController());

      // Add Bride section
      detailedDescription.add(EventDetailSection(title: "Bride", text: ""));
      detailTitleControllers.add(TextEditingController(text: "Bride"));
      detailControllers.add(TextEditingController());
    }
    notifyListeners();
  }

  List<XFile> coverImages = [];

  DateTime? selectedDate;
  DateTime? selectedTime;

  bool spanMultipleDays = false;
  DateTime? endDate;

  void toggleSpanMultipleDays(bool val) {
    spanMultipleDays = val;
    notifyListeners();
  }

  void addCoverImages(List<XFile> images) {
    coverImages.addAll(images);
    notifyListeners();
  }

  void removeExistingCoverImageUrl(int index) {
    if (index >= 0 && index < existingCoverImageUrls.length) {
      existingCoverImageUrls.removeAt(index);
      notifyListeners();
    }
  }

  void removeCoverImage(int index) {
    if (index >= 0 && index < coverImages.length) {
      coverImages.removeAt(index);
      notifyListeners();
    }
  }

  // Step 2: Organizers
  final TextEditingController organizerPhoneCtrl = TextEditingController();
  List<UserSearchModel> organizers = [];

  checkPhoneField() {
    if (organizerPhoneCtrl.text.length == 11) {
      searchUserViaPhone(phone: formatPhoneNumber(organizerPhoneCtrl.text));
    } else {
      userSearchModel?.clear();
      notifyListeners();
    }
  }

  void addOrganizer() {
    // ensure number is not the user's own number
    if (organizerPhoneCtrl.text == UserLocalStorageService().getUserId()) {
      showErrorToast("You cannot add yourself as an organizer");
      return;
    }

    if (organizerPhoneCtrl.text.isNotEmpty &&
        (userSearchModel?.isNotEmpty ?? false)) {
      organizers.add(userSearchModel![0]);
      organizerPhoneCtrl.clear();
      userSearchModel?.clear();
      notifyListeners();
    }
  }

  void removeOrganizer(int index) {
    organizers.removeAt(index);
    notifyListeners();
  }

  // Step 3: Detailed Description
  List<EventDetailSection> detailedDescription = [EventDetailSection(text: "")];
  List<TextEditingController> detailTitleControllers = [
    TextEditingController(),
  ];
  List<TextEditingController> detailControllers = [TextEditingController()];

  void addDetailSection() {
    detailedDescription.add(EventDetailSection(text: ""));
    detailTitleControllers.add(TextEditingController());
    detailControllers.add(TextEditingController());
    notifyListeners();
  }

  void removeDetailSection(int index) {
    if (detailedDescription.length > 1) {
      detailedDescription.removeAt(index);
      detailTitleControllers[index].dispose();
      detailTitleControllers.removeAt(index);
      detailControllers[index].dispose();
      detailControllers.removeAt(index);
      notifyListeners();
    }
  }

  void updateDetailSectionTitle(int index, String title) {
    detailedDescription[index].title = title;
  }

  void updateDetailSectionText(int index, String text) {
    detailedDescription[index].text = text;
    // Don't notify listeners on every keystroke, controller handles the UI updates
  }

  void addMediaToDetailSection(int index, List<XFile> newMedia) {
    detailedDescription[index].media.addAll(newMedia);
    notifyListeners();
  }

  void removeMediaFromDetailSection(int sectionIndex, int mediaIndex) {
    detailedDescription[sectionIndex].media.removeAt(mediaIndex);
    notifyListeners();
  }

  void removeExistingMediaFromDetailSection(int sectionIndex, int mediaIndex) {
    detailedDescription[sectionIndex].existingMediaUrls.removeAt(mediaIndex);
    notifyListeners();
  }

  // Step 4: Location and Venue
  final TextEditingController venueNameCtrl = TextEditingController();
  final TextEditingController locationDescCtrl = TextEditingController();
  final TextEditingController locationAddressCtrl = TextEditingController();

  Map<String, dynamic> location = {'lat': 0.0, 'lng': 0.0, 'address': ''};

  void updateLocation(double lat, double lng, String address) {
    location['lat'] = lat;
    location['lng'] = lng;
    location['address'] = address;
    locationAddressCtrl.text = address;
    log("::::::$address");
    notifyListeners();
  }

  // Step 5: Financing, Purchase, Activities
  final TextEditingController targetAmountCtrl = TextEditingController();
  final TextEditingController expectedParticipantsCtrl =
      TextEditingController();

  bool acceptDonations = false;
  void toggleAcceptDonations(bool val) {
    acceptDonations = val;
    notifyListeners();
  }

  List<PurchasableItem> purchasableItems = [];
  List<EventActivity> activities = [];

  void addPurchasableItem(PurchasableItem item) {
    purchasableItems.add(item);
    notifyListeners();
  }

  void removePurchasableItem(int index) {
    purchasableItems.removeAt(index);
    notifyListeners();
  }

  void addActivity(EventActivity activity) {
    activities.add(activity);
    notifyListeners();
  }

  void removeActivity(int index) {
    activities.removeAt(index);
    notifyListeners();
  }

  Future<void> getEventCategories() async {
    try {
      if (eventCategoriesList.isNotEmpty) return;
      eventCategoriesList = await _eventApi.getEventCategories();
    } catch (e) {
      log("Error fetching event categories: $e");
    }
  }

  List<UserSearchModel>? userSearchModel;
  Future<void> searchUserViaPhone({required String phone}) async {
    try {
      EasyLoading.show();
      var res = await _eventApi.searchUserViaPhone(phone: phone);
      if (res.isNotEmpty) {
        userSearchModel = res;
        notifyListeners();
      } else {
        userSearchModel = [];
        showErrorToast("No user found with that phone number");
        notifyListeners();
      }
    } catch (e) {
      log("Error searching user via phone: $e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  PlaceAutocompleteModel? addressSuggestions;
  ViewState addressSuggestionState = ViewState.Idle;

  void clearAddressSuggestions() {
    addressSuggestions = null;
    notifyListeners();
  }

  Future<bool> getAddressSuggestion({String? query}) async {
    setCustomState(ViewState state) {
      addressSuggestionState = state;
      notifyListeners();
    }

    try {
      if (query == null || query.isEmpty) {
        addressSuggestions = null;
        notifyListeners();
        return false;
      }
      setCustomState(ViewState.Busy);
      final response = await _eventApi.getAddressSuggestion(query: query);
      addressSuggestions = response;
      if (response.predictions?.isNotEmpty ?? false) {
        setCustomState(ViewState.Success);
        return true;
      }
      setCustomState(ViewState.NoDataAvailable);
      return false;
    } catch (e) {
      setCustomState(ViewState.Error);
      return false;
    }
  }

  Map<String, dynamic> generatePayload({
    required List<String> coverImageUrls,
    required List<Map<String, dynamic>> detailedDescriptionData,
    required List<Map<String, dynamic>> purchasableItemsData,
    required List<Map<String, dynamic>> activitiesData,
  }) {
    return {
      "name": nameCtrl.text,
      "hashtag": hashtagCtrl.text,
      "shortDescription": shortDescCtrl.text,
      "category": categoryCtrl.text,
      "coverImages": coverImageUrls,
      "startDateTime": selectedDate?.toIso8601String(),
      "startTime": selectedTime?.toIso8601String(),
      "spanMultipleDays": spanMultipleDays,
      "endDateTime": endDate?.toIso8601String(),
      "internalOrganizers": organizers
          .map((o) => {"userId": o.id, "role": "co-organizer"})
          .toList(),
      "detailedDescription": detailedDescriptionData,
      "location": {
        "venueName": venueNameCtrl.text,
        "locationDescription": locationDescCtrl.text,
        "lat": location['lat'],
        "lng": location['lng'],
        "address": location['address'],
      },
      "financing": {
        "targetAmount":
            double.tryParse(targetAmountCtrl.text.replaceAll(',', '')) ?? 0.0,
        "expectedParticipants":
            int.tryParse(expectedParticipantsCtrl.text) ?? 0,
        "purchasableItems": purchasableItemsData,
        "acceptDonations": acceptDonations,
        "activities": activitiesData,
      },
    };
  }

  List<EventDatum>? allEvents;
  List<EventDatum>? liveEvents;
  List<EventDatum>? upcomingEvents;
  Set<String> myRsvpedEventIds = <String>{};
  bool isRsvpedEvent(String? eventId) =>
      eventId != null && myRsvpedEventIds.contains(eventId);
  ViewState allEventsState = ViewState.Idle;
  Future<void> getAllEvents() async {
    setCustomState(ViewState state) {
      allEventsState = state;
      notifyListeners();
    }

    try {
      setCustomState(ViewState.Busy);
      final publicEventsRes = await _eventApi.getAllEvents();
      final rsvpedEventsRes = await _eventApi.getMyRsvpedEvents();

      myRsvpedEventIds = (rsvpedEventsRes.events ?? [])
          .map((e) => e.id)
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toSet();

      final combined = <EventDatum>[
        ...(publicEventsRes.events ?? []),
        ...(rsvpedEventsRes.events ?? []),
      ];

      final dedupedMap = <String, EventDatum>{};
      for (final event in combined) {
        if (event.id != null && event.id!.isNotEmpty) {
          dedupedMap[event.id!] = event;
        }
      }

      final mergedEvents = dedupedMap.values.toList();

      final now = DateTime.now();
      final todayOnly = DateTime(now.year, now.month, now.day);

      liveEvents = mergedEvents.where((event) {
        final start = event.startDateTime;
        if (start == null) return false;
        final eventDay = DateTime(start.year, start.month, start.day);
        return eventDay == todayOnly;
      }).toList();

      upcomingEvents = mergedEvents.where((event) {
        final start = event.startDateTime;
        if (start == null) return false;
        final eventDay = DateTime(start.year, start.month, start.day);
        return eventDay.isAfter(todayOnly);
      }).toList();

      allEvents = mergedEvents;

      if (mergedEvents.isNotEmpty) {
        notifyListeners();
        setCustomState(ViewState.Success);
      } else {
        setCustomState(ViewState.NoDataAvailable);
      }
    } catch (e, stackTrace) {
      log("Error fetching all events: $e :::: $stackTrace");
      setCustomState(ViewState.Error);
    }
  }

  List<EventDatum>? myEvents;
  ViewState myEventsState = ViewState.Idle;
  Future<void> getMyEvents() async {
    try {
      myEventsState = ViewState.Busy;
      notifyListeners();
      var res = await _eventApi.getMyEvents();
      if (res.events?.isNotEmpty ?? false) {
        myEvents = res.events;
        notifyListeners();
        myEventsState = ViewState.Success;
      } else {
        myEventsState = ViewState.NoDataAvailable;
      }
    } catch (e) {
      log("Error fetching my events: $e");
      myEventsState = ViewState.Error;
    } finally {
      notifyListeners();
    }
  }

  EventDetailsModel? eventDetailsModel;
  ViewState selectedEventState = ViewState.Idle;
  Future<void> getEventById(String id) async {
    try {
      selectedEventState = ViewState.Busy;
      notifyListeners();
      eventDetailsModel = await _eventApi.getEventById(id);
      selectedEventState = ViewState.Success;
      notifyListeners();
    } catch (e, stackTrace) {
      log("Error fetching event by id: $e ::: $stackTrace");
      selectedEventState = ViewState.Error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> contributeToEvent(
    String id,
    Map<String, dynamic> payload,
  ) async {
    try {
      EasyLoading.show(status: "Processing contribution...");
      await _eventApi.contributeToEvent(id: id, payload: payload);
      showSuccessToast("Contribution successful");
    } catch (e) {
      log("Error contributing to event: $e");
      showErrorToast("Contribution failed");
    } finally {
      EasyLoading.dismiss();
    }
  }

  List<dynamic>? leaderboard;
  ViewState leaderboardState = ViewState.Idle;
  Future<void> getEventLeaderboard(String id) async {
    try {
      leaderboardState = ViewState.Busy;
      notifyListeners();
      leaderboard = await _eventApi.getEventLeaderboard(id);
      leaderboardState = ViewState.Success;
    } catch (e) {
      log("Error fetching leaderboard: $e");
      leaderboardState = ViewState.Error;
    } finally {
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────────────────────
  // RSVP Methods
  // ──────────────────────────────────────────────────────────────

  Future<bool> rsvpToEvent({
    required String eventId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      EasyLoading.show(status: "Submitting RSVP...");
      await _eventApi.rsvpToEvent(eventId: eventId, payload: payload);
      showSuccessToast("RSVP submitted successfully");
      return true;
    } catch (e) {
      log("Error submitting RSVP: $e");
      showErrorToast("$e");
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> rsvpGuestToEvent({
    required String eventId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      EasyLoading.show(status: "Submitting RSVP...");
      await _eventApi.rsvpGuestToEvent(eventId: eventId, payload: payload);
      showSuccessToast("Guest RSVP submitted successfully");
    } catch (e) {
      log("Error submitting guest RSVP: $e");
      showErrorToast("Failed to submit guest RSVP");
      rethrow;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> updateRsvp({
    required String eventId,
    required String rsvpId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      EasyLoading.show(status: "Updating RSVP...");
      await _eventApi.updateRsvp(
        eventId: eventId,
        rsvpId: rsvpId,
        payload: payload,
      );
      showSuccessToast("RSVP updated successfully");
    } catch (e) {
      log("Error updating RSVP: $e");
      showErrorToast("Failed to update RSVP");
      rethrow;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> deleteRsvp({
    required String eventId,
    required String rsvpId,
  }) async {
    try {
      EasyLoading.show(status: "Deleting RSVP...");
      await _eventApi.deleteRsvp(eventId: eventId, rsvpId: rsvpId);
      showSuccessToast("RSVP deleted successfully");
    } catch (e) {
      log("Error deleting RSVP: $e");
      showErrorToast("Failed to delete RSVP");
      rethrow;
    } finally {
      EasyLoading.dismiss();
    }
  }

  dynamic myRsvp;
  ViewState myRsvpState = ViewState.Idle;
  Future<void> getMyRsvp(String eventId) async {
    setCustomState(ViewState state) {
      myRsvpState = state;
      notifyListeners();
    }

    try {
      setCustomState(ViewState.Busy);
      final rsvp = await _eventApi.getMyRsvp(eventId);
      if (rsvp != null) {
        myRsvp = rsvp;
        setCustomState(ViewState.Success);
      } else {
        setCustomState(ViewState.NoDataAvailable);
      }
    } catch (e) {
      log("Error fetching my RSVP: $e");
      setCustomState(ViewState.Error);
    }
  }

  dynamic allRsvps;
  ViewState allRsvpsState = ViewState.Idle;
  Future<void> getAllRsvps(String eventId) async {
    setCustomState(ViewState state) {
      allRsvpsState = state;
      notifyListeners();
    }

    try {
      setCustomState(ViewState.Busy);
      final rsvps = await _eventApi.getAllRsvps(eventId);
      if (rsvps != null) {
        allRsvps = rsvps;
        setCustomState(ViewState.Success);
      } else {
        setCustomState(ViewState.NoDataAvailable);
      }
    } catch (e) {
      log("Error fetching all RSVPs: $e");
      setCustomState(ViewState.Error);
    }
  }

  disposeRsvp() {
    selectedNameToRsvp = "";
    selectedNameValue = "";
    notifyListeners();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    hashtagCtrl.dispose();
    shortDescCtrl.dispose();
    categoryCtrl.dispose();
    visibilityStatusCtrl.dispose();
    organizerPhoneCtrl.dispose();
    venueNameCtrl.dispose();
    locationDescCtrl.dispose();
    locationAddressCtrl.dispose();
    targetAmountCtrl.dispose();
    expectedParticipantsCtrl.dispose();
    for (var ctrl in detailTitleControllers) {
      ctrl.dispose();
    }
    for (var ctrl in detailControllers) {
      ctrl.dispose();
    }
    // billOutletTabController.dispose();
    super.dispose();
  }
}
