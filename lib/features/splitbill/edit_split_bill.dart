// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:greyfundr/core/api/splitbill_api/splitbill_api.dart';        // interface
import 'package:greyfundr/core/api/splitbill_api/splitbill_api_impl.dart';  // implementation

import 'package:greyfundr/core/models/split_bill_model.dart';
import 'package:greyfundr/services/custom_alert.dart';

class EditSplitBill extends StatefulWidget {
  final SplitBill initialBill;

  const EditSplitBill({
    super.key,
    required this.initialBill,
  });

  @override
  State<EditSplitBill> createState() => _EditSplitBillState();
}

class _EditSplitBillState extends State<EditSplitBill> with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;

  late DateTime _dueDate;
  late String _selectedSplitMethod;
  late String _originalSplitMethod;
  late bool _manualSplit;
  late String _imageUrl;
  late List<Participant> _participants;
  late TabController _tabController;
  late double _displayAmount;

  final _formKey = GlobalKey<FormState>();

  final List<String> _splitMethods = [
    'equal',
    'custom',
    'percentage',
    'by_amount',
  ];

 

 final SplitBillApi _splitBillApi = SplitBillApiImpl();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final bill = widget.initialBill;

    _titleController = TextEditingController(text: bill.title);
    _descriptionController = TextEditingController(text: bill.description);
    _amountController = TextEditingController(
      text: bill.amount.toStringAsFixed(0),
    );

    _displayAmount = bill.amount;

    _dueDate = bill.dueDate;
    _originalSplitMethod = _normalizeSplitMethod(bill.splitMethod);
    _selectedSplitMethod = _originalSplitMethod;
    _manualSplit = false;
    _participants = List.from(bill.participants);
    _imageUrl = bill.imageUrl;
    _tabController = TabController(length: 3, vsync: this);
  }

  String _normalizeSplitMethod(String? stored) {
    if (stored == null || stored.isEmpty) return 'equal';

    final lower = stored.toLowerCase().trim();

    if (lower.contains('even') || lower.contains('equal')) return 'equal';
    if (lower.contains('custom') || lower.contains('manual') || lower.contains('fixed')) return 'custom';
    if (lower.contains('percent')) return 'percentage';
    if (lower.contains('amount') || lower == 'by_amount') return 'by_amount';

    return 'equal'; // fallback
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF0D7377)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dueDate && mounted) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _showReceiptBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  Expanded(
                    child: _imageUrl.isNotEmpty
                        ? Image.network(
                            _imageUrl,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            errorBuilder: (c, e, s) => Container(
                              color: Colors.grey[200],
                              child: const Center(child: Icon(Icons.broken_image, size: 64, color: Colors.grey)),
                            ),
                          )
                        : Container(
                            color: Colors.grey[100],
                            child: const Center(child: Text('No receipt image')),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          if (!mounted) return;
                          setState(() => _imageUrl = '');
                          Navigator.of(ctx).pop();
                        },
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final newUrl = await showDialog<String>(
                            context: context,
                            builder: (dctx) {
                              final controller = TextEditingController(text: _imageUrl);
                              return AlertDialog(
                                title: const Text('Replace Receipt'),
                                content: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(hintText: 'Enter image URL'),
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(dctx).pop(), child: const Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.of(dctx).pop(controller.text.trim()), child: const Text('Replace')),
                                ],
                              );
                            },
                          );

                          if (newUrl != null && newUrl.isNotEmpty && mounted) {
                            setState(() => _imageUrl = newUrl);
                            Navigator.of(ctx).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D7377)),
                        child: const Text('Replace Receipt'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _showEditAmountBottomSheet() async {
    final controller = TextEditingController(text: _displayAmount.toStringAsFixed(0));

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Edit Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Text('Be aware that changing the Total Bill Amount will affect all participants.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Total Amount (₦)',
                    prefixText: '₦ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final raw = controller.text.trim().replaceAll(',', '');
                        final val = double.tryParse(raw);
                        if (val == null || val <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
                          return;
                        }
                        if (!mounted) return;
                        setState(() {
                          _displayAmount = val;
                          _amountController.text = val.toStringAsFixed(0);
                        });
                        Navigator.of(ctx).pop();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D7377)),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addParticipant() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Participant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone (optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name is required')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    setState(() {
      final tempId = "temp_${DateTime.now().millisecondsSinceEpoch}";

      _participants.add(
        Participant(
          id: tempId,
          amountOwed: 0.0,
          amountPaid: 0.0,
          status: 'UNPAID',
          paid: false,
          inviteCode: '',
          guestName: name,
          guestPhone: phone.isNotEmpty ? phone : null,
        ),
      );
    });
  }

  void _removeParticipant(int index) {
    setState(() {
      _participants.removeAt(index);
    });
  }

  Future<void> _saveChanges() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSaving = true);

  try {
    final updatedData = {
      "title": _titleController.text.trim(),
      "description": _descriptionController.text.trim(),
      "amount": double.tryParse(_amountController.text) ?? 0.0,
      "due_date": _dueDate.toUtc().toIso8601String(),
      "split_method": _selectedSplitMethod,
      "participants": _participants.map((p) {
        final map = {
          "id": p.id.startsWith("temp_") ? null : p.id,
          "guestName": p.guestName,
          "guestPhone": p.guestPhone,
          "amountOwed": p.amountOwed,
          "amountPaid": p.amountPaid,
          "status": p.status,
          "paid": p.paid,
        };
        map.removeWhere((key, value) => key == "id" && value == null);
        return map;
      }).toList(),
    };

    // FIXED: use _splitBillApi instead of _authApi
    final result = await _splitBillApi.updateSplitBill(
  splitBillId: widget.initialBill.id,
  updatedData: updatedData,
);

    if (!mounted) return;

    if (result != null) {
      CustomMessageModal.show(
        context: context,
        message: "Changes saved successfully",
        isSuccess: true,
      );
      Navigator.pop(context, true); // true = refresh summary
    } else {
      _showError("Failed to save changes");
    }
  } catch (e) {
    if (!mounted) return;
    _showError("Error: ${e.toString().split('\n').first}");
  } finally {
    if (mounted) setState(() => _isSaving = false);
  }
}

  void _showError(String message) {
    CustomMessageModal.show(
      context: context,
      message: message,
      isSuccess: false,
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _getSplitMethodDisplay(String method) {
    switch (method) {
      case 'equal':
        return 'Evenly / Equally';
      case 'custom':
        return 'Custom Amounts';
      case 'percentage':
        return 'By Percentage';
      case 'by_amount':
        return 'By Fixed Amount';
      default:
        return method[0].toUpperCase() + method.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bill = widget.initialBill;
    final progress = _displayAmount > 0 ? bill.amountRaised / _displayAmount : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _saveChanges,
        backgroundColor: const Color(0xFF0D7377),
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Icon(Icons.save, color: Colors.white),
        label: Text(
          _isSaving ? "SAVING..." : "SAVE CHANGES",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150, // reduced by 15% from 280
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Image.asset(
                  'assets/images/arrow_back.png',
                  width: 32,
                  height: 32,
                  color: Colors.white,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _imageUrl.isNotEmpty
                      ? Image.network(
                          _imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/bill_summary_header.png',
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(color: Colors.grey[300]),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                  ),
                  // image action icon (center-right)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTap: _showReceiptBottomSheet,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(Icons.image, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EFEF),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    
                    child: Column(
                      children: [
                        Row( 
                          children: [
                             Text(
                              "Edit Details",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [


                           

                            Text(
                              
                              "₦${bill.amountRaised.toStringAsFixed(0)} raised",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${(progress * 100).toStringAsFixed(0)}%",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D7377),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D7377)),
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  // bill amount (formatted with commas)
                                  "of ₦${NumberFormat.decimalPattern().format(_displayAmount.round())}",
                                  style: const TextStyle(color: Color.fromARGB(255, 60, 60, 60), fontWeight: FontWeight.w600, fontSize: 17),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18, color: Color(0xFF0D7377)),
                                  tooltip: 'Edit total amount',
                                  onPressed: _showEditAmountBottomSheet,
                                ),
                              ],
                            ),

                            // icon to edit amount
                            Text(
                              "${bill.participants.where((p) => p.paid).length} of ${bill.totalParticipants} paid",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Edit Details",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                _formatDate(_dueDate),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _selectDueDate(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Container(
                        color: Colors.white,
                        child: TabBar(
                          controller: _tabController,
                          labelColor: const Color(0xFF0D7377),
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: const Color(0xFF0D7377),
                          tabs: const [
                            Tab(text: "Title"),
                            Tab(text: "Description"),
                            Tab(text: "Participants"),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 360,
                        child: Form(
                          key: _formKey,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Title tab
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: TextFormField(
                                  controller: _titleController,
                                  decoration: const InputDecoration(
                                    labelText: "Bill Title",
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (v) => v?.trim().isEmpty ?? true ? "Required" : null,
                                ),
                              ),

                              // Description tab
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: TextFormField(
                                  controller: _descriptionController,
                                  maxLines: 6,
                                  decoration: const InputDecoration(
                                    labelText: "Description",
                                    border: OutlineInputBorder(),
                                    alignLabelWithHint: true,
                                  ),
                                ),
                              ),

                                // (Amount tab removed) editing total amount is available via the pencil icon

                              // Participants tab
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Participants", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                        TextButton.icon(
                                          onPressed: _addParticipant,
                                          icon: const Icon(Icons.person_add, size: 18),
                                          label: const Text("Add"),
                                          style: TextButton.styleFrom(foregroundColor: const Color(0xFF0D7377)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: _participants.length,
                                        itemBuilder: (context, index) {
                                          final p = _participants[index];
                                          final progress = (p.amountOwed > 0) ? (p.amountPaid / p.amountOwed) : 0.0;
                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 12),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.grey.shade200),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 20,
                                                      backgroundColor: const Color(0xFF0D7377),
                                                      child: Text(p.avatarInitial, style: const TextStyle(color: Colors.white)),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(p.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                                          if (p.guestPhone != null && p.guestPhone!.isNotEmpty)
                                                            Text(p.guestPhone!, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                      decoration: BoxDecoration(
                                                        color: p.paid ? Colors.green.shade100 : Colors.orange.shade100,
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: Text(p.paid ? "PAID" : "UNPAID", style: TextStyle(color: p.paid ? Colors.green.shade800 : Colors.orange.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                Row(
                                                  children: [
                                                    Text('₦${p.amountPaid.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                    const SizedBox(width: 8),
                                                    Text('of ₦${p.amountOwed.toStringAsFixed(0)}', style: TextStyle(color: const Color.fromARGB(255, 62, 44, 44), fontSize: 14, fontWeight: FontWeight.w600)),
                                                    const Spacer(),
                                                    Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D7377), fontSize: 16)),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: LinearProgressIndicator(
                                                    value: progress,
                                                    backgroundColor: Colors.grey[300],
                                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D7377)),
                                                    minHeight: 10,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Align(
                                                  alignment: Alignment.centerRight,
                                                  child: IconButton(
                                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                                    onPressed: () => _removeParticipant(index),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}