import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/core/api/campaign_api/campaign_api.dart';
import 'package:greyfundr/core/dependencies/locator.dart';
import 'package:greyfundr/core/models/all_campaign_response_model.dart';
import 'package:greyfundr/core/models/participants_model.dart';
import 'package:greyfundr/services/user_local_storage_service.dart';
import 'package:greyfundr/shared/responsiveState/base_view_model.dart';
import 'package:greyfundr/shared/responsiveState/view_state.dart';

class CharityProvider extends BaseNotifier {
  final CampaignApi _campaignApi = locator<CampaignApi>();

 
  List<CampaignDatum> campaigns = [];
  Pagination? pagination;
  String selectedCategory = 'All';
  int currentPage = 1;

  ViewState campaignsState = ViewState.Idle;
  ViewState loadMoreState = ViewState.Idle;

  void _setCampaignsState(ViewState state) {
    campaignsState = state;
    notifyListeners();
  }

  void _setLoadMoreState(ViewState state) {
    loadMoreState = state;
    notifyListeners();
  }

  void setCategory(String category) {
    if (selectedCategory == category) return;
    selectedCategory = category;
    notifyListeners();
    getAllCampaigns(refresh: true);
  }

  Future<bool> getAllCampaigns({bool refresh = false}) async {
    if (refresh) {
      currentPage = 1;
      campaigns = [];
    }

    _setCampaignsState(ViewState.Busy);
    try {
      final res = await _campaignApi.getAllCampaigns(
        page: currentPage,
        category: selectedCategory,
      );

      campaigns = res.data ?? [];
      pagination = res.pagination;

      if (campaigns.isEmpty) {
        _setCampaignsState(ViewState.NoDataAvailable);
        return true;
      }

      _setCampaignsState(ViewState.Success);
      return true;
    } catch (e, stack) {
      log('CharityProvider.getAllCampaigns error: $e', stackTrace: stack);
      _setCampaignsState(ViewState.Error);
      return false;
    }
  }

  Future<bool> loadMoreCampaigns() async {
    if (loadMoreState == ViewState.Busy) return false;
    if (!(pagination?.hasNext ?? false)) return false;

    _setLoadMoreState(ViewState.Busy);
    try {
      final nextPage = (pagination?.page ?? currentPage) + 1;
      final res = await _campaignApi.getAllCampaigns(
        page: nextPage,
        category: selectedCategory,
      );

      campaigns = [...campaigns, ...(res.data ?? [])];
      pagination = res.pagination;
      currentPage = nextPage;

      _setLoadMoreState(ViewState.Success);
      return true;
    } catch (e, stack) {
      log('CharityProvider.loadMoreCampaigns error: $e', stackTrace: stack);
      _setLoadMoreState(ViewState.Error);
      return false;
    }
  }

  String donationDisplayName = '';
  String donationUsername = '';
  bool donationIsAnonymous = false;

  String donationComments = '';
  bool donationHasComment = false;

  bool donationHasBehalfOf = false;
  String donationBehalfDisplay = '';
  String? donationTaggedUserId;
  String? donationExternalName;
  String? donationExternalPhone;

  bool donationIsProcessing = false;

  void initDonationForm({String? currentUserFullName}) {
    donationDisplayName = (currentUserFullName ?? '').trim();
    donationUsername = donationDisplayName;
    donationIsAnonymous = false;

    donationComments = '';
    donationHasComment = false;

    donationHasBehalfOf = false;
    donationBehalfDisplay = '';
    donationTaggedUserId = null;
    donationExternalName = null;
    donationExternalPhone = null;

    donationIsProcessing = false;
    notifyListeners();
  }

  void setNickname(String nickname) {
    donationUsername = nickname;
    donationDisplayName = nickname;
    donationIsAnonymous = false;
    notifyListeners();
  }

  void setAnonymousDisplayName() {
    final anonymousId =
        UserLocalStorageService().getUserData()?.anonymousId?.trim() ?? '';
    final fallback = "Anonymous${Random().nextInt(9000) + 1000}";
    final name = anonymousId.isNotEmpty ? anonymousId : fallback;
    donationDisplayName = name;
    donationUsername = name;
    donationIsAnonymous = true;
    notifyListeners();
  }

  void clearDisplayName() {
    donationDisplayName = '';
    donationUsername = '';
    donationIsAnonymous = false;
    notifyListeners();
  }

  void setComment(String comment) {
    donationComments = comment.trim();
    donationHasComment = donationComments.isNotEmpty;
    notifyListeners();
  }

  void clearComment() {
    donationComments = '';
    donationHasComment = false;
    notifyListeners();
  }

  void setTaggedBehalfOfUser({required String userId, required String username}) {
    donationHasBehalfOf = true;
    donationTaggedUserId = userId;
    donationExternalName = null;
    donationExternalPhone = null;
    donationBehalfDisplay = '@$username';
    notifyListeners();
  }

  void setExternalBehalfOf({required String name, required String phone}) {
    donationHasBehalfOf = true;
    donationTaggedUserId = null;
    donationExternalName = name;
    donationExternalPhone = phone;
    donationBehalfDisplay = "$name • $phone";
    notifyListeners();
  }

  void clearBehalfOf() {
    donationHasBehalfOf = false;
    donationTaggedUserId = null;
    donationExternalName = null;
    donationExternalPhone = null;
    donationBehalfDisplay = '';
    notifyListeners();
  }

  /// Search Greyfundr users by username/name — used for the tag-user sheet.
  Future<List<Map<String, dynamic>>> searchUsersForBehalfOf(String pattern) async {
    if (pattern.trim().length < 2) return [];
    try {
      final users = await _campaignApi.getUsers();
      final needle = pattern.replaceAll('@', '').toLowerCase();
      return users
          .where((u) =>
              u.username.toLowerCase().contains(needle) ||
              u.name.toLowerCase().contains(needle))
          .map((Participant u) => {
                'id': u.id,
                'username': u.username,
                'name': u.name,
                'profile_pic': u.imageUrl,
              })
          .toList();
    } catch (e, stack) {
      log('searchUsersForBehalfOf error: $e', stackTrace: stack);
      return [];
    }
  }

  /// Submit a donation to [campaign] by the current user ([currentUserId]).
  /// Returns true on success.
  Future<bool> createDonation({
    required CampaignDatum campaign,
    required String? currentUserId,
    required int amount,
  }) async {
    final campaignId = campaign.id?.toString();
    if (campaignId == null || campaignId.isEmpty) {
      showErrorToast('Campaign ID is missing.');
      return false;
    }

    donationIsProcessing = true;
    notifyListeners();
    EasyLoading.show(status: 'Processing donation...');

    try {
      final creatorId = campaign.creator?.id?.toString() ?? '';
      final success = await _campaignApi.createDonation(
        userId: currentUserId ?? '',
        creatorId: creatorId,
        campaignId: campaignId,
        amount: amount,
        nickname: donationUsername.isNotEmpty ? donationUsername : null,
        comments: donationComments.isNotEmpty ? donationComments : null,
        behalfUserId: (donationHasBehalfOf && donationTaggedUserId != null)
            ? donationTaggedUserId
            : null,
        externalName: donationExternalName,
        externalContact: donationExternalPhone,
      );

      return success;
    } catch (e, stack) {
      log('CharityProvider.createDonation error: $e', stackTrace: stack);
      showErrorToast('Donation failed: ${e.toString()}');
      return false;
    } finally {
      donationIsProcessing = false;
      EasyLoading.dismiss();
      notifyListeners();
    }
  }

  /// Donate using the in-app wallet. Requires the user's transaction PIN.
  Future<bool> donateWithWallet({
    required CampaignDatum campaign,
    required String? currentUserId,
    required int amount,
    required String transactionPin,
  }) async {
    final campaignId = campaign.id?.toString();
    if (campaignId == null || campaignId.isEmpty) {
      showErrorToast('Campaign ID is missing.');
      return false;
    }

    donationIsProcessing = true;
    notifyListeners();
    EasyLoading.show(status: 'Processing payment...');

    try {
      final payload = <String, dynamic>{
        'amount': amount,
        'paymentMethod': 'wallet',
        'transactionPin': transactionPin,
        if (donationUsername.isNotEmpty) 'username': donationUsername,
        'isAnonymous': donationUsername.isEmpty,
        if (donationComments.isNotEmpty) 'comment': donationComments,
        if (donationHasBehalfOf && donationTaggedUserId != null) ...{
          'onBehalfOf': 'user',
          'onBehalfOfUserId': donationTaggedUserId,
        } else if (donationExternalName != null &&
            donationExternalName!.isNotEmpty) ...{
          'onBehalfOf': 'external',
          'onBehalfOfExternal': {
            'fullName': donationExternalName,
            'phoneNumber': donationExternalPhone ?? '',
          },
        } else ...{
          'onBehalfOf': 'self',
          if (currentUserId != null && currentUserId.isNotEmpty)
            'onBehalfOfUserId': currentUserId,
        },
      };

      final res = await _campaignApi.donateToCampaign(campaignId, payload);
      return !res.toString().contains('error');
    } catch (e, stack) {
      log('CharityProvider.donateWithWallet error: $e', stackTrace: stack);
      showErrorToast('Payment failed: ${e.toString()}');
      return false;
    } finally {
      donationIsProcessing = false;
      EasyLoading.dismiss();
      notifyListeners();
    }
  }

  /// Donate using Paystack. Returns the authorization URL on success.
  Future<String> donateWithPaystack({
    required CampaignDatum campaign,
    required String? currentUserId,
    required int amount,
  }) async {
    final campaignId = campaign.id?.toString();
    if (campaignId == null || campaignId.isEmpty) {
      showErrorToast('Campaign ID is missing.');
      return '';
    }

    donationIsProcessing = true;
    notifyListeners();
    EasyLoading.show(status: 'Initializing Paystack...');

    try {
      final payload = <String, dynamic>{
        'amount': amount,
        'paymentMethod': 'paystack',
        if (donationUsername.isNotEmpty) 'username': donationUsername,
        'isAnonymous': donationUsername.isEmpty,
        if (donationComments.isNotEmpty) 'comment': donationComments,
        if (donationHasBehalfOf && donationTaggedUserId != null) ...{
          'onBehalfOf': 'user',
          'onBehalfOfUserId': donationTaggedUserId,
        } else if (donationExternalName != null &&
            donationExternalName!.isNotEmpty) ...{
          'onBehalfOf': 'external',
          'onBehalfOfExternal': {
            'fullName': donationExternalName,
            'phoneNumber': donationExternalPhone ?? '',
          },
        } else ...{
          'onBehalfOf': 'self',
          if (currentUserId != null && currentUserId.isNotEmpty)
            'onBehalfOfUserId': currentUserId,
        },
      };

      final res = await _campaignApi.donateToCampaign(campaignId, payload);

      final authUrl = (res['authorizationUrl'] ??
              res['authorization_url'] ??
              res['data']?['authorizationUrl'] ??
              res['data']?['authorization_url'] ??
              '')
          .toString();
      return authUrl;
    } catch (e, stack) {
      log('CharityProvider.donateWithPaystack error: $e', stackTrace: stack);
      showErrorToast('Paystack init failed: ${e.toString()}');
      return '';
    } finally {
      donationIsProcessing = false;
      EasyLoading.dismiss();
      notifyListeners();
    }
  }
}
