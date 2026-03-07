class User {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phoneNumber;
  final String profilePic;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.profilePic,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone'] as String? ?? '',
      profilePic: json['profile_pic'] as String? ?? 'assets/images/personal.png',
    );
  }

  // Helper for display
  String get displayName => username.isNotEmpty
      ? '$username '.trim()
      : firstName.isNotEmpty
      ? firstName
      : lastName;

 
}