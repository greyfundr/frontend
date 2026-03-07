import 'dart:async';
import 'dart:io';

import 'package:greyfundr/core/models/split_user_model.dart' as splitUser;
import 'package:greyfundr/core/models/split_bill_model.dart' as splitBill;

abstract class AuthApi {
  // ──────────────────────────────────────────────────────────────
  // Authentication / Registration
  // ──────────────────────────────────────────────────────────────

  Future<dynamic> signInApi({
    required String emailOrPhone,
    required String password,
  });

  Future<dynamic> signUpApi({
    required String email,
    required String phoneNumber,
    required String password,
    String? accountType,
  });

  Future<dynamic> verifyOtpApi({
    String? emailOrPhone,
    required String otp,
  });

  Future<Map<String, dynamic>> getSplitBillDetails(String splitBillId);

  Future<dynamic> resendOtpApi({required String emailOrPhone});

  Future<dynamic> forgotPasswordApi({required String emailOrPhone});

  Future<dynamic> createPasswordApi({required String password});

  Future<dynamic> submitBasicInfoApi({
    required String firstName,
    required String lastName,
    required String username,
    required bool agreeToTerms,
  });

  Future<dynamic> completeKycApi({
    required String cacNumber,
    required String companyName,
    required String tin,
  });

  Future<dynamic> loginPinApi({
    String? pin,
    String? emailOrPhone,
  });

  Future<dynamic> setPinApi({required String pin});

  // ──────────────────────────────────────────────────────────────
  // Campaign Management
  // ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getCampaignDetails(String campaignId);

  /// Uploads an image file and returns the public URL
  Future<String?> uploadImage(File imageFile);

  Future<dynamic> refreshTokenApi();

  Future<Map<String, dynamic>> updateCampaign(
    String campaignId,
    Map<String, dynamic> payload,
  );

  // ──────────────────────────────────────────────────────────────
  // Donation Creation (NEW)
  // ──────────────────────────────────────────────────────────────

  /// Creates a new donation for a campaign
  /// Returns true on success, false on failure
  Future<bool> createDonation({
    required String userId,
    required String creatorId,
    required String campaignId,
    required int amount,
    String? nickname,
    String? comments,
    String? behalfUserId,
    String? externalName,
    String? externalContact,
  });

  // ──────────────────────────────────────────────────────────────
  // Two-Factor Authentication
  // ──────────────────────────────────────────────────────────────

  Future<dynamic> generateTwoFactorApi();

  Future<dynamic> verifyTwoFactorApi({required String code});

  Future<dynamic> validateTwoFactorApi({required String code});

  Future<dynamic> disableTwoFactorApi();

  // ──────────────────────────────────────────────────────────────
  // User Profile & Settings
  // ──────────────────────────────────────────────────────────────

  Future<dynamic> userProfileApi();

  Future<dynamic> getSettingsApi();

  Future<dynamic> updateSettingsApi({
    required String key,
    required String value,
  });

  // ──────────────────────────────────────────────────────────────
  // Users / Participants (used in split bill, team selection, etc.)
  // ──────────────────────────────────────────────────────────────

  Future<List<splitUser.User>> getUsers();

  Future<List<splitBill.SplitBill>> getMySplitBills();

  // ──────────────────────────────────────────────────────────────
  // Bill / Split Bill Features
  // ──────────────────────────────────────────────────────────────

  /// Upload bill receipt image → returns public URL or null on failure
  Future<String?> uploadBillReceipt(File file);

  /// Create even split bill
  Future<Map<String, dynamic>?> createEvenSplitBill({
    required String title,
    required String description,
    required double totalAmount,
    required String? imageUrl,
    required String dueDateIso8601,
    required List<splitUser.User> participants,
  });

  Future<Map<String, dynamic>?> updateSplitBill({
    required String splitBillId,
    required Map<String, dynamic> updatedData,
  });

  /// Create manual split bill
  Future<Map<String, dynamic>?> createManualSplitBill({
    required String title,
    required String description,
    required double totalAmount,
    required String? imageUrl,
    required String dueDateIso8601,
    required Map<String, double> userAmounts,  // user ID as string key
    required List<splitUser.User> participants,
  });
}