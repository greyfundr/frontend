// === MODELS (unchanged) ===
import 'dart:convert';

class SplitBill {
  final String id;
  final String title;
  final String description;
  final String currency;
  final double amount;
  final String creatorId;
  final String splitMethod;
  final DateTime dueDate;
  final bool isFinalized;
  final String status;
  final String imageUrl;
  final int totalParticipants;
  final double totalPaid;
  final double amountRaised;
  final double percentageComplete;
  final bool isOverdue;
  final List<Participant> participants;

  SplitBill({
    required this.id,
    required this.title,
    required this.description,
    required this.currency,
    required this.amount,
    required this.creatorId,
    required this.splitMethod,
    required this.dueDate,
    required this.isFinalized,
    required this.status,
    required this.imageUrl,
    required this.totalParticipants,
    required this.totalPaid,
    required this.amountRaised,
    required this.percentageComplete,
    required this.isOverdue,
    required this.participants,
  });

  factory SplitBill.fromJson(Map<String, dynamic> json) {
    return SplitBill(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      currency: json['currency'],
      amount: double.parse(json['amount']),
      creatorId: json['creator_id'],
      splitMethod: json['split_method'],
      dueDate: DateTime.parse(json['due_date']),
      isFinalized: json['is_finalized'],
      status: json['status'],
      imageUrl: json['image_url'] ?? '',
      totalParticipants: json['total_participants'],
      totalPaid: double.tryParse(json['total_paid'] ?? '0') ?? 0.0,
      amountRaised: double.tryParse(json['amount_raised'] ?? '0') ?? 0.0,
      percentageComplete:
          double.tryParse(json['percentage_complete'] ?? '0') ?? 0.0,
      isOverdue: json['is_overdue'] ?? false,
      participants: (json['participants'] as List)
          .map((p) => Participant.fromJson(p))
          .toList(),
    );
  }
}


class Participant {
  final String id;
  final String? userId;
  final String? guestName;
  final String? guestPhone;
  final String? guestEmail;
  final double amountOwed;
  final double amountPaid;
  final String status;
  final bool paid;
  final String inviteCode;
  final String? profilePic; // From user.profile_pic
  final User? user;         // Full User object if registered

  Participant({
    required this.id,
    this.userId,
    this.guestName,
    this.guestPhone,
    this.guestEmail,
    required this.amountOwed,
    required this.amountPaid,
    required this.status,
    required this.paid,
    required this.inviteCode,
    this.profilePic,
    this.user,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    double parseAmount(String value) {
      return double.tryParse(value) ?? 0.0;
    }

    final userJson = json['user'] as Map<String, dynamic>?;

    User? userObject;
    String? pic;

    if (userJson != null) {
      userObject = User(
        id: userJson['id'].toString(),
        firstName: (userJson['first_name'] as String?) ?? '',
        lastName: (userJson['last_name'] as String?) ?? '',
        profilePic: (userJson['profile_pic'] as String?) ?? '',
      );
      pic = userJson['profile_pic'] as String?;
    }

    return Participant(
      id: json['id'] as String,
      userId: json['user_id']?.toString(),
      guestName: json['guest_name'] as String?,
      guestPhone: json['guest_phone'] as String?,
      guestEmail: json['guest_email'] as String?,
      amountOwed: parseAmount(json['amount_owed'] as String),
      amountPaid: parseAmount(json['amount_paid'] as String),
      status: json['status'] as String? ?? 'UNPAID',
      paid: json['paid'] as bool? ?? false,
      inviteCode: json['invite_code'] as String? ?? '',
      profilePic: pic,
      user: userObject,
    );
  }

  // Smart display name
  String get displayName {
    // Guest name has priority
    if (guestName != null && guestName!.trim().isNotEmpty) {
      return guestName!.trim();
    }

    // Registered user — use first name
    if (user != null && user!.firstName.trim().isNotEmpty) {
      return user!.firstName.trim();
    }

    // Fallback to phone
    if (guestPhone != null && guestPhone!.trim().isNotEmpty) {
      return guestPhone!.trim();
    }

    return 'Guest';
  }

  // Avatar initial — EXACTLY what you wanted
  String get avatarInitial {
    if (guestName != null && guestName!.trim().isNotEmpty) {
      return guestName!.trim()[0].toUpperCase();
    }

    if (user != null && user!.firstName.trim().isNotEmpty) {
      return user!.firstName.trim()[0].toUpperCase();
    }

    if (guestPhone != null && guestPhone!.trim().isNotEmpty) {
      final digits = guestPhone!.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.isNotEmpty) return digits[0];
    }

    return 'G';
  }

  // Profile pic path with fallback
  String get avatarPath {
    if (profilePic != null && profilePic!.isNotEmpty) {
      if (profilePic!.startsWith('http')) return profilePic!;
      if (profilePic!.startsWith('assets/')) return profilePic!;
    }
    return 'assets/images/default_avatar.png';
  }
}

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String profilePic;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.profilePic,
  });
}