class Category {
  final String id;
  final String name;
  final String? parentId;

  Category({
    required this.id,
    required this.name,
    this.parentId,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      parentId: map['parentId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
    };
  }
}
