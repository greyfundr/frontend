import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:greyfundr/shared/currency_input_formatter.dart';

import 'package:greyfundr/core/models/split_user_model.dart';
// assuming you still use this for messages

class ManualSplitModal extends StatefulWidget {
  final TextEditingController billAmountController;
  final List<User> selectedUsers;
  final Future<void> Function(
   Map<String, double> userAmounts,
    String? imageUrl,
  ) onCreateSplit;

  const ManualSplitModal({
    super.key,
    required this.billAmountController,
    required this.selectedUsers,
    required this.onCreateSplit,
  });

  @override
  State<ManualSplitModal> createState() => _ManualSplitModalState();
}

class _ManualSplitModalState extends State<ManualSplitModal> {
  // Local state
  bool _isPercentageMode = false;
  
  late Map<String, double> _userAmounts;
late Map<String, double> _userPercentages;
late Map<String, TextEditingController> _amountControllers;

  double? _totalBillAmount;
  String _formatCurrency(double value) {
  final formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '₦',
    decimalDigits: 2,
  );
  return formatter.format(value);
}

String _formatNumber(double value, {int decimalDigits = 0}) {
  final formatter = NumberFormat.decimalPattern('en_US');
  formatter.maximumFractionDigits = decimalDigits;
  formatter.minimumFractionDigits = decimalDigits;
  return formatter.format(value);
}

  @override
  void initState() {
    super.initState();

    final amountText = widget.billAmountController.text.trim().replaceAll(',', '');
    _totalBillAmount = double.tryParse(amountText);

    _userAmounts = {};
    _userPercentages = {};
    _amountControllers = {};

    for (final user in widget.selectedUsers) {
      _userAmounts[user.id] = 0.0;
      _userPercentages[user.id] = 0.0;

      final ctrl = TextEditingController();
      _amountControllers[user.id] = ctrl;
    }
  }

  @override
  void dispose() {
    for (var ctrl in _amountControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  double get _totalAssigned => _userAmounts.values.fold(0.0, (sum, v) => sum + v);
  double get _totalPercentage => _userPercentages.values.fold(0.0, (sum, v) => sum + v);

  bool get _isOver => _totalAssigned > (_totalBillAmount ?? 0);
  bool get _isComplete => (_totalBillAmount ?? 0) > 0 && (_totalAssigned - (_totalBillAmount ?? 0)).abs() < 0.01;

  void _switchMode(bool percentage) {
    setState(() {
      _isPercentageMode = percentage;

      if (percentage) {
        // Convert amounts → percentages
        for (final user in widget.selectedUsers) {
          final amt = _userAmounts[user.id] ?? 0.0;
          final pct = _totalBillAmount != null && _totalBillAmount! > 0
              ? (amt / _totalBillAmount!) * 100
              : 0.0;
          _userPercentages[user.id] = pct;
          _amountControllers[user.id]!.text = pct > 0 ? pct.toStringAsFixed(1) : '';
        }
      } else {
        // Convert percentages → amounts
        for (final user in widget.selectedUsers) {
          final pct = _userPercentages[user.id] ?? 0.0;
          final amt = (_totalBillAmount ?? 0) * (pct / 100);
          _userAmounts[user.id] = amt;
          _amountControllers[user.id]!.text = amt > 0 ? amt.toStringAsFixed(0) : '';
        }
      }
    });
  }
  

  Widget _buildHeader() {
  final remaining = (_totalBillAmount ?? 0) - _totalAssigned;
  final remainingPct = 100 - _totalPercentage;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Split Manually",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF007A74).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _switchMode(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: !_isPercentageMode ? const Color(0xFF007A74) : null,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "₦ Amount",
                        style: TextStyle(
                          color: !_isPercentageMode ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _switchMode(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isPercentageMode ? const Color(0xFF007A74) : null,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "% Percent",
                        style: TextStyle(
                          color: _isPercentageMode ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Total Bill:"),
            Text(
              _formatCurrency(_totalBillAmount ?? 0),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Assigned:"),
            Text(
              _isPercentageMode
                  ? "${_formatNumber(_totalPercentage, decimalDigits: 1)}%"
                  : _formatCurrency(_totalAssigned),
              style: TextStyle(
                color: _isOver || (_isPercentageMode && _totalPercentage > 100)
                    ? Colors.red
                    : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Remaining:"),
            Text(
              _isPercentageMode
                  ? "${_formatNumber(remainingPct, decimalDigits: 1)}% left"
                  : _formatCurrency(remaining.abs()),
              style: TextStyle(
                color: _isOver || (_isPercentageMode && _totalPercentage > 100)
                    ? Colors.red
                    : _isComplete
                        ? Colors.green
                        : const Color.fromARGB(255, 88, 66, 66),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildParticipantRow(User user) {
    final id = user.id;
    final amountCtrl = _amountControllers[id]!;

    final currentAmount = _userAmounts[id] ?? 0.0;
    final currentPct = _userPercentages[id] ?? 0.0;

    final displayPct = _totalBillAmount != null && _totalBillAmount! > 0
        ? (currentAmount / _totalBillAmount!) * 100
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: 

            AssetImage('assets/images/personal.png'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.displayName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 100,
            child: TextField(
  controller: amountCtrl,
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  textAlign: TextAlign.center,
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')), // allow digits + one decimal
    CurrencyInputFormatter(),                             // live formatting + commas
  ],
  decoration: InputDecoration(
    hintText: _isPercentageMode ? "0.0" : "0",
    filled: true,
    fillColor: const Color(0xFFF0FAFF),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 10),
  ),
  onChanged: (value) {
    // Remove formatting before parsing the real number
    final cleanValue = value.replaceAll(',', '');
    final input = double.tryParse(cleanValue) ?? 0.0;

    setState(() {
      if (_isPercentageMode) {
        final pct = input.clamp(0.0, 100.0);
        _userPercentages[id] = pct;
        _userAmounts[id] = (_totalBillAmount ?? 0) * (pct / 100);
        // Optional: keep percentage formatted in field
        amountCtrl.text = pct > 0 ? pct.toStringAsFixed(1) : '';
      } else {
        _userAmounts[id] = input;
        _userPercentages[id] = _totalBillAmount != null && _totalBillAmount! > 0
            ? (input / _totalBillAmount!) * 100
            : 0.0;
        // Optional: show formatted amount
        amountCtrl.text = input > 0 ? _formatNumber(input) : '';
      }

      // Keep cursor at end
      amountCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: amountCtrl.text.length),
      );
    });
  },
),
          ),
          const SizedBox(width: 16),
         SizedBox(
  width: 90,
  child: Text(
    _isPercentageMode
        ? _formatCurrency(currentAmount)                    // ₦ formatted
        : "${_formatNumber(displayPct, decimalDigits: 1)}%",
    textAlign: TextAlign.right,
    style: TextStyle(
      fontWeight: FontWeight.w600,
      color: currentAmount > 0 ? const Color(0xFF007A74) : Colors.grey,
    ),
  ),
),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = _isComplete && !_isOver;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFFDFDFDF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          _buildHeader(),

          if (_isOver || (_isPercentageMode && _totalPercentage > 100))
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isPercentageMode
                          ? "Total exceeds 100% by ${(_totalPercentage - 100).toStringAsFixed(1)}%"
                          : "Total exceeds bill by ₦${(_totalAssigned - (_totalBillAmount ?? 0)).toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: widget.selectedUsers.length,
              itemBuilder: (context, index) {
                return _buildParticipantRow(widget.selectedUsers[index]);
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: canConfirm
                    ? () {
                        // Close the modal first so any navigation performed by
                        // the parent `_createManualSplit` isn't blocked by the
                        // bottom sheet route. Then call the create handler.
                        if (mounted) Navigator.pop(context);
                        Future.microtask(() => widget.onCreateSplit(_userAmounts, null));
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canConfirm ? const Color(0xFF007A74) : Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: canConfirm ? 6 : 0,
                ),
                child: Text(
                  canConfirm
                      ? "CREATE SPLIT BILL"
                      : _isPercentageMode
                          ? "${(100 - _totalPercentage).toStringAsFixed(1)}% remaining"
                          : "₦${((_totalBillAmount ?? 0) - _totalAssigned).toStringAsFixed(2)} remaining",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}