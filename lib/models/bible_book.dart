class BibleBook {
  final int id;
  final String name;
  final String abbreviation;
  final int chapterCount;
  final String testament;
  final int orderIndex;

  BibleBook({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.chapterCount,
    required this.testament,
    required this.orderIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'abbreviation': abbreviation,
      'chapter_count': chapterCount,
      'testament': testament,
      'order_index': orderIndex,
    };
  }

  factory BibleBook.fromMap(Map<String, dynamic> map) {
    return BibleBook(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      abbreviation: map['abbreviation'] ?? '',
      chapterCount: map['chapter_count'] ?? 0,
      testament: map['testament'] ?? '',
      orderIndex: map['order_index'] ?? 0,
    );
  }
}

