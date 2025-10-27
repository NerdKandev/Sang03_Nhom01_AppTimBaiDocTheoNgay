import 'package:sqflite/sqflite.dart';
import '../models/timetable.dart';
import '../utils/database_helper.dart';

class TimetableDao {
  final dbHelper = DatabaseHelper();

  Future<int> insert(Timetable timetable) async {
    final db = await dbHelper.db;
    return await db.insert('schedules', timetable.toMap());
  }

  Future<List<Timetable>> getAll() async {
    final db = await dbHelper.db;
    final maps = await db.query('schedules');
    return maps.map((e) => Timetable.fromMap(e)).toList();
  }

  Future<int> update(Timetable timetable) async {
    final db = await dbHelper.db;
    return await db.update(
      'schedules',
      timetable.toMap(),
      where: 'id = ?',
      whereArgs: [timetable.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await dbHelper.db;
    return await db.delete('schedules', where: 'id = ?', whereArgs: [id]);
  }
}
