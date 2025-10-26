import 'package:sqflite/sqflite.dart';
import '../services/database_service.dart';
import '../models/user.dart';

class AdminService {
  static final DatabaseService _dbService = DatabaseService();

  // Get all users for admin management
  Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final db = await _dbService.database;
      if (db == null) {
        return {
          'success': false,
          'message': 'Không thể kết nối database'
        };
      }

      final List<Map<String, dynamic>> users = await db.query(
        'users',
        orderBy: 'created_at DESC',
      );

      final List<User> userList = users.map((map) => User.fromMap(map)).toList();

      return {
        'success': true,
        'data': userList,
        'count': userList.length,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi hệ thống: ${e.toString()}'
      };
    }
  }

  // Get user by ID
  Future<Map<String, dynamic>> getUserById(int userId) async {
    try {
      final db = await _dbService.database;
      if (db == null) {
        return {
          'success': false,
          'message': 'Không thể kết nối database'
        };
      }

      final List<Map<String, dynamic>> users = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (users.isEmpty) {
        return {
          'success': false,
          'message': 'Không tìm thấy người dùng'
        };
      }

      final User user = User.fromMap(users.first);

      return {
        'success': true,
        'data': user,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi hệ thống: ${e.toString()}'
      };
    }
  }

  // Toggle user status (lock/unlock)
  Future<Map<String, dynamic>> toggleUserStatus(int userId, bool isActive) async {
    try {
      final db = await _dbService.database;
      if (db == null) {
        return {
          'success': false,
          'message': 'Không thể kết nối database'
        };
      }

      await db.update(
        'users',
        {'is_active': isActive ? 1 : 0},
        where: 'id = ?',
        whereArgs: [userId],
      );

      return {
        'success': true,
        'message': isActive ? 'Đã mở khóa tài khoản' : 'Đã khóa tài khoản'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi hệ thống: ${e.toString()}'
      };
    }
  }

  // Delete user
  Future<Map<String, dynamic>> deleteUser(int userId) async {
    try {
      final db = await _dbService.database;
      if (db == null) {
        return {
          'success': false,
          'message': 'Không thể kết nối database'
        };
      }

      // Check if user exists
      final List<Map<String, dynamic>> users = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (users.isEmpty) {
        return {
          'success': false,
          'message': 'Không tìm thấy người dùng'
        };
      }

      // Delete user and related data
      await db.transaction((txn) async {
        // Delete user progress
        await txn.delete('user_progress', where: 'user_id = ?', whereArgs: [userId]);
        
        // Delete favorites
        await txn.delete('favorites', where: 'user_id = ?', whereArgs: [userId]);
        
        // Delete bookmarks
        await txn.delete('bookmarks', where: 'user_id = ?', whereArgs: [userId]);
        
        // Delete notes
        await txn.delete('notes', where: 'user_id = ?', whereArgs: [userId]);
        
        // Delete user
        await txn.delete('users', where: 'id = ?', whereArgs: [userId]);
      });

      return {
        'success': true,
        'message': 'Đã xóa người dùng thành công'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi hệ thống: ${e.toString()}'
      };
    }
  }

  // Update user role
  Future<Map<String, dynamic>> updateUserRole(int userId, String newRole) async {
    try {
      final db = await _dbService.database;
      if (db == null) {
        return {
          'success': false,
          'message': 'Không thể kết nối database'
        };
      }

      if (!['admin', 'user'].contains(newRole)) {
        return {
          'success': false,
          'message': 'Vai trò không hợp lệ'
        };
      }

      await db.update(
        'users',
        {'role': newRole},
        where: 'id = ?',
        whereArgs: [userId],
      );

      return {
        'success': true,
        'message': 'Đã cập nhật vai trò thành công'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi hệ thống: ${e.toString()}'
      };
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final db = await _dbService.database;
      if (db == null) {
        return {
          'success': false,
          'message': 'Không thể kết nối database'
        };
      }

      // Get total users
      final totalUsers = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM users')
      ) ?? 0;

      // Get active users
      final activeUsers = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM users WHERE is_active = 1')
      ) ?? 0;

      // Get admin users
      final adminUsers = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM users WHERE role = "admin"')
      ) ?? 0;

      // Get regular users
      final regularUsers = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM users WHERE role = "user"')
      ) ?? 0;

      // Get users created today
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = DateTime(today.year, today.month, today.day, 23, 59, 59);
      
      final usersToday = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM users WHERE created_at BETWEEN ? AND ?',
          [todayStart.toIso8601String(), todayEnd.toIso8601String()]
        )
      ) ?? 0;

      // Get users created this week
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
      
      final usersThisWeek = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM users WHERE created_at BETWEEN ? AND ?',
          [weekStart.toIso8601String(), weekEnd.toIso8601String()]
        )
      ) ?? 0;

      // Get users created this month
      final monthStart = DateTime(today.year, today.month, 1);
      final monthEnd = DateTime(today.year, today.month + 1, 0, 23, 59, 59);
      
      final usersThisMonth = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM users WHERE created_at BETWEEN ? AND ?',
          [monthStart.toIso8601String(), monthEnd.toIso8601String()]
        )
      ) ?? 0;

      return {
        'success': true,
        'data': {
          'total_users': totalUsers,
          'active_users': activeUsers,
          'inactive_users': totalUsers - activeUsers,
          'admin_users': adminUsers,
          'regular_users': regularUsers,
          'users_today': usersToday,
          'users_this_week': usersThisWeek,
          'users_this_month': usersThisMonth,
          'activity_rate': totalUsers > 0 ? ((activeUsers / totalUsers) * 100).round() : 0,
        }
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi hệ thống: ${e.toString()}'
      };
    }
  }

  // Get admin dashboard statistics
  Future<Map<String, dynamic>> getAdminStatistics() async {
    try {
      final users = await _dbService.getAllUsers();
      final books = await _dbService.getAllBibleBooks();
      final readings = await _dbService.getAllDailyReadings();
      
      // Get user activity data
      final favorites = await _dbService.getAllFavorites();
      final bookmarks = await _dbService.getAllBookmarks();
      final notes = await _dbService.getAllNotes();
      final progress = await _dbService.getAllUserProgress();
      
      // Calculate today's stats
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final newUsersToday = users.where((u) => 
        u.createdAt.isAfter(todayStart)).length;
      
      // Calculate activity rate
      final activeUsers = users.where((u) => u.isActive).length;
      final activityRate = users.isNotEmpty ? 
        (activeUsers / users.length * 100).round() : 0;
      
      return {
        'success': true,
        'data': {
          'total_users': users.length,
          'active_users': activeUsers,
          'total_books': books.length,
          'old_testament_books': books.where((b) => b.testament == 'Cựu Ước').length,
          'new_testament_books': books.where((b) => b.testament == 'Tân Ước').length,
          'total_readings': readings.length,
          'total_favorites': favorites.length,
          'total_bookmarks': bookmarks.length,
          'total_notes': notes.length,
          'total_progress': progress.length,
          'new_users_today': newUsersToday,
          'activity_today': newUsersToday,
          'activity_rate': activityRate,
        }
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi hệ thống: ${e.toString()}'
      };
    }
  }

  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final result = await getAdminStatistics();
      if (result['success']) {
        return result['data'];
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }
}

