import 'package:flutter/material.dart';

class ReminderModel {
  final String id;
  final DateTime date;
  final TimeOfDay time;
  final String timeOfDay; // 'morning', 'afternoon', 'evening', 'night'
  final String categoryId;
  final String categoryName;
  final List<String> sutraIds;
  final List<String> sutraTitles; // For display
  final DateTime createdAt;
  final bool isActive;

  ReminderModel({
    required this.id,
    required this.date,
    required this.time,
    required this.timeOfDay,
    required this.categoryId,
    required this.categoryName,
    required this.sutraIds,
    required this.sutraTitles,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'timeOfDay': timeOfDay,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'sutraIds': sutraIds,
      'sutraTitles': sutraTitles,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    final timeParts = (map['time'] as String).split(':');
    return ReminderModel(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      timeOfDay: map['timeOfDay'] as String,
      categoryId: map['categoryId'] as String,
      categoryName: map['categoryName'] as String,
      sutraIds: List<String>.from(map['sutraIds'] as List),
      sutraTitles: List<String>.from(map['sutraTitles'] as List),
      createdAt: DateTime.parse(map['createdAt'] as String),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  ReminderModel copyWith({
    String? id,
    DateTime? date,
    TimeOfDay? time,
    String? timeOfDay,
    String? categoryId,
    String? categoryName,
    List<String>? sutraIds,
    List<String>? sutraTitles,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      sutraIds: sutraIds ?? this.sutraIds,
      sutraTitles: sutraTitles ?? this.sutraTitles,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

