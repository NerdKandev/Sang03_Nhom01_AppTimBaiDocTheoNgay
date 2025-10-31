import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/video_model.dart';
import 'category_service.dart';

class VideoService {
  static final VideoService _instance = VideoService._internal();
  factory VideoService() => _instance;
  VideoService._internal();

  List<VideoModel> _videos = [];
  final CategoryService _categoryService = CategoryService();

  List<VideoModel> get videos => _videos;

  Future<void> initializeVideos() async {
    await _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/videos.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> videosData = data['videos'] ?? [];
      
      _videos = videosData
          .map((video) => VideoModel.fromMap(video))
          .toList();
    } catch (e) {
      print('Error loading videos: $e');
      _videos = [];
    }
  }

  List<VideoModel> getVideosByCategory(String categoryName) {
    return _videos.where((video) => video.category == categoryName).toList();
  }

  List<String> getCategoriesWithVideos() {
    final categories = _categoryService.getActiveCategoryNames();
    return categories.where((category) {
      return _videos.any((video) => video.category == category);
    }).toList();
  }
}
