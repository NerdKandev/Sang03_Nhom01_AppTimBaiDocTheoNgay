import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/user_model.dart';

class UserStorageService {
  static final UserStorageService _instance = UserStorageService._internal();
  factory UserStorageService() => _instance;
  UserStorageService._internal();

  List<UserModel> _users = [];
  String? _storagePath;

  List<UserModel> get users => _users;

  Future<void> initializeUsers() async {
    await _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      // Try to load from documents directory first
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/users.json');
      
      if (await file.exists()) {
        final String jsonString = await file.readAsString();
        final Map<String, dynamic> data = json.decode(jsonString);
        final List<dynamic> usersData = data['users'] ?? [];
        _users = usersData.map((user) => UserModel.fromMap(user)).toList();
        _storagePath = file.path;
        print('Loaded ${_users.length} users from: ${file.path}');
      } else {
        // If no file exists, create with default users
        _users = _getDefaultUsers();
        await _saveUsers();
        print('Created new users file with default data');
      }
    } catch (e) {
      print('Error loading users: $e');
      _users = _getDefaultUsers();
    }
  }

  List<UserModel> _getDefaultUsers() {
    return [
      UserModel(
        id: '1',
        username: 'admin',
        email: 'admin@example.com',
        password: 'admin123',
        role: 'admin',
        fullName: 'Quản trị viên',
        phone: '0123456789',
        avatar: '',
        isActive: true,
        isLocked: false,
        createdAt: DateTime.now().toIso8601String(),
        lastLogin: DateTime.now().toIso8601String(),
        loginCount: 1,
        notes: 'Tài khoản quản trị viên',
      ),
    ];
  }

  // Add new user
  Future<bool> addUser(UserModel user) async {
    try {
      // Check if username already exists
      if (_users.any((u) => u.username == user.username)) {
        print('Username already exists: ${user.username}');
        return false;
      }

      _users.add(user);
      await _saveUsers();
      print('User added successfully: ${user.username}');
      return true;
    } catch (e) {
      print('Error adding user: $e');
      return false;
    }
  }

  // Update user
  Future<bool> updateUser(String userId, UserModel updatedUser) async {
    try {
      final index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index] = updatedUser;
        await _saveUsers();
        print('User updated successfully: ${updatedUser.username}');
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      _users.removeWhere((user) => user.id == userId);
      await _saveUsers();
      print('User deleted successfully: $userId');
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // Toggle user lock
  Future<bool> toggleUserLock(String userId) async {
    try {
      final index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(
          isLocked: !_users[index].isLocked,
        );
        await _saveUsers();
        print('User lock toggled: ${_users[index].username}');
        return true;
      }
      return false;
    } catch (e) {
      print('Error toggling user lock: $e');
      return false;
    }
  }

  // Toggle user active
  Future<bool> toggleUserActive(String userId) async {
    try {
      final index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(
          isActive: !_users[index].isActive,
        );
        await _saveUsers();
        print('User active toggled: ${_users[index].username}');
        return true;
      }
      return false;
    } catch (e) {
      print('Error toggling user active: $e');
      return false;
    }
  }

  // Get user by username
  UserModel? getUserByUsername(String username) {
    try {
      return _users.firstWhere((user) => user.username == username);
    } catch (e) {
      return null;
    }
  }

  // Get user by ID
  UserModel? getUserById(String userId) {
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  // Search users
  List<UserModel> searchUsers(String query) {
    if (query.isEmpty) return _users;
    
    return _users.where((user) =>
        user.username.toLowerCase().contains(query.toLowerCase()) ||
        user.fullName.toLowerCase().contains(query.toLowerCase()) ||
        user.email.toLowerCase().contains(query.toLowerCase()) ||
        user.phone.contains(query)
    ).toList();
  }

  // Get users by role
  List<UserModel> getUsersByRole(String role) {
    return _users.where((user) => user.role == role).toList();
  }

  // Get active users
  List<UserModel> getActiveUsers() {
    return _users.where((user) => user.isActive && !user.isLocked).toList();
  }

  // Get locked users
  List<UserModel> getLockedUsers() {
    return _users.where((user) => user.isLocked).toList();
  }

  // Update user login info
  Future<bool> updateUserLogin(String userId) async {
    try {
      final index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(
          lastLogin: DateTime.now().toIso8601String(),
          loginCount: _users[index].loginCount + 1,
        );
        await _saveUsers();
        print('User login updated: ${_users[index].username}');
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating user login: $e');
      return false;
    }
  }

  // Save users to file
  Future<void> _saveUsers() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/users.json');
      
      final Map<String, dynamic> data = {
        'users': _users.map((user) => user.toMap()).toList(),
        'statistics': _getUpdatedStatistics(),
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      await file.writeAsString(json.encode(data));
      _storagePath = file.path;
      print('Users saved successfully to: ${file.path}');
      print('Total users: ${_users.length}');
    } catch (e) {
      print('Error saving users: $e');
    }
  }

  // Get updated statistics
  Map<String, dynamic> _getUpdatedStatistics() {
    return {
      'totalUsers': _users.length,
      'activeUsers': _users.where((user) => user.isActive && !user.isLocked).length,
      'lockedUsers': _users.where((user) => user.isLocked).length,
      'adminUsers': _users.where((user) => user.role == 'admin').length,
      'regularUsers': _users.where((user) => user.role == 'user').length,
      'guestUsers': _users.where((user) => user.role == 'guest').length,
      'totalLogins': _users.fold(0, (sum, user) => sum + user.loginCount),
      'averageLoginsPerUser': _users.isNotEmpty 
          ? (_users.fold(0, (sum, user) => sum + user.loginCount) / _users.length).toStringAsFixed(1)
          : '0.0',
    };
  }

  // Get storage info
  String? get storagePath => _storagePath;
  
  // Get statistics
  Map<String, dynamic> getStatistics() {
    return _getUpdatedStatistics();
  }
}

