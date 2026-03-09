import 'dart:io';

import 'package:greyfundr/core/models/split_bill_model.dart' as splitBill;
import 'package:greyfundr/core/models/split_user_model.dart' as splitUser;

abstract class SplitBillApi {
  /// Fetch details of a specific split bill by ID
  Future<Map<String, dynamic>> getSplitBillDetails(String splitBillId);

  /// Get list of users/participants (used when creating/editing bills)
  Future<List<splitUser.User>> getUsers();

  /// Get all split bills where current user is a participant
  Future<List<splitBill.SplitBill>> getMySplitBills();

  /// Upload bill receipt image → returns public URL or null on failure
  Future<String?> uploadBillReceipt(File file);

  /// Create an EVEN split bill (equal amounts for all participants)
  Future<Map<String, dynamic>?> createEvenSplitBill({
    required String title,
    required String description,
    required double totalAmount,
    required String? imageUrl,
    required String dueDateIso8601,
    required List<splitUser.User> participants,
  });

  /// Create a MANUAL split bill (custom amounts per participant)
  Future<Map<String, dynamic>?> createManualSplitBill({
    required String title,
    required String description,
    required double totalAmount,
    required String? imageUrl,
    required String dueDateIso8601,
    required Map<String, double> userAmounts, // user ID as string key
    required List<splitUser.User> participants,
  });

  /// Update an existing split bill
  Future<Map<String, dynamic>?> updateSplitBill({
    required String splitBillId,
    required Map<String, dynamic> updatedData,
  });
}