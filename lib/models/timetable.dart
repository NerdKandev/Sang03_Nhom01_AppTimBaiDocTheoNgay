class Timetable {
  final String id;
  final String name;
  final int hour;
  final int minute;
  final String? scriptureId;
  final bool repeatDaily;

  Timetable({
    required this.id,
    required this.name,
    required this.hour,
    required this.minute,
    this.scriptureId,
    this.repeatDaily = true,
  });

  factory Timetable.fromMap(Map<String, dynamic> map) {
    return Timetable(
      id: map['id'] as String,
      name: map['name'] as String,
      hour: map['hour'] as int,
      minute: map['minute'] as int,
      scriptureId: map['scriptureId'] as String?,
      repeatDaily: (map['repeatDaily'] == 1),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'hour': hour,
      'minute': minute,
      'scriptureId': scriptureId,
      'repeatDaily': repeatDaily ? 1 : 0,
    };
  }
}
