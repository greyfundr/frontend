// class/participants.dart
class Participant {
  final String id;
  final String name;
  final String username;
  final String imageUrl;
  final String role;  // New: 'host', 'champion', 'backer', or 'member'

  Participant({
    required this.id,
    required this.name,
    required this.username,
    required this.imageUrl,
    this.role = 'member',
  });

  // Updated copy constructor to include role
  Participant.from(Participant other)
      : id = other.id,
        name = other.name,
        username = other.username,
        imageUrl = other.imageUrl,
        role = other.role;

  // Updated toJson to include role
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'imageUrl': imageUrl,
      'role': role, // ← include role when saving
    };
  }

  // Optional: Nice for debugging
  @override
  String toString() {
    return 'Participant(id: $id, name: $name, role: $role)';
  }
}