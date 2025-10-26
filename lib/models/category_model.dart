class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String color;
  final String icon;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final int sutraCount;
  final int order;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.sutraCount,
    required this.order,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'sutraCount': sutraCount,
      'order': order,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      color: map['color'] ?? '#000000',
      icon: map['icon'] ?? 'book',
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
      sutraCount: map['sutraCount'] ?? 0,
      order: map['order'] ?? 0,
    );
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? icon,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
    int? sutraCount,
    int? order,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sutraCount: sutraCount ?? this.sutraCount,
      order: order ?? this.order,
    );
  }
}

