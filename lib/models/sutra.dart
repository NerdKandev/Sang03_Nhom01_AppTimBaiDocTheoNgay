class Sutra {
  final String id;
  final String title;
  final String titleVietnamese;
  final String titlePali;
  final String category;
  final String description;
  final String content;
  final String fullContent;
  final String readingTime;
  final String difficulty;
  final List<String> tags;
  final String dateAdded;
  final bool isFavorite;
  final int readingCount;
  final String? lastRead;
  
  // Audio properties
  final bool hasAudio;
  final String? audioPath;
  final String? audioUrl;
  final int audioDuration; // in seconds
  final bool isAudioEnabled;

  Sutra({
    required this.id,
    required this.title,
    required this.titleVietnamese,
    required this.titlePali,
    required this.category,
    required this.description,
    required this.content,
    required this.fullContent,
    required this.readingTime,
    required this.difficulty,
    required this.tags,
    required this.dateAdded,
    required this.isFavorite,
    required this.readingCount,
    this.lastRead,
    this.hasAudio = false,
    this.audioPath,
    this.audioUrl,
    this.audioDuration = 0,
    this.isAudioEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'titleVietnamese': titleVietnamese,
      'titlePali': titlePali,
      'category': category,
      'description': description,
      'content': content,
      'fullContent': fullContent,
      'readingTime': readingTime,
      'difficulty': difficulty,
      'tags': tags,
      'dateAdded': dateAdded,
      'isFavorite': isFavorite,
      'readingCount': readingCount,
      'lastRead': lastRead,
      'hasAudio': hasAudio,
      'audioPath': audioPath,
      'audioUrl': audioUrl,
      'audioDuration': audioDuration,
      'isAudioEnabled': isAudioEnabled,
    };
  }

  factory Sutra.fromMap(Map<String, dynamic> map) {
    return Sutra(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      titleVietnamese: map['titleVietnamese'] ?? '',
      titlePali: map['titlePali'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      content: map['content'] ?? '',
      fullContent: map['fullContent'] ?? '',
      readingTime: map['readingTime'] ?? '',
      difficulty: map['difficulty'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      dateAdded: map['dateAdded'] ?? '',
      isFavorite: map['isFavorite'] ?? false,
      readingCount: map['readingCount'] ?? 0,
      lastRead: map['lastRead'],
      hasAudio: map['hasAudio'] ?? false,
      audioPath: map['audioPath'],
      audioUrl: map['audioUrl'],
      audioDuration: map['audioDuration'] ?? 0,
      isAudioEnabled: map['isAudioEnabled'] ?? true,
    );
  }

  // Helper methods for audio functionality
  String get audioDisplayDuration {
    if (audioDuration == 0) return 'Không xác định';
    
    int minutes = audioDuration ~/ 60;
    int seconds = audioDuration % 60;
    
    if (minutes > 0) {
      return '${minutes} phút ${seconds} giây';
    } else {
      return '${seconds} giây';
    }
  }

  String get audioStatusText {
    if (!isAudioEnabled) return 'Tắt âm thanh';
    if (hasAudio) return 'Có âm thanh';
    return 'Đọc bằng TTS';
  }

  bool get canPlayAudio {
    return isAudioEnabled && (hasAudio || fullContent.isNotEmpty);
  }

  // Copy with method for updating audio properties
  Sutra copyWith({
    String? id,
    String? title,
    String? titleVietnamese,
    String? titlePali,
    String? category,
    String? description,
    String? content,
    String? fullContent,
    String? readingTime,
    String? difficulty,
    List<String>? tags,
    String? dateAdded,
    bool? isFavorite,
    int? readingCount,
    String? lastRead,
    bool? hasAudio,
    String? audioPath,
    String? audioUrl,
    int? audioDuration,
    bool? isAudioEnabled,
  }) {
    return Sutra(
      id: id ?? this.id,
      title: title ?? this.title,
      titleVietnamese: titleVietnamese ?? this.titleVietnamese,
      titlePali: titlePali ?? this.titlePali,
      category: category ?? this.category,
      description: description ?? this.description,
      content: content ?? this.content,
      fullContent: fullContent ?? this.fullContent,
      readingTime: readingTime ?? this.readingTime,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      dateAdded: dateAdded ?? this.dateAdded,
      isFavorite: isFavorite ?? this.isFavorite,
      readingCount: readingCount ?? this.readingCount,
      lastRead: lastRead ?? this.lastRead,
      hasAudio: hasAudio ?? this.hasAudio,
      audioPath: audioPath ?? this.audioPath,
      audioUrl: audioUrl ?? this.audioUrl,
      audioDuration: audioDuration ?? this.audioDuration,
      isAudioEnabled: isAudioEnabled ?? this.isAudioEnabled,
    );
  }
}