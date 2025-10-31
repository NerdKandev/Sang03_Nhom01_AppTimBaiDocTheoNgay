class VideoModel {
  final String id;
  final String titleVietnamese;
  final String category;
  final String youtubeUrl;
  final String? thumbnailUrl;
  final String? duration;
  final String? description;

  VideoModel({
    required this.id,
    required this.titleVietnamese,
    required this.category,
    required this.youtubeUrl,
    this.thumbnailUrl,
    this.duration,
    this.description,
  });

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    return VideoModel(
      id: map['id'] ?? '',
      titleVietnamese: map['titleVietnamese'] ?? '',
      category: map['category'] ?? '',
      youtubeUrl: map['youtubeUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      duration: map['duration'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titleVietnamese': titleVietnamese,
      'category': category,
      'youtubeUrl': youtubeUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'description': description,
    };
  }

  // Extract YouTube video ID from URL
  String? get videoId {
    final regExp = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]{11})',
    );
    final match = regExp.firstMatch(youtubeUrl);
    return match?.group(1);
  }
}
