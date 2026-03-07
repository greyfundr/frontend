import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greyfundr/core/models/participants_model.dart';

class ParticipantsSection extends StatelessWidget {
  final List<Participant> participants;
  final VoidCallback onEdit;

  const ParticipantsSection({
    super.key,
    required this.participants,
    required this.onEdit,
  });

  Widget _buildCard({
    required String name,
    required String role,
    required String? imageUrl,
    required bool isOrganizer,
  }) {
    return Container(
      // Fixed width based on screen size – now safe!
      width: 280, // You can adjust this, or use LayoutBuilder below
      constraints: const BoxConstraints(maxWidth: 320),
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 229, 229, 229),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [

              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.grey[300],
                backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : const AssetImage('assets/images/personal.png') as ImageProvider,
              ),


              if (isOrganizer)
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
          Expanded( // Use Expanded so text doesn't overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width once here – safe!
    // final double screenWidth = MediaQuery.of(context).size.width;
    // final double cardWidth = screenWidth * 0.7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Campaign Organizers",
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            TextButton(
  onPressed: onEdit,
  style: TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  ),
  child: const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        "Edit",
        style: TextStyle(
          color: Color.fromRGBO(0, 164, 175, 1),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      SizedBox(width: 6), // Adjust spacing between text and icon
      Icon(
        Icons.edit_note_rounded,
        size: 18,
        color: Color.fromRGBO(0, 164, 175, 1),
      ),
    ],
  ),
),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 74,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildCard(
                name: "You",
                role: "Campaign Organizer",
                imageUrl: null,
                isOrganizer: true,
              ),
              ...participants.map((p) => _buildCard(
                    name: p.name,
                    role: "Team Member",
                    imageUrl: p.imageUrl,
                    isOrganizer: false,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}