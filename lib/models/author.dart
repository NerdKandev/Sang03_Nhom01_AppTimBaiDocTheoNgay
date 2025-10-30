class Author {
  final String id;
  final String name;
  final String? bio;
  final String? avatarUrl;

  Author({
    required this.id,
    required this.name,
    this.bio,
    this.avatarUrl,
  });

  factory Author.fromMap(Map<String, dynamic> map) {
    return Author(
      id: map['id'] as String,
      name: map['name'] as String,
      bio: map['bio'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'avatarUrl': avatarUrl,
    };
  }
}
