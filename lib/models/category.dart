class Category {
  final String id;
  final String name;
  final String description;
  final String color;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      color: map['color'] ?? '#000000',
    );
  }
}