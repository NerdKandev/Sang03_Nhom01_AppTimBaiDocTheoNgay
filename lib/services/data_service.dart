import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/sutra.dart';
import '../models/category_model.dart';
import 'category_service.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  List<Sutra> _sutras = [];
  final CategoryService _categoryService = CategoryService();

  List<Sutra> get sutras => _sutras;
  List<CategoryModel> get categories => _categoryService.categories;

  Future<void> initializeData() async {
    await _loadSutras();
    await _loadCategories();
  }

  Future<void> _loadSutras() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/buddhist_sutras.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      
      final List<dynamic> sutrasData = data['sutras'] ?? [];
      _sutras = sutrasData.map((sutra) => Sutra.fromMap(sutra)).toList();
    } catch (e) {
      print('Error loading sutras: $e');
      // Fallback data
      _sutras = _getFallbackSutras();
    }
  }

  Future<void> _loadCategories() async {
    await _categoryService.initializeCategories();
  }

  List<Sutra> _getFallbackSutras() {
    return [
      Sutra(
        id: '1',
        title: 'Amitabha Sutra',
        titleVietnamese: 'Kinh A Di Đà',
        titlePali: 'Amitābha Sūtra',
        category: 'Tịnh Độ',
        description: 'Kinh dạy về cõi Tịnh Độ của Phật A Di Đà, giúp tâm được an lạc',
        content: 'Nam mô A Di Đà Phật. Nam mô A Di Đà Phật. Nam mô A Di Đà Phật...',
        fullContent: 'Nam mô A Di Đà Phật. Nam mô A Di Đà Phật. Nam mô A Di Đà Phật. Nam mô A Di Đà Phật. Nam mô A Di Đà Phật. Nam mô A Di Đà Phật. Nam mô A Di Đà Phật. Nam mô A Di Đà Phật. Nam mô A Di Đà Phật. Nam mô A Di Đà Phật.',
        readingTime: '15 phút',
        difficulty: 'Dễ',
        tags: ['Tịnh Độ', 'A Di Đà', 'Cầu siêu', 'An lạc'],
        dateAdded: '2024-01-01',
        isFavorite: false,
        readingCount: 0,
        lastRead: null,
      ),
    ];
  }


  // Get sutras by category
  List<Sutra> getSutrasByCategory(String category) {
    return _sutras.where((sutra) => sutra.category == category).toList();
  }

  // Search sutras
  List<Sutra> searchSutras(String query) {
    if (query.isEmpty) return _sutras;
    
    return _sutras.where((sutra) =>
        sutra.title.toLowerCase().contains(query.toLowerCase()) ||
        sutra.titleVietnamese.toLowerCase().contains(query.toLowerCase()) ||
        sutra.description.toLowerCase().contains(query.toLowerCase()) ||
        sutra.content.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Get all categories
  List<String> getCategoryNames() {
    return _categoryService.getActiveCategoryNames();
  }

  // Toggle favorite
  void toggleFavorite(String sutraId) {
    final index = _sutras.indexWhere((sutra) => sutra.id == sutraId);
    if (index != -1) {
      _sutras[index] = Sutra(
        id: _sutras[index].id,
        title: _sutras[index].title,
        titleVietnamese: _sutras[index].titleVietnamese,
        titlePali: _sutras[index].titlePali,
        category: _sutras[index].category,
        description: _sutras[index].description,
        content: _sutras[index].content,
        fullContent: _sutras[index].fullContent,
        readingTime: _sutras[index].readingTime,
        difficulty: _sutras[index].difficulty,
        tags: _sutras[index].tags,
        dateAdded: _sutras[index].dateAdded,
        isFavorite: !_sutras[index].isFavorite,
        readingCount: _sutras[index].readingCount,
        lastRead: _sutras[index].lastRead,
        hasAudio: _sutras[index].hasAudio,
        audioPath: _sutras[index].audioPath,
        audioUrl: _sutras[index].audioUrl,
        audioDuration: _sutras[index].audioDuration,
        isAudioEnabled: _sutras[index].isAudioEnabled,
      );
    }
  }

  // Update reading count
  void updateReadingCount(String sutraId) {
    final index = _sutras.indexWhere((sutra) => sutra.id == sutraId);
    if (index != -1) {
      _sutras[index] = Sutra(
        id: _sutras[index].id,
        title: _sutras[index].title,
        titleVietnamese: _sutras[index].titleVietnamese,
        titlePali: _sutras[index].titlePali,
        category: _sutras[index].category,
        description: _sutras[index].description,
        content: _sutras[index].content,
        fullContent: _sutras[index].fullContent,
        readingTime: _sutras[index].readingTime,
        difficulty: _sutras[index].difficulty,
        tags: _sutras[index].tags,
        dateAdded: _sutras[index].dateAdded,
        isFavorite: _sutras[index].isFavorite,
        readingCount: _sutras[index].readingCount + 1,
        lastRead: DateTime.now().toIso8601String(),
        hasAudio: _sutras[index].hasAudio,
        audioPath: _sutras[index].audioPath,
        audioUrl: _sutras[index].audioUrl,
        audioDuration: _sutras[index].audioDuration,
        isAudioEnabled: _sutras[index].isAudioEnabled,
      );
    }
  }

  // Get recently read sutras
  List<Sutra> getRecentlyReadSutras() {
    return _sutras.where((sutra) => sutra.readingCount > 0).toList();
  }

  // Get reading stats
  Map<String, int> getReadingStats() {
    return {
      'totalSutras': _sutras.length,
      'totalReadings': _sutras.fold(0, (sum, sutra) => sum + sutra.readingCount),
      'favoriteCount': _sutras.where((sutra) => sutra.isFavorite).length,
      'recentlyReadCount': _sutras.where((sutra) => sutra.readingCount > 0).length,
    };
  }
}