import 'dart:convert';
import 'dart:developer'; // for log()
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:greyfundr/core/api/api_utils/api_route.dart';
import 'package:greyfundr/core/api/api_utils/app_client.dart';
import 'package:greyfundr/core/api/splitbill_api/splitbill_api.dart';
import 'package:greyfundr/core/models/split_bill_model.dart' as splitBill;
import 'package:greyfundr/core/models/split_user_model.dart' as splitUser;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class SplitBillApiImpl implements SplitBillApi {
  final ApiClient _apiClient = ApiClient();

  Map<String, String> get header => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  // ──────────────────────────────────────────────────────────────
  // Get Split Bill Details
  // ──────────────────────────────────────────────────────────────
  @override
  Future<Map<String, dynamic>> getSplitBillDetails(String splitBillId) async {
    try {
      final responseBody = await _apiClient.get(
        '/split-bill/$splitBillId',
        requiresToken: true,
      );

      final decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw Exception('Invalid split bill response format');
    } catch (e, stack) {
      log('getSplitBillDetails failed for $splitBillId: $e', stackTrace: stack);
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Get Users / Participants
  // ──────────────────────────────────────────────────────────────
  @override
  Future<List<splitUser.User>> getUsers() async {
    try {
      final responseBody = await _apiClient.get(
        ApiRoute.getUserRoute,
        headers: header,
        requiresToken: true,
      );

      final dynamic decoded = jsonDecode(responseBody);

      List<dynamic> rawList;

      if (decoded is List<dynamic>) {
        rawList = decoded;
      } else if (decoded is Map<String, dynamic>) {
        rawList = decoded['data'] as List<dynamic>? ??
                  decoded['users'] as List<dynamic>? ??
                  decoded['results'] as List<dynamic>? ??
                  decoded['members'] as List<dynamic>? ??
                  (throw Exception('No user list found in response'));
      } else {
        throw Exception('Unexpected root type: ${decoded.runtimeType}');
      }

      return rawList
          .whereType<Map<String, dynamic>>()
          .map((map) => splitUser.User.fromJson(map))
          .toList();
    } catch (e, stack) {
      log('Error in getUsers(): $e', stackTrace: stack);
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Upload Bill Receipt
  // ──────────────────────────────────────────────────────────────
  @override
  Future<String?> uploadBillReceipt(File file) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
          contentType: lookupMimeType(file.path) != null
              ? MediaType.parse(lookupMimeType(file.path)!)
              : MediaType('image', 'jpeg'),
        ),
      });

      final responseBody = await _apiClient.post(
        ApiRoute.uploadBillReceiptRoute,
        headers: header,
        body: formData,
        requiresToken: true,
      );

      final decoded = responseBody is String ? jsonDecode(responseBody) : responseBody;

      return decoded is Map ? decoded['url'] as String? : null;
    } catch (e) {
      log('uploadBillReceipt failed: $e');
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Create EVEN Split Bill
  // ──────────────────────────────────────────────────────────────
  @override
  Future<Map<String, dynamic>?> createEvenSplitBill({
    required String title,
    required String description,
    required double totalAmount,
    required String? imageUrl,
    required String dueDateIso8601,
    required List<splitUser.User> participants,
  }) async {
    try {
      final amountPerPerson = totalAmount / participants.length;

      final payload = {
        "title": title.trim().isEmpty ? "Even Split Bill" : title.trim(),
        "description": description.trim(),
        "currency": "NGN",
        "amount": totalAmount.toInt(),
        "imageUrl": imageUrl ?? "",
        "splitMethod": "EVEN",
        "dueDate": dueDateIso8601,
        "participants": participants.map((user) {
          final isGuest = user.id.toString().length < 5 || user.id.toString().length > 10;
          return {
            "type": isGuest ? "GUEST" : "USER",
            if (isGuest) ...{
              "name": user.displayName?.trim() ?? "",
              "phone": user.phoneNumber?.trim() ?? "",
            } else ...{
              "userId": user.id,
            },
            "amount": amountPerPerson,
          };
        }).toList(),
      };

      final responseBody = await _apiClient.post(
        ApiRoute.createSplitBillRoute,
        headers: header,
        body: payload,
        requiresToken: true,
      );

      final decoded = responseBody is String ? jsonDecode(responseBody) : responseBody;

      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e) {
      log('createEvenSplitBill failed: $e');
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Create MANUAL Split Bill
  // ──────────────────────────────────────────────────────────────
  @override
  Future<Map<String, dynamic>?> createManualSplitBill({
    required String title,
    required String description,
    required double totalAmount,
    required String? imageUrl,
    required String dueDateIso8601,
    required Map<String, double> userAmounts,
    required List<splitUser.User> participants,
  }) async {
    try {
      final participantList = <Map<String, dynamic>>[];

      for (final user in participants) {
        final assignedAmount = userAmounts[user.id.toString()] ?? 0.0;
        if (assignedAmount <= 0) continue;

        final isGuest = user.id.toString().length < 5 || user.id.toString().length > 10;

        participantList.add({
          "type": isGuest ? "GUEST" : "USER",
          if (isGuest) ...{
            "name": user.displayName?.trim() ?? "",
            "phone": user.phoneNumber?.trim() ?? "",
          } else ...{
            "userId": user.id,
          },
          "amount": assignedAmount,
        });
      }

      if (participantList.isEmpty) return null;

      final payload = {
        "title": title.trim().isEmpty ? "Manual Split Bill" : title.trim(),
        "description": description.trim(),
        "currency": "NGN",
        "amount": totalAmount.toInt(),
        "imageUrl": imageUrl ?? "",
        "splitMethod": "MANUAL",
        "dueDate": dueDateIso8601,
        "participants": participantList,
      };

      final responseBody = await _apiClient.post(
        ApiRoute.createSplitBillRoute,
        headers: header,
        body: payload,
        requiresToken: true,
      );

      final decoded = responseBody is String ? jsonDecode(responseBody) : responseBody;

      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e) {
      log('createManualSplitBill failed: $e');
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Update Split Bill
  // ──────────────────────────────────────────────────────────────
  @override
  Future<Map<String, dynamic>?> updateSplitBill({
    required String splitBillId,
    required Map<String, dynamic> updatedData,
  }) async {
    try {
      final responseBody = await _apiClient.put(
        '/split-bills/$splitBillId',
        body: updatedData,
        requiresToken: true,
      );

      final decoded = jsonDecode(responseBody is String ? responseBody : jsonEncode(responseBody));

      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e) {
      log('updateSplitBill failed: $e');
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Get My Split Bills
  // ──────────────────────────────────────────────────────────────
  @override
  Future<List<splitBill.SplitBill>> getMySplitBills() async {
    try {
      final responseBody = await _apiClient.get(
        '/split-bill?role=participant',
        requiresToken: true,
      );

      final decoded = jsonDecode(responseBody is String ? responseBody : jsonEncode(responseBody));

      final List<dynamic> billList = (decoded['data'] as List?) ?? [];

      return billList
          .whereType<Map<String, dynamic>>()
          .map((item) => splitBill.SplitBill.fromJson(item))
          .toList();
    } catch (e) {
      log('getMySplitBills failed: $e');
      rethrow;
    }
  }
}