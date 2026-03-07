// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:greyfundr/core/api/auth_api/auth_api.dart';
import 'package:greyfundr/core/api/auth_api/auth_api_impl.dart';
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

class _EditSplitBillState extends State<EditSplitBill> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;

  late DateTime _dueDate;
  late String _selectedSplitMethod;

  late List<Participant> _participants;

  final _formKey = GlobalKey<FormState>();

  final List<String> _splitMethods = [
    'equal',
    'custom',
    'percentage',
    'by_amount',
  ];

  final AuthApi _authApi = AuthApiImpl();

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

    _dueDate = bill.dueDate;
    _selectedSplitMethod = _normalizeSplitMethod(bill.splitMethod);
    _participants = List.from(bill.participants);
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

      final result = await _authApi.updateSplitBill(
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
    final progress = bill.amount > 0 ? bill.amountRaised / bill.amount : 0.0;

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
            expandedHeight: 280,
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
                  bill.imageUrl.isNotEmpty
                      ? Image.network(
                          bill.imageUrl,
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
                            Text(
                              "of ₦${bill.amount.toStringAsFixed(0)}",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Edit Split Details",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),

                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: "Bill Title",
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v?.trim().isEmpty ?? true ? "Required" : null,
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: "Description",
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: "Total Amount (₦)",
                            border: OutlineInputBorder(),
                            prefixText: "₦ ",
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Required";
                            final val = double.tryParse(v);
                            if (val == null || val <= 0) return "Enter valid amount";
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        DropdownButtonFormField<String>(
                          value: _splitMethods.contains(_selectedSplitMethod)
                              ? _selectedSplitMethod
                              : null,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: "Split Method",
                            border: OutlineInputBorder(),
                          ),
                          hint: const Text('Select split method'),
                          items: _splitMethods.map((m) {
                            return DropdownMenuItem<String>(
                              value: m,
                              child: Text(_getSplitMethodDisplay(m)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedSplitMethod = value);
                            }
                          },
                          validator: (value) => value == null ? 'Please select a split method' : null,
                        ),
                        const SizedBox(height: 20),

                        InkWell(
                          onTap: () => _selectDueDate(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: "Due Date",
                              border: OutlineInputBorder(),
                            ),
                            child: Text(_formatDate(_dueDate)),
                          ),
                        ),
                        const SizedBox(height: 32),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Participants",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            TextButton.icon(
                              onPressed: _addParticipant,
                              icon: const Icon(Icons.person_add, size: 18),
                              label: const Text("Add"),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF0D7377),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _participants.length,
                          itemBuilder: (context, index) {
                            final p = _participants[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF0D7377),
                                  child: Text(
                                    p.avatarInitial,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(p.displayName),
                                subtitle: Text(
                                  p.guestPhone ?? p.guestName ?? p.user?.firstName ?? "No contact",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _removeParticipant(index),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 140), // space for FAB
                      ],
                    ),
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