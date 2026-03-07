import 'package:flutter/material.dart';


import 'package:greyfundr/core/models/split_user_model.dart';

class SplitParticipantsContainer extends StatefulWidget {
  final List<User> selectedUsers;
  final VoidCallback onAddParticipant;
  final ValueChanged<bool> onIncludeMeChanged;
  final User? currentUser;

  const SplitParticipantsContainer({
    super.key,
    required this.selectedUsers,
    required this.onAddParticipant,
    required this.onIncludeMeChanged,
    this.currentUser,
  });

  @override
  State<SplitParticipantsContainer> createState() => _SplitParticipantsContainerState();
}

class _SplitParticipantsContainerState extends State<SplitParticipantsContainer> {
  bool _includeMe = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentUser != null) {
      _includeMe = widget.selectedUsers.any((u) => u.id == widget.currentUser!.id);
    }
  }

  void _toggleIncludeMe(bool? value) {
    if (value == null || widget.currentUser == null) return;

    setState(() {
      _includeMe = value;
    });

    widget.onIncludeMeChanged(value);

    if (value) {
      if (!widget.selectedUsers.any((u) => u.id == widget.currentUser!.id)) {
        widget.selectedUsers.add(widget.currentUser!);
      }
    } else {
      widget.selectedUsers.removeWhere((u) => u.id == widget.currentUser!.id);
    }
  }

  String _getParticipantSummary() {
    final total = widget.selectedUsers.length;
    final isCreatorIncluded = widget.currentUser != null &&
        widget.selectedUsers.any((u) => u.id == widget.currentUser!.id);

    if (total == 0) {
      return "You selected 0 participants";
    }

    if (isCreatorIncluded) {
      final others = total - 1;
      if (others == 0) {
        return "You selected yourself only";
      }
      return "You selected $others participant${others == 1 ? '' : 's'} + you = $total";
    } else {
      return "You selected $total participant${total == 1 ? '' : 's'}";
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF007A74);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Split With",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          "Add participants you are splitting with",
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),

        // NEW: Dynamic participant count summary
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            _getParticipantSummary(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
          ),
        ),

        CheckboxListTile(
          value: _includeMe,
          onChanged: _toggleIncludeMe,
          title: const Text(
            "Include me (creator)",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          activeColor: primaryColor,
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          height: 90,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: primaryColor.withOpacity(0.4), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.onAddParticipant,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/add_split_participant.png',
                      width: 56,
                      height: 56,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: widget.selectedUsers.isEmpty
                    ? Center(
                        child: Text(
                          "No participants added yet",
                          style: TextStyle(color: Colors.grey[500], fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.selectedUsers.length,
                        itemBuilder: (context, index) {
                          final user = widget.selectedUsers[index];
                          final isCreator = widget.currentUser != null && user.id == widget.currentUser!.id;

                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: AssetImage(user.profilePic),
                                      backgroundColor: primaryColor.withOpacity(0.1),
                                    ),
                                    if (isCreator)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 1.5),
                                          ),
                                          child: const Icon(Icons.person, size: 12, color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    isCreator ? "Yourself" : user.displayName,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isCreator ? FontWeight.bold : FontWeight.normal,
                                      color: isCreator ? primaryColor : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}