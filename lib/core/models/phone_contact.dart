import 'package:flutter/services.dart';
import 'package:greyfundr/core/models/split_user_model.dart';


// Add this class anywhere in your file (or in models/phone_contact.dart)
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

  // Convert to your main User model when needed
  User toUser() => User(
    id:
        (int.tryParse(id) ??
        DateTime.now().millisecondsSinceEpoch).toString(), // fallback ID
    firstName: displayName.split(' ').first,
    lastName: displayName.split(' ').length > 1
        ? displayName.split(' ').sublist(1).join(' ')
        : '',
    username: displayName,
    email: email ?? '',
    phoneNumber: phone ?? '',
    profilePic: "assets/images/personal.png",
  );
}