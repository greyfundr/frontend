import 'dart:convert';
import 'dart:developer'; // for log()
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:greyfundr/core/api/api_utils/api_route.dart';
import 'package:greyfundr/core/api/api_utils/app_client.dart';
import 'package:greyfundr/core/api/splitbill_api/splitbill_api.dart';
import 'package:greyfundr/core/models/all_user_model.dart';
import 'package:greyfundr/core/models/split_bill_model.dart' as splitBill;
import 'package:greyfundr/core/models/split_user_model.dart' as splitUser;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class SplitBillApiImpl implements SplitBillApi {
  final ApiClient _apiClient = ApiClient();

  Map<String, String> get header => {
      'Accept': 'application/json',
      };

  // ──────────────────────────────────────────────────────────────
  // Get Split Bill Details
  // ──────────────────────────────────────────────────────────────
  @override
  Future<Map<String, dynamic>> getSplitBillDetails(String splitBillId) async {
    try {
      final url = '${ApiRoute.createSplitBillRoute}/$splitBillId';
      final responseBody = await _apiClient.get(
        url,
        requiresToken: true,
      );

      final decoded = jsonDecode(responseBody);
      log('getSplitBillDetails response for $splitBillId: $decoded');

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
Future<List<AllUsersModel>> getUsers() async {
  try {
    final responseBody = await _apiClient.get(
      ApiRoute.getUserRoute,
      headers: header,
      requiresToken: true,
      hideLog: false
    );
    
    final decoded = jsonDecode(responseBody);
    log("DECODED USERS RESPONSE: $decoded");

    if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
      return (decoded['data'] as List).map((x) => AllUsersModel.fromJson(x)).toList();
    } else if (decoded is List) {
      return decoded.map((x) => AllUsersModel.fromJson(x)).toList();
    }

    // Fallback logic in case the structure is different or empty
    return []; 
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
      // Try common form field names used by different upload endpoints
      final multipart = await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
        contentType: lookupMimeType(file.path) != null
            ? MediaType.parse(lookupMimeType(file.path)!)
            : MediaType('image', 'jpeg'),
      );

      // Use a single field name to avoid duplicate file references which can
      // confuse content-length calculation on some servers.
      final fileSize = File(file.path).lengthSync();
      log('uploadBillReceipt - file size: $fileSize bytes');
      // For single-file receipt uploads the backend typically expects the
      // field name `file`. Use that instead of `image` which some endpoints
      // reject (see server response).
      final formData = FormData.fromMap({
        'file': multipart,
      });

      // Use the dedicated formData parameter to make intent explicit
      final responseBody = await _apiClient.post(
        ApiRoute.uploadBillReceiptRoute,
        headers: header,
        formData: formData,
        requiresToken: true,
      );

      // Try to decode JSON safely, fall back to raw body
      dynamic decoded;
      try {
        decoded = responseBody is String ? jsonDecode(responseBody) : responseBody;
      } catch (e) {
        decoded = responseBody;
      }

      log('uploadBillReceipt response decoded: $decoded');

      // Helper to try extract a URL-ish string from a dynamic response
      String? extractUrl(dynamic node) {
        if (node == null) return null;
        if (node is String) {
          final s = node.trim();
          if (s.startsWith('http')) return s;
          return s.isNotEmpty ? s : null;
        }
        if (node is Map<String, dynamic>) {
          for (final k in ['url', 'imageUrl', 'path', 'link', 'file']) {
            if (node.containsKey(k)) {
              final v = node[k];
              final found = extractUrl(v);
              if (found != null) return found;
            }
          }
          // try nested data/result
          for (final k in ['data', 'result', 'file']) {
            if (node.containsKey(k)) {
              final v = node[k];
              final found = extractUrl(v);
              if (found != null) return found;
            }
          }
        }
        if (node is List) {
          for (final item in node) {
            final found = extractUrl(item);
            if (found != null) return found;
          }
        }
        return null;
      }

      final found = extractUrl(decoded);
      if (found != null && found.isNotEmpty) return found;

      return null;
    } catch (e, stack) {
      log('uploadBillReceipt failed: $e', stackTrace: stack);
      // If it's a DioException, log more details
      try {
        if (e is DioException) {
          log('DioException details: ${e.type} ${e.message} ${e.response?.statusCode} ${e.response?.data}');
        }
      } catch (_) {}
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
      // Ensure integer amounts that sum to totalAmount.toInt()
      final totalInt = totalAmount.toInt();
      final count = participants.length;
      final base = count > 0 ? totalInt ~/ count : 0;
      final remainder = count > 0 ? totalInt % count : 0;

      final participantList = <Map<String, dynamic>>[];
      for (var i = 0; i < participants.length; i++) {
        final user = participants[i];
        // Treat as guest only when id looks like a short temp id (e.g. generated timestamp)
        final isGuest = user.id.toString().length < 5;
        var name = user.displayName?.trim() ?? '';
        final phone = user.phoneNumber?.trim() ?? '';
        if (isGuest) {
          if (name.length < 2) {
            // fallback to phone or default 'Guest'
            name = phone.isNotEmpty ? phone : 'Guest';
          }
        }

        final amountForThis = base + (i < remainder ? 1 : 0);

        final entry = <String, dynamic>{
          "type": isGuest ? "GUEST" : "USER",
          if (isGuest) ...{
              "name": name,
              "phone": phone,
            } else ...{
              // Some backends accept numeric userId. Send int when possible.
              "userId": int.tryParse(user.id.toString()) ?? user.id,
            },
          "amount": amountForThis,
        };
        participantList.add(entry);
      }

      final payload = {
        "title": title.trim().isEmpty ? "Even Split Bill" : title.trim(),
        "description": description.trim(),
        "currency": "NGN",
        "amount": totalInt,
        "imageUrl": imageUrl ?? "",
        "splitMethod": "EVEN",
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
    String? recipientUserId,
    String? billReceipt,
  }) async {
    try {
      final participantList = <Map<String, dynamic>>[];

      for (final user in participants) {
        final assignedAmountDouble = userAmounts[user.id.toString()] ?? 0.0;
        // Convert to kobo (backend expects kobo integers for manual)
        final assignedAmountKobo = (assignedAmountDouble * 100).toInt();
        // Debug: log mapping from participant -> assigned amount (kobo)
        // ignore: avoid_print
        print('ManualSplit: participant=${user.id} assignedAmt_kobo=$assignedAmountKobo');
        if (assignedAmountKobo <= 0) continue;

        // Treat as guest only when id looks like a short temp id (e.g. generated timestamp)
        final isGuest = user.id.toString().length < 5;
        var name = user.displayName?.trim() ?? '';
        final phone = user.phoneNumber?.trim() ?? '';
        if (isGuest && name.length < 2) {
          name = phone.isNotEmpty ? phone : 'Guest';
        }

        // Try to send numeric userId when possible (some backends accept ints)
        final maybeNumericId = int.tryParse(user.id.toString());

        final entry = <String, dynamic>{
          "type": isGuest ? "GUEST" : "USER",
          if (isGuest) ...{
            "name": name,
            "phone": phone,
          } else ...{
            "userId": maybeNumericId ?? user.id,
          },
          "amount": assignedAmountKobo,
        };

        participantList.add(entry);
      }

      if (participantList.isEmpty) return null;

      // convert total to kobo
      final totalKobo = (totalAmount * 100).toInt();
      final payload = <String, dynamic>{
        "title": title.trim().isEmpty ? "Manual Split Bill" : title.trim(),
        "description": description.trim(),
        "currency": "NGN",
        "amount": totalKobo,
        "imageUrl": imageUrl ?? "",
        "splitMethod": "MANUAL",
        "dueDate": dueDateIso8601,
        "participants": participantList,
        // use same defaults as even-split creation
        "visibility": "private",
        "allowPartialPayment": true,
        "minPaymentAmount": null,
        if (billReceipt != null) "billReceipt": billReceipt,
        if (recipientUserId != null) "recipientUserId": recipientUserId,
      };

      // Debug: print payload summary as compact JSON
      // ignore: avoid_print
      try {
        final pretty = jsonEncode(payload);
        print('ManualSplit payload JSON: $pretty');
      } catch (_) {
        print('ManualSplit payload (toString): $payload');
      }

      final responseBody = await _apiClient.post(
        ApiRoute.createSplitBillRoute,
        headers: header,
        body: payload,
        requiresToken: true,
      );

      // Debug: show raw response
      // ignore: avoid_print
      print('ManualSplit responseBody: $responseBody');

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
      // Use the canonical route so the full base URL from ApiRoute is used.
      final url = '${ApiRoute.createSplitBillRoute}/$splitBillId';
      // Some backends prefer PATCH for partial updates; switch to PATCH to
      // match the server behavior which rejects PUT for this route.
      final responseBody = await _apiClient.patch(
        url,
        headers: header,
        body: updatedData,
        requiresToken: true,
      );

      log('updateSplitBill raw response: $responseBody');

      dynamic decoded;
      try {
        decoded = responseBody is String ? jsonDecode(responseBody) : responseBody;
      } catch (e) {
        // If decoding fails, keep the raw response around
        decoded = responseBody;
      }

      log('updateSplitBill decoded response: $decoded');

      if (decoded is Map<String, dynamic>) return decoded;

      // If the server returned a non-empty plain string, return it wrapped
      if (decoded is String && decoded.trim().isNotEmpty) {
        return {"raw": decoded};
      }

      // Fallback: return a simple success marker if something plausible returned
      return {"raw": responseBody.toString()};
    } catch (e, stack) {
      log('updateSplitBill failed: $e', stackTrace: stack);
      try {
        if (e is DioException) {
          log('DioException in updateSplitBill: ${e.type} ${e.message} ${e.response?.statusCode} ${e.response?.data}');
        }
      } catch (_) {}
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Pay participant share
  // ──────────────────────────────────────────────────────────────
  @override
  Future<Map<String, dynamic>?> payParticipant({
    required String splitBillId,
    required String participantId,
    required double amount,
  }) async {
    try {
      final url = '${ApiRoute.createSplitBillRoute}/$splitBillId/participants/$participantId/pay';

      final body = {
        'amount': amount.toInt(),
      };

      final responseBody = await _apiClient.post(
        url,
        headers: header,
        body: body,
        requiresToken: true,
      );

      final decoded = responseBody is String ? jsonDecode(responseBody) : responseBody;
      if (decoded is Map<String, dynamic>) return decoded;
      return {'raw': decoded};
    } catch (e, stack) {
      log('payParticipant failed: $e', stackTrace: stack);
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

  @override
  Future<List<splitBill.SplitBill>> getAllSplitBills() async {
    try {
      // Use the main split-bills route which returns all bills
      final responseBody = await _apiClient.get(
        ApiRoute.createSplitBillRoute,
        requiresToken: true,
      );

      final decoded = jsonDecode(responseBody is String ? responseBody : jsonEncode(responseBody));

      final List<dynamic> billList = (decoded['data'] as List?) ?? [];

      return billList
          .whereType<Map<String, dynamic>>()
          .map((item) => splitBill.SplitBill.fromJson(item))
          .toList();
    } catch (e) {
      log('getAllSplitBills failed: $e');
      rethrow;
    }
  }
}