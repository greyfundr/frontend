import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

class CampaignProgressShowcase extends StatelessWidget {
  final String currentAmount;
  final String goalAmount;
  final double percentage;
  final int daysLeft;
  final String donors;     // ← Changed from int to String
  final String champions;  // ← Changed from int to String

  const CampaignProgressShowcase({
    super.key,
    required this.currentAmount,
    required this.goalAmount,
    required this.percentage,
    required this.daysLeft,
    required this.donors,
    required this.champions,
  });

  String _formatCurrency(String amount) {
    final number = double.tryParse(amount) ?? 0.0;
    final formatter = NumberFormat("#,##0", "en_US");
    return formatter.format(number);
  }

  // Helper to safely convert string count to int for display
  int _parseCount(String count) {
    return int.tryParse(count) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpired = daysLeft <= 0;
    final int donorCount = _parseCount(donors);
    final int championCount = _parseCount(champions);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 224, 224, 224),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "₦${_formatCurrency(currentAmount)} raised of ₦${_formatCurrency(goalAmount)}",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isExpired ? "Expired" : "$daysLeft Day${daysLeft == 1 ? '' : 's'} left",
                    style: TextStyle(
                      fontSize: 10,
                      color: isExpired ? Colors.red[700] : Colors.grey[700],
                      fontWeight: isExpired ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            lineHeight: 10,
            percent: percentage.clamp(0.0, 1.0),
            progressColor: Colors.teal,
            backgroundColor: Colors.grey.shade200,
            barRadius: const Radius.circular(10),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.people_outline, size: 14, color: Colors.grey[700]),
              const SizedBox(width: 6),
              Text(
                "$donorCount Donor${donorCount == 1 ? '' : 's'}",
                style: TextStyle(color: Colors.grey[700], fontSize: 10),
              ),
              const SizedBox(width: 24),
              Icon(Icons.volunteer_activism_outlined,
                  size: 14, color: Colors.grey[700]),
              const SizedBox(width: 6),
              Text(
                "$championCount Champion${championCount == 1 ? '' : 's'}",
                style: TextStyle(color: Colors.grey[700], fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}