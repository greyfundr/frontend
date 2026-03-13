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
    double parseToDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    int parseToInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? (double.tryParse(v)?.toInt() ?? 0);
      return 0;
    }

    String? tryString(List<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null) return json[k].toString();
      }
      return null;
    }

    final amountValue = tryString(['amount', 'totalAmount', 'total_amount']);
    final creatorValue = tryString(['creatorId', 'creator_id', 'creator']);
    final splitMethodValue = tryString(['splitMethod', 'split_method']);
    final dueDateValue = tryString(['dueDate', 'due_date']);
    final imageUrlValue = tryString(['imageUrl', 'image_url']);
    final totalParticipantsValue = tryString(['totalParticipants', 'total_participants']);
    final totalPaidValue = tryString(['totalPaid', 'total_paid', 'totalCollected', 'totalCollected']);
    final amountRaisedValue = tryString(['amountRaised', 'amount_raised', 'totalCollected']);
    final percentageValue = tryString(['percentageComplete', 'percentage_complete']);

    final participantsRaw = json['participants'] ?? json['participant'] ?? [];

    return SplitBill(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'NGN',
      amount: parseToDouble(amountValue),
      creatorId: creatorValue ?? '',
      splitMethod: splitMethodValue ?? '',
      dueDate: DateTime.tryParse(dueDateValue ?? '') ?? DateTime.now(),
      isFinalized: json['isFinalized'] as bool? ?? json['is_finalized'] as bool? ?? false,
      status: json['status']?.toString() ?? '',
      imageUrl: imageUrlValue ?? '',
      totalParticipants: parseToInt(totalParticipantsValue),
      totalPaid: parseToDouble(totalPaidValue),
      amountRaised: parseToDouble(amountRaisedValue),
      percentageComplete: parseToDouble(percentageValue),
      isOverdue: json['isOverdue'] as bool? ?? json['is_overdue'] as bool? ?? false,
      participants: (participantsRaw is List)
          ? participantsRaw.map((p) => Participant.fromJson(Map<String, dynamic>.from(p))).toList()
          : [],
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
    dynamic parseNum(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    final userJson = (json['user'] is Map) ? Map<String, dynamic>.from(json['user']) : null;

    User? userObject;
    String? pic;

    if (userJson != null) {
      userObject = User(
        id: userJson['id']?.toString() ?? '',
        firstName: (userJson['first_name'] ?? userJson['firstName'] ?? '')?.toString() ?? '',
        lastName: (userJson['last_name'] ?? userJson['lastName'] ?? '')?.toString() ?? '',
        profilePic: (userJson['profile_pic'] ?? userJson['profilePic'] ?? '')?.toString() ?? '',
      );
      pic = (userJson['profile_pic'] ?? userJson['profilePic'])?.toString();
    }

    final amountOwedRaw = json['amount_owed'] ?? json['amountOwed'] ?? json['amountOwed'];
    final amountPaidRaw = json['amount_paid'] ?? json['amountPaid'] ?? json['amountPaid'];

    return Participant(
      id: json['id']?.toString() ?? '',
      userId: (json['user_id'] ?? json['userId'])?.toString(),
      guestName: (json['guest_name'] ?? json['guestName'])?.toString(),
      guestPhone: (json['guest_phone'] ?? json['guestPhone'])?.toString(),
      guestEmail: (json['guest_email'] ?? json['guestEmail'])?.toString(),
      amountOwed: parseNum(amountOwedRaw) as double,
      amountPaid: parseNum(amountPaidRaw) as double,
      status: (json['status'] as String?)?.toUpperCase() ?? 'UNPAID',
      paid: json['paid'] as bool? ?? false,
      inviteCode: (json['invite_code'] ?? json['inviteCode'])?.toString() ?? '',
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