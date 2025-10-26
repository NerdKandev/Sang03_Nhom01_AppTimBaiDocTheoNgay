import 'package:sqflite/sqflite.dart';
import '../services/database_service.dart';

class UserFeaturesService {
  static final DatabaseService _dbService = DatabaseService();

  // Get user favorites
  Future<List<Map<String, dynamic>>> getUserFavorites(int userId) async {
    try {
      final db = await _dbService.database;
      if (db == null) return [];

      final List<Map<String, dynamic>> favorites = await db.rawQuery('''
        SELECT f.*, dr.title, dr.date, dr.book_id, dr.chapter, dr.start_verse, dr.end_verse,
               bb.name as book_name
        FROM favorites f
        JOIN daily_readings dr ON f.reading_id = dr.id
        JOIN bible_books bb ON dr.book_id = bb.id
        WHERE f.user_id = ?
        ORDER BY f.created_at DESC
      ''', [userId]);

      return favorites;
    } catch (e) {
      print('Error getting user favorites: $e');
      return [];
    }
  }

  // Add favorite
  Future<Map<String, dynamic>> addFavorite(int userId, int readingId) async {
    try {
      final db = await _dbService.database;
      if (db == null) {
        return {
          'success': false,
          'message': 'Không thể kết nối database'
        };
      }

      // Check if already favorited
      final existing = await db.query(
        'favorites',
        where: 'user_id = ? AND reading_id = ?',
        whereArgs: [userId, readingId],
      );

      if (existing.isNotEmpty) {
        return {
          'success': false,
          'message': 'Bài đọc đã có trong yêu thích'
        };
      }

      await db.insert('favorites', {
        'user_id': userId,
        'reading_id': readingId,
        'created_at': DateTime.now().toIso8601String(),
      });

      return {
        'success': true,
        'message': 'Đã thêm vào yêu thích'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi hệ thống: ${e.toString()}'
      };
    }
  }

  // Remove favorite
  Future<Map<String, dynamic>> removeFavorite(int userId, int favoriteId) async {
    try {
      final db = await _dbService.database;
      if (db == null) {
        return {
          'success': false,
          'message': 'Không thể kết nối database'
        };
      }

      await db.delete(
        'favorites',
        where: 'id = ? AND user_id = ?',
        whereArgs: [favoriteId, userId],
      );

      return {
        'success': true,
        'message': 'Đã xóa khỏi yêu thích'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi hệ thống: ${e.toString()}'
      };
    }
  }

  // Get user bookmarks
  Future<List<Map<String, dynamic>>> getUserBookmarks(int userId) async {
    try {
      final db = await _dbService.database;
      if (db == null) return [];

      final List<Map<String, dynamic>> bookmarks = await db.rawQuery('''
        SELECT b.*, bb.name as book_name
        FROM bookmarks b
        JOIN bible_books bb ON b.book_id = bb.id
        WHERE b.user_id = ?
        ORDER BY b.created_at DESC
      ''', [userId]);

      return bookmarks;
    } catch (e) {
      print('Error getting user bookmarks: $e');
      return [];
    }
  }

  // Add bookmark
  Future<Map<String, dynamic>> addBookmark(int userId, int bookId, int chapter, int verse, String? title) async {
    try {
      final db = await _dbService.database;
      if (db == null) {
        return {
          'success': false,
          'message': 'Không thể kết nối database'
        };
      }

      // Check if already bookmarked
      final existing = await db.query(
        'bookmarks',
        where: 'user_id = ? AND book_id = ? AND chapter = ? AND verse = ?',
        whereArgs: [userId, bookId, chapter, verse],
      );

      if (existing.isNotEmpty) {
        return {
          'success': false,
          'message': 'Đã đánh dấu trước đó'
        };
      }

      await db.insert('bookmarks', {
        'user_id': userId,
        'book_id': bookId,
        'chapter': chapter,
        'verse': verse,
        'title': title ?? 'Đánh dấu ${chapter}:${verse}',
        'created_at': DateTime.now().toIso8601String(),
      });

      return {
        'success': true,
        'message': 'Đã thêm đánh dấu'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi hệ thống: ${e.toString()}'
      };
    }
  }

  // Remove bookmark
  Future<Map<String, dynamic>> removeBookmark(int bookmarkId) async {
    try {
      final db = await _dbService.database;
      if (db == null) {
        return {
          'success': false,
          'message': 'Không thể kết nối database'
        };
      }

      await db.delete(
        'bookmarks',
        where: 'id = ?',
        whereArgs: [bookmarkId],
      );

      return {
        'success': true,
        'message': 'Đã xóa đánh dấu'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi hệ thống: ${e.toString()}'
      };
    }
  }

  // Get user notes
  Future<List<Map<String, dynamic>>> getUserNotes(int userId) async {
    try {
      final db = await _dbService.database;
      if (db == null) return [];

      final List<Map<String, dynamic>> notes = await db.rawQuery('''
        SELECT n.*, bb.name as book_name, dr.title as reading_title
        FROM notes n
        LEFT JOIN bible_books bb ON n.book_id = bb.id
        LEFT JOIN daily_readings dr ON n.reading_id = dr.id
        WHERE n.user_id = ?
        ORDER BY n.updated_at DESC
      ''', [userId]);

      return notes;
    } catch (e) {
      print('Error getting user notes: $e');
      return [];
    }
  }

  // Add note
  Future<Map<String, dynamic>> addNote(int userId, String content, {int? readingId, int? bookId, int? chapter, int? verse, String? title}) async {
    try {
      final db = await _dbService.database;
      if (db == null) {
        return {
          'success': false,
          'message': 'Không thể kết nối database'
        };
      }

      final now = DateTime.now().toIso8601String();
      await db.insert('notes', {
        'user_id': userId,
        'reading_id': readingId,
        'book_id': bookId,
        'chapter': chapter,
        'verse': verse,
        'title': title ?? 'Ghi chú mới',
        'content': content,
        'created_at': now,
        'updated_at': now,
      });

      return {
        'success': true,
        'message': 'Đã thêm ghi chú'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi hệ thống: ${e.toString()}'
      };
    }
  }

  // Update note
  Future<Map<String, dynamic>> updateNote(int noteId, String content, {String? title}) async {
    try {
      final db = await _dbService.database;
      if (db == null) {
        return {
          'success': false,
          'message': 'Không thể kết nối database'
        };
      }

      await db.update(
        'notes',
        {
          'content': content,
          'title': title,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [noteId],
      );

      return {
        'success': true,
        'message': 'Đã cập nhật ghi chú'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi hệ thống: ${e.toString()}'
      };
    }
  }

  // Delete note
  Future<Map<String, dynamic>> deleteNote(int noteId) async {
    try {
      final db = await _dbService.database;
      if (db == null) {
        return {
          'success': false,
          'message': 'Không thể kết nối database'
        };
      }

      await db.delete(
        'notes',
        where: 'id = ?',
        whereArgs: [noteId],
      );

      return {
        'success': true,
        'message': 'Đã xóa ghi chú'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi hệ thống: ${e.toString()}'
      };
    }
  }

  // Get user progress
  Future<List<Map<String, dynamic>>> getUserProgress(int userId) async {
    try {
      final db = await _dbService.database;
      if (db == null) return [];

      final List<Map<String, dynamic>> progress = await db.rawQuery('''
        SELECT p.*, dr.title, dr.date, dr.book_id, dr.chapter,
               bb.name as book_name
        FROM user_progress p
        JOIN daily_readings dr ON p.reading_id = dr.id
        JOIN bible_books bb ON dr.book_id = bb.id
        WHERE p.user_id = ?
        ORDER BY p.completed_at DESC
      ''', [userId]);

      return progress;
    } catch (e) {
      print('Error getting user progress: $e');
      return [];
    }
  }

  // Add progress
  Future<Map<String, dynamic>> addProgress(int userId, int readingId, {int? readingTime}) async {
    try {
      final db = await _dbService.database;
      if (db == null) {
        return {
          'success': false,
          'message': 'Không thể kết nối database'
        };
      }

      await db.insert('user_progress', {
        'user_id': userId,
        'reading_id': readingId,
        'completed_at': DateTime.now().toIso8601String(),
        'reading_time': readingTime,
      });

      return {
        'success': true,
        'message': 'Đã lưu tiến độ'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi hệ thống: ${e.toString()}'
      };
    }
  }
}

