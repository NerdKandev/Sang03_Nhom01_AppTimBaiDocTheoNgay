import 'package:sqflite/sqflite.dart';
import '../models/audio_item.dart';
import '../utils/database_helper.dart';

class AudioItemDao {
  final dbHelper = DatabaseHelper();

  Future<int> insert(AudioItem audio) async {
    final db = await dbHelper.db;
    return await db.insert('audio_items', audio.toMap());
  }

  Future<List<AudioItem>> getAll() async {
    final db = await dbHelper.db;
    final maps = await db.query('audio_items');
    return maps.map((e) => AudioItem.fromMap(e)).toList();
  }

  Future<List<AudioItem>> getByScripture(String scriptureId) async {
    final db = await dbHelper.db;
    final maps = await db.query(
      'audio_items',
      where: 'scriptureId = ?',
      whereArgs: [scriptureId],
    );
    return maps.map((e) => AudioItem.fromMap(e)).toList();
  }

  Future<int> update(AudioItem audio) async {
    final db = await dbHelper.db;
    return await db.update(
      'audio_items',
      audio.toMap(),
      where: 'id = ?',
      whereArgs: [audio.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await dbHelper.db;
    return await db.delete('audio_items', where: 'id = ?', whereArgs: [id]);
  }
}
