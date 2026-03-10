import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:greyfundr/core/api/splitbill_api/splitbill_api.dart';
import 'package:greyfundr/core/api/user_api/user_api.dart';
import 'package:greyfundr/core/dependencies/locator.dart';
import 'package:greyfundr/core/models/all_user_model.dart';
import 'package:greyfundr/core/models/split_user_model.dart';
import 'package:greyfundr/shared/responsiveState/base_view_model.dart';

class SplitBillProvider extends BaseNotifier {
  final _splitBillApi = locator<SplitBillApi>();

  List<AllUsersModel> allUsers = [];
  List<AllUsersModel> selectedUsers = [];
  var searchController = TextEditingController();


  addToSelectedUsers(String userId) {
    final user = allUsers.firstWhere((u) => u.id == userId, orElse: () => throw Exception("User not found")); 
    if (!selectedUsers.any((u) => u.id == userId)) {
      selectedUsers.add(user);
      notifyListeners();
    }
  }

  removeFromSelectedUsers(String userId) {
    selectedUsers.removeWhere((u) => u.id == userId);
    notifyListeners();
  }

  Future<bool> getAllUsers() async {
    notifyListeners();
    try {
      allUsers = await _splitBillApi.getUsers();
      notifyListeners();
      return true;
    } catch (e, stack) {
      log("ERROR FETCHING USER PROFILE: $e", stackTrace: stack);
      notifyListeners();
      return false;
    } finally {
      notifyListeners();
    }
  }
}
