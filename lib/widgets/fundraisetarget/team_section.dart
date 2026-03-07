import 'package:flutter/material.dart';
import 'package:greyfundr/core/models/participants_model.dart';

class TeamSection extends StatelessWidget {
  final List<Participant> selectedParticipants;
  final List<Participant> allUsers;
  final ValueChanged<List<Participant>> onParticipantsChanged;
  final VoidCallback onAddPressed; // You'll pass the bottom sheet opener from parent

  const TeamSection({
    super.key,
    required this.selectedParticipants,
    required this.allUsers,
    required this.onParticipantsChanged,
    required this.onAddPressed,
  });
Widget _buildEmptyPlaceholder() {


  return GestureDetector(
    onTap: onAddPressed,
    child: Container(
     
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16), // left & right only
      decoration: BoxDecoration(
        border: Border.all(color: Colors.teal),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          // Plus button
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 228, 228, 228),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_outlined, color: Colors.teal),
          ),

          const SizedBox(width: 16),

          // Overlapping preview avatars (just like before)
          Expanded(
            child: SizedBox(
              height: 40,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
  left: 50,
  child: Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      color: const Color.fromARGB(230, 0, 150, 135),            
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.grey,          
        width: 2,
      ),
    ),
  ),
),

               Positioned(
  left: 30,
  child: Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      color: const Color.fromARGB(222, 0, 150, 135),           
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.grey,          
        width: 2,
      ),
    ),
  ),
),


               Positioned(
  left: 10,
  child: Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      color: const Color.fromARGB(224, 0, 150, 135),            // circle color
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.grey,          // grey border
        width: 2,
      ),
    ),
  ),
),
           
                
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );



}

 Widget _buildSelectedMembers() {
  return GestureDetector(
    onTap: onAddPressed, // Tapping anywhere on the border opens the selector
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.teal),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          // Add Button (same style as empty state)
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 228, 228, 228),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_outlined, color: Colors.teal),
          ),

          const SizedBox(width: 50),

          // Selected members with overlapping avatars and remove buttons
          Expanded(
            child: SizedBox(
              height: 56,
              child: Stack(
                clipBehavior: Clip.none,
                children: selectedParticipants.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final user = entry.value;
                  final offset = idx * 40.0; // Overlap spacing

                  return Positioned(
                    left: offset,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // User avatar
                        CircleAvatar(
                          radius: 34,
                          backgroundImage: NetworkImage('https://pub-bcb5a51a1259483e892a2c2993882380.r2.dev/${user.imageUrl}'),
                          backgroundColor: Colors.grey.shade300,
                        ),

                        Positioned(
                          left: -8,
                          top: -8,
                          child: GestureDetector(
                            onTap: () {
                              final newList = List<Participant>.from(selectedParticipants)
                                ..removeAt(idx);
                              onParticipantsChanged(newList);
                            },
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Create Team',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        const Text(
            'Create a team to help you reach your goal. Add participant that belong to this Campaign or fundraiser',
            style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 113, 113, 113))),
        const SizedBox(height: 12),
        selectedParticipants.isEmpty
            ? _buildEmptyPlaceholder()
            : _buildSelectedMembers(),
        const SizedBox(height: 24),
      ],
    );
  }
}