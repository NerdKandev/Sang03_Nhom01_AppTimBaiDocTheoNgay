class UserModel {
  final String id;
  final String username;
  final String email;
  final String password;
  final String role;
  final String fullName;
  final String phone;
  final String avatar;
  final bool isActive;
  final bool isLocked;
  final String createdAt;
  final String? lastLogin;
  final int loginCount;
  final String notes;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.role,
    required this.fullName,
    required this.phone,
    required this.avatar,
    required this.isActive,
    required this.isLocked,
    required this.createdAt,
    this.lastLogin,
    required this.loginCount,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'role': role,
      'fullName': fullName,
      'phone': phone,
      'avatar': avatar,
      'isActive': isActive,
      'isLocked': isLocked,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
      'loginCount': loginCount,
      'notes': notes,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? 'user',
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      avatar: map['avatar'] ?? '',
      isActive: map['isActive'] ?? true,
      isLocked: map['isLocked'] ?? false,
      createdAt: map['createdAt'] ?? '',
      lastLogin: map['lastLogin'],
      loginCount: map['loginCount'] ?? 0,
      notes: map['notes'] ?? '',
    );
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    String? role,
    String? fullName,
    String? phone,
    String? avatar,
    bool? isActive,
    bool? isLocked,
    String? createdAt,
    String? lastLogin,
    int? loginCount,
    String? notes,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      isActive: isActive ?? this.isActive,
      isLocked: isLocked ?? this.isLocked,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      loginCount: loginCount ?? this.loginCount,
      notes: notes ?? this.notes,
    );
  }
}

