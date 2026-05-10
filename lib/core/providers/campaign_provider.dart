import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/core/api/auth_api/auth_api.dart';
import 'package:greyfundr/core/api/campaign_api/campaign_api.dart';
import 'package:greyfundr/core/models/budget_model.dart';
import 'package:greyfundr/core/models/campaign_comment_model.dart';
import 'package:greyfundr/core/models/campaign_details_model.dart';
import 'package:greyfundr/core/models/campaign_donations_response_model.dart';
import 'package:greyfundr/core/models/campaign_model.dart';
import 'package:greyfundr/core/models/participants_model.dart';
import 'package:greyfundr/core/models/top_donors_response_model.dart';
import 'package:greyfundr/services/locator.dart';
import 'package:greyfundr/shared/responsiveState/base_view_model.dart';
import 'package:greyfundr/shared/responsiveState/view_state.dart';
import 'package:intl/intl.dart';

class CampaignProvider extends BaseNotifier {
  final CampaignApi campaignApi = locator<CampaignApi>();
  final AuthApi authApi = locator<AuthApi>();

  // ─── Form Controllers ─────────────────────────────────────────
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController teamSearchController = TextEditingController();

  // ─── Selected Form State ──────────────────────────────────────
  Map<String, String>? selectedCategory;
  DateTime? startDate;
  DateTime? endDate;
  List<File> selectedImages = [];
  List<Participant> selectedTeamMembers = [];
  List<Expense> expenses = [];
  List<Map<String, String>> autoOffers = [];
  List<Map<String, String>> manualOffers = [];

  // ─── Async State ──────────────────────────────────────────────
  ViewState categoriesState = ViewState.Idle;
  ViewState usersState = ViewState.Idle;
  ViewState submitState = ViewState.Idle;
  String? createdCampaignId;

  // ─── Campaign Details ─────────────────────────────────────────
  ViewState campaignDetailsState = ViewState.Idle;
  CampaignDetailsModel? campaignDetails;
  String? _detailsCampaignId;

  Future<void> fetchCampaignDetails(String campaignId, {bool force = false}) async {
    if (!force &&
        campaignDetails != null &&
        _detailsCampaignId == campaignId) {
      campaignDetailsState = ViewState.Success;
      notifyListeners();
      return;
    }
    _detailsCampaignId = campaignId;
    campaignDetails = null;
    campaignDetailsState = ViewState.Busy;
    notifyListeners();
    try {
      campaignDetails = await campaignApi.getCampaignDetailsTyped(campaignId);
      campaignDetailsState = ViewState.Success;
    } catch (e, st) {
      log('fetchCampaignDetails error: $e', stackTrace: st);
      campaignDetailsState = ViewState.Error;
    }
    notifyListeners();
  }

  void clearCampaignDetails() {
    campaignDetails = null;
    _detailsCampaignId = null;
    campaignDetailsState = ViewState.Idle;
    notifyListeners();
  }

  // ─── Campaign Donations (paginated) ───────────────────────────
  ViewState donationsState = ViewState.Idle;
  ViewState donationsLoadMoreState = ViewState.Idle;
  List<DonationDatum> donations = [];
  DonationsPagination? donationsPagination;
  String? _donationsCampaignId;
  static const int donationsPageLimit = 10;

  bool get hasMoreDonations => donationsPagination?.hasNext ?? false;

  Future<void> fetchCampaignDonations(
    String campaignId, {
    bool refresh = false,
  }) async {
    if (!refresh &&
        _donationsCampaignId == campaignId &&
        donations.isNotEmpty) {
      donationsState = ViewState.Success;
      notifyListeners();
      return;
    }
    _donationsCampaignId = campaignId;
    donations = [];
    donationsPagination = null;
    donationsState = ViewState.Busy;
    notifyListeners();
    try {
      final res = await campaignApi.getCampaignDonations(
        campaignId: campaignId,
        page: 1,
        limit: donationsPageLimit,
      );
      donations = res.data ?? [];
      donationsPagination = res.pagination;
      donationsState = donations.isEmpty
          ? ViewState.NoDataAvailable
          : ViewState.Success;
    } catch (e, st) {
      log('fetchCampaignDonations error: $e', stackTrace: st);
      donationsState = ViewState.Error;
    }
    notifyListeners();
  }

  Future<void> fetchMoreDonations(String campaignId) async {
    if (donationsLoadMoreState == ViewState.Busy) return;
    if (!hasMoreDonations) return;
    final nextPage = (donationsPagination?.page ?? 1) + 1;
    donationsLoadMoreState = ViewState.Busy;
    notifyListeners();
    try {
      final res = await campaignApi.getCampaignDonations(
        campaignId: campaignId,
        page: nextPage,
        limit: donationsPageLimit,
      );
      donations.addAll(res.data ?? []);
      donationsPagination = res.pagination;
      donationsLoadMoreState = ViewState.Success;
    } catch (e, st) {
      log('fetchMoreDonations error: $e', stackTrace: st);
      donationsLoadMoreState = ViewState.Error;
    }
    notifyListeners();
  }

  void clearDonations() {
    donations = [];
    donationsPagination = null;
    _donationsCampaignId = null;
    donationsState = ViewState.Idle;
    donationsLoadMoreState = ViewState.Idle;
    notifyListeners();
  }

  // ─── Top Donors ──────────────────────────────────────────────
  ViewState topDonorsState = ViewState.Idle;
  List<TopDonor> topDonors = [];
  String? _topDonorsCampaignId;

  Future<void> fetchTopDonors(
    String campaignId, {
    bool refresh = false,
  }) async {
    if (!refresh &&
        _topDonorsCampaignId == campaignId &&
        topDonors.isNotEmpty) {
      topDonorsState = ViewState.Success;
      notifyListeners();
      return;
    }
    _topDonorsCampaignId = campaignId;
    topDonors = [];
    topDonorsState = ViewState.Busy;
    notifyListeners();
    try {
      topDonors = await campaignApi.getCampaignTopDonors(campaignId);
      topDonorsState = topDonors.isEmpty
          ? ViewState.NoDataAvailable
          : ViewState.Success;
    } catch (e, st) {
      log('fetchTopDonors error: $e', stackTrace: st);
      topDonorsState = ViewState.Error;
    }
    notifyListeners();
  }

  void clearTopDonors() {
    topDonors = [];
    _topDonorsCampaignId = null;
    topDonorsState = ViewState.Idle;
    notifyListeners();
  }

  // ─── Campaign Like ────────────────────────────────────────────
  bool _likeBusy = false;

  Future<void> toggleCampaignLike(String campaignId) async {
    if (_likeBusy) return;
    final details = campaignDetails;
    if (details == null || details.id != campaignId) return;
    _likeBusy = true;
    final wasLiked = details.isLiked ?? false;
    final originalCount = details.likesCount ?? 0;
    details.isLiked = !wasLiked;
    details.likesCount = wasLiked
        ? (originalCount > 0 ? originalCount - 1 : 0)
        : originalCount + 1;
    notifyListeners();
    final ok = wasLiked
        ? await campaignApi.unlikeCampaign(campaignId)
        : await campaignApi.likeCampaign(campaignId);
    if (!ok) {
      details.isLiked = wasLiked;
      details.likesCount = originalCount;
      notifyListeners();
    }
    _likeBusy = false;
  }

  // ─── Campaign Comments ────────────────────────────────────────
  ViewState commentsState = ViewState.Idle;
  List<CampaignComment> comments = [];
  bool postingComment = false;
  String? _commentsCampaignId;

  Future<void> fetchCampaignComments(
    String campaignId, {
    bool refresh = false,
  }) async {
    if (!refresh &&
        _commentsCampaignId == campaignId &&
        commentsState == ViewState.Success) {
      return;
    }
    _commentsCampaignId = campaignId;
    commentsState = ViewState.Busy;
    notifyListeners();
    try {
      comments = await campaignApi.getCampaignComments(campaignId);
      commentsState =
          comments.isEmpty ? ViewState.NoDataAvailable : ViewState.Success;
    } catch (e, st) {
      log('fetchCampaignComments error: $e', stackTrace: st);
      commentsState = ViewState.Error;
    }
    notifyListeners();
  }

  Future<bool> postCampaignComment({
    required String campaignId,
    required String content,
  }) async {
    if (content.trim().isEmpty) return false;
    if (postingComment) return false;
    postingComment = true;
    notifyListeners();
    final result = await campaignApi.addCampaignComment(
      campaignId: campaignId,
      content: content.trim(),
    );
    postingComment = false;
    if (result != null) {
      comments = [...comments, result];
      commentsState = ViewState.Success;
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  void clearCampaignComments() {
    comments = [];
    _commentsCampaignId = null;
    commentsState = ViewState.Idle;
    notifyListeners();
  }

  List<Map<String, String>> categories = [];
  List<Participant> users = [];
  List<Participant> _filteredUsers = [];
  List<Participant> get filteredUsers =>
      _filteredUsers.isEmpty && teamSearchController.text.isEmpty
      ? users
      : _filteredUsers;

  // ─── Validation ───────────────────────────────────────────────
  bool get canProceedToReview {
    final amount =
        double.tryParse(amountController.text.replaceAll(',', '')) ?? 0;
    return titleController.text.trim().isNotEmpty &&
        descriptionController.text.trim().isNotEmpty &&
        selectedCategory != null &&
        amount > 0 &&
        startDate != null &&
        endDate != null &&
        selectedImages.isNotEmpty;
  }

  int get offersCount => autoOffers.length + manualOffers.length;

  // ─── Categories ───────────────────────────────────────────────
  Future<void> fetchCategories({bool force = false}) async {
    if (!force && categories.isNotEmpty) return;
    categoriesState = ViewState.Busy;
    notifyListeners();
    try {
      categories = await campaignApi.getCategories();
      categoriesState = categories.isEmpty
          ? ViewState.NoDataAvailable
          : ViewState.Success;
    } catch (e, st) {
      log('fetchCategories error: $e', stackTrace: st);
      categoriesState = ViewState.Error;
    }
    notifyListeners();
  }

  void setCategory(Map<String, String> category) {
    selectedCategory = category;
    notifyListeners();
  }

  void clearCategory() {
    selectedCategory = null;
    notifyListeners();
  }

  // ─── Users / Team ─────────────────────────────────────────────
  Future<List<Participant>> fetchUsers({bool force = false}) async {
    if (!force && users.isNotEmpty) {
      usersState = ViewState.Success;
      notifyListeners();
      return users;
    }
    usersState = ViewState.Busy;
    notifyListeners();
    try {
      users = await campaignApi.getUsers();
      _filteredUsers = users;
      usersState = users.isEmpty
          ? ViewState.NoDataAvailable
          : ViewState.Success;
      notifyListeners();
      return users;
    } catch (e, st) {
      log('fetchUsers error: $e', stackTrace: st);
      usersState = ViewState.Error;
      notifyListeners();
      return [];
    }
  }

  void filterTeamMembers(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      _filteredUsers = users;
    } else {
      _filteredUsers = users
          .where(
            (u) =>
                u.name.toLowerCase().contains(q) ||
                u.username.toLowerCase().contains(q),
          )
          .toList();
    }
    notifyListeners();
  }

  bool isTeamMemberSelected(String id) {
    return selectedTeamMembers.any((p) => p.id == id);
  }

  void toggleTeamMember(Participant participant) {
    final idx = selectedTeamMembers.indexWhere((p) => p.id == participant.id);
    if (idx == -1) {
      selectedTeamMembers.add(participant);
    } else {
      selectedTeamMembers.removeAt(idx);
    }
    notifyListeners();
  }

  void removeTeamMember(String id) {
    selectedTeamMembers.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // ─── Images ───────────────────────────────────────────────────
  static const int maxImages = 6;

  void addImages(List<File> files) {
    final remaining = maxImages - selectedImages.length;
    if (remaining <= 0) return;
    selectedImages.addAll(files.take(remaining));
    notifyListeners();
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
      notifyListeners();
    }
  }

  // ─── Dates ────────────────────────────────────────────────────
  void setStartDate(DateTime date) {
    startDate = date;
    startDateController.text = DateFormat('dd MMM, yyyy').format(date);
    if (endDate != null && endDate!.isBefore(date)) {
      endDate = null;
      endDateController.clear();
    }
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    endDate = date;
    endDateController.text = DateFormat('dd MMM, yyyy').format(date);
    notifyListeners();
  }

  // ─── Expenses / Budget ────────────────────────────────────────
  void addExpense(Expense expense) {
    expenses.add(expense);
    notifyListeners();
  }

  void updateExpense(int index, Expense expense) {
    if (index >= 0 && index < expenses.length) {
      expenses[index] = expense;
      notifyListeners();
    }
  }

  void removeExpense(int index) {
    if (index >= 0 && index < expenses.length) {
      expenses.removeAt(index);
      notifyListeners();
    }
  }

  double get totalExpenses =>
      expenses.fold<double>(0, (sum, e) => sum + (e.cost));

  // ─── Offers ───────────────────────────────────────────────────
  void setOffers(
    List<Map<String, String>> auto,
    List<Map<String, String>> manual,
  ) {
    autoOffers = auto;
    manualOffers = manual;
    notifyListeners();
  }

  // ─── Build / Submit ───────────────────────────────────────────
  Campaign buildCampaign() {
    final amount =
        double.tryParse(amountController.text.replaceAll(',', '')) ?? 0;
    final c = Campaign(
      titleController.text.trim(),
      descriptionController.text.trim(),
      selectedCategory?['id']?.isNotEmpty == true
          ? selectedCategory!['id']!
          : (selectedCategory?['label'] ?? ''),
      manualOffers,
      autoOffers,
    );
    c.amount = amount;
    c.startDate = startDate != null
        ? DateFormat('dd/MM/yyyy').format(startDate!)
        : '';
    c.endDate = endDate != null
        ? DateFormat('dd/MM/yyyy').format(endDate!)
        : '';
    c.images = List<File>.from(selectedImages);
    c.imageUrl = selectedImages.isNotEmpty ? selectedImages.first : null;
    c.participants = List<Participant>.from(selectedTeamMembers);
    c.budgets = List<Expense>.from(expenses);
    return c;
  }

  Future<dynamic> submitCampaign(String userId) async {
    submitState = ViewState.Busy;
    setState(ViewState.Busy);
    try {
      final campaign = buildCampaign();
      final res = await campaignApi.createCampaignApi(
        campaign: campaign,
        userId: userId,
      );
      createdCampaignId = _extractCampaignId(res);
      submitState = ViewState.Success;
      setState(ViewState.Success);
      return res;
    } catch (e, st) {
      log('submitCampaign error: $e', stackTrace: st);
      submitState = ViewState.Error;
      setError(e.toString());
      showErrorToast(e.toString());
      rethrow;
    }
  }

  String? _extractCampaignId(dynamic response) {
    dynamic source = response;
    if (source is Map<String, dynamic>) {
      final nested = source['data'] ?? source['campaign'] ?? source['payload'];
      if (nested != null) source = nested;
    }
    if (source is Map<String, dynamic>) {
      final id = source['id'] ?? source['_id'] ?? source['campaignId'];
      if (id != null) return id.toString();
    }
    return null;
  }

  // ─── Legacy methods retained for screens not yet migrated ─────
  Future<dynamic> createCampaign(Campaign campaign, String userId) async {
    setState(ViewState.Busy);
    try {
      final res = await campaignApi.createCampaignApi(
        campaign: campaign,
        userId: userId,
      );
      setState(ViewState.Success);
      return res;
    } catch (e) {
      final err = e.toString();
      setError(err);
      showErrorToast(err);
      rethrow;
    }
  }

  Future<dynamic> getCampaignApproval(String campaignId) async {
    try {
      return await campaignApi.getCampaignApprovalApi(campaignId);
    } catch (e) {
      final err = e.toString();
      setError(err);
      showErrorToast(err);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchCurrentUserProfile() async {
    try {
      final response = await authApi.userProfileApi();
      if (response is String) {
        return jsonDecode(response) as Map<String, dynamic>?;
      }
      if (response is Map<String, dynamic>) return response;
      return null;
    } catch (e) {
      final err = e.toString();
      setError(err);
      showErrorToast(err);
      return null;
    }
  }

  // ─── Reset (called when CampaignOptionScreen is closed) ───────
  void clearAll() {
    titleController.clear();
    descriptionController.clear();
    amountController.clear();
    startDateController.clear();
    endDateController.clear();
    teamSearchController.clear();
    selectedCategory = null;
    startDate = null;
    endDate = null;
    selectedImages = [];
    selectedTeamMembers = [];
    expenses = [];
    autoOffers = [];
    manualOffers = [];
    submitState = ViewState.Idle;
    createdCampaignId = null;
    _filteredUsers = users;
    notifyListeners();
  }
}
