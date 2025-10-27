import 'package:sqflite/sqflite.dart';
import '../models/glossary_item.dart';
import '../utils/database_helper.dart';

class GlossaryItemDao {
  final dbHelper = DatabaseHelper();

  Future<int> insert(GlossaryItem item) async {
    final db = await dbHelper.db;
    return await db.insert('glossary_items', item.toMap());
  }

  Future<List<GlossaryItem>> getAll() async {
    final db = await dbHelper.db;
    final maps = await db.query('glossary_items');
    return maps.map((e) => GlossaryItem.fromMap(e)).toList();
  }

  Future<List<GlossaryItem>> searchByKeyword(String keyword) async {
    final db = await dbHelper.db;
    final maps = await db.query(
      'glossary_items',
      where: 'term LIKE ? OR definition LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
    );
    return maps.map((e) => GlossaryItem.fromMap(e)).toList();
  }

  Future<int> update(GlossaryItem item) async {
    final db = await dbHelper.db;
    return await db.update(
      'glossary_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await dbHelper.db;
    return await db.delete('glossary_items', where: 'id = ?', whereArgs: [id]);
  }
}
