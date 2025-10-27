import 'package:flutter/material.dart';
import 'manage_scriptures.dart';
import 'manage_categories.dart';
import 'manage_audios.dart';
import 'manage_authors.dart';
import 'manage_glossary.dart';
import 'manage_timetable.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_AdminItem> items = [
      _AdminItem(
        title: 'Quản lý Bài đọc',
        icon: Icons.menu_book,
        page: const ManageScriptureScreen(),
      ),
      _AdminItem(
        title: 'Quản lý Danh mục',
        icon: Icons.category,
        page: const ManageCategoryScreen(),
      ),
      _AdminItem(
        title: 'Quản lý Bài nghe',
        icon: Icons.audiotrack,
        page: const ManageAudioScreen(),
      ),
      _AdminItem(
        title: 'Quản lý Tác giả',
        icon: Icons.person,
        page: const ManageAuthorScreen(),
      ),
      _AdminItem(
        title: 'Quản lý Từ điển',
        icon: Icons.book,
        page: const ManageGlossaryScreen(),
      ),
      _AdminItem(
        title: 'Quản lý Lịch tụng',
        icon: Icons.schedule,
        page: const ManageTimetableScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng điều khiển Quản trị'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item.page),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, size: 48, color: Colors.blue),
                    const SizedBox(height: 12),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AdminItem {
  final String title;
  final IconData icon;
  final Widget page;

  const _AdminItem({
    required this.title,
    required this.icon,
    required this.page,
  });
}
