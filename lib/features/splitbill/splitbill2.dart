// // lib/screens/create/bill/quick_split_bill_screen.dart
// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';

// import '../../../class/auth_service.dart';
// import 'package:greyfundr/class/jwt_helper.dart';

// import 'package:greyfundr/features/auth/signin_widget.dart';
// import 'package:greyfundr/features/splitbill/split_bill_summary.dart';


// import 'package:greyfundr/core/models/split_user_model.dart';
// import 'package:greyfundr/services/custom_alert.dart';
// import 'package:greyfundr/shared/currency_input_formatter.dart';
// import '../../../../../services/bill_service.dart';
// import 'package:greyfundr/services/bill_service.dart';

// import 'package:greyfundr/widgets/splitabill/bill_image_preview.dart';
// import 'package:greyfundr/widgets/splitabill/form_section_title.dart';
// import 'package:greyfundr/widgets/splitabill/split_method_selector.dart';
// import 'package:greyfundr/widgets/splitabill/split_participants_container.dart';

// import 'package:greyfundr/modals/splitbill/add_participant_modal.dart';
// import 'package:greyfundr/modals/splitbill/manual_split_modal.dart';
// import 'package:greyfundr/modals/splitbill/due_date_time_modal.dart';

// class SplitBillScreen extends StatefulWidget {
//   const SplitBillScreen({super.key});

//   @override
//   State<SplitBillScreen> createState() => _SplitBillScreenState();
// }

// class _SplitBillScreenState extends State<SplitBillScreen> {
//   // Controllers
//   final _titleController       = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _amountController      = TextEditingController();
//   final _searchController      = TextEditingController();

//   // State
//   File? _billImage;
//   String? _billImageUrl;
//   String? _dueDate; // ISO8601 string

//   User? _currentUser;

//   bool _isEvenSplit = true;
//   List<User> _selectedUsers = [];
//   String? _splitError;

//   bool _isCreating = false;
//   bool _isLoadingUsers = false;
//   List<User> _allUsers = [];

//   final ImagePicker _picker = ImagePicker();
//   final String _baseUrl = "https://api.greyfundr.com";

//   @override
//   void initState() {
//     super.initState();
//     _fetchUsers();
//     _loadCurrentUser();
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _amountController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadCurrentUser() async {
//   final token = await AuthService().getToken();
//   if (token != null && !JWTHelper.isTokenExpired(token)) {
//     final payload = JWTHelper.decodeToken(token);
//     final userJson = payload['user']; // adjust according to your token structure
//     setState(() {
//       _currentUser = User.fromJson(userJson);
//     });
//   }
// }

//   Future<void> _fetchUsers() async {
//     setState(() => _isLoadingUsers = true);

//     try {
//       final token = await AuthService().getToken();
//       if (token == null || JWTHelper.isTokenExpired(token)) {
//         CustomMessageModal.show(
//           context: context,
//           message: "Session expired. Please log in again.",
//           isSuccess: false,
//         );
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => SigninScreen()),
//         );
//         return;
//       }

//       final response = await http.get(
//         Uri.parse('$_baseUrl/users'),
//         headers: {"Authorization": "Bearer $token"},
//       );

//       if (response.statusCode == 200) {
//         final json = jsonDecode(response.body);
//         if (json is List && json.isNotEmpty && json[0] is List) {
//           final usersJson = json[0] as List<dynamic>;
//           final currentId = JWTHelper.decodeToken(token)['user']['id'].toString();

//           setState(() {
//             _allUsers = usersJson
//                 .map((e) => User.fromJson(e))
//                 .where((u) => u.id.toString() != currentId)
//                 .toList();
//           });
//         }
//       } else {
//         debugPrint("Users fetch failed: ${response.statusCode}");
//       }
//     } catch (e) {
//       debugPrint("Fetch users error: $e");
//       CustomMessageModal.show(
//         context: context,
//         message: "Failed to load users. Check your connection.",
//         isSuccess: false,
//       );
//     } finally {
//       if (mounted) setState(() => _isLoadingUsers = false);
//     }
//   }

//   // ── Image Picker + Upload ─────────────────────────────
//   Future<void> _pickImage() async {
//     final source = await showModalBottomSheet<ImageSource>(
//       context: context,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (context) => SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Padding(
//               padding: EdgeInsets.all(16),
//               child: Text("Choose source", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
//             ),
//             ListTile(
//               leading: const Icon(Icons.camera_alt, color: Color(0xFF007A74)),
//               title: const Text("Camera"),
//               onTap: () => Navigator.pop(context, ImageSource.camera),
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_library, color: Color(0xFF007A74)),
//               title: const Text("Gallery"),
//               onTap: () => Navigator.pop(context, ImageSource.gallery),
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );

//     if (source == null) return;

//     try {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Row(
//             children: [
//               SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
//               SizedBox(width: 16),
//               Text("Processing receipt..."),
//             ],
//           ),
//           backgroundColor: Color(0xFF007A74),
//           duration: Duration(seconds: 30),
//         ),
//       );

//       final xFile = await _picker.pickImage(
//         source: source,
//         maxWidth: 1800,
//         maxHeight: 1800,
//         imageQuality: 88,
//       );

//       if (xFile == null) {
//         ScaffoldMessenger.of(context).hideCurrentSnackBar();
//         return;
//       }

//       final file = File(xFile.path);

//       setState(() => _billImage = file);

//       final uploadedUrl = await BillService.uploadReceipt(file, xFile);

//       ScaffoldMessenger.of(context).hideCurrentSnackBar();

//       if (uploadedUrl != null) {
//         setState(() => _billImageUrl = uploadedUrl);
//         CustomMessageModal.show(context: context, message: "Receipt uploaded!", isSuccess: true);
//       } else {
//         setState(() => _billImage = null);
//         CustomMessageModal.show(context: context, message: "Upload failed.", isSuccess: false);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).hideCurrentSnackBar();
//       setState(() => _billImage = null);
//       CustomMessageModal.show(context: context, message: "Error: ${e.toString().split('\n')[0]}", isSuccess: false);
//     }
//   }

//   // ── Participant Modal ─────────────────────────────────
//   void _showAddParticipant() {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (_) => AddParticipantModal(
//       allUsers: _allUsers,
//       selectedUsers: _selectedUsers,
//       onUsersChanged: (updated) => setState(() => _selectedUsers = updated),
//       searchController: _searchController,
//     ),
//   );
// }

//   // ── Manual Split Modal ────────────────────────────────
//   void _openManualSplit() {
//     if (!_validateBeforeManual()) return;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => ManualSplitModal(
//         billAmountController: _amountController,
//         selectedUsers: _selectedUsers,
//         onCreateSplit: (userAmounts, _) => _createManualSplit(userAmounts),
//       ),
//     );
//   }

//   // ── Validation Helpers ────────────────────────────────
//   bool _validateCommon() {
//     final title = _titleController.text.trim();
//     final desc = _descriptionController.text.trim();

    

//     final amountText = _amountController.text.trim().replaceAll(',', '');
// final amount = double.tryParse(amountText) ?? 0.0;

//     if (title.isEmpty) return _showErrorAndReturnFalse("Please enter a title");
//     if (title.length > 100) return _showErrorAndReturnFalse("Title must be under 100 characters");
//     if (desc.isEmpty) return _showErrorAndReturnFalse("Please enter a description");
//     if (amount <= 0) return _showErrorAndReturnFalse("Please enter a valid bill amount");
//     if (_billImageUrl == null) return _showErrorAndReturnFalse("Please upload a receipt");
//     if (_selectedUsers.isEmpty) return _showErrorAndReturnFalse("Add at least one participant");
//     if (_dueDate == null) return _showErrorAndReturnFalse("Set a due date");

//     return true;
//   }

//   bool _validateBeforeManual() {
//     return _validateCommon();
//   }

//   bool _showErrorAndReturnFalse(String message) {
//     _showError(message);
//     return false;
//   }

//   void _showError(String message) {
//     setState(() => _splitError = message);
//     Future.delayed(const Duration(seconds: 4), () {
//       if (mounted) setState(() => _splitError = null);
//     });
//     CustomMessageModal.show(context: context, message: message, isSuccess: false);
//   }

//   // ── Create Even Split ─────────────────────────────────
//   Future<void> _createEvenSplit() async {
//     if (!_validateCommon()) return;

//     final amountText = _amountController.text.trim().replaceAll(',', '');
//     final totalAmount = double.tryParse(amountText) ?? 0.0;

//     setState(() => _isCreating = true);

//     final result = await BillService.createEvenSplitBill(
//       title: _titleController.text.trim(),
//       description: _descriptionController.text.trim(),
//       totalAmount: totalAmount,
//       imageUrl: _billImageUrl,
//       dueDateIso8601: _dueDate!,
//       participants: _selectedUsers,
//     );

//     setState(() => _isCreating = false);

//     if (result != null && result['data']?['id'] != null) {
//       final splitId = result['data']['id'].toString();
//       CustomMessageModal.show(context: context, message: "Even split bill created!", isSuccess: true);
//       Navigator.push(context, MaterialPageRoute(builder: (_) => SplitBillSummary(splitBillId: splitId)));
//     } else {
//       _showError("Failed to create even split bill");
//     }
//   }

//   // ── Create Manual Split ───────────────────────────────
//   Future<void> _createManualSplit(Map<int, double> userAmounts) async {
//     if (!_validateCommon()) return;

//     final amountText = _amountController.text.trim().replaceAll(',', '');
//     final totalAmount = double.tryParse(amountText) ?? 0.0;

//     setState(() => _isCreating = true);

//     final result = await BillService.createManualSplitBill(
//       title: _titleController.text.trim(),
//       description: _descriptionController.text.trim(),
//       totalAmount: totalAmount,
//       imageUrl: _billImageUrl,
//       dueDateIso8601: _dueDate!,
//       userAmounts: userAmounts,
//       participants: _selectedUsers,
//     );

//     setState(() => _isCreating = false);

//     if (result != null && result['data']?['id'] != null) {
//       final splitId = result['data']['id'].toString();
//       CustomMessageModal.show(context: context, message: "Manual split bill created!", isSuccess: true);
//       Navigator.push(context, MaterialPageRoute(builder: (_) => SplitBillSummary(splitBillId: splitId)));
//     } else {
//       _showError("Failed to create manual split bill");
//     }
//   }

//   // ── Due Date Picker ───────────────────────────────────
//   Future<void> _pickDueDate() async {
//     final initialDate = _dueDate != null ? DateTime.parse(_dueDate!) : DateTime.now().add(const Duration(days: 7));
//     final initialTime = TimeOfDay.fromDateTime(initialDate);

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (_) => DueDateTimeModal(
//         initialDate: initialDate,
//         initialTime: initialTime,
//         onConfirm: (dt) {
//           setState(() {
//             _dueDate = dt.toUtc().toIso8601String();
//           });
//         },
//       ),
//     );
//   }

//   // ── Build ─────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     final billAmount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Create New Split Bill"),
//         centerTitle: true,
//       ),
//       body: _isLoadingUsers
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   FormSectionTitle("Title"),
//                   Text(
//               "Give a bill title so that participants can relate with the bill",
//               style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//             ),
//             const SizedBox(height: 3),
//                   TextField(
//                     controller: _titleController,
//                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
//                     // 
//                      decoration: InputDecoration(
//                 hintText: "E.g Dinner at the Beach",
//                 hintStyle: TextStyle(
//                   color: const Color.fromARGB(255, 110, 109, 109),
//                 ),
//                 filled: true,
//                 fillColor: Colors.transparent,
//                 // contentPadding: const EdgeInsets.symmetric(
//                 //   horizontal: 20,
//                 //   vertical: 18,
//                 // ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide.none,
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(4),
//                   borderSide: const BorderSide(
//                     color: Colors.teal,
//                     width: 1.5,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(4),
//                   borderSide: const BorderSide(
//                     color: Colors.teal,
//                     width: 1.5,
//                   ),
//                 ),
//               ),
//                   ),

//                   const SizedBox(height: 16),

//                   FormSectionTitle("Description"),
//                   Text(
//               "Give a detailed description for this bill",
//               style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//             ),
//             const SizedBox(height: 3),
//                   TextField(
//                     controller: _descriptionController,
//                     maxLines: 2,

//                     decoration: InputDecoration(
//                 hintText: "E.g Sunset seafood dinner at the beach for the whole group" ,
//                 hintStyle: TextStyle(color: Colors.grey[400]),
//                 filled: true,
//                 fillColor: Colors.transparent,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 18,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                    borderSide: const BorderSide(
//                     color: Colors.teal,
//                     width: 1,
//                   ),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                    borderSide: const BorderSide(
//                     color: Colors.teal,
//                     width: 1,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: const BorderSide(
//                     color: Colors.teal,
//                     width: 1,
//                   ),
//                 ),
//               ),
//                   ),

//                   const SizedBox(height: 24),




//                   FormSectionTitle("Bill Amount"),
// TextField(
//   controller: _amountController,
//   keyboardType: TextInputType.number,
//   inputFormatters: [
//     FilteringTextInputFormatter.digitsOnly,         // only allow digits
//     CurrencyInputFormatter(),                       // add comma formatting
//   ],
//   decoration: InputDecoration(
//     prefixIcon: Padding(
//       padding: const EdgeInsets.only(left: 16, right: 8),
//       child: Image.asset(
//         'assets/images/naira.png',
//         width: 30,
//         height: 30,
//         color: const Color(0xFF0B5754),
//       ),
//     ),
//     prefixIconConstraints: const BoxConstraints(
//       minWidth: 40,
//       minHeight: 40,
//     ),
//     hintText: "0.00",
//     hintStyle: TextStyle(color: Colors.grey[400], fontSize: 18),
//     filled: true,
//     fillColor: Colors.transparent,
//     contentPadding: const EdgeInsets.symmetric(
//       horizontal: 20,
//       vertical: 18,
//     ),
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(8),
//       borderSide: const BorderSide(color: Colors.teal, width: 1),
//     ),
//     enabledBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(8),
//       borderSide: const BorderSide(color: Colors.teal, width: 1),
//     ),
//     focusedBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(8),
//       borderSide: const BorderSide(color: Color(0xFF007A74), width: 1),
//     ),
//   ),
// ),






//                   const SizedBox(height: 20),
//                   BillImagePreview(
//                     imageFile: _billImage,
//                     imageUrl: _billImageUrl,
//                     onPickImage: _pickImage,
//                     onRemove: () => setState(() => _billImage = null),
//                   ),

//                   const SizedBox(height: 32),
//                   SplitParticipantsContainer(
//   selectedUsers: _selectedUsers,
//   onAddParticipant: _showAddParticipant,
//   currentUser: _currentUser,                    // NEW
//   onIncludeMeChanged: (include) {               // NEW
//     setState(() {
//       if (include && _currentUser != null) {
//         if (!_selectedUsers.any((u) => u.id == _currentUser!.id)) {
//           _selectedUsers.add(_currentUser!);
//         }
//       } else {
//         _selectedUsers.removeWhere((u) => u.id == _currentUser?.id);
//       }
//     });
//   },
// ),

//                   const SizedBox(height: 32),
//                   FormSectionTitle("Due Date"),
//                   GestureDetector(
//                     onTap: _pickDueDate,
//                     child: Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             _dueDate != null
//                                 ? DateFormat('dd MMM yyyy HH:mm').format(DateTime.parse(_dueDate!))
//                                 : "Not set",
//                             style: TextStyle(color: _dueDate != null ? Colors.black87 : Colors.grey),
//                           ),
//                           const Icon(Icons.calendar_today),
//                         ],
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 32),
//                   SplitMethodSelector(
//                     isEvenSplit: _isEvenSplit,
//                     onChanged: (v) => setState(() => _isEvenSplit = v),
//                     onManualTap: _openManualSplit,
//                     billAmount: billAmount,
//                     participantCount: _selectedUsers.length,
//                   ),

//                   if (_splitError != null) ...[
//                     const SizedBox(height: 12),
//                     Text(_splitError!, style: const TextStyle(color: Colors.red)),
//                   ],

//                   const SizedBox(height: 40),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 54,
//                     child: ElevatedButton(
//                       onPressed: _isCreating || !_isEvenSplit
//                           ? null
//                           : () async {
//                               setState(() => _isCreating = true);
//                               await _createEvenSplit();
//                               setState(() => _isCreating = false);
//                             },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF007A74),
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       child: _isCreating
//                           ? const SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
//                             )
//                           : const Text("CREATE SPLIT BILL"),
//                     ),
//                   ),

//                   const SizedBox(height: 100),
//                 ],
//               ),
//             ),
//     );
//   }
// }