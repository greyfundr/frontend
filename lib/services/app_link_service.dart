import 'dart:async';
import 'dart:developer';
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:greyfundr/features/bill/event_rsvp_page.dart';
import 'package:greyfundr/features/bill/my_event_details_screen.dart';

class AppLinkService {
  // Singleton instance
  static final AppLinkService _instance = AppLinkService._internal();
  factory AppLinkService() => _instance;
  AppLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  void init() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _onIncomingUri,
      onError: (error) {
        // Optional: report to crash analytics/logging.
      },
    );
  }

  Future<void> _onIncomingUri(Uri uri) async {
    log("Received deep link: $uri");

    // Extract query parameters from URI
    final type = uri.queryParameters['type'];
    final id = uri.queryParameters['id'];

    if (type == null || id == null) {
      log("Invalid link: missing type or id");
      return;
    }

    await _handleIncomingLink(linkType: type, id: id);
  }

  Future<void> _handleIncomingLink({
    required String linkType,
    required String id,
  }) async {
    switch (linkType.toLowerCase()) {
      case 'event':
        await _handleEventLink(id);
        break;
      case 'campaign':
        await _handleCampaignLink(id);
        break;
      case 'user':
        await _handleUserLink(id);
        break;
      default:
        log("Unknown link type: $linkType");
    }
  }

  Future<void> _handleEventLink(String eventId) async {
    try {
      log("Navigating to event: $eventId");
      Get.to(() => EventRSVPScreen(eventId: eventId));
    } catch (e) {
      log("Error handling event link: $e");
    }
  }

  Future<void> _handleCampaignLink(String campaignId) async {
    try {
      log("Navigating to campaign: $campaignId");
      // TODO: Implement campaign navigation
      // Get.to(() => CampaignDetailsScreen(campaignId: campaignId));
    } catch (e) {
      log("Error handling campaign link: $e");
    }
  }

  Future<void> _handleUserLink(String userId) async {
    try {
      log("Navigating to user profile: $userId");
      // TODO: Implement user profile navigation
      // Get.to(() => UserProfileScreen(userId: userId));
    } catch (e) {
      log("Error handling user link: $e");
    }
  }

  Future<void> dispose() async {
    await _linkSubscription?.cancel();
    _linkSubscription = null;
  }
}
