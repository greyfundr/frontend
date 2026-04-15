import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:greyfundr/services/local_storage.dart';     
// ────────────────────────────────────────────────
// Models
// ────────────────────────────────────────────────

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phone;
  final String profilePic;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phone,
    required this.profilePic,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      profilePic: json['profile_pic'] as String? ?? 'assets/images/avatar.png',
    );
  }

  String get displayName => username.isNotEmpty
      ? username
      : firstName.isNotEmpty
          ? firstName
          : email;
}

class PhoneContact {
  final String id;
  final String displayName;
  final String? phone;
  final String? email;
  final Uint8List? photo;

  PhoneContact({
    required this.id,
    required this.displayName,
    this.phone,
    this.email,
    this.photo,
  });

  String get avatarPath => photo != null
      ? "data:image/jpeg;base64,${base64Encode(photo!)}"
      : "assets/images/default_avatar.png";

  User toUser() => User(
        id: id,
        firstName: displayName.split(' ').first,
        lastName: displayName.split(' ').length > 1 ? displayName.split(' ').sublist(1).join(' ') : '',
        username: displayName,
        email: email ?? '',
        phone: phone ?? '',
        profilePic: avatarPath,
      );
}

// ────────────────────────────────────────────────
// Main Screen
// ────────────────────────────────────────────────

class SplitBillScreenUpdate extends StatefulWidget {
  const SplitBillScreenUpdate({super.key});

  @override
  State<SplitBillScreenUpdate> createState() => _SplitBillScreenUpdateState();
}

class _SplitBillScreenUpdateState extends State<SplitBillScreenUpdate> {
  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _billAmountController = TextEditingController();
  final _searchController = TextEditingController();

  // Image
  File? _billImage;
  String? _billImageUrl;
  final ImagePicker _picker = ImagePicker();

  // Participants
  List<User> _allUsers = [];
  final List<User> _selectedUsers = [];
  List<User> _filteredUsers = [];

  final List<PhoneContact> _selectedPhoneContacts = [];

  // Split data
  double? _totalBillAmount;
  final Map<String, double> _userAmounts = {}; // key = user.id

  // State
  bool _isLoadingUsers = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _billAmountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredUsers = _allUsers.where((u) {
        return u.displayName.toLowerCase().contains(query) ||
            u.email.toLowerCase().contains(query) ||
            u.phone.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoadingUsers = true);

    try {
      final token = await localStorage.getString('access_token');
      final response = await http.get(
        Uri.parse('https://api.greyfundr.com/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic body = jsonDecode(response.body);
        List<dynamic> usersJson = [];

        if (body is List) {
          usersJson = body;
        } else if (body is Map && body['data'] is List) {
          usersJson = body['data'];
        } else if (body is List && body.isNotEmpty && body[0] is List) {
          usersJson = body[0];
        } else {
          throw Exception('Unexpected response format');
        }

        setState(() {
          _allUsers = usersJson.map((j) => User.fromJson(j)).toList();
          _filteredUsers = _allUsers;
        });
      } else {
        _showError('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingUsers = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _pickAndUploadImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? xFile = await _picker.pickImage(source: source);
    if (xFile == null) return;

    final file = File(xFile.path);
    setState(() => _billImage = file);

    final url = await _uploadPhoto(file, xFile);
    if (url != null && mounted) {
      setState(() => _billImageUrl = url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Receipt uploaded")),
      );
    }
  }

  Future<String?> _uploadPhoto(File file, XFile xFile) async {
    try {
      final uri = Uri.parse('https://api.greyfundr.com/upload/image');
      final request = http.MultipartRequest('POST', uri);

      // Add auth if needed
      final token = await localStorage.getString('access_token');
      request.headers['Authorization'] = 'Bearer $token';
    
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        file.path,
        filename: file.path.split('/').last,
        contentType: MediaType.parse(xFile.mimeType ?? 'image/jpeg'),
      ));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return json['url'] as String?;
      }
      _showError('Upload failed: ${response.statusCode}');
      return null;
    } catch (e) {
      _showError('Upload error: $e');
      return null;
    }
  }

  // ────────────────────────────────────────────────
  // Placeholder for your other modals / logic
  // You can expand these as needed
  // ────────────────────────────────────────────────

  void _showAddParticipantModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              color: Colors.white,
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  const Text("Add Participants", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search friends or contacts",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // List of users / contacts here
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      final isSelected = _selectedUsers.any((u) => u.id == user.id);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.profilePic),
                        ),
                        title: Text(user.displayName),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : const Icon(Icons.add_circle_outline),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedUsers.removeWhere((u) => u.id == user.id);
                            } else {
                              _selectedUsers.add(user);
                            }
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Split Bill"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text("Title", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "e.g. Dinner at Joe's",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            // Description
            const Text("Description (optional)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "What is this bill for?",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            // Amount
            const Text("Bill Amount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _billAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              decoration: InputDecoration(
                prefixText: "₦ ",
                hintText: "0.00",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            // Receipt Image
            const Text("Receipt Photo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickAndUploadImage,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _billImage == null
                    ? const Center(child: Icon(Icons.camera_alt, size: 48, color: Colors.grey))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_billImage!, fit: BoxFit.cover),
                      ),
              ),
            ),
            if (_billImage != null)
              TextButton(
                onPressed: () => setState(() => _billImage = null),
                child: const Text("Remove photo", style: TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 32),

            // Participants
            const Text("Split With", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _showAddParticipantModal,
              icon: const Icon(Icons.person_add),
              label: const Text("Add Participants"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedUsers.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedUsers.map((user) {
                  return Chip(
                    avatar: CircleAvatar(backgroundImage: NetworkImage(user.profilePic)),
                    label: Text(user.displayName),
                    onDeleted: () => setState(() => _selectedUsers.remove(user)),
                  );
                }).toList(),
              )
            else
              const Center(child: Text("No participants added yet")),

            const SizedBox(height: 40),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Validate & submit logic here
                  if (_titleController.text.trim().isEmpty) {
                    _showError("Title is required");
                    return;
                  }
                  if (_billAmountController.text.trim().isEmpty) {
                    _showError("Amount is required");
                    return;
                  }
                  if (_selectedUsers.isEmpty) {
                    _showError("Add at least one participant");
                    return;
                  }
                  // Proceed with API call to update/create split bill
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Split bill updated!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007A74),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Update Split Bill", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}