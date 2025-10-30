import 'package:flutter/material.dart';
import '../services/user_storage_service.dart';
import '../models/user_model.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final UserStorageService _userService = UserStorageService();
  String _searchQuery = '';
  String _selectedFilter = 'Tất cả';
  String _selectedSort = 'Tên A-Z';

  @override
  void initState() {
    super.initState();
    _userService.initializeUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _userService.initializeUsers();
              });
            },
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Tìm kiếm người dùng...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Filter and Sort Row
                Row(
                  children: [
                    // Filter Dropdown
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedFilter,
                        decoration: const InputDecoration(
                          labelText: 'Lọc theo',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Tất cả', child: Text('Tất cả')),
                          DropdownMenuItem(value: 'Admin', child: Text('Quản trị viên')),
                          DropdownMenuItem(value: 'user', child: Text('Người dùng')),
                          DropdownMenuItem(value: 'Hoạt động', child: Text('Đang hoạt động')),
                          DropdownMenuItem(value: 'Bị khóa', child: Text('Bị khóa')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedFilter = value!;
                          });
                        },
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Sort Dropdown
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSort,
                        decoration: const InputDecoration(
                          labelText: 'Sắp xếp',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Tên A-Z', child: Text('Tên A-Z')),
                          DropdownMenuItem(value: 'Tên Z-A', child: Text('Tên Z-A')),
                          DropdownMenuItem(value: 'Mới nhất', child: Text('Mới nhất')),
                          DropdownMenuItem(value: 'Cũ nhất', child: Text('Cũ nhất')),
                          DropdownMenuItem(value: 'Đăng nhập nhiều', child: Text('Đăng nhập nhiều')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedSort = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Statistics Cards
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Tổng người dùng',
                    _userService.users.length.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Đang hoạt động',
                    _userService.getActiveUsers().length.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Bị khóa',
                    _userService.getLockedUsers().length.toString(),
                    Icons.lock,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ),
          
          // Users List
          Expanded(
            child: _buildUsersList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.person_add, color: Colors.white),
        tooltip: 'Thêm người dùng',
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    List<UserModel> filteredUsers = _getFilteredUsers();
    
    if (filteredUsers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Không tìm thấy người dùng nào',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRoleColor(user.role),
              child: Text(
                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              user.fullName.isNotEmpty ? user.fullName : user.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('@${user.username} • ${user.email}'),
                Text('${_getRoleName(user.role)} • ${user.phone}'),
                if (user.lastLogin != null)
                  Text('Đăng nhập cuối: ${_formatDate(user.lastLogin!)}'),
                Row(
                  children: [
                    if (user.isActive)
                      _buildStatusChip('Hoạt động', Colors.green)
                    else
                      _buildStatusChip('Không hoạt động', Colors.grey),
                    const SizedBox(width: 8),
                    if (user.isLocked)
                      _buildStatusChip('Bị khóa', Colors.red)
                    else
                      _buildStatusChip('Mở khóa', Colors.green),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleUserAction(value, user),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 20),
                      SizedBox(width: 8),
                      Text('Xem chi tiết'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Chỉnh sửa'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: user.isLocked ? 'unlock' : 'lock',
                  child: Row(
                    children: [
                      Icon(
                        user.isLocked ? Icons.lock_open : Icons.lock,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(user.isLocked ? 'Mở khóa' : 'Khóa tài khoản'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: user.isActive ? 'deactivate' : 'activate',
                  child: Row(
                    children: [
                      Icon(
                        user.isActive ? Icons.person_off : Icons.person,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(user.isActive ? 'Vô hiệu hóa' : 'Kích hoạt'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Xóa', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<UserModel> _getFilteredUsers() {
    List<UserModel> users = _userService.users;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      users = _userService.searchUsers(_searchQuery);
    }

    // Apply role/status filter
    switch (_selectedFilter) {
      case 'Admin':
        users = users.where((user) => user.role == 'admin').toList();
        break;
      case 'user':
        users = users.where((user) => user.role == 'user').toList();
        break;
      case 'Hoạt động':
        users = users.where((user) => user.isActive && !user.isLocked).toList();
        break;
      case 'Bị khóa':
        users = users.where((user) => user.isLocked).toList();
        break;
    }

    // Apply sorting
    switch (_selectedSort) {
      case 'Tên A-Z':
        users.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
      case 'Tên Z-A':
        users.sort((a, b) => b.fullName.compareTo(a.fullName));
        break;
      case 'Mới nhất':
        users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Cũ nhất':
        users.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'Đăng nhập nhiều':
        users.sort((a, b) => b.loginCount.compareTo(a.loginCount));
        break;
    }

    return users;
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'user':
        return Colors.blue;
      case 'guest':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getRoleName(String role) {
    switch (role) {
      case 'admin':
        return 'Quản trị viên';
      case 'user':
        return 'Người dùng';
      case 'guest':
        return 'Khách';
      default:
        return 'Không xác định';
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Không xác định';
    }
  }

  void _handleUserAction(String action, UserModel user) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'lock':
      case 'unlock':
        _toggleUserLock(user);
        break;
      case 'activate':
      case 'deactivate':
        _toggleUserActive(user);
        break;
      case 'delete':
        _showDeleteConfirmation(user);
        break;
    }
  }

  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chi tiết người dùng'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Tên đầy đủ', user.fullName),
              _buildDetailRow('Tên đăng nhập', user.username),
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Số điện thoại', user.phone),
              _buildDetailRow('Vai trò', _getRoleName(user.role)),
              _buildDetailRow('Trạng thái', user.isActive ? 'Hoạt động' : 'Không hoạt động'),
              _buildDetailRow('Khóa tài khoản', user.isLocked ? 'Có' : 'Không'),
              _buildDetailRow('Ngày tạo', _formatDate(user.createdAt)),
              if (user.lastLogin != null)
                _buildDetailRow('Đăng nhập cuối', _formatDate(user.lastLogin!)),
              _buildDetailRow('Số lần đăng nhập', user.loginCount.toString()),
              if (user.notes.isNotEmpty)
                _buildDetailRow('Ghi chú', user.notes),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(UserModel user) {
    final nameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone);
    final notesController = TextEditingController(text: user.notes);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa người dùng'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên đầy đủ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedUser = user.copyWith(
                fullName: nameController.text,
                email: emailController.text,
                phone: phoneController.text,
                notes: notesController.text,
              );
              
              final success = await _userService.updateUser(user.id, updatedUser);
              if (success) {
                setState(() {});
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã cập nhật thông tin người dùng')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lỗi khi cập nhật thông tin')),
                );
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    // TODO: Implement add user dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng thêm người dùng đang phát triển')),
    );
  }

  void _toggleUserLock(UserModel user) async {
    final success = await _userService.toggleUserLock(user.id);
    if (success) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            user.isLocked ? 'Đã mở khóa tài khoản' : 'Đã khóa tài khoản',
          ),
        ),
      );
    }
  }

  void _toggleUserActive(UserModel user) async {
    final success = await _userService.toggleUserActive(user.id);
    if (success) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            user.isActive ? 'Đã vô hiệu hóa tài khoản' : 'Đã kích hoạt tài khoản',
          ),
        ),
      );
    }
  }

  void _showDeleteConfirmation(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa người dùng "${user.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await _userService.deleteUser(user.id);
              if (success) {
                setState(() {});
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa người dùng')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lỗi khi xóa người dùng')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}