import 'dart:convert';
import 'dart:developer'; // for log()
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:greyfundr/core/api/api_utils/api_route.dart';
import 'package:greyfundr/core/api/api_utils/app_client.dart';
import 'package:greyfundr/core/api/splitbill_api/splitbill_api.dart';
import 'package:greyfundr/core/models/all_user_model.dart';
import 'package:greyfundr/core/models/split_bill_details_model.dart';
import 'package:greyfundr/core/models/split_bill_response_model.dart';
import 'package:greyfundr/core/models/split_user_model.dart' as splitUser;
import 'package:greyfundr/core/models/my_split_bill_model.dart';
import 'package:greyfundr/core/models/split_bill_invite_model.dart';

class SplitBillApiImpl implements SplitBillApi {
  final ApiClient _apiClient = ApiClient();

  Map<String, String> get header => {'Accept': 'application/json'};

  // ──────────────────────────────────────────────────────────────
  // Get Split Bill Details
  // ──────────────────────────────────────────────────────────────
  @override
  Future<SplitBillDetailsModel> getSplitBillDetails(String splitBillId) async {
    final url = '${ApiRoute.createSplitBillRoute}/$splitBillId';
    final responseBody = await _apiClient.get(
      url,
      requiresToken: true,
      hideLog: false,
    );
    return splitBillDetailsModelFromJson(responseBody);
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
        hideLog: false,
      );

      final decoded = jsonDecode(responseBody);
      log("DECODED USERS RESPONSE: $decoded");

      if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
        return (decoded['data'] as List)
            .map((x) => AllUsersModel.fromJson(x))
            .toList();
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
      );
      final formData = FormData.fromMap({'file': multipart});
      final responseBody = await _apiClient.post(
        ApiRoute.uploadBillReceiptRoute,
        headers: header,
        formData: formData,
        requiresToken: true,
      );

      // Try to decode JSON safely, fall back to raw body
      dynamic decoded;
      try {
        decoded = jsonDecode(responseBody);
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
          log(
            'DioException details: ${e.type} ${e.message} ${e.response?.statusCode} ${e.response?.data}',
          );
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
        var name = user.displayName.trim() ?? '';
        final phone = user.phoneNumber.trim() ?? '';
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

      final decoded = jsonDecode(responseBody);

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
        // Send integer Naira amounts (to match Even split behavior)
        final assignedAmountInt = assignedAmountDouble.toInt();
        // Debug: log mapping from participant -> assigned amount (naira int)
        // ignore: avoid_print
        print(
          'ManualSplit: participant=${user.id} assignedAmt_naira=$assignedAmountInt',
        );
        if (assignedAmountInt <= 0) continue;

        // Treat as guest only when id looks like a short temp id (e.g. generated timestamp)
        final isGuest = user.id.toString().length < 5;
        var name = user.displayName.trim() ?? '';
        final phone = user.phoneNumber.trim() ?? '';
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
          "amount": assignedAmountInt,
        };

        participantList.add(entry);
      }

      if (participantList.isEmpty) return null;

      // total as integer Naira (match even split behavior)
      final totalInt = totalAmount.toInt();
      final payload = <String, dynamic>{
        "title": title.trim().isEmpty ? "Manual Split Bill" : title.trim(),
        "description": description.trim(),
        "currency": "NGN",
        "amount": totalInt,
        "imageUrl": imageUrl ?? "",
        "splitMethod": "MANUAL",
        "dueDate": dueDateIso8601,
        "participants": participantList,
        // use same defaults as even-split creation
        "visibility": "private",
        "allowPartialPayment": true,
        "minPaymentAmount": null,
        "billReceipt": ?billReceipt,
        "recipientUserId": ?recipientUserId,
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

      final decoded = jsonDecode(responseBody);

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
        decoded = jsonDecode(responseBody);
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
          log(
            'DioException in updateSplitBill: ${e.type} ${e.message} ${e.response?.statusCode} ${e.response?.data}',
          );
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
      final url =
          '${ApiRoute.createSplitBillRoute}/$splitBillId/participants/$participantId/pay';

      final body = {'amount': amount.toInt()};

      final responseBody = await _apiClient.post(
        url,
        headers: header,
        body: body,
        requiresToken: true,
      );

      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'raw': decoded};
    } catch (e, stack) {
      log('payParticipant failed: $e', stackTrace: stack);
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Add participants to an existing split bill
  // ──────────────────────────────────────────────────────────────
  @override
  Future<List<Map<String, dynamic>>?> addParticipants({
    required String splitBillId,
    required List<Map<String, dynamic>> participants,
  }) async {
    try {
      final url = '${ApiRoute.createSplitBillRoute}/$splitBillId/participants';

      final created = <Map<String, dynamic>>[];

      // Some backends accept batch arrays; attempt a batch POST first
      try {
        final responseBody = await _apiClient.post(
          url,
          headers: header,
          body: {'participants': participants},
          requiresToken: true,
        );

        final decoded = jsonDecode(responseBody);
        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          final data = decoded['data'];
          if (data is List) {
            for (final item in data) {
              if (item is Map<String, dynamic>) created.add(item);
            }
            return created;
          }
        }
      } catch (_) {
        // fall through to per-item POST
      }

      // Fallback: post participants one-by-one
      for (final p in participants) {
        try {
          final responseBody = await _apiClient.post(
            url,
            headers: header,
            body: p,
            requiresToken: true,
          );
          final decoded = jsonDecode(responseBody);
          if (decoded is Map<String, dynamic>) {
            // try extract created participant from data or raw map
            if (decoded.containsKey('data')) {
              final d = decoded['data'];
              if (d is Map<String, dynamic>) {
                created.add(d);
              } else if (d is List) {
                for (final it in d) {
                  if (it is Map<String, dynamic>) created.add(it);
                }
              }
            } else {
              created.add(decoded);
            }
          }
        } catch (e) {
          log('addParticipants per-item post failed for $p: $e');
        }
      }

      return created.isEmpty ? null : created;
    } catch (e, stack) {
      log('addParticipants failed: $e', stackTrace: stack);
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Remove a participant from a split bill
  // ──────────────────────────────────────────────────────────────
  @override
  Future<bool> removeParticipant({
    required String splitBillId,
    required String participantId,
  }) async {
    try {
      final url =
          '${ApiRoute.createSplitBillRoute}/$splitBillId/participants/$participantId';
      final responseBody = await _apiClient.delete(
        url,
        headers: header,
        requiresToken: true,
      );

      // If server returned JSON with success marker, consider it success
      try {
        final decoded = jsonDecode(responseBody);
        if (decoded is Map<String, dynamic> &&
            (decoded['success'] == true || decoded['status'] == 'success')) {
          return true;
        }
      } catch (_) {}

      // Default to true when server responded without throwing
      return true;
    } catch (e, stack) {
      log('removeParticipant failed: $e', stackTrace: stack);
      return false;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Cancel a split bill
  // ──────────────────────────────────────────────────────────────
  @override
  Future<bool> cancelSplitBill({
    required String splitBillId,
    required String reason,
    String? description,
  }) async {
    try {
      final url = '${ApiRoute.getSplitBillRoute}/$splitBillId/cancel';
      final body = <String, dynamic>{'reason': reason};
      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }

      final responseBody = await _apiClient.post(
        url,
        headers: header,
        body: body,
        requiresToken: true,
      );

      // Try decode and check for success markers
      try {
        final decoded = jsonDecode(responseBody);
        if (decoded is Map<String, dynamic>) {
          if (decoded['success'] == true) return true;
          if (decoded['status'] == 'success') return true;
        }
      } catch (_) {}

      // If request didn't throw, assume success
      return true;
    } catch (e, stack) {
      log('cancelSplitBill failed: $e', stackTrace: stack);
      return false;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Get My Split Bills
  // ──────────────────────────────────────────────────────────────
  @override
  Future<MySplitBillModel> getMySplitBills() async {
    try {
      final url = '${ApiRoute.createSplitBillRoute}/my-bills';
      final responseBody = await _apiClient.get(url, requiresToken: true);
      return mySplitBillModelFromJson(responseBody);
    } catch (e) {
      log('getMySplitBills failed: $e');
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Get Split Bill Invites
  // ──────────────────────────────────────────────────────────────
  @override
  Future<SplitBillInviteModel> getSplitBillInvites() async {
    try {
      final url = '${ApiRoute.createSplitBillRoute}/invites';
      final responseBody = await _apiClient.get(url, requiresToken: true);
      return splitBillInviteModelFromJson(responseBody);
    } catch (e) {
      log('getSplitBillInvites failed: $e');
      rethrow;
    }
  }

  @override
  Future<SplitBillResponseModel> getCurrentUserSplitBill() async {
    final responseBody = await _apiClient.get(
      ApiRoute.getSplitBillRoute,
      requiresToken: true,
    );
    return splitBillResponseModelFromJson(responseBody);
  }

  @override
  Future createNewSplitBill({
    required String title,
    required String description,
    required double totalAmount,
    String? imageUrl,
    required String dueDate,
    required List<Map> participants,
    String? recipientUserId,
    String? billReceipt,
    bool? allowPartialPayments,
    double? minPaymentAmountForPartial,
    String? splitMethod,
  }) async {
    Map val = {
      "title": title,
      "description": description,
      "currency": "NGN",
      "amount": totalAmount.toInt(),
      "imageUrl": imageUrl ?? "",
      "dueDate": dueDate,
      "participants": participants,
      "recipientUserId": recipientUserId,
      "billReceipt": billReceipt,
      "allowPartialPayment": allowPartialPayments,
      "minPaymentAmount": minPaymentAmountForPartial ?? 0.0,
      "splitMethod": splitMethod,
    };
    log("createNewSplitBill payload: $val");
    final responseBody = await _apiClient.post(
      ApiRoute.createSplitBillRoute,
      requiresToken: true,
      hideLog: false,
      body: val,
    );
    return responseBody;
  }

  @override
  Future<List<AllUsersModel>> searchForUser({
    String? email,
    String? phoneNumber,
    String? username,
  }) async {
    try {
      String queryParam = "";
      if (email != null && email.isNotEmpty) {
        queryParam = "?email=$email";
      } else if (phoneNumber != null && phoneNumber.isNotEmpty) {
        queryParam = "?phoneNumber=$phoneNumber";
      } else if (username != null && username.isNotEmpty) {
        queryParam = "?username=$username";
      }

      final responseBody = await _apiClient.get(
        "${ApiRoute.getUserRoute}$queryParam",
        headers: header,
        requiresToken: true,
        hideLog: false,
      );
      return allUsersModelFromJson(responseBody);
    } catch (e, stack) {
      log('Error in getUsers(): $e', stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future payForBillWithWallet({
    String? participantId,
    String? billId,
    String? amount,
    String? transactionPin,
  }) async {
    final responseBody = await _apiClient.post(
      "${ApiRoute.getSplitBillRoute}/$billId/participants/$participantId/pay",
      body: {
        "amount": amount != null ? double.tryParse(amount.replaceAll(',', '')) ?? 0.0 : 0.0,
        "paymentMethod": "wallet",
        if (transactionPin != null) "transactionPin": transactionPin,
      },
      headers: header,
      hideLog: false,
      requiresToken: true,
    );
    return (responseBody);
  }

  @override
  Future payForBillWithPaystack({
    String? participantId,
    String? billId,
    String? amount,
  }) async {
    final responseBody = await _apiClient.post(
      "${ApiRoute.getSplitBillRoute}/$billId/$billId/participants/$participantId/pay",
      body: {
        "amount": amount != null ? double.tryParse(amount)?.toInt() ?? 0 : 0,
        "paymentMethod": "paystack",
      },
      requiresToken: true,
    );
    return (responseBody);
  }

  @override
  Future<bool> acceptSplitBillInvite(String billId) async {
    await _apiClient.patch(
      "${ApiRoute.getSplitBillRoute}/$billId/accept",
      requiresToken: true,
    );
    return true;
  }

  @override
  Future<bool> declineSplitBillInvite(String billId) async {
    await _apiClient.patch(
      "${ApiRoute.getSplitBillRoute}/$billId/decline",
      requiresToken: true,
    );
    return true;
  }

  @override
  Future sendSplitBillReminder(String billId) async {
    await _apiClient.post(
      "${ApiRoute.createSplitBillRoute}/$billId/reminders",
      requiresToken: true,
    );
    return true;
  }
}
