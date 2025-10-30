import 'package:sqflite/sqflite.dart';
import '../models/category.dart';
import '../utils/database_helper.dart';

class CategoryDao {
  final dbHelper = DatabaseHelper();

  Future<int> insert(Category category) async {
    final db = await dbHelper.db;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getAll() async {
    final db = await dbHelper.db;
    final maps = await db.query('categories');
    return maps.map((e) => Category.fromMap(e)).toList();
  }

  Future<int> update(Category category) async {
    final db = await dbHelper.db;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await dbHelper.db;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
