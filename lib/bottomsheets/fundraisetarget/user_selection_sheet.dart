import 'package:flutter/material.dart';
import 'package:greyfundr/core/models/participants_model.dart';

class UserSelectionSheet extends StatefulWidget {
  final List<Participant> allUsers;
  final List<Participant> initiallySelected;
  final ValueChanged<List<Participant>> onSelectionConfirmed;

  const UserSelectionSheet({
    super.key,
    required this.allUsers,
    required this.initiallySelected,
    required this.onSelectionConfirmed,
  });

  @override
  State<UserSelectionSheet> createState() => _UserSelectionSheetState();
}

class _UserSelectionSheetState extends State<UserSelectionSheet> {
  late List<Participant> filteredUsers;
  late List<Participant> tempSelected;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredUsers = List.from(widget.allUsers);
    tempSelected = List.from(widget.initiallySelected);

    searchController.addListener(() {
      _filter(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredUsers = List.from(widget.allUsers);
      } else {
        filteredUsers = widget.allUsers
            .where((u) =>
                u.name.toLowerCase().contains(query.toLowerCase()) ||
                u.username.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggle(Participant user) {
    setState(() {
      tempSelected.contains(user)
          ? tempSelected.remove(user)
          : tempSelected.add(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: SoftCurveTopClipper(), // Apply the curve here
      child: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.86,
              child: Column(
                children: [
                  /// Drag handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 12),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  /// Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Select Organizers',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                     
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// Selected participants preview
                  SizedBox(
                    height: 100,
                    child: tempSelected.isEmpty
                        ? const Center(
                            child: Text(
                              'No organizers selected yet',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 113, 113, 113)),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemCount: tempSelected.length,
                            itemBuilder: (_, i) {
                              final p = tempSelected[i];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    CircleAvatar(
  radius: 34,
  backgroundImage: NetworkImage('https://pub-bcb5a51a1259483e892a2c2993882380.r2.dev/${p.imageUrl}'),
  onBackgroundImageError: (exception, stackTrace) {
    // Optional: log or do nothing – prevents console spam
  },
  child: const Icon(Icons.person, size: 40), // fallback shown when image fails
),
                                    Positioned(
                                      right: -6,
                                      top: -6,
                                      child: GestureDetector(
                                        onTap: () => setState(
                                            () => tempSelected.remove(p)),
                                        child: const CircleAvatar(
                                          radius: 13,
                                          backgroundColor: Colors.red,
                                          child: Icon(Icons.close,
                                              size: 18, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 20),

                  /// Search field
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search by name or username',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// List of users
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (_, i) {
                        final user = filteredUsers[i];
                        final isSelected = tempSelected.contains(user);

                        return ListTile(
                          leading:
                            CircleAvatar(
  backgroundImage: NetworkImage('https://pub-bcb5a51a1259483e892a2c2993882380.r2.dev/${user.imageUrl}'),
  onBackgroundImageError: (_, __) {},
  child: const Icon(Icons.person),
),
                          title: Text(user.name),

                          subtitle: Text(user.username),
                          trailing: ElevatedButton(
                            onPressed: () => _toggle(user),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isSelected ? Colors.grey[700] : Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(isSelected ? 'Selected' : 'Select'),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: tempSelected.isEmpty
                          ? null
                          : () {
                              widget.onSelectionConfirmed(tempSelected);
                              Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'ADD ${tempSelected.length} PARTICIPANT${tempSelected.length == 1 ? '' : 'S'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ==============================
/// CURVED TOP CLIPPER
/// ==============================
class SoftCurveTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 20);

    path.quadraticBezierTo(
      size.width / 2,
      -20, // height of curve
      size.width,
      20,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
