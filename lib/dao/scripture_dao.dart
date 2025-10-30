import 'package:sqflite/sqflite.dart';
import '../utils/database_helper.dart';
import '../models/scripture.dart';

class ScriptureDao {
  final dbHelper = DatabaseHelper();

  Future<int> insert(Scripture scripture) async {
    final db = await dbHelper.db;
    return await db.insert('scriptures', scripture.toMap());
  }

  Future<List<Scripture>> getAll() async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query('scriptures');
    return maps.map((map) => Scripture.fromMap(map)).toList();
  }

  Future<int> update(Scripture scripture) async {
    final db = await dbHelper.db;
    return await db.update(
      'scriptures',
      scripture.toMap(),
      where: 'id = ?',
      whereArgs: [scripture.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await dbHelper.db;
    return await db.delete('scriptures', where: 'id = ?', whereArgs: [id]);
  }
}
