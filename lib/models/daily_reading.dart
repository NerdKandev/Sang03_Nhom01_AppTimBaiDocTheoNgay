class DailyReading {
  final int id;
  final int dayOfYear;
  final String date;
  final String bookId;
  final String bookName;
  final int chapter;
  final int startVerse;
  final int endVerse;
  final String title;
  final String description;
  final String content;

  DailyReading({
    required this.id,
    required this.dayOfYear,
    required this.date,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.startVerse,
    required this.endVerse,
    required this.title,
    required this.description,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day_of_year': dayOfYear,
      'date': date,
      'book_id': bookId,
      'book_name': bookName,
      'chapter': chapter,
      'start_verse': startVerse,
      'end_verse': endVerse,
      'title': title,
      'description': description,
      'content': content,
    };
  }

  factory DailyReading.fromMap(Map<String, dynamic> map) {
    return DailyReading(
      id: map['id'] ?? 0,
      dayOfYear: map['day_of_year'] ?? 0,
      date: map['date'] ?? '',
      bookId: map['book_id'] ?? '',
      bookName: map['book_name'] ?? '',
      chapter: map['chapter'] ?? 0,
      startVerse: map['start_verse'] ?? 0,
      endVerse: map['end_verse'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      content: map['content'] ?? '',
    );
  }
}