import 'package:flutter/material.dart';
import '../models/video_model.dart';
import 'video_player_screen.dart';

class CategoryVideosScreen extends StatelessWidget {
  final String categoryName;
  final List<VideoModel> videos;

  const CategoryVideosScreen({
    super.key,
    required this.categoryName,
    required this.videos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: const Color.fromARGB(255, 255, 252, 221),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(video: video),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[300],
                        child: video.thumbnailUrl != null
                            ? Image.network(
                                video.thumbnailUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) {
                                  return const Center(
                                    child: Icon(
                                      Icons.play_circle_outline,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                            : const Center(
                                child: Icon(
                                  Icons.play_circle_outline,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      const Center(
                        child: Icon(
                          Icons.play_circle_filled,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                      if (video.duration != null)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              video.duration!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Title and description
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.titleVietnamese,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (video.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            video.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
