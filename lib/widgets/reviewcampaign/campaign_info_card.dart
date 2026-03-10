// lib/screens/campaign_review/widgets/campaign_info_card.dart
import 'package:flutter/material.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:intl/intl.dart';
import 'package:greyfundr/core/models/campaign_model.dart';

class CampaignInfoCard extends StatelessWidget {
  final Campaign campaign;
  final int daysLeft;

  const CampaignInfoCard({super.key, required this.campaign, required this.daysLeft});

  @override
  Widget build(BuildContext context) {
    final formattedTarget = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 0)
        .format(campaign.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title placed ABOVE the card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
          child: Text(
            campaign.title,
            style: txStyle18.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(height: 4),

        // The actual card container
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₦0 Raised of $formattedTarget",
                    style: txStyle12,
                  ),
                  Text(
                    "$daysLeft Days left",
                    style: txStyle12.copyWith(color: Colors.grey[700]),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              LinearProgressIndicator(
                value: 0.0,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation(Color.fromRGBO(0, 164, 175, 1)),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),

              const SizedBox(height: 10),

              Row(
  children: [
    _stat(Icons.group, "0 Donors"),
    const SizedBox(width: 32), // Adjust this value to control spacing between the two stats
    _stat(Icons.emoji_events_outlined, "0 Champions"),
  ],
),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stat(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          label,
          style: txStyle10SemiBold.copyWith(color: Colors.grey[700]),
        ),
      ],
    );
  }
}