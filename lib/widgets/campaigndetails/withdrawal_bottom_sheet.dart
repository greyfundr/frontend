// withdrawal_bottom_sheet.dart
// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greyfundr/shared/custom_message_modal.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

class Budget {
  final int? id;
  final String name;
  final double cost;

  Budget({
    this.id,
    required this.name,
    required this.cost,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    print("Parsing budget item: $json");

    String nameGuess =
        json['name'] as String? ??
        json['item'] as String? ??
        json['description'] as String? ??
        json['title'] as String? ??
        'Unnamed Item';

    double costGuess = 
        (json['cost'] as num?)?.toDouble() ??
        (json['amount'] as num?)?.toDouble() ??
        (json['value'] as num?)?.toDouble() ??
        0.0;

    return Budget(
      id: json['id'] is int ? json['id'] as int : null,
      name: nameGuess,
      cost: costGuess,
    );
  }
}


class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove any existing commas
    final unformatted = newValue.text.replaceAll(',', '');

    // Parse as integer (safe)
    final number = int.tryParse(unformatted) ?? 0;

    // Format with commas
    final formatted = NumberFormat('#,###').format(number);

    // Preserve cursor position
    final selectionIndex = newValue.selection.end;
    final oldLength = newValue.text.length;
    final newLength = formatted.length;

    // Adjust cursor after formatting
    int newSelection = selectionIndex + (newLength - oldLength);

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: newSelection),
    );
  }
}

class WithdrawalBottomSheet extends StatefulWidget {
  final String raisedAmount;
  final String goalAmount;
  final String donors;       // ← changed from int to String
  final String champions;    // ← changed from int to String
  final String campaignId;   // ← changed from int to String
  final List<dynamic> budgetsRaw;

  const WithdrawalBottomSheet({
    super.key,
    required this.raisedAmount,
    required this.goalAmount,
    required this.donors,
    required this.champions,
    required this.campaignId,
    required this.budgetsRaw,
  });

  @override
  State<WithdrawalBottomSheet> createState() => _WithdrawalBottomSheetState();
}

class _WithdrawalBottomSheetState extends State<WithdrawalBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController(); // ← NEW
  Set<int> _selectedBudgetIds = {};

  late final List<Budget> _budgets;

  @override
  void initState() {
    super.initState();

    _budgets = widget.budgetsRaw
        .whereType<Map<String, dynamic>>()
        .map((e) => Budget.fromJson(e))
        .toList();
  }

  String formatCurrency(String value) {
    final num = double.tryParse(value) ?? 0;
    final f = NumberFormat("#,##0", "en_US");
    return f.format(num);
  }

  double get percentage {
    final raised = double.tryParse(widget.raisedAmount) ?? 0;
    final goal = double.tryParse(widget.goalAmount) ?? 1;
    return (raised / goal).clamp(0.0, 1.0);
  }

 void _showBudgetSelectionBottomSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setBottomSheetState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.45,
            maxChildSize: 0.92,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const Text(
                      "Select Budget(s)",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 16),

                    Expanded(
                      child: _budgets.isEmpty
                          ? const Center(
                              child: Text("No budgets found for this campaign"))
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: _budgets.length,
                              itemBuilder: (context, index) {
                                final budget = _budgets[index];
                                final isSelected = _selectedBudgetIds.contains(index);

                                return CheckboxListTile(
                                  value: isSelected,
                                  activeColor: Colors.teal,
                                  title: Text(
                                    budget.name,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Text(
                                    "₦${formatCurrency(budget.cost.toStringAsFixed(0))}",
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  onChanged: (bool? value) {
                                    setBottomSheetState(() {
                                      if (value == true) {
                                        _selectedBudgetIds.add(index);
                                      } else {
                                        _selectedBudgetIds.remove(index);
                                      }
                                    });
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                    ),

                    // ── Buttons + generous bottom space ────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 64), // ← 64 bottom = solid visible space below buttons
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Optional: save selected budgets before closing
                                // e.g. update parent state or call callback
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 2,
                              ),
                              child: const Text(
                                "Done",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final raisedFormatted = formatCurrency(widget.raisedAmount);
    final goalFormatted = formatCurrency(widget.goalAmount);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Title
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "WITHDRAWAL",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Raised amount (unchanged)
                Row(
                  children: [
                    Text(
                      "₦$raisedFormatted",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "raised",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color.fromARGB(255, 52, 52, 52),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Goal & progress (unchanged)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "₦$raisedFormatted",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 45, 45, 45),
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Text(
                      "raised of",
                      style: TextStyle(color: Color.fromARGB(255, 79, 79, 79)),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      "₦$goalFormatted",
                      style: const TextStyle(color: Color.fromARGB(255, 79, 79, 79)),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                LinearPercentIndicator(
                  width: MediaQuery.of(context).size.width - 40,
                  lineHeight: 10.0,
                  percent: percentage,
                  backgroundColor: Colors.grey[300]!,
                  linearGradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color.fromARGB(255, 10, 45, 25),
                      Color.fromARGB(255, 60, 69, 65),
                      Color.fromARGB(255, 47, 109, 73),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                  barRadius: const Radius.circular(8),
                  animation: true,
                  animationDuration: 800,
                ),

                const SizedBox(height: 16),

                // Donors & Champions (unchanged)
                Row(
                  children: [
                    Icon(Icons.people, size: 18, color: Colors.grey[700]),
                    const SizedBox(width: 6),
                    Text(
                      "${widget.donors} Donors",
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                    const SizedBox(width: 24),
                    Icon(Icons.emoji_events_outlined, size: 18, color: Colors.grey[700]),
                    const SizedBox(width: 6),
                    Text(
                      "${widget.champions} Champions",
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Service charge warning (unchanged)
                Container(
                  padding: const EdgeInsets.all(12),
                  
                  child: Text(
                    "20% service charge will be applied to total amount raised",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 230, 61, 0),
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Amount input (unchanged)
                const Text(
                  "Amount you want to withdraw",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 8),

                TextField(
  controller: _amountController,
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,           // ← only allows 0-9
    _ThousandsSeparatorInputFormatter(),              // ← adds commas automatically
  ],
  decoration: InputDecoration(
    prefixIcon: const Padding(
      padding: EdgeInsets.only(left: 16),
      child: Text(
        "₦",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.teal,
        ),
      ),
    ),
    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[400]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[400]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF00C853), width: 2),
    ),
    hintText: "0",
    hintStyle: TextStyle(color: Colors.grey[400]),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  style: const TextStyle(fontSize: 20),
),

                const SizedBox(height: 20),

                // Budget selection button (unchanged)
                const Text(
                  "Reason for withdrawal",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 8),

                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _showBudgetSelectionBottomSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                     
                      child: Row(
                        children: const [
                          Icon(
                            Icons.add_circle_outline_rounded,
                            color: Colors.teal,
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Tag Budgeting",
                            style: TextStyle(
                              color: Colors.teal,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (_selectedBudgetIds.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    "${_selectedBudgetIds.length} budget item${_selectedBudgetIds.length == 1 ? '' : 's'} selected",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.teal[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 15),

                // ── NEW: TextField for additional reason ────────────────────────────────
                // const Text(
                //   "Additional reason (optional)",
                //   style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                // ),
                const SizedBox(height: 8),

                TextField(
                  controller: _reasonController,
                  maxLines: 4,
                  minLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: "Describe your reason for this withdrawal...",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00C853), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 32),

                // Withdraw button (updated to also capture reason)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      final amount = _amountController.text.trim();
                      final reason = _reasonController.text.trim();

                      if (amount.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter amount")),
                        );
                        return;
                      }

                      // Optional: warn if reason is empty but budgets are selected
                      if (reason.isEmpty && _selectedBudgetIds.isNotEmpty) {
                        // You can make this required or keep optional
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(content: Text("Please provide a reason when selecting budgets")),
                        // );
                        // return;
                      }

                      // TODO: Send withdrawal request with:
                      // - amount
                      // - campaignId
                      // - selected budget indices or ids: _selectedBudgetIds.toList()
                      // - reason (if not empty)

                      print("Withdrawal request:");
                      print("Amount: $amount");
                      print("Reason: $reason");
                      print("Selected budgets indices: ${_selectedBudgetIds.toList()}");

                      Navigator.pop(context);

                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(content: Text("Withdrawal request for ₦$amount submitted")),
                      // );


                      CustomMessageModal.show(
        context: context,
        message: "Withdrawal request for ₦$amount submitted",
        isSuccess: true,
        duration: const Duration(seconds: 3),
      );

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "WITHDRAW",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose(); // ← don't forget!
    super.dispose();
  }
}