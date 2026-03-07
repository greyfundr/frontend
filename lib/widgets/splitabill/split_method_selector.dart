import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SplitMethodSelector extends StatelessWidget {
  final bool isEvenSplit;
  final ValueChanged<bool> onChanged;
  final VoidCallback onManualTap;
  final double? billAmount;
  final int participantCount;

  const SplitMethodSelector({
    super.key,
    required this.isEvenSplit,
    required this.onChanged,
    required this.onManualTap,
    this.billAmount,
    this.participantCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF007A74);
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '₦', decimalDigits: 2);

    String evenSplitText = "Even split";
    if (billAmount != null && billAmount! > 0 && participantCount > 0) {
      final perPerson = billAmount! / participantCount;
      evenSplitText = "Split evenly ($participantCount) = ${formatter.format(perPerson)} each";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Split Method",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          "How would you like to split the bill?",
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Checkbox(
              value: isEvenSplit,
              activeColor: primaryColor,
              onChanged: (v) => onChanged(v == true),
            ),
            Expanded(
              child: Text(
                evenSplitText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isEvenSplit ? primaryColor : null,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Opacity(
          opacity: isEvenSplit ? 0.5 : 1.0,
          child: IgnorePointer(
            ignoring: isEvenSplit,
            child: InkWell(
              onTap: onManualTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_note_rounded,
                      color: isEvenSplit ? Colors.grey : primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Split manually",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isEvenSplit ? Colors.grey[600] : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}