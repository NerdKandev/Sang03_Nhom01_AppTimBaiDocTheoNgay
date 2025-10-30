import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({super.key});

  @override
  State<AdminStatsScreen> createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final statsData = await _adminService.getStatistics();
      setState(() {
        _stats = statsData;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải thống kê: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống Kê Hệ Thống'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildStatCard(
                    context,
                    'Tổng Số Người Dùng',
                    _stats['total_users']?.toString() ?? 'N/A',
                    Icons.people,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    context,
                    'Người Dùng Hoạt Động',
                    _stats['active_users']?.toString() ?? 'N/A',
                    Icons.person_add_alt_1,
                    Colors.green,
                  ),
                  _buildStatCard(
                    context,
                    'Người Dùng Mới Hôm Nay',
                    _stats['new_users_today']?.toString() ?? 'N/A',
                    Icons.person_add,
                    Colors.teal,
                  ),
                  _buildStatCard(
                    context,
                    'Tỷ Lệ Hoạt Động',
                    '${_stats['activity_rate']?.toString() ?? 'N/A'}%',
                    Icons.trending_up,
                    Colors.purple,
                  ),
                  const Divider(height: 32),
                  _buildStatCard(
                    context,
                    'Tổng Số Sách',
                    _stats['total_books']?.toString() ?? 'N/A',
                    Icons.menu_book,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    context,
                    'Sách Cựu Ước',
                    _stats['old_testament_books']?.toString() ?? 'N/A',
                    Icons.book,
                    Colors.brown,
                  ),
                  _buildStatCard(
                    context,
                    'Sách Tân Ước',
                    _stats['new_testament_books']?.toString() ?? 'N/A',
                    Icons.auto_stories,
                    Colors.indigo,
                  ),
                  const Divider(height: 32),
                  _buildStatCard(
                    context,
                    'Tổng Số Bài Đọc',
                    _stats['total_readings']?.toString() ?? 'N/A',
                    Icons.library_books,
                    Colors.red,
                  ),
                  _buildStatCard(
                    context,
                    'Tổng Số Yêu Thích',
                    _stats['total_favorites']?.toString() ?? 'N/A',
                    Icons.favorite,
                    Colors.pink,
                  ),
                  _buildStatCard(
                    context,
                    'Tổng Số Đánh Dấu',
                    _stats['total_bookmarks']?.toString() ?? 'N/A',
                    Icons.bookmark,
                    Colors.deepPurple,
                  ),
                  _buildStatCard(
                    context,
                    'Tổng Số Ghi Chú',
                    _stats['total_notes']?.toString() ?? 'N/A',
                    Icons.note,
                    Colors.lime,
                  ),
                  _buildStatCard(
                    context,
                    'Tổng Tiến Độ Đọc',
                    _stats['total_progress']?.toString() ?? 'N/A',
                    Icons.track_changes,
                    Colors.cyan,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

