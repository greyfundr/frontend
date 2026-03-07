// // lib/services/bill_service.dart
// import 'dart:convert';
// import 'dart:io';

// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:image_picker/image_picker.dart';

// import '../../class/auth_service.dart';
// import '../../class/jwt_helper.dart';
// import 'package:greyfundr/core/models/split_user_model.dart';


// class BillService {
//   static const String _baseUrl = 'https://api.greyfundr.com';

//   // ────────────────────────────────────────────────
//   //  Shared helper: Get valid auth token
//   // ────────────────────────────────────────────────
//   static Future<String?> _getValidToken() async {
//     final token = await AuthService().getToken();
//     if (token == null || JWTHelper.isTokenExpired(token)) {
//       return null;
//     }
//     return token;
//   }

//   // ────────────────────────────────────────────────
//   //  Upload receipt image → returns public URL or null
//   // ────────────────────────────────────────────────
//   static Future<String?> uploadReceipt(File file, XFile xFile) async {
//     try {
//       final token = await _getValidToken();
//       if (token == null) return null;

//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$_baseUrl/upload/image'),
//       );

//       request.headers['Authorization'] = 'Bearer $token';

//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'image',
//           file.path,
//           filename: file.path.split('/').last,
//           contentType: xFile.mimeType != null
//               ? MediaType.parse(xFile.mimeType!)
//               : MediaType('image', 'jpeg'),
//         ),
//       );

//       final streamed = await request.send();
//       final response = await http.Response.fromStream(streamed);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final json = jsonDecode(response.body);
//         final url = json['url'] as String?;
//         if (url != null && url.isNotEmpty) {
//           return url;
//         }
//       }

//       // debugPrint("Upload failed: ${response.statusCode} - ${response.body}");
//       return null;
//     } catch (e) {
//       // debugPrint("Upload exception: $e");
//       return null;
//     }
//   }

//   // ────────────────────────────────────────────────
//   //  Create EVEN split bill
//   // ────────────────────────────────────────────────
//   static Future<Map<String, dynamic>?> createEvenSplitBill({
//     required String title,
//     required String description,
//     required double totalAmount,
//     required String? imageUrl,
//     required String dueDateIso8601,
//     required List<User> participants,
//   }) async {
//     final token = await _getValidToken();
//     if (token == null) return null;

//     final amountPerPerson = totalAmount / participants.length;

//     final payload = {
//       "title": title.trim().isEmpty ? "Even Split Bill" : title.trim(),
//       "description": description.trim(),
//       "currency": "NGN",
//       "amount": totalAmount.toInt(), // backend likely expects integer kobo
//       "imageUrl": imageUrl ?? "",
//       "splitMethod": "EVEN",
//       "dueDate": dueDateIso8601,
//       "participants": participants.map((user) {
//         final isGuest = user.id.toString().length < 5 || user.id.toString().length > 10;
//         return {
//           "type": isGuest ? "GUEST" : "USER",
//           if (isGuest) ...{
//             "name": user.displayName.trim(),
//             "phone": user.phone?.trim() ?? "",
//           } else ...{
//             "userId": user.id,
//           },
//           "amount": amountPerPerson,
//         };
//       }).toList(),
//     };

//     try {
//       final response = await http.post(
//         Uri.parse('$_baseUrl/split-bill/create'),
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//         body: jsonEncode(payload),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return jsonDecode(response.body);
//       }

//       // debugPrint("Even split failed: ${response.statusCode} - ${response.body}");
//       return null;
//     } catch (e) {
//       // debugPrint("Even split exception: $e");
//       return null;
//     }
//   }

//   // ────────────────────────────────────────────────
//   //  Create MANUAL split bill
//   // ────────────────────────────────────────────────
//   static Future<Map<String, dynamic>?> createManualSplitBill({
//     required String title,
//     required String description,
//     required double totalAmount,
//     required String? imageUrl,
//     required String dueDateIso8601,
//     required Map<int, double> userAmounts, // user.id → assigned amount
//     required List<User> participants,
//   }) async {
//     final token = await _getValidToken();
//     if (token == null) return null;

//     // Build participants with custom amounts
//     final participantList = <Map<String, dynamic>>[];

//     for (final user in participants) {
//       final assignedAmount = userAmounts[user.id] ?? 0.0;
//       if (assignedAmount <= 0) continue; // skip zero-amount users (optional)

//       final isGuest = user.id.toString().length < 5 || user.id.toString().length > 10;

//       participantList.add({
//         "type": isGuest ? "GUEST" : "USER",
//         if (isGuest) ...{
//           "name": user.displayName.trim(),
//           "phone": user.phone?.trim() ?? "",
//         } else ...{
//           "userId": user.id,
//         },
//         "amount": assignedAmount,
//       });
//     }

//     if (participantList.isEmpty) return null;

//     final payload = {
//       "title": title.trim().isEmpty ? "Manual Split Bill" : title.trim(),
//       "description": description.trim(),
//       "currency": "NGN",
//       "amount": totalAmount.toInt(),
//       "imageUrl": imageUrl ?? "",
//       "splitMethod": "MANUAL",
//       "dueDate": dueDateIso8601,
//       "participants": participantList,
//     };

//     try {
//       final response = await http.post(
//         Uri.parse('$_baseUrl/split-bill/create'),
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//         body: jsonEncode(payload),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return jsonDecode(response.body);
//       }

//       // debugPrint("Manual split failed: ${response.statusCode} - ${response.body}");
//       return null;
//     } catch (e) {
//       // debugPrint("Manual split exception: $e");
//       return null;
//     }
//   }
// }