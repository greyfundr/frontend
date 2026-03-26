// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:greyfundr/core/api/splitbill_api/splitbill_api.dart';        // interface
// import 'package:greyfundr/core/api/splitbill_api/splitbill_api_impl.dart';  // implementation
// import 'package:greyfundr/core/models/ny_split_bill_model.dart';
// import 'package:greyfundr/modals/splitbill/add_participant_modal.dart';
// import 'package:greyfundr/services/custom_alert.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:greyfundr/features/splitbill/splitbill_provider.dart';

// class EditSplitBill extends StatefulWidget {
//   final SplitBill initialBill;

//   const EditSplitBill({
//     super.key,
//     required this.initialBill,
//   });

//   @override
//   State<EditSplitBill> createState() => _EditSplitBillState();
// }

// class _EditSplitBillState extends State<EditSplitBill> with SingleTickerProviderStateMixin {
//   late TextEditingController _titleController;
//   late TextEditingController _descriptionController;
//   late TextEditingController _amountController;

//   DateTime? _dueDate;
//   late String _selectedSplitMethod;
//   late String _originalSplitMethod;
//   late bool _manualSplit;
//   late String _imageUrl;
//   late List<Participant> _participants;
//   late double _displayAmount;
//   // Tab controller removed; DefaultTabController will manage tabs
  

//   final _formKey = GlobalKey<FormState>();

//   final List<String> _splitMethods = [
//     'equal',
//     'custom',
//   ];

 

//  final SplitBillApi _splitBillApi = SplitBillApiImpl();
//   final ImagePicker _picker = ImagePicker();

//   bool _isSaving = false;

//   @override
//   void initState() {
//     super.initState();
//     final bill = widget.initialBill;

//     _titleController = TextEditingController(text: bill.title);
//     _descriptionController = TextEditingController(text: bill.description);
//     _amountController = TextEditingController(
//       text: bill.amount.toStringAsFixed(0),
//     );

//     _displayAmount = bill.amount;

//     _dueDate = bill.dueDate;
//     _originalSplitMethod = _normalizeSplitMethod(bill.splitMethod);
//     _selectedSplitMethod = _originalSplitMethod;
//     _manualSplit = false;
//     _participants = List.from(bill.participants);
//     _imageUrl = bill.imageUrl;
//   }

//   String _normalizeSplitMethod(String? stored) {
//     if (stored == null || stored.isEmpty) return 'equal';

//     final lower = stored.toLowerCase().trim();

//     if (lower.contains('even') || lower.contains('equal')) return 'equal';
//     if (lower.contains('custom') || lower.contains('manual') || lower.contains('fixed')) return 'custom';
//     // Treat percentage and by-amount variants as custom/manual in the UI
//     if (lower.contains('percent')) return 'custom';
//     if (lower.contains('amount') || lower == 'by_amount') return 'custom';

//     return 'equal'; // fallback
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _amountController.dispose();
//     // TabController removed; DefaultTabController will manage tabs
//     super.dispose();
//   }

//   Future<void> _selectDueDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _dueDate ?? DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2030),
//       builder: (context, child) {
//         return Theme(
//           data: ThemeData.light().copyWith(
//             colorScheme: const ColorScheme.light(primary: Color(0xFF0D7377)),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && picked != _dueDate && mounted) {
//       setState(() => _dueDate = picked);
//     }
//   }

//   Future<void> _showReceiptBottomSheet() async {
//     File? tempImageFile;
//     bool isUploading = false; 

//     await showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) {
//         return StatefulBuilder(builder: (ctx, setModalState) {
//           return Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: const EdgeInsets.all(12),
//               height: MediaQuery.of(context).size.height * 0.6,
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: tempImageFile != null
//                         ? Image.file(
//                             tempImageFile!,
//                             fit: BoxFit.contain,
//                             width: double.infinity,
//                           )
//                         : (_isNetworkUrl(_imageUrl)
//                             ? Image.network(
//                                 _imageUrl,
//                                 fit: BoxFit.contain,
//                                 width: double.infinity,
//                                 errorBuilder: (c, e, s) => Container(
//                                   color: Colors.grey[200],
//                                   child: const Center(child: Icon(Icons.broken_image, size: 64, color: Colors.grey)),
//                                 ),
//                               )
//                             : (_imageUrl.isNotEmpty && _imageUrl.startsWith('assets/')
//                                 ? Image.asset(
//                                     _imageUrl,
//                                     fit: BoxFit.contain,
//                                     width: double.infinity,
//                                   )
//                                 : Container(
//                                     color: Colors.grey[100],
//                                     child: const Center(child: Text('No receipt image')),
//                                   ))),
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.delete_outline, color: Colors.red),
//                         onPressed: () {
//                           if (!mounted) return;
//                           tempImageFile = null;
//                           setState(() => _imageUrl = '');
//                           Navigator.of(ctx).pop();
//                         },
//                       ),
//                       // Replace button or inline loader
//                       isUploading
//                           ? const SizedBox(
//                               width: 140,
//                               height: 40,
//                               child: Center(child: CircularProgressIndicator()),
//                             )
//                           : ElevatedButton(
//                               onPressed: () async {
//                                 // Offer options: pick from device (camera/gallery) or enter URL
//                                 final choice = await showModalBottomSheet<String>(
//                                   context: context,
//                                   builder: (cctx) {
//                                     return SafeArea(
//                                       child: Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           ListTile(
//                                             leading: const Icon(Icons.photo_library),
//                                             title: const Text('Pick from Gallery'),
//                                             onTap: () => Navigator.of(cctx).pop('gallery'),
//                                           ),
//                                           ListTile(
//                                             leading: const Icon(Icons.camera_alt),
//                                             title: const Text('Take Photo'),
//                                             onTap: () => Navigator.of(cctx).pop('camera'),
//                                           ),
//                                           ListTile(
//                                             leading: const Icon(Icons.link),
//                                             title: const Text('Enter Image URL'),
//                                             onTap: () => Navigator.of(cctx).pop('url'),
//                                           ),
//                                           const SizedBox(height: 8),
//                                         ],
//                                       ),
//                                     );
//                                   },
//                                 );

//                                 if (choice == null) return;

//                                 if (choice == 'url') {
//                                   final newUrl = await showDialog<String>(
//                                     context: context,
//                                     builder: (dctx) {
//                                       final controller = TextEditingController(text: _imageUrl);
//                                       return AlertDialog(
//                                         title: const Text('Replace Receipt'),
//                                         content: TextField(
//                                           controller: controller,
//                                           decoration: const InputDecoration(hintText: 'Enter image URL'),
//                                         ),
//                                         actions: [
//                                           TextButton(onPressed: () => Navigator.of(dctx).pop(), child: const Text('Cancel')),
//                                           TextButton(onPressed: () => Navigator.of(dctx).pop(controller.text.trim()), child: const Text('Replace')),
//                                         ],
//                                       );
//                                     },
//                                   );

//                                   if (newUrl != null && newUrl.isNotEmpty && mounted) {
//                                     setState(() => _imageUrl = newUrl);
//                                     Navigator.of(ctx).pop();
//                                   }
//                                   return;
//                                 }

//                                 // pick from device (camera/gallery)
//                                 final source = choice == 'camera' ? ImageSource.camera : ImageSource.gallery;
//                                 try {
//                                   // pick (apply same constraints as CreateSplitBill)
//                                   final xFile = await _picker.pickImage(
//                                     source: source,
//                                     maxWidth: 1800,
//                                     maxHeight: 1800,
//                                     imageQuality: 88,
//                                   );
//                                   if (xFile == null) {
//                                     // user cancelled
//                                     return;
//                                   }

//                                   final file = File(xFile.path);

//                                   // show local preview immediately inside modal
//                                   tempImageFile = file;
//                                   setModalState(() {});

//                                   // show a global progress snackbar while uploading
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                       content: Row(
//                                         children: [
//                                           SizedBox(
//                                             width: 20,
//                                             height: 20,
//                                             child: CircularProgressIndicator(
//                                               strokeWidth: 2.5,
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                           SizedBox(width: 16),
//                                           Text('Processing receipt...'),
//                                         ],
//                                       ),
//                                       backgroundColor: Color(0xFF0D7377),
//                                       duration: Duration(seconds: 30),
//                                     ),
//                                   );

//                                   final uploadedUrl = await _splitBillApi.uploadBillReceipt(file);

//                                   ScaffoldMessenger.of(context).hideCurrentSnackBar();

//                                   if (uploadedUrl != null && mounted) {
//                                     setState(() {
//                                       _imageUrl = uploadedUrl;
//                                       tempImageFile = null;
//                                     });
//                                     Navigator.of(ctx).pop();
//                                     CustomMessageModal.show(context: context, message: 'Receipt replaced', isSuccess: true);
//                                   } else {
//                                     // keep local preview so user can retry or remove
//                                     setModalState(() {});
//                                     CustomMessageModal.show(context: context, message: 'Upload failed. Preview kept — try again.', isSuccess: false);
//                                   }
//                                 } catch (e) {
//                                   ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                                   final msg = e.toString().toLowerCase().contains('permission')
//                                       ? 'Permission denied to access photos or camera'
//                                       : 'Failed to replace image';
//                                   CustomMessageModal.show(context: context, message: msg, isSuccess: false);
//                                 }
//                               },
//                               style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D7377)),
//                               child: const Text('Replace Receipt'),
//                             ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         });
//       },
//     );
//   }

//   Future<void> _showEditAmountBottomSheet() async {
//     final controller = TextEditingController(text: _displayAmount.toStringAsFixed(0));

//     // Local modal state
//     String modalSelectedMethod = _selectedSplitMethod;
//     final Map<String, double> modalAmounts = {
//       for (final p in _participants) p.id: (p.amountOwed ?? 0.0),
//     };

//     final Map<String, TextEditingController> participantControllers = {
//       for (final p in _participants)
//         p.id: TextEditingController(text: (modalAmounts[p.id] ?? 0.0).toStringAsFixed(0)),
//     };

//     await showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) {
//         return StatefulBuilder(builder: (ctx, setModalState) {
//           final formatter = NumberFormat.currency(locale: 'en_US', symbol: '₦', decimalDigits: 0);

//           double parseTotal() {
//             final raw = controller.text.replaceAll(',', '').replaceAll('₦', '').trim();
//             return double.tryParse(raw) ?? 0.0;
//           }

//           void recalcEqual(double total) {
//             final count = _participants.isEmpty ? 1 : _participants.length;
//             final per = count > 0 ? (total / count) : 0.0;
//             for (final p in _participants) {
//               modalAmounts[p.id] = per;
//               // guard controller access in case of unexpected mutation while modal is open
//               participantControllers[p.id]?.text = per.toStringAsFixed(0);
//             }
//           }

//           return Padding(
//             padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//               ),
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text('Edit Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//                   const SizedBox(height: 6),
//                   const Text('Changing the total updates participant shares when split method is Even. Switch to Manual to edit participant amounts.', style: TextStyle(fontSize: 13),),
//                   const SizedBox(height: 12),

//                   // Total amount field
//                   TextField(
//                     controller: controller,
//                     keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                     decoration: const InputDecoration(
//                       labelText: 'Total Amount (₦)',
//                       prefixText: '₦ ',
//                       border: OutlineInputBorder(),
//                     ),
//                     onChanged: (v) {
//                       final total = parseTotal();
//                       if (modalSelectedMethod == 'equal') {
//                         setModalState(() => recalcEqual(total));
//                       }
//                     },
//                   ),

//                   const SizedBox(height: 12),

//                   // Split method dropdown
//                   Row(
//                     children: [
//                       const Text('Split Method:', style: TextStyle(fontWeight: FontWeight.w600)),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: DropdownButtonFormField<String>(
//                           value: modalSelectedMethod,
//                           items: _splitMethods.map((m) => DropdownMenuItem(
//                                 value: m,
//                                 child: Text(_getSplitMethodDisplay(m)),
//                               )).toList(),
//                           onChanged: (val) {
//                             if (val == null) return;
//                             setModalState(() {
//                               modalSelectedMethod = val;
//                               // if switching to equal, recalc amounts immediately
//                               if (modalSelectedMethod == 'equal') {
//                                 final total = parseTotal();
//                                 recalcEqual(total);
//                               }
//                               // if switching to custom, keep current amounts and allow editing
//                             });
//                           },
//                           decoration: const InputDecoration(border: OutlineInputBorder()),
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 12),

//                   // Participants list
//                   Flexible(
//                     child: ConstrainedBox(
//                       constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
//                       child: ListView.separated(
//                         shrinkWrap: true,
//                         itemCount: _participants.length,
//                         separatorBuilder: (_, __) => const SizedBox(height: 8),
//                           itemBuilder: (context, i) {
//                           final p = _participants[i];
//                           final ctrl = participantControllers[p.id]!;
//                           final editable = modalSelectedMethod == 'custom';

//                           return Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//                             child: Row(
//                               children: [
//                                 CircleAvatar(radius: 18, backgroundImage: AssetImage('assets/images/personal.png')),
//                                 const SizedBox(width: 12),
//                                 Expanded(child: Text(p.guestName ?? '', overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
//                                 const SizedBox(width: 12),
//                                 SizedBox(
//                                   width: 120,
//                                   child: TextField(
//                                     controller: ctrl,
//                                     textAlign: TextAlign.right,
//                                     keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                                     inputFormatters: [],
//                                     readOnly: !editable,
//                                     decoration: InputDecoration(
//                                       prefixText: '₦',
//                                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                                       isDense: true,
//                                       contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//                                     ),
//                                     onChanged: (val) {
//                                       if (!editable) return;
//                                       final clean = val.replaceAll(',', '').replaceAll('₦', '').trim();
//                                       final num = double.tryParse(clean) ?? 0.0;
//                                       setModalState(() => modalAmounts[p.id] = num);
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Participants: ${_participants.length}'),
//                       Builder(builder: (ctx) {
//                         final total = parseTotal();
//                         final sum = modalAmounts.values.fold(0.0, (a, b) => a + b);
//                         return Text('Assigned: ${formatter.format(sum)}', style: const TextStyle(fontWeight: FontWeight.w600));
//                       })
//                     ],
//                   ),

//                   const SizedBox(height: 12),

//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
//                       const SizedBox(width: 8),
//                       ElevatedButton(
//                         onPressed: () {
//                           try {
//                             final total = parseTotal();
//                             final sum = modalAmounts.values.fold(0.0, (a, b) => a + b);

//                             if (modalSelectedMethod == 'custom') {
//                               // require sums to match
//                               if ((sum - total).abs() > 0.01) {
//                                 CustomMessageModal.show(context: ctx, message: 'Participant amounts must sum to total', isSuccess: false);
//                                 return;
//                               }
//                             }

//                             // Commit to parent state
//                             if (mounted) {
//                               setState(() {
//                                 _displayAmount = total;
//                                 _selectedSplitMethod = modalSelectedMethod;
//                                 _amountController.text = _displayAmount.toStringAsFixed(0);

//                                 // Replace each participant with a new instance carrying updated amountOwed,
//                                 // because Participant.amountOwed is final.
//                                 for (final p in List<Participant>.from(_participants)) {
//                                   final idx = _participants.indexWhere((x) => x.id == p.id);
//                                   if (idx != -1) {
//                                     final newAmount = (modalAmounts[p.id] ?? p.amountOwed) as double;
//                                     _participants[idx] = Participant(
//                                       id: p.id,
//                                       userId: p.userId,
//                                       guestName: p.guestName,
//                                       guestPhone: p.guestPhone,
//                                       guestEmail: p.guestEmail,
//                                       amountOwed: newAmount,
//                                       amountPaid: p.amountPaid,
//                                       status: p.status,
//                                       paid: p.paid,
//                                       inviteCode: p.inviteCode,
//                                       profilePic: p.profilePic,
//                                       user: p.user,
//                                     );
//                                   }
//                                 }
//                               });
//                             }

//                             // remove focus (close keyboard) before popping to avoid rebuilds
//                             try {
//                               FocusScope.of(ctx).unfocus();
//                             } catch (_) {}
//                             Navigator.of(ctx).pop();
//                           } catch (e, st) {
//                             // Prevent modal from crashing the app; show friendly error and log
//                             CustomMessageModal.show(context: ctx, message: 'Failed to save amounts: ${e.toString()}', isSuccess: false);
//                             // ignore: avoid_print
//                             print('Error saving participant amounts: $e\n$st');
//                           }
//                         },
//                         child: const Text('Save'),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         });
//       },
//     );

//     // dispose temporary controllers after the current frame so TextFields detach safely
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       for (final c in participantControllers.values) {
//         try {
//           c.dispose();
//         } catch (_) {}
//       }
//     });
//   }

//   Future<void> _addParticipant() async {
//     // Ensure the provider has the latest users before opening the picker
//     final splitProvider = Provider.of<SplitBillProvider>(context, listen: false);
//     await splitProvider.getAllUsers();

//     // Open the same participants picker used in Create Split Bill
//     await showModalBottomSheet<List<dynamic>>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => AddParticipantModal(currentUserId: widget.initialBill.creatorId),
//     );

//     // After the modal closes, read the selected users from the provider
//     final selected = splitProvider.selectedUsers;
//     if (selected.isEmpty || !mounted) return;

//     int added = 0;
//     setState(() {
//       for (final u in selected) {
//         final String uid = (u.id != null) ? u.id.toString() : 'temp_${DateTime.now().millisecondsSinceEpoch}';
//         final String? name = (u.firstName ?? u.username)?.toString();
//         final String? phone = (u.phoneNumber ?? u.email)?.toString();
//         final String? pic = (u.profile != null && u.profile.toString().isNotEmpty)
//           ? u.profile.toString()
//           : 'assets/images/personal.png';

//         // Skip if already added (by phone or id)
//         final existsByPhone = phone != null && _participants.any((p) => p.guestPhone != null && p.guestPhone == phone);
//         final existsById = _participants.any((p) => p.userId != null && p.userId == uid);
//         if (existsByPhone || existsById) continue;

//         _participants.add(Participant(
//           id: uid,
//           userId: uid,
//           guestName: name,
//           guestPhone: phone,
//           guestEmail: null,
//           amountOwed: 0.0,
//           amountPaid: 0.0,
//           status: 'UNPAID',
//           paid: false,
//           inviteCode: '',
//           profilePic: pic,
//           user: null,
//         ));
//         added += 1;
//       }

//       // If current split method is equal, recalculate each participant's share
//       if (added > 0 && _selectedSplitMethod == 'equal') {
//         final count = _participants.isEmpty ? 1 : _participants.length;
//         final per = count > 0 ? (_displayAmount / count) : 0.0;
//         for (var i = 0; i < _participants.length; i++) {
//           final p = _participants[i];
//           _participants[i] = Participant(
//             id: p.id,
//             userId: p.userId,
//             guestName: p.guestName,
//             guestPhone: p.guestPhone,
//             guestEmail: p.guestEmail,
//             amountOwed: per,
//             amountPaid: p.amountPaid,
//             status: p.status,
//             paid: p.paid,
//             inviteCode: p.inviteCode,
//             profilePic: p.profilePic,
//             user: p.user,
//           );
//         }
//       }
//     });

//     // clear provider selection so modal starts fresh next time
//     splitProvider.clearSelectedUsers();

//     if (added > 0) {
//       CustomMessageModal.show(context: context, message: 'Added $added participant${added > 1 ? 's' : ''}', isSuccess: true);
//     } else {
//       CustomMessageModal.show(context: context, message: 'No new participants added', isSuccess: false);
//     }
//   }

//   void _removeParticipant(int index) {
//     setState(() {
//       _participants.removeAt(index);

//       // If split method is equal, recalculate equal shares for remaining participants
//       if (_selectedSplitMethod == 'equal') {
//         final count = _participants.isEmpty ? 0 : _participants.length;
//         final per = (count > 0) ? (_displayAmount / count) : 0.0;
//         for (var i = 0; i < _participants.length; i++) {
//           final p = _participants[i];
//           _participants[i] = Participant(
//             id: p.id,
//             userId: p.userId,
//             guestName: p.guestName,
//             guestPhone: p.guestPhone,
//             guestEmail: p.guestEmail,
//             amountOwed: per,
//             amountPaid: p.amountPaid,
//             status: p.status,
//             paid: p.paid,
//             inviteCode: p.inviteCode,
//             profilePic: p.profilePic,
//             user: p.user,
//           );
//         }
//       }
//     });
//   }

//   Future<void> _saveChanges() async {
//   if (!_formKey.currentState!.validate()) return;

//   setState(() => _isSaving = true);

//     try {
//     // The backend accepts only top-level editable fields on patch updates.
//     // Send camelCase keys and include additional fields only when they changed.
//     final Map<String, dynamic> updatedData = {
//       "title": _titleController.text.trim(),
//       "description": _descriptionController.text.trim(),
//       // send the edited total amount (use _displayAmount as the source of truth)
//       "amount": _displayAmount.round(),
//     };

//     // include dueDate if changed (use camelCase key)
//     final isoDue = _dueDate?.toUtc().toIso8601String();
//     final initialDueIso = widget.initialBill.dueDate?.toUtc().toIso8601String();
//     if (isoDue != initialDueIso) updatedData['dueDate'] = isoDue;

//     // include splitMethod if changed
//     if ((_selectedSplitMethod ?? '') != (_originalSplitMethod ?? '')) {
//       updatedData['splitMethod'] = _selectedSplitMethod;
//     }

//     // NOTE: the backend rejects `participants` on this PATCH endpoint
//     // (response: "property participants should not exist").
//     // Participants updates must be handled via the appropriate participants
//     // endpoint (if available). Do not include `participants` here.

//     // FIXED: use _splitBillApi instead of _authApi
//     final result = await _splitBillApi.updateSplitBill(
//   splitBillId: widget.initialBill.id,
//   updatedData: updatedData,
// );

//     if (!mounted) return;

//     if (result != null) {
//       // If backend returned the updated bill in `data`, apply it locally
//       // so UI shows the updated values immediately, and return the data
//       // to the caller so the previous screen can refresh.
//       final Map<String, dynamic>? returned = (result is Map<String, dynamic>) ? (result['data'] as Map<String, dynamic>?) : null;

//       if (returned != null) {
//         // update local fields from server response when available
//         final totalStr = returned['totalAmount']?.toString();
//         final totalNum = double.tryParse(totalStr ?? '') ?? (double.tryParse(_amountController.text) ?? _displayAmount);

//         setState(() {
//           _displayAmount = totalNum;
//           _amountController.text = totalNum.toStringAsFixed(0);
//           _titleController.text = returned['title']?.toString() ?? _titleController.text;
//           _descriptionController.text = returned['description']?.toString() ?? _descriptionController.text;
//           _imageUrl = returned['imageUrl']?.toString() ?? _imageUrl;
//         });

//         CustomMessageModal.show(
//           context: context,
//           message: "Changes saved successfully",
//           isSuccess: true,
//         );

//         Navigator.pop(context, returned);
//         return;
//       }

//       // Fallback if no `data` returned
//       CustomMessageModal.show(
//         context: context,
//         message: "Changes saved successfully",
//         isSuccess: true,
//       );
//       Navigator.pop(context, true); // true = refresh summary
//     } else {
//       _showError("Failed to save changes");
//     }
//   } catch (e) {
//     if (!mounted) return;
//     _showError("Error: ${e.toString().split('\n').first}");
//   } finally {
//     if (mounted) setState(() => _isSaving = false);
//   }
// }

//   void _showError(String message) {
//     CustomMessageModal.show(
//       context: context,
//       message: message,
//       isSuccess: false,
//     );
//   }

//   String _formatDate(DateTime? date) {
//     if (date == null) return 'No due date';
//     return DateFormat('dd/MM/yyyy').format(date);
//   }

//   String _getSplitMethodDisplay(String method) {
//     switch (method) {
//       case 'equal':
//         return 'Evenly / Equally';
//       case 'custom':
//         return 'Custom Amounts';
//       default:
//         return method.isNotEmpty ? method[0].toUpperCase() + method.substring(1) : method;
//     }
//   }

//   bool _isNetworkUrl(String? s) {
//     if (s == null) return false;
//     final str = s.trim();
//     if (str.isEmpty) return false;
//     return str.startsWith('http://') || str.startsWith('https://');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bill = widget.initialBill;
//     final progress = _displayAmount > 0 ? bill.amountRaised / _displayAmount : 0.0;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _isSaving ? null : _saveChanges,
//         backgroundColor: const Color(0xFF0D7377),
//         icon: _isSaving
//             ? const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2.5,
//                 ),
//               )
//             : const Icon(Icons.save, color: Colors.white),
//         label: Text(
//           _isSaving ? "SAVING..." : "SAVE CHANGES",
//           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 150, // reduced by 15% from 280
//             pinned: true,
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             leading: Padding(
//               padding: const EdgeInsets.only(left: 16, top: 8),
//               child: IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: Image.asset(
//                   'assets/images/arrow_back.png',
//                   width: 32,
//                   height: 32,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//             flexibleSpace: FlexibleSpaceBar(
//               background: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   _isNetworkUrl(_imageUrl)
//                       ? Image.network(
//                           _imageUrl,
//                           fit: BoxFit.cover,
//                           errorBuilder: (_, __, ___) => Image.asset(
//                             'assets/images/bill_summary_header.png',
//                             fit: BoxFit.cover,
//                           ),
//                         )
//                       : (_imageUrl.isNotEmpty && _imageUrl.startsWith('assets/')
//                           ? Image.asset(
//                               _imageUrl,
//                               fit: BoxFit.cover,
//                             )
//                           : Container(color: Colors.grey[300])),
//                   Container(
//                     decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [Colors.black54, Colors.transparent],
//                       ),
//                     ),
//                   ),
//                   // image action icon (center-right)
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: Padding(
//                       padding: const EdgeInsets.only(right: 12.0),
//                       child: GestureDetector(
//                         onTap: _showReceiptBottomSheet,
//                         child: Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.black45,
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           child: const Icon(Icons.image, color: Colors.white, size: 20),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           SliverToBoxAdapter(
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical:10),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF0EFEF),
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey,
//                           blurRadius: 10,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
                    
//                     child: Column(
//                       children: [
//                         Row( 
//                           children: [
//                              Text(
//                               "Edit Details",
//                               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                             ),
//                           ],
//                         ),
//                        const SizedBox(height: 15),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [


                           

//                             Text(
                              
//                               "₦${bill.amountRaised.toStringAsFixed(0)} raised",
//                               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                             ),
//                             Text(
//                               "${(progress * 100).toStringAsFixed(0)}%",
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF0D7377),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: LinearProgressIndicator(
//                             value: progress,
//                             backgroundColor: Colors.grey[300],
//                             valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D7377)),
//                             minHeight: 10,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   // bill amount (formatted with commas)
//                                   "of ₦${NumberFormat.decimalPattern().format(_displayAmount.round())}",
//                                   style: const TextStyle(color: Color.fromARGB(255, 60, 60, 60), fontWeight: FontWeight.w600, fontSize: 17),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 IconButton(
//                                   icon: const Icon(Icons.edit, size: 18, color: Color(0xFF0D7377)),
//                                   tooltip: 'Edit total amount',
//                                   onPressed: _showEditAmountBottomSheet,
//                                 ),
//                               ],
//                             ),

//                             // icon to edit amount
//                             Text(
//                               "${bill.participants.where((p) => p.paid).length} of ${bill.totalParticipants} paid",
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Row(
//                               children: [
//                                 Text(
//                                   _getSplitMethodDisplay(_selectedSplitMethod),
//                                   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Row(
//                             children: [
//                               Text(
//                                 _formatDate(_dueDate),
//                                 style: TextStyle(color: Colors.grey[600]),
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.edit, size: 20),
//                                 onPressed: () => _selectDueDate(context),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),

//                       DefaultTabController(
//                         length: 3,
//                         child: Column(
//                           children: [
//                             Container(
//                               color: Colors.white,
//                               child: const TabBar(
//                                 labelColor: Color(0xFF0D7377),
//                                 unselectedLabelColor: Colors.grey,
//                                 indicatorColor: Color(0xFF0D7377),
//                                 tabs: [
//                                   Tab(text: "Title"),
//                                   Tab(text: "Description"),
//                                   Tab(text: "Participants"),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(
//                               height: 360,
//                               child: Form(
//                                 key: _formKey,
//                                 child: TabBarView(
//                                   children: [
//                                   // Title tab
//                                   Padding(
//                                     padding: const EdgeInsets.all(12),
//                                     child: TextFormField(
//                                       controller: _titleController,
//                                       decoration: const InputDecoration(
//                                         labelText: "Bill Title",
//                                         border: OutlineInputBorder(),
//                                       ),
//                                       validator: (v) => v?.trim().isEmpty ?? true ? "Required" : null,
//                                     ),
//                                   ),

//                                   // Description tab
//                                   Padding(
//                                     padding: const EdgeInsets.all(12),
//                                     child: TextFormField(
//                                       controller: _descriptionController,
//                                       maxLines: 6,
//                                       decoration: const InputDecoration(
//                                         labelText: "Description",
//                                         border: OutlineInputBorder(),
//                                         alignLabelWithHint: true,
//                                       ),
//                                     ),
//                                   ),

//                                   // Participants tab
//                                   Padding(
//                                     padding: const EdgeInsets.all(8),
//                                     child: Column(
//                                       children: [
//                                         Row(
//                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             const Text("Participants", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
//                                             // Add participant button
//                                             TextButton.icon(
//                                               onPressed: _addParticipant,
//                                               icon: const Icon(Icons.person_add, size: 18),
//                                               label: const Text("Add"),
//                                               style: TextButton.styleFrom(foregroundColor: const Color(0xFF0D7377)),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Expanded(
//                                           child: ListView.builder(
//                                             itemCount: _participants.length,
//                                             itemBuilder: (context, index) {
//                                               final p = _participants[index];
//                                               final progress = (p.amountOwed > 0) ? (p.amountPaid / p.amountOwed) : 0.0;
//                                               return Container(
//                                                 margin: const EdgeInsets.only(bottom: 12),
//                                                 padding: const EdgeInsets.all(12),
//                                                 decoration: BoxDecoration(
//                                                   color: Colors.white,
//                                                   borderRadius: BorderRadius.circular(12),
//                                                   border: Border.all(color: Colors.grey.shade200),
//                                                 ),
//                                                 child: Column(
//                                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                                   children: [
//                                                     Row(
//                                                       children: [
//                                                         CircleAvatar(
//                                                           radius: 20,
//                                                           backgroundColor: const Color(0xFF0D7377),
//                                                           child: Text(p.avatarInitial, style: const TextStyle(color: Colors.white)),
//                                                         ),
//                                                         const SizedBox(width: 12),
//                                                         Expanded(
//                                                           child: Column(
//                                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                                             children: [
//                                                               Text(p.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
//                                                               if (p.guestPhone != null && p.guestPhone!.isNotEmpty)
//                                                                 Text(p.guestPhone!, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                         Container(
//                                                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                                           decoration: BoxDecoration(
//                                                             color: p.paid ? Colors.green.shade100 : Colors.orange.shade100,
//                                                             borderRadius: BorderRadius.circular(20),
//                                                           ),
//                                                           child: Text(
//                                                             p.paid ? "PAID" : "UNPAID",
//                                                             style: TextStyle(
//                                                                 color: p.paid ? Colors.green.shade800 : Colors.orange.shade800,
//                                                                 fontWeight: FontWeight.bold,
//                                                                 fontSize: 12),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     const SizedBox(height: 12),
//                                                     Row(
//                                                       children: [
//                                                         Text('expected to pay', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                                                         const SizedBox(width: 8),
//                                                         Text('₦${p.amountOwed.toStringAsFixed(0)}', style: TextStyle(color: const Color.fromARGB(255, 62, 44, 44), fontSize: 14, fontWeight: FontWeight.w600)),
//                                                         const Spacer(),
//                                                       ],
//                                                     ),
//                                                     const SizedBox(height: 4),
//                                                     Align(
//                                                       alignment: Alignment.centerRight,
//                                                       child: IconButton(
//                                                         icon: const Icon(Icons.delete_outline, color: Colors.red),
//                                                         onPressed: () => _removeParticipant(index),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               );
//                                             },
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                       const SizedBox(height: 24),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }