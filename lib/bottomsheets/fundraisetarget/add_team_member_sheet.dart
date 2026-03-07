import 'package:flutter/material.dart';

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

class AddTeamMemberSheet extends StatelessWidget {
  final VoidCallback onSelectMembersPressed;

  const AddTeamMemberSheet({super.key, required this.onSelectMembersPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ClipPath(
        clipper: CurvedTopClipper(),
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 40),
                  const Text(
                    'Create Team',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                 
                ],
              ),

              const SizedBox(height: 20),

              // Fixed Card with visible overlapping avatars
              // Replace the entire Card widget with this updated version:
Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  elevation: 0,
  color: Colors.white,
  child: InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () {
      Navigator.pop(context);
      onSelectMembersPressed();
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Icon + "Select Host"
          Row(
            children: [
            CircleAvatar(
  backgroundColor: Colors.lightBlue.shade50,
  radius: 20,
  backgroundImage: NetworkImage(
    'https://i.pravatar.cc/150?img=12', // any nice placeholder
  ),
  // Optional: show a default icon if the image fails to load
  child: ClipOval(
    child: Image.network(
      'https://i.pravatar.cc/150?img=12',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.person, color: Colors.blue.shade700),
    ),
  ),
),
              const SizedBox(width: 12),
              const Text(
                'Select Host',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // NEW: Avatars + "added as Host" text + add icon on the SAME ROW



          // Replace the whole SizedBox that contains the avatars and text
SizedBox(
  height: 56,
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFE3F2FD), // Soft baby blue
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        // Overlapping Avatars (left side)
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: List.generate(4, (index) => Positioned(
              left: index * 28.0, // Slightly increased overlap for tighter look
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=${index + 1}',
                ),
              ),
              
            )),
          ),
          
        ),

        // "added as Host" + icon — pushed very close to avatars
        Padding(
          padding: const EdgeInsets.only(left: 20), // This controls closeness!
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '0 People added as Host',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.person_add_alt_1_outlined,
                color: Colors.grey.shade700,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    ),
  ),
),

          const SizedBox(height: 16),

          // "Add Offers"
         
        ],
      ),
    ),
  ),
),
              const SizedBox(height: 20),

             ElevatedButton(
  onPressed: () => Navigator.pop(context),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.teal,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    minimumSize: const Size(double.infinity, 44),     // ← perfect compact height
    padding: const EdgeInsets.symmetric(vertical: 12), // ← reduced vertical padding
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,   // ← removes extra touch padding
  ),
  child: const Text(
    'ADD SELECTED',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Colors.white,
    ),
  ),
),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}