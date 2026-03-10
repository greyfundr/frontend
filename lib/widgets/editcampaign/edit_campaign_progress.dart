
import 'package:flutter/material.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:intl/intl.dart'; 
import 'package:greyfundr/core/models/campaign_model.dart';
import 'package:greyfundr/services/error_boundary.dart';

class EditCampaignProgress extends StatelessWidget {
  final Campaign campaign;
  const EditCampaignProgress({super.key, required this.campaign});

  // Helper to format number with commas
  String _formatAmount(dynamic amount) {
    final cleanAmount = amount
        .toString()
        .replaceAll(RegExp(r'[₦,\s]'), '')
        .trim();

    final number = double.tryParse(cleanAmount) ?? 0.0;
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    final double target = double.tryParse(
          campaign.amount
              .toString()
              .replaceAll(RegExp(r'[₦,]'), '')
              .trim(),
        ) ??
        1.0;

    const double raised = 0.0;
    final double progress = (raised / target).clamp(0.0, 1.0);
    final int percentage = (progress * 100).round();
    final String formattedTarget = _formatAmount(campaign.amount);

    return ErrorBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount raised text with properly formatted target
            RichText(
              text: TextSpan(
                style: txStyle14.copyWith(color: Colors.black87),
                children: [
                  const TextSpan(text: "₦0 raised of "),
                  TextSpan(
                    text: "₦$formattedTarget",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Progress bar + percentage
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 10,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color.fromRGBO(192, 206, 199, 1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color.fromRGBO(0, 164, 175, 1),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Text(
                  '$percentage%',
                  style: txStyle14.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}