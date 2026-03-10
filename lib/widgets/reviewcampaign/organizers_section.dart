// lib/screens/campaign_review/widgets/organizers_section.dart
import 'package:flutter/material.dart';
import 'package:greyfundr/core/models/campaign_model.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'team_member_card.dart';

class OrganizersSection extends StatelessWidget {
  final Campaign campaign;
  final Map<String, dynamic> user;
  final VoidCallback onSeeAll;

  const OrganizersSection({super.key, required this.campaign, required this.user, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Organizers", style: txStyle12.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
              GestureDetector(
                onTap: onSeeAll,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    
                    
                  ),
                  child: Text("See All", style: txStyle12.copyWith(color: Colors.teal, fontWeight: FontWeight.w600, fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 1 + campaign.participants.length,
            itemBuilder: (context, i) {
              if (i == 0) {
                return TeamMemberCard(
                  imageUrl: user["https://pub-bcb5a51a1259483e892a2c2993882380.r2.dev/profile_pic"]
                   ?? 'assets/images/personal.png',
                  name: "${user['first_name']} ${user['last_name']}".trim(),
                  role: "Campaign Organizer",
                  isOrganizer: true,
                );



               
              }
              final p = campaign.participants[i - 1];
              return TeamMemberCard(imageUrl: p.imageUrl, name: p.name, role: "Participant", isOrganizer: false);
            },
          ),
        ),
      ],
    );
  }
}