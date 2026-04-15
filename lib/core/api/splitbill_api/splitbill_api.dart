import 'dart:io';

import 'package:greyfundr/core/models/all_user_model.dart';
import 'package:greyfundr/core/models/split_bill_details_model.dart';
import 'package:greyfundr/core/models/split_bill_response_model.dart';
import 'package:greyfundr/core/models/split_user_model.dart' as splitUser;
import 'package:greyfundr/core/models/my_split_bill_model.dart';
import 'package:greyfundr/core/models/split_bill_invite_model.dart';

abstract class SplitBillApi {
  /// Fetch details of a specific split bill by ID
  Future<SplitBillDetailsModel> getSplitBillDetails(String splitBillId);

  /// Get list of users/participants (used when creating/editing bills)
  Future<List<AllUsersModel>> getUsers();

  /// Get all split bills where current user is a participant
  Future<MySplitBillModel> getMySplitBills();

  /// Get all split bill invites for the current user
  Future<SplitBillInviteModel> getSplitBillInvites();

  /// Get all split bills (admin / global view)
  Future<SplitBillResponseModel> getCurrentUserSplitBill();

  /// Upload bill receipt image → returns public URL or null on failure
  Future<String?> uploadBillReceipt(File file);

  /// Create an EVEN split bill (equal amounts for all participants)
  Future createEvenSplitBill({
    required String title,
    required String description,
    required double totalAmount,
    required String? imageUrl,
    required String dueDateIso8601,
    required List<splitUser.User> participants,
  });

  /// Create a MANUAL split bill (custom amounts per participant)
  Future createManualSplitBill({
    required String title,
    required String description,
    required double totalAmount,
    required String? imageUrl,
    required String dueDateIso8601,
    required Map<String, double> userAmounts, // user ID as string key
    required List<splitUser.User> participants,
    String? recipientUserId,
    String? billReceipt,
  });

  /// Update an existing split bill
  Future updateSplitBill({
    required String splitBillId,
    required Map<String, dynamic> updatedData,
  });

  /// Pay participant's share for a split bill
  Future payParticipant({
    required String splitBillId,
    required String participantId,
    required double amount,
  });

  /// Add one or more participants to an existing split bill
  Future<List<Map<String, dynamic>>?> addParticipants({
    required String splitBillId,
    required List<Map<String, dynamic>> participants,
  });

  /// Remove a participant from a split bill
  Future<bool> removeParticipant({
    required String splitBillId,
    required String participantId,
  });

  /// Cancel a split bill with a reason/description
  Future<bool> cancelSplitBill({
    required String splitBillId,
    required String reason,
    String? description,
  });

  Future createNewSplitBill({
    required String title,
    required String description,
    required double totalAmount,
    required String? imageUrl,
    required String dueDate,
    required List<Map> participants,
    String? recipientUserId,
    String? billReceipt,
    bool? allowPartialPayments,
    double? minPaymentAmountForPartial,
    String? splitMethod,
  });

  Future<List<AllUsersModel>> searchForUser({
    String? email,
    String? phoneNumber,
    String? username,
  });

  Future payForBillWithWallet({
    String? participantId,
    String? billId,
    String? amount,
    String? transactionPin,
  });

  Future payForBillWithPaystack({
    String? participantId,
    String? billId,
    String? amount,
  });

  /// Accept a split bill invite
  Future<bool> acceptSplitBillInvite(String billId);

  /// Decline a split bill invite
  Future<bool> declineSplitBillInvite(String billId);

  /// Send reminders to participants
  Future sendSplitBillReminder(String billId);
}
