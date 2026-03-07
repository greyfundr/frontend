import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:greyfundr/core/models/split_user_model.dart';
import 'package:greyfundr/core/models/phone_contact.dart';
import 'package:greyfundr/services/custom_alert.dart';

class AddParticipantModal extends StatefulWidget {
  final List<User> allUsers;             
  final List<User> selectedUsers;
  final ValueChanged<List<User>> onUsersChanged;
  final TextEditingController searchController;

  const AddParticipantModal({
    super.key,
    required this.allUsers,
    required this.selectedUsers,
    required this.onUsersChanged,
    required this.searchController,
  });

  @override
  State<AddParticipantModal> createState() => _AddParticipantModalState();
}

class _AddParticipantModalState extends State<AddParticipantModal> {
  List<PhoneContact> _selectedPhoneContacts = [];
  bool _isLoadingContacts = false;

  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {}); // Trigger rebuild for filtered list
  }

  List<User> get _filteredUsers {
    final query = widget.searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return widget.allUsers.where((u) => !widget.selectedUsers.any((s) => s.id == u.id)).toList();
    }

    return widget.allUsers.where((user) {
      return user.displayName.toLowerCase().contains(query) ||
          (user.email?.toLowerCase().contains(query) ?? false) ||
          (user.phoneNumber?.toLowerCase().contains(query) ?? false);
    }).where((user) => !widget.selectedUsers.any((s) => s.id == user.id)).toList();
  }

  Future<void> _pickContactFromDevice() async {
  if (!await FlutterContacts.requestPermission(readonly: true)) {
    if (!mounted) return;
    CustomMessageModal.show(context: context, message: "Contact permission denied", isSuccess: false);
    return;
  }

  setState(() => _isLoadingContacts = true);

  try {
    final contact = await FlutterContacts.openExternalPick();
    if (contact == null) return;

    final phone = contact.phones.isNotEmpty ? contact.phones.first.number : null;
    if (phone == null || phone.trim().isEmpty) {
      CustomMessageModal.show(context: context, message: "No phone number found", isSuccess: false);
      return;
    }

    final cleanedPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    if (_selectedPhoneContacts.any((c) => c.phone == cleanedPhone) ||
        widget.selectedUsers.any((u) => u.phoneNumber == cleanedPhone)) {
      CustomMessageModal.show(context: context, message: "Contact already added", isSuccess: false);
      return;
    }

    final newContact = PhoneContact(
      id: contact.id,
      displayName: contact.displayName ?? "Unknown",
      phone: cleanedPhone,
      email: contact.emails.isNotEmpty ? contact.emails.first.address : null,
      photo: contact.photo ?? contact.thumbnail,
    );

    final nameParts = newContact.displayName.trim().split(RegExp(r'\s+'));
    final firstName = nameParts.isNotEmpty ? nameParts.first : newContact.displayName;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    String username = cleanedPhone.isNotEmpty ? cleanedPhone : 'guest_${DateTime.now().millisecondsSinceEpoch}';

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      firstName: firstName,
      lastName: lastName,
      username: username,
      phoneNumber: newContact.phone ?? '',
      email: newContact.email ?? '',
      profilePic: "assets/images/personal.png",  // ← fixed: no .path
      // Add other required fields if needed
    );

    setState(() {
      _selectedPhoneContacts.add(newContact);
      widget.selectedUsers.add(newUser);
      widget.onUsersChanged(widget.selectedUsers);
    });

    CustomMessageModal.show(
      context: context,
      message: "Added: ${newContact.displayName}",
      isSuccess: true,
    );
  } catch (e) {
    CustomMessageModal.show(context: context, message: "Failed to add contact", isSuccess: false);
  } finally {
    if (mounted) setState(() => _isLoadingContacts = false);
  }
}

  void _addManualContact() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Add Manual Contact", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Phone number", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final phone = phoneCtrl.text.trim();

                    if (name.isEmpty || phone.isEmpty) {
                      CustomMessageModal.show(context: context, message: "Name and phone required", isSuccess: false);
                      return;
                    }

                    // Basic name split
                    final nameParts = name.trim().split(RegExp(r'\s+'));
                    final firstName = nameParts.isNotEmpty ? nameParts.first : name;
                    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

                    String username = phone.replaceAll(RegExp(r'[^0-9]'), '');
                    if (username.isEmpty) username = 'guest_${DateTime.now().millisecondsSinceEpoch}';

                    final newUser = User(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      firstName: firstName,
                      lastName: lastName,
                      username: username,
                      phoneNumber: phone,
                      email: '',
                      profilePic: "assets/images/personal.png",
                      // Add other required fields here if errors appear (e.g. role: 'guest')
                    );
                  

                    setState(() {
                      widget.selectedUsers.add(newUser);
                      widget.onUsersChanged(widget.selectedUsers);
                    });

                    Navigator.pop(context);
                    CustomMessageModal.show(context: context, message: "$name added!", isSuccess: true);
                  },
                  child: const Text("ADD CONTACT"),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedChips() {
    if (widget.selectedUsers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text("No participants selected yet", style: TextStyle(color: Colors.grey, fontSize: 15)),
        ),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: widget.selectedUsers.length,
        itemBuilder: (context, index) {
          final user = widget.selectedUsers[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(user.profilePic),
                      backgroundColor: const Color(0xFF007A74).withOpacity(0.1),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 70,
                      child: Text(
                        user.displayName,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.selectedUsers.removeAt(index);
                        widget.onUsersChanged(widget.selectedUsers);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF007A74);

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFFDFDFDF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(
              width: 44,
              height: 6,
              decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const Text("Add Participants", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

          const SizedBox(height: 20),

          _buildSelectedChips(),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: widget.searchController,
              decoration: InputDecoration(
                hintText: "Search friends by name or email",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildOptionTile(Icons.group, "Select Friends", "From GreyFundr users", () {
                  CustomMessageModal.show(context: context, message: "Use search above", isSuccess: true);
                }),
                const SizedBox(height: 12),
                _buildOptionTile(Icons.person_add, "Add Manually", "Enter name & phone", _addManualContact),
                const SizedBox(height: 12),
                _buildOptionTile(Icons.contacts, "Select from Contacts", "Pick from device", _pickContactFromDevice),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: _isLoadingContacts
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(child: Text("No users found"))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(backgroundImage: AssetImage(user.profilePic)),
                              title: Text(user.displayName),
                              subtitle: Text(user.phoneNumber ?? user.email ?? ""),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    widget.selectedUsers.add(user);
                                    widget.onUsersChanged(widget.selectedUsers);
                                    widget.searchController.clear();
                                  });
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                                child: const Text("Add", style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          );
                        },
                      ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: widget.selectedUsers.isEmpty ? null : () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("CONFIRM PARTICIPANTS", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF007A74), size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}