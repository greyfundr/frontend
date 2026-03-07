// lib/screens/campaign_review/widgets/team_member_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TeamMemberCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String role;
  final bool isOrganizer;

  const TeamMemberCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.role,
    required this.isOrganizer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      margin: const EdgeInsets.only(right: 16),
     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // reduced a bit
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        // boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: imageUrl.startsWith('http')
                    ? NetworkImage("https://pub-bcb5a51a1259483e892a2c2993882380.r2.dev/$imageUrl")
                    : AssetImage(imageUrl) as ImageProvider,
                backgroundColor: Colors.grey[200],
              ),
          
              if (isOrganizer)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2.5)),
                    ),
                    child: const Icon(Icons.star, size: 14, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name, style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2), // reduced spacing
                Text(role, style: GoogleFonts.inter(fontSize: 11.5, color: Colors.grey[700])),
              ],
            ),
          ),
          const SizedBox(width: 16),
         ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.teal,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // ↓ smaller height
    minimumSize: const Size(0, 28), // ↓ reduce default height
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    textStyle: const TextStyle(fontSize: 12),
  ),
  onPressed: () {},
  child: const Text("Follow"),
),
        ],
      ),
    );
  }
}