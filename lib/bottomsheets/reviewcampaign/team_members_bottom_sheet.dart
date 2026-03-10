// lib/screens/campaign_review/bottom_sheets/team_members_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:greyfundr/core/models/campaign_model.dart';
import 'package:greyfundr/shared/text_style.dart';

class TeamMembersBottomSheet {
  static void show(BuildContext context, Campaign campaign, Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => ClipPath(
          clipper: CurvedTopClipper(),
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                // This extra space prevents the curve from clipping the nudge
                const SizedBox(height: 28),

                // Draggable nudge — now 100% visible and centered
                Center(
                  child: Container(
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Perfectly centered title
                Text(
                  "Campaign Organizers",
                  style: txStyle19.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 16),
                
                // Scrollable member list
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      _memberRow(
                        user['profile_pic'] ?? 'assets/images/personal.png',
                        "${user['first_name']} ${user['last_name']}".trim(),
                        "Campaign Organizer",
                        true,
                      ),
                      ...campaign.participants.map(
                        (p) => _memberRow(p.imageUrl, p.name, "Campaign Participant", false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _memberRow(String img, String name, String role, bool isHost) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      // padding: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: img.startsWith('http')
                    ? NetworkImage(
                     "https://pub-bcb5a51a1259483e892a2c2993882380.r2.dev/$img")
                    : AssetImage(img) 
                    as ImageProvider,
              ),


              //  CircleAvatar(
              //                 radius: 24,
              //                 backgroundImage: profilePic.isNotEmpty
              //                     ? NetworkImage(
              //                         "https://pub-bcb5a51a1259483e892a2c2993882380.r2.dev/$profilePic")
              //                     : const AssetImage('assets/images/personal.png')
              //                         as ImageProvider,
              //               ),




              if (isHost)
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.star, size: 14, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: txStyle13.copyWith(fontSize: 15, fontWeight: FontWeight.w600)),
                Text(role, style: txStyle13.copyWith(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          if (isHost)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Host",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}

class CurvedTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 20);
    var firstControlPoint = Offset(size.width / 4, 0);
    var firstEndPoint = Offset(size.width / 2, 1);
    var secondControlPoint = Offset(3 * size.width / 4, 0);
    var secondEndPoint = Offset(size.width, 30);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}