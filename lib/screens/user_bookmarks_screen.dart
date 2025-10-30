import 'package:flutter/material.dart';
import '../services/user_features_service.dart';

class UserBookmarksScreen extends StatefulWidget {
  const UserBookmarksScreen({super.key});

  @override
  State<UserBookmarksScreen> createState() => _UserBookmarksScreenState();
}

class _UserBookmarksScreenState extends State<UserBookmarksScreen> {
  final UserFeaturesService _userService = UserFeaturesService();
  List<Map<String, dynamic>> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final bookmarks = await _userService.getUserBookmarks(1); // TODO: Get current user ID
      setState(() {
        _bookmarks = bookmarks;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải đánh dấu: $e')),
        );
      }
    }
  }

  Future<void> _removeBookmark(int bookmarkId) async {
    try {
      final result = await _userService.removeBookmark(bookmarkId);
      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa đánh dấu')),
          );
        }
        _loadBookmarks(); // Refresh list
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
          SnackBar(content: Text('Lỗi xóa đánh dấu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài Đọc Đã Đánh Dấu'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarks.isEmpty
              ? const Center(child: Text('Chưa có bài đọc nào được đánh dấu.'))
              : ListView.builder(
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = _bookmarks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.bookmark, color: Colors.blue),
                        title: Text(bookmark['title'] ?? 'Không có tiêu đề'),
                        subtitle: Text(
                          '${bookmark['book_name']} Chương ${bookmark['chapter']} Câu ${bookmark['verse']}\n'
                          'Ngày: ${bookmark['created_at']}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.grey),
                          onPressed: () => _removeBookmark(bookmark['id']),
                        ),
                        onTap: () {
                          // Optionally navigate to the book/chapter/verse detail screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Xem chi tiết đánh dấu: ${bookmark['title']}')),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

