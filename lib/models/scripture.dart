// lib/models/scripture.dart

class Scripture {
  final String id;
  final String title;
  final String content;
  final String? categoryId;
  final String? authorId;
  final String? coverImage;
  final bool isPublished;

  Scripture({
    required this.id,
    required this.title,
    required this.content,
    this.categoryId,
    this.authorId,
    this.coverImage,
    this.isPublished = true,
  });

  // Tạo từ Map (được sqflite trả về)
  factory Scripture.fromMap(Map<String, dynamic> map) {
    return Scripture(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      categoryId: map['categoryId'] as String?,
      authorId: map['authorId'] as String?,
      coverImage: map['coverImage'] as String?,
      // Một số DB lưu boolean bằng 0/1
      isPublished: (map['isPublished'] == null)
          ? true
          : ((map['isPublished'] is int)
              ? (map['isPublished'] as int) == 1
              : (map['isPublished'] as bool)),
    );
  }

  // Chuyển về Map để lưu vào SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'categoryId': categoryId,
      'authorId': authorId,
      'coverImage': coverImage,
      // lưu isPublished dưới dạng int (1/0)
      'isPublished': isPublished ? 1 : 0,
    };
  }

  // Nếu bạn còn dùng JSON (ví dụ import/export), giữ thêm toJson/fromJson
  factory Scripture.fromJson(Map<String, dynamic> json) => Scripture(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        categoryId: json['categoryId'] as String?,
        authorId: json['authorId'] as String?,
        coverImage: json['coverImage'] as String?,
        isPublished: json['isPublished'] == null
            ? true
            : (json['isPublished'] is int
                ? json['isPublished'] == 1
                : json['isPublished'] as bool),
      );

  Map<String, dynamic> toJson() => toMap();
}
