import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:greyfundr/core/models/split_bill_model.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/features/bill/pathsforbill/sboscreen.dart';
import 'package:greyfundr/services/custom_alert.dart';

class SortBillModal extends StatefulWidget {
  final SplitBill bill;

  const SortBillModal({super.key, required this.bill});

  static Future<void> show(BuildContext context, SplitBill bill) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SortBillModal(bill: bill),
    );
  }

  @override
  State<SortBillModal> createState() => _SortBillModalState();
}

class _SortBillModalState extends State<SortBillModal> {
  final TextEditingController donorController = TextEditingController();
  String? nickname;
  String? donorName;
  String? comment;
  final formatter = NumberFormat('#,##0.00');

  @override
  void dispose() {
    donorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bill = widget.bill;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId = userProvider.userProfileModel?.id ?? '';

    final participant = bill.participants.firstWhere(
      (p) => p.userId == currentUserId,
      orElse: () => Participant(
        id: 'fallback_${DateTime.now().millisecondsSinceEpoch}',
        inviteCode: '',
        amountOwed: 0.0,
        amountPaid: 0.0,
        paid: false,
        status: 'UNKNOWN',
      ),
    );

    final progress = bill.amount > 0 ? bill.amountRaised / bill.amount : 0.0;
    final remainingAmount = participant.amountOwed - bill.amountRaised;

    final formattedPaid = formatter.format(bill.amountRaised);
    final formattedTotal = formatter.format(bill.amount);
    final formattedRemaining = formatter.format(remainingAmount);

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 48,
              height: 6,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              bill.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.grey, blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      children: [
                        TextSpan(
                          text: formattedPaid,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        const TextSpan(text: " raised of "),
                        TextSpan(
                          text: formattedTotal,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF007A74)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            "${bill.totalParticipants} Split${bill.totalParticipants == 1 ? '' : 's'}",
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),


                       Row(
                        children: [
                         Icon(Icons.emoji_events_outlined, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            " 0 champions",
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),

                      Row(
                        children: [
                        Icon(Icons.favorite_outline, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            " 0 Backers",
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "You are supporting ${bill.title}. Your donation will help reach the goal.",
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: donorController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "Enter Amount",
                labelStyle: const TextStyle(color: Colors.grey),
                helperText: remainingAmount > 0 ? "Max: ₦$formattedRemaining" : null,
                helperStyle: const TextStyle(color: Color(0xFF007A74), fontSize: 12),
                prefixText: "₦ ",
                prefixStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildOptionRow(
            iconPath: "assets/images/add-circle.png",
            defaultText: "Use my Nickname or Be Anonymous",
            value: nickname,
            onTap: () => _showInputDialog(context, "Enter Nickname", "e.g. Davido", (val) => setState(() => nickname = val.isEmpty ? null : val)),
            onDelete: () => setState(() => nickname = null),
          ),
          _buildOptionRow(
            iconPath: "assets/images/add-circle.png",
            defaultText: "Donating On Behalf Of",
            value: donorName,
            onTap: () => _showInputDialog(context, "Donating On Behalf Of", "e.g. My Mom, Church, Team", (val) => setState(() => donorName = val.isEmpty ? null : val)),
            onDelete: () => setState(() => donorName = null),
          ),
          _buildOptionRow(
            iconPath: "assets/images/add-circle.png",
            defaultText: "Add Comment",
            value: comment,
            onTap: () => _showInputDialog(context, "Add a Comment", "Your comment will appear publicly", (val) => setState(() => comment = val.isEmpty ? null : val)),
            onDelete: () => setState(() => comment = null),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final amountText = donorController.text.trim();
                  if (amountText.isEmpty) return;

                  final amount = double.tryParse(amountText.replaceAll(',', ''));
                  if (amount == null || amount <= 0) return;

                  if (remainingAmount > 0 && amount > remainingAmount) {
                    CustomMessageModal.show(
                      context: context,
                      message: "Amount cannot exceed ₦$formattedRemaining",
                      isSuccess: false,
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SortBillOptionsScreen(
                        bill: bill,
                        amountToPay: amountText,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007A74),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildOptionRow({
    required String iconPath,
    required String defaultText,
    required String? value,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    final hasValue = value != null && value.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: InkWell(
        onTap: hasValue ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: hasValue ? Colors.grey[100] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              if (hasValue)
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
                )
              else
                Image.asset(iconPath, width: 24, height: 24, color: const Color(0xFF007A74)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  hasValue ? value! : defaultText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: hasValue ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showInputDialog(BuildContext ctx, String title, String hint, Function(String) onSave) async {
    final controller = TextEditingController();
    await showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final val = controller.text.trim();
              if (val.isNotEmpty) onSave(val);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
