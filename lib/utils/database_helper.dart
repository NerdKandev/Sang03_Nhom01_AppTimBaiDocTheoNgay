import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'buddhism_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Danh mục
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT,
        parentId TEXT
      )
    ''');

    // Tác giả
    await db.execute('''
      CREATE TABLE authors (
        id TEXT PRIMARY KEY,
        name TEXT,
        bio TEXT,
        avatarUrl TEXT
      )
    ''');

    // Bài đọc kinh sách
    await db.execute('''
      CREATE TABLE scriptures (
        id TEXT PRIMARY KEY,
        title TEXT,
        content TEXT,
        categoryId TEXT,
        authorId TEXT,
        coverImage TEXT,
        isPublished INTEGER
      )
    ''');

    // Bài nghe
    await db.execute('''
      CREATE TABLE audio_items (
        id TEXT PRIMARY KEY,
        title TEXT,
        path TEXT,
        scriptureId TEXT,
        duration INTEGER,
        narrator TEXT
      )
    ''');

    // Từ điển Phật pháp
    await db.execute('''
      CREATE TABLE glossary_items (
        id TEXT PRIMARY KEY,
        term TEXT,
        definition TEXT,
        synonyms TEXT,
        tags TEXT
      )
    ''');

    // Lịch tụng
    await db.execute('''
      CREATE TABLE timetable (
        id TEXT PRIMARY KEY,
        name TEXT,
        hour INTEGER,
        minute INTEGER,
        scriptureId TEXT,
        repeatDaily INTEGER
      )
    ''');
  }
}
