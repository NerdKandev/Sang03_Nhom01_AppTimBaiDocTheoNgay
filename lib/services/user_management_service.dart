import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_model.dart';

class UserManagementService {
  static final UserManagementService _instance = UserManagementService._internal();
  factory UserManagementService() => _instance;
  UserManagementService._internal();

  List<UserModel> _users = [];
  Map<String, dynamic> _statistics = {};

  List<UserModel> get users => _users;
  Map<String, dynamic> get statistics => _statistics;

  Future<void> initializeUsers() async {
    await _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/users.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      
      final List<dynamic> usersData = data['users'] ?? [];
      _users = usersData.map((user) => UserModel.fromMap(user)).toList();
      
      _statistics = data['statistics'] ?? {};
    } catch (e) {
      print('Error loading users: $e');
      _users = _getFallbackUsers();
      _statistics = _getFallbackStatistics();
    }
  }

  List<UserModel> _getFallbackUsers() {
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

  Map<String, dynamic> _getFallbackStatistics() {
    return {
      'totalUsers': 1,
      'activeUsers': 1,
      'lockedUsers': 0,
      'adminUsers': 1,
      'regularUsers': 0,
    };
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

  // Toggle user lock status
  Future<void> toggleUserLock(String userId) async {
    final index = _users.indexWhere((user) => user.id == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(
        isLocked: !_users[index].isLocked,
      );
      await _saveUsers();
    }
  }

  // Toggle user active status
  Future<void> toggleUserActive(String userId) async {
    final index = _users.indexWhere((user) => user.id == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(
        isActive: !_users[index].isActive,
      );
      await _saveUsers();
    }
  }

  // Update user information
  Future<void> updateUser(String userId, {
    String? fullName,
    String? email,
    String? phone,
    String? notes,
  }) async {
    final index = _users.indexWhere((user) => user.id == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(
        fullName: fullName,
        email: email,
        phone: phone,
        notes: notes,
      );
      await _saveUsers();
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    _users.removeWhere((user) => user.id == userId);
    await _saveUsers();
  }

  // Add new user
  Future<void> addUser(UserModel user) async {
    _users.add(user);
    await _saveUsers();
  }

  // Save users to file
  Future<void> _saveUsers() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/users.json');
      
      final Map<String, dynamic> data = {
        'users': _users.map((user) => user.toMap()).toList(),
        'statistics': _getUpdatedStatistics(),
      };
      
      await file.writeAsString(json.encode(data));
      print('Users saved successfully to: ${file.path}');
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

  // Get user by ID
  UserModel? getUserById(String userId) {
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
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

  // Update user login info
  Future<void> updateUserLogin(String userId) async {
    final index = _users.indexWhere((user) => user.id == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(
        lastLogin: DateTime.now().toIso8601String(),
        loginCount: _users[index].loginCount + 1,
      );
      await _saveUsers();
    }
  }
}
