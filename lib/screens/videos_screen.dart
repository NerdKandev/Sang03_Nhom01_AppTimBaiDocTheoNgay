import 'package:flutter/material.dart';
import '../services/video_service.dart';
import '../services/category_service.dart';
import 'category_videos_screen.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  final VideoService _videoService = VideoService();
  final CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _videoService.initializeVideos();
    _categoryService.initializeCategories();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesWithVideos = _videoService.getCategoriesWithVideos();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📹 Video'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: const Color.fromARGB(255, 255, 252, 221),
      ),
      body: categoriesWithVideos.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_library_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có video nào',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categoriesWithVideos.length,
              itemBuilder: (context, index) {
                final category = categoriesWithVideos[index];
                final videos = _videoService.getVideosByCategory(category);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(
                      Icons.play_circle_outline,
                      size: 40,
                      color: Color(0xFF2196F3),
                    ),
                    title: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${videos.length} video',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryVideosScreen(
                            categoryName: category,
                            videos: videos,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
