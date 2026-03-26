import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
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
  String title;
  String text;
  List<XFile> media; // URLs or paths
  EventDetailSection({this.title = "", required this.text, List<XFile>? media})
    : media = media ?? [];

  Map<String, dynamic> toJson() => {
    "title": title,
    "text": text,
    "media": media.map((e) => e.path).toList(),
  };
}

class PurchasableItem {
  String name;
  List<XFile> images;
  double price;
  int quantity;
  PurchasableItem({
    required this.name,
    required this.price,
    required this.quantity,
    this.images = const [],
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
  double targetAmount;
  String time; // Keep as string for now or DateTime

  EventActivity({
    required this.name,
    required this.description,
    this.image,
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

  final PageController pageController = PageController();
  int currentStep = 0;

  void nextStep() {
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

  // Step 1: Names and Co
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController hashtagCtrl = TextEditingController();
  final TextEditingController shortDescCtrl = TextEditingController();
  final TextEditingController categoryCtrl = TextEditingController();

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

  Future<void> createEvent() async {
    try {
      EasyLoading.show(status: "Uploading images...");

      // 1. Upload Cover Images
      List<String> uploadedCoverUrls = [];
      for (var image in coverImages) {
        String? url = await _eventApi.uploadSingleImage(image.path);
        if (url != null) uploadedCoverUrls.add(url);
      }

      // 2. Upload Detailed Description Media
      List<Map<String, dynamic>> detailedDescriptionData = [];
      for (var section in detailedDescription) {
        List<String> sectionMediaUrls = [];
        for (var media in section.media) {
          String? url = await _eventApi.uploadSingleImage(media.path);
          if (url != null) sectionMediaUrls.add(url);
        }
        detailedDescriptionData.add({
          "text": section.text,
          "media": sectionMediaUrls,
        });
      }

      // 3. Upload Purchasable Items Images
      List<Map<String, dynamic>> purchasableItemsData = [];
      for (var item in purchasableItems) {
        List<String> itemImageUrls = [];
        for (var image in item.images) {
          String? url = await _eventApi.uploadSingleImage(image.path);
          if (url != null) itemImageUrls.add(url);
        }
        purchasableItemsData.add({
          "name": item.name,
          "images": itemImageUrls,
          "price": item.price,
          "quantity": item.quantity,
        });
      }

      // 4. Upload Activities Images
      List<Map<String, dynamic>> activitiesData = [];
      for (var activity in activities) {
        String? imageUrl;
        if (activity.image != null) {
          imageUrl = await _eventApi.uploadSingleImage(activity.image!.path);
        }
        activitiesData.add({
          "name": activity.name,
          "image": imageUrl ?? "",
          "description": activity.description,
          "targetAmount": activity.targetAmount,
          "time": activity.time,
        });
      }

      EasyLoading.show(status: "Creating event...");
      final payload = generatePayload(
        coverImageUrls: uploadedCoverUrls,
        detailedDescriptionData: detailedDescriptionData,
        purchasableItemsData: purchasableItemsData,
        activitiesData: activitiesData,
      );

      await _eventApi.createEvent(payload);
      showSuccessToast("Event created successfully");
      Get.back(); // Navigate back on success
    } catch (e) {
      log("Error creating event: $e");
      showErrorToast("Failed to create event");
    } finally {
      EasyLoading.dismiss();
    }
  }

  List<AllEventModel>? allEvents;
  ViewState allEventsState = ViewState.Idle;
  Future<void> getAllEvents() async {
    setCustomState(ViewState state) {
      allEventsState = state;
      notifyListeners();
    }

    try {
      setCustomState(ViewState.Busy);
      var res = await _eventApi.getAllEvents();
      if (res.isNotEmpty) {
        allEvents = res;
        notifyListeners();
        setCustomState(ViewState.Success);
      } else {
        setCustomState(ViewState.NoDataAvailable);
      }
    } catch (e) {
      log("Error fetching all events: $e");
      setCustomState(ViewState.Error);
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    hashtagCtrl.dispose();
    shortDescCtrl.dispose();
    categoryCtrl.dispose();
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
    super.dispose();
  }
}
