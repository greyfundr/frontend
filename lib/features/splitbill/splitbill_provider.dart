import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:greyfundr/core/api/splitbill_api/splitbill_api.dart';
import 'package:greyfundr/core/dependencies/locator.dart';
import 'package:greyfundr/core/models/all_user_model.dart';
import 'package:greyfundr/shared/responsiveState/base_view_model.dart';

class SplitBillProvider extends BaseNotifier {
  final _splitBillApi = locator<SplitBillApi>();

  // ── Private state ────────────────────────────────────────────────────────
  final List<AllUsersModel> _allUsers = [];
  final List<AllUsersModel> _selectedUsers = [];

  final TextEditingController _searchController = TextEditingController();

  // ── Getters ──────────────────────────────────────────────────────────────
  List<AllUsersModel> get allUsers => List.unmodifiable(_allUsers);
  List<AllUsersModel> get selectedUsers => List.unmodifiable(_selectedUsers);

  TextEditingController get searchController => _searchController;

  bool get hasSelectedUsers => _selectedUsers.isNotEmpty;

  int get selectedCount => _selectedUsers.length;

  // ── Selection methods ────────────────────────────────────────────────────
  void addToSelectedUsers(String? userId) {
    if (userId == null || userId.isEmpty) return;

    // Already selected? → skip
    if (_selectedUsers.any((u) => u.id == userId)) {
      return;
    }

    final user = _allUsers.firstWhere(
      (u) => u.id == userId,
      orElse: () {
        log("User with id $userId not found in allUsers");
        return AllUsersModel(id: userId); // fallback – adjust as needed
      },
    );

    _selectedUsers.add(user);
    notifyListeners();
  }

  /// Add a custom user object to the selected users list (used for manual/contacts additions).
  void addCustomSelectedUser(AllUsersModel user) {
    if (user.id == null || user.id!.isEmpty) return;
    if (_selectedUsers.any((u) => u.id == user.id)) return;
    _selectedUsers.add(user);
    notifyListeners();
  }

  void removeFromSelectedUsers(String? userId) {
    if (userId == null || userId.isEmpty) return;

    final oldLength = _selectedUsers.length;
    _selectedUsers.removeWhere((u) => u.id == userId);

    if (_selectedUsers.length != oldLength) {
      notifyListeners();
    }
  }

  void clearSelectedUsers() {
    if (_selectedUsers.isNotEmpty) {
      _selectedUsers.clear();
      notifyListeners();
    }
  }

  bool isUserSelected(String? userId) {
    if (userId == null || userId.isEmpty) return false;
    return _selectedUsers.any((u) => u.id == userId);
  }

  // ── Data fetching ────────────────────────────────────────────────────────
  Future<bool> getAllUsers() async {
    try {
      final fetchedUsers = await _splitBillApi.getUsers();

      // Optional: remove current user from the list if your backend includes it
      // final currentUserId = ... get from auth or storage
      // fetchedUsers.removeWhere((u) => u.id == currentUserId);

      _allUsers
        ..clear()
        ..addAll(fetchedUsers);

      notifyListeners();
      return true;
    } catch (e, stack) {
      log("ERROR FETCHING ALL USERS: $e", stackTrace: stack);
      return false;
    }
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}