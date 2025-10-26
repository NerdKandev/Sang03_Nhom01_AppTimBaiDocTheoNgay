import 'package:flutter/material.dart';
import '../services/user_features_service.dart';

class UserFavoritesScreen extends StatefulWidget {
  const UserFavoritesScreen({super.key});

  @override
  State<UserFavoritesScreen> createState() => _UserFavoritesScreenState();
}

class _UserFavoritesScreenState extends State<UserFavoritesScreen> {
  final UserFeaturesService _userService = UserFeaturesService();
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final favorites = await _userService.getUserFavorites(1); // TODO: Get current user ID
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải yêu thích: $e')),
        );
      }
    }
  }

  Future<void> _removeFavorite(int favoriteId) async {
    try {
      final result = await _userService.removeFavorite(1, favoriteId); // TODO: Get current user ID
      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa khỏi yêu thích')),
          );
        }
        _loadFavorites(); // Refresh list
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${result['message']}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xóa yêu thích: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài Đọc Yêu Thích'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const Center(child: Text('Chưa có bài đọc yêu thích nào.'))
              : ListView.builder(
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final favorite = _favorites[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.favorite, color: Colors.red),
                        title: Text(favorite['title'] ?? 'Không có tiêu đề'),
                        subtitle: Text(
                          '${favorite['book_name']} Chương ${favorite['chapter']} Câu ${favorite['verses']}\n'
                          'Ngày: ${favorite['date']}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.grey),
                          onPressed: () => _removeFavorite(favorite['id']),
                        ),
                        onTap: () {
                          // Optionally navigate to the reading detail screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Xem chi tiết bài đọc: ${favorite['title']}')),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

