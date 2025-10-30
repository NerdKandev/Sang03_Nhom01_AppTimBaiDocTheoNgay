class AudioItem {
  final String id;
  final String title;
  final String path;
  final String? scriptureId;
  final int? duration;
  final String? narrator;

  AudioItem({
    required this.id,
    required this.title,
    required this.path,
    this.scriptureId,
    this.duration,
    this.narrator,
  });

  factory AudioItem.fromMap(Map<String, dynamic> map) {
    return AudioItem(
      id: map['id'] as String,
      title: map['title'] as String,
      path: map['path'] as String,
      scriptureId: map['scriptureId'] as String?,
      duration: map['duration'] != null ? map['duration'] as int : null,
      narrator: map['narrator'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'path': path,
      'scriptureId': scriptureId,
      'duration': duration,
      'narrator': narrator,
    };
  }
}
