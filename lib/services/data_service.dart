import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
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
    await _loadCategories(); // Load categories first
    await _loadSutras(); // Then load sutras (which will sync counts)
  }

  Future<void> _loadSutras() async {
    try {
      print('=== Loading Sutras ===');
      // Try to load from documents directory first (for saved data)
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/buddhist_sutras.json');
      
      print('Loading from assets: assets/data/buddhist_sutras.json');
      // Load from assets first to get latest data
      final String assetsJsonString = await rootBundle.loadString('assets/data/buddhist_sutras.json');
      print('Assets JSON loaded, length: ${assetsJsonString.length}');
      
      final Map<String, dynamic> assetsData = json.decode(assetsJsonString);
      final List<dynamic> assetsSutrasData = assetsData['sutras'] ?? [];
      print('Found ${assetsSutrasData.length} sutras in assets JSON');
      
      List<Sutra> assetsSutras = [];
      for (var i = 0; i < assetsSutrasData.length; i++) {
        try {
          final sutra = Sutra.fromMap(assetsSutrasData[i]);
          assetsSutras.add(sutra);
        } catch (e) {
          print('Error parsing sutra at index $i: $e');
          print('Sutra data: ${assetsSutrasData[i]}');
        }
      }
      print('Successfully parsed ${assetsSutras.length} sutras from assets');
      
      // Ensure all assets sutras have coverImage
      for (var i = 0; i < assetsSutras.length; i++) {
        if (assetsSutras[i].coverImage == null || assetsSutras[i].coverImage!.isEmpty) {
          assetsSutras[i] = Sutra(
            id: assetsSutras[i].id,
            title: assetsSutras[i].title,
            titleVietnamese: assetsSutras[i].titleVietnamese,
            titlePali: assetsSutras[i].titlePali,
            category: assetsSutras[i].category,
            description: assetsSutras[i].description,
            content: assetsSutras[i].content,
            fullContent: assetsSutras[i].fullContent,
            readingTime: assetsSutras[i].readingTime,
            difficulty: assetsSutras[i].difficulty,
            tags: assetsSutras[i].tags,
            dateAdded: assetsSutras[i].dateAdded,
            isFavorite: assetsSutras[i].isFavorite,
            readingCount: assetsSutras[i].readingCount,
            lastRead: assetsSutras[i].lastRead,
            hasAudio: assetsSutras[i].hasAudio,
            audioPath: assetsSutras[i].audioPath,
            audioUrl: assetsSutras[i].audioUrl,
            audioDuration: assetsSutras[i].audioDuration,
            isAudioEnabled: assetsSutras[i].isAudioEnabled,
            coverImage: 'assets/images/placeholder.jpg',
          );
        }
      }
      
      if (await file.exists()) {
        try {
          // Merge: load saved data and update with assets data
          final String savedJsonString = await file.readAsString();
          final Map<String, dynamic> savedData = json.decode(savedJsonString);
          final List<dynamic> savedSutrasData = savedData['sutras'] ?? [];
          
          // Create a map of saved sutras by ID for quick lookup
          Map<String, Sutra> savedSutrasMap = {};
          for (var sutraData in savedSutrasData) {
            try {
              final sutra = Sutra.fromMap(sutraData);
              savedSutrasMap[sutra.id] = sutra;
            } catch (e) {
              print('Error parsing saved sutra: $e');
            }
          }
          
          // Merge: use assets data as base (ALWAYS use all assets sutras), but preserve user data (favorites, reading count) from saved file
          // This ensures all sutras from assets are always included, even if they're not in saved file
          _sutras = assetsSutras.map((assetsSutra) {
            final savedSutra = savedSutrasMap[assetsSutra.id];
            if (savedSutra != null) {
              // Keep user data but update content from assets
              return Sutra(
                id: assetsSutra.id,
                title: assetsSutra.title,
                titleVietnamese: assetsSutra.titleVietnamese,
                titlePali: assetsSutra.titlePali,
                category: assetsSutra.category,
                description: assetsSutra.description,
                content: assetsSutra.content,
                fullContent: assetsSutra.fullContent,
                readingTime: assetsSutra.readingTime,
                difficulty: assetsSutra.difficulty,
                tags: assetsSutra.tags,
                dateAdded: assetsSutra.dateAdded,
                isFavorite: savedSutra.isFavorite, // Keep user preference
                readingCount: savedSutra.readingCount, // Keep reading count
                lastRead: savedSutra.lastRead, // Keep last read time
                hasAudio: assetsSutra.hasAudio,
                audioPath: assetsSutra.audioPath,
                audioUrl: assetsSutra.audioUrl,
                audioDuration: assetsSutra.audioDuration,
                isAudioEnabled: assetsSutra.isAudioEnabled,
                coverImage: assetsSutra.coverImage ?? 'assets/images/placeholder.jpg',
              );
            }
            // Return assets sutra as-is if not in saved file (new sutra from assets)
            return assetsSutra;
          }).toList();
          
          print('Loaded ${_sutras.length} sutras (merged from assets and saved data)');
          print('Assets has ${assetsSutras.length} sutras, Saved has ${savedSutrasMap.length} sutras');
          
          // Safety check: If merged result has fewer sutras than assets, something is wrong
          if (_sutras.length < assetsSutras.length) {
            print('WARNING: Merged result has fewer sutras (${_sutras.length}) than assets (${assetsSutras.length}). Using assets directly.');
            _sutras = assetsSutras;
            print('Corrected: Now have ${_sutras.length} sutras from assets');
          }
        } catch (e, stackTrace) {
          print('Error loading saved data: $e');
          print('Stack trace: $stackTrace');
          print('Falling back to assets only');
          // If saved file is corrupted, fall back to assets only
          _sutras = assetsSutras;
          print('Loaded ${_sutras.length} sutras from assets (saved file had errors)');
        }
      } else {
        // Load from assets if no file exists
        _sutras = assetsSutras;
        print('Loaded ${_sutras.length} sutras from assets (no saved file exists)');
      }
      
      // Final safety check
      if (_sutras.isEmpty) {
        print('WARNING: _sutras is empty after loading! This should not happen.');
        print('Trying to reload from assets one more time...');
        try {
          final String assetsJsonString = await rootBundle.loadString('assets/data/buddhist_sutras.json');
          final Map<String, dynamic> assetsData = json.decode(assetsJsonString);
          final List<dynamic> assetsSutrasData = assetsData['sutras'] ?? [];
          _sutras = assetsSutrasData.map((sutra) => Sutra.fromMap(sutra)).toList();
          print('Reloaded ${_sutras.length} sutras from assets');
        } catch (e) {
          print('Final reload failed: $e');
        }
      }
      
      print('=== Final Result: ${_sutras.length} sutras loaded ===');
      for (var sutra in _sutras) {
        print('  - ${sutra.id}: ${sutra.titleVietnamese} [${sutra.category}]');
      }
      
      // Debug: Check categories
      final categories = _sutras.map((s) => s.category).toSet().toList();
      print('=== Categories found: $categories ===');
      
      // Calculate sutra counts by category name
      Map<String, int> categoryCounts = {};
      for (var cat in categories) {
        final count = _sutras.where((s) => s.category == cat).length;
        categoryCounts[cat] = count;
        print('  - $cat: $count sutras');
      }
      
      // Sync sutra counts to CategoryService
      await _categoryService.syncSutraCounts(categoryCounts);
    } catch (e, stackTrace) {
      print('=== ERROR Loading Sutras ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      print('Falling back to assets data directly...');
      
      // Try to load from assets one more time as fallback
      try {
        final String assetsJsonString = await rootBundle.loadString('assets/data/buddhist_sutras.json');
        final Map<String, dynamic> assetsData = json.decode(assetsJsonString);
        final List<dynamic> assetsSutrasData = assetsData['sutras'] ?? [];
        List<Sutra> assetsSutras = [];
        for (var sutraData in assetsSutrasData) {
          try {
            assetsSutras.add(Sutra.fromMap(sutraData));
          } catch (e) {
            print('Error parsing sutra in fallback: $e');
          }
        }
        _sutras = assetsSutras;
        print('Fallback loaded ${_sutras.length} sutras from assets');
        
        // Sync sutra counts even in fallback
        final categories = _sutras.map((s) => s.category).toSet().toList();
        Map<String, int> categoryCounts = {};
        for (var cat in categories) {
          categoryCounts[cat] = _sutras.where((s) => s.category == cat).length;
        }
        await _categoryService.syncSutraCounts(categoryCounts);
      } catch (fallbackError) {
        print('Fallback also failed: $fallbackError');
        // Last resort: use minimal fallback data
        _sutras = _getFallbackSutras();
        print('Using minimal fallback data with ${_sutras.length} sutras');
        
        // Sync counts even with fallback data
        final categories = _sutras.map((s) => s.category).toSet().toList();
        Map<String, int> categoryCounts = {};
        for (var cat in categories) {
          categoryCounts[cat] = _sutras.where((s) => s.category == cat).length;
        }
        await _categoryService.syncSutraCounts(categoryCounts);
      }
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
        category: 'Kinh tịnh độ',
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
        coverImage: 'assets/images/placeholder.jpg',
      ),
    ];
  }


  // Get sutras by category
  List<Sutra> getSutrasByCategory(String category) {
    final result = _sutras.where((sutra) => sutra.category == category).toList();
    print('=== getSutrasByCategory("$category") ===');
    print('Total sutras: ${_sutras.length}');
    print('Found: ${result.length} sutras');
    if (result.isEmpty) {
      print('Available categories in sutras: ${_sutras.map((s) => s.category).toSet().toList()}');
    } else {
      print('Sutras found: ${result.map((s) => '${s.id}: ${s.titleVietnamese}').join(", ")}');
    }
    return result;
  }

  // Get favorite sutras
  List<Sutra> getFavoriteSutras() {
    return _sutras.where((sutra) => sutra.isFavorite).toList();
  }

  // Search sutras
  List<Sutra> searchSutras(String query) {
    if (query.isEmpty) return _sutras;
    
    return _sutras.where((sutra) =>
        sutra.title.toLowerCase().contains(query.toLowerCase()) ||
        sutra.titleVietnamese.toLowerCase().contains(query.toLowerCase()) ||
        sutra.description.toLowerCase().contains(query.toLowerCase()) ||
        sutra.content.toLowerCase().contains(query.toLowerCase()) ||
        sutra.author.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Get all categories
  List<String> getCategoryNames() {
    return _categoryService.getActiveCategoryNames();
  }

  // Toggle favorite
  Future<void> toggleFavorite(String sutraId) async {
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
        coverImage: _sutras[index].coverImage ?? 'assets/images/placeholder.jpg',
      );
      await _saveSutras();
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
        coverImage: _sutras[index].coverImage ?? 'assets/images/placeholder.jpg',
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

  // Add new sutra
  Future<void> addSutra(Sutra sutra) async {
    _sutras.add(sutra);
    await _saveSutras();
  }

  // Update sutra
  Future<void> updateSutra(Sutra updatedSutra) async {
    final index = _sutras.indexWhere((sutra) => sutra.id == updatedSutra.id);
    if (index != -1) {
      _sutras[index] = updatedSutra;
      await _saveSutras();
    }
  }

  // Delete sutra
  Future<void> deleteSutra(String sutraId) async {
    _sutras.removeWhere((sutra) => sutra.id == sutraId);
    await _saveSutras();
  }

  // Save sutras to JSON file
  Future<void> _saveSutras() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/buddhist_sutras.json');
      
      final Map<String, dynamic> data = {
        'sutras': _sutras.map((sutra) => sutra.toMap()).toList(),
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      await file.writeAsString(json.encode(data));
      print('Sutras saved successfully to: ${file.path}');
    } catch (e) {
      print('Error saving sutras: $e');
    }
  }

  // Reload sutras from assets (useful when assets are updated)
  Future<void> reloadFromAssets() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/buddhist_sutras.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> sutrasData = data['sutras'] ?? [];
      
      // Create a map of current sutras by ID to preserve user data
      Map<String, Sutra> currentSutrasMap = {};
      for (var sutra in _sutras) {
        currentSutrasMap[sutra.id] = sutra;
      }
      
      // Load new sutras from assets
      List<Sutra> newSutras = sutrasData.map((sutra) => Sutra.fromMap(sutra)).toList();
      
      // Merge: use new data from assets but preserve user data (favorites, reading count)
      _sutras = newSutras.map((newSutra) {
        final currentSutra = currentSutrasMap[newSutra.id];
        if (currentSutra != null) {
          // Keep user data but update content from assets
          return Sutra(
            id: newSutra.id,
            title: newSutra.title,
            titleVietnamese: newSutra.titleVietnamese,
            titlePali: newSutra.titlePali,
            category: newSutra.category,
            description: newSutra.description,
            content: newSutra.content,
            fullContent: newSutra.fullContent,
            readingTime: newSutra.readingTime,
            difficulty: newSutra.difficulty,
            tags: newSutra.tags,
            dateAdded: newSutra.dateAdded,
            isFavorite: currentSutra.isFavorite, // Keep user preference
            readingCount: currentSutra.readingCount, // Keep reading count
            lastRead: currentSutra.lastRead, // Keep last read time
            hasAudio: newSutra.hasAudio,
            audioPath: newSutra.audioPath,
            audioUrl: newSutra.audioUrl,
            audioDuration: newSutra.audioDuration,
            isAudioEnabled: newSutra.isAudioEnabled,
            coverImage: newSutra.coverImage ?? 'assets/images/placeholder.jpg',
          );
        }
        return newSutra;
      }).toList();
      
      // Ensure all sutras have coverImage
      for (var i = 0; i < _sutras.length; i++) {
        if (_sutras[i].coverImage == null || _sutras[i].coverImage!.isEmpty) {
          _sutras[i] = Sutra(
            id: _sutras[i].id,
            title: _sutras[i].title,
            titleVietnamese: _sutras[i].titleVietnamese,
            titlePali: _sutras[i].titlePali,
            category: _sutras[i].category,
            description: _sutras[i].description,
            content: _sutras[i].content,
            fullContent: _sutras[i].fullContent,
            readingTime: _sutras[i].readingTime,
            difficulty: _sutras[i].difficulty,
            tags: _sutras[i].tags,
            dateAdded: _sutras[i].dateAdded,
            isFavorite: _sutras[i].isFavorite,
            readingCount: _sutras[i].readingCount,
            lastRead: _sutras[i].lastRead,
            hasAudio: _sutras[i].hasAudio,
            audioPath: _sutras[i].audioPath,
            audioUrl: _sutras[i].audioUrl,
            audioDuration: _sutras[i].audioDuration,
            isAudioEnabled: _sutras[i].isAudioEnabled,
            coverImage: 'assets/images/placeholder.jpg',
          );
        }
      }
      
      // Save merged data
      await _saveSutras();
      print('Reloaded ${_sutras.length} sutras from assets');
    } catch (e) {
      print('Error reloading sutras from assets: $e');
    }
  }
}