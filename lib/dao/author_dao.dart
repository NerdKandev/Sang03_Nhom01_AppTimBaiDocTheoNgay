import 'package:sqflite/sqflite.dart';
import '../models/author.dart';
import '../utils/database_helper.dart';

class AuthorDao {
  final dbHelper = DatabaseHelper();

  Future<int> insert(Author author) async {
    final db = await dbHelper.db;
    return await db.insert('authors', author.toMap());
  }

  Future<List<Author>> getAll() async {
    final db = await dbHelper.db;
    final maps = await db.query('authors');
    return maps.map((e) => Author.fromMap(e)).toList();
  }

  Future<int> update(Author author) async {
    final db = await dbHelper.db;
    return await db.update(
      'authors',
      author.toMap(),
      where: 'id = ?',
      whereArgs: [author.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await dbHelper.db;
    return await db.delete('authors', where: 'id = ?', whereArgs: [id]);
  }
}
