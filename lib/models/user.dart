/// Lightweight User model to satisfy existing imports. The project contains a
/// more detailed `UserModel` in `models/user_model.dart`; this `User` class is a
/// small, compatible wrapper used by services/screens that expect simple user
/// properties.
class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    // Support different naming conventions that may be present in DB rows.
    final created = map['created_at'] ?? map['createdAt'] ?? map['createdAtString'];
    DateTime createdAt;
    if (created is DateTime) {
      createdAt = created;
    } else if (created is String) {
      createdAt = DateTime.tryParse(created) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    final isActiveVal = map['is_active'] ?? map['isActive'] ?? map['active'];
    final bool isActive = (isActiveVal == 1 || isActiveVal == true);

    return User(
      id: (map['id'] is int) ? map['id'] as int : int.tryParse('${map['id']}') ?? 0,
      username: map['username']?.toString() ?? map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      role: map['role']?.toString() ?? 'user',
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}
