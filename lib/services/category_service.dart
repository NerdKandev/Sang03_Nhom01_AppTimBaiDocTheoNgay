import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/category_model.dart';

class CategoryService {
  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal();

  List<CategoryModel> _categories = [];
  Map<String, dynamic> _statistics = {};

  List<CategoryModel> get categories => _categories;
  Map<String, dynamic> get statistics => _statistics;

  Future<void> initializeCategories() async {
    await _loadCategories();
  }

  // Force reload from assets and replace or merge with existing categories
  Future<void> reloadFromAssets({bool replace = false}) async {
    try {
      // Load categories from assets
      final String jsonString = await rootBundle.loadString('assets/data/categories.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> assetCategoriesData = data['categories'] ?? [];
      final assetCategoriesList = assetCategoriesData.map((category) => CategoryModel.fromMap(category)).toList();
      
      if (replace) {
        // Replace completely
        _categories = assetCategoriesList;
      } else {
        // Merge: Remove old categories not in assets, add new ones from assets
        final assetCategoryNames = assetCategoriesList.map((cat) => cat.name).toSet();
        
        // Remove categories that no longer exist in assets
        _categories.removeWhere((cat) => !assetCategoryNames.contains(cat.name));
        
        // Add new categories from assets that don't exist in current list
        for (var assetCat in assetCategoriesList) {
          if (!_categories.any((cat) => cat.name == assetCat.name)) {
            _categories.add(assetCat);
            print('Added new category from assets: ${assetCat.name}');
          }
        }
      }
      
      // Update statistics and save
      await _saveCategories();
      print('Reloaded ${_categories.length} categories from assets (replace: $replace)');
    } catch (e) {
      print('Error reloading from assets: $e');
      rethrow;
    }
  }

  Future<void> _loadCategories() async {
    try {
      // Try to load from documents directory first
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/categories.json');
      
      if (await file.exists()) {
        final String jsonString = await file.readAsString();
        final Map<String, dynamic> data = json.decode(jsonString);
        final List<dynamic> categoriesData = data['categories'] ?? [];
        _categories = categoriesData.map((category) => CategoryModel.fromMap(category)).toList();
        _statistics = data['statistics'] ?? {};
        print('Loaded ${_categories.length} categories from: ${file.path}');
        
        // Check if we need to merge with assets (compare with assets to see if there are new categories)
        await _mergeWithAssetsIfNeeded();
      } else {
        // Load from assets if no file exists
        await _loadFromAssets();
        await _saveCategories();
        print('Created new categories file with assets data');
      }
    } catch (e) {
      print('Error loading categories: $e');
      await _loadFromAssets();
    }
  }
  
  Future<void> _mergeWithAssetsIfNeeded() async {
    try {
      // Load categories from assets
      final String jsonString = await rootBundle.loadString('assets/data/categories.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> assetCategoriesData = data['categories'] ?? [];
      final assetCategories = assetCategoriesData.map((category) => CategoryModel.fromMap(category)).toList();
      
      // Get list of category names from assets
      final assetCategoryNames = assetCategories.map((cat) => cat.name).toSet();
      
      // Remove categories that no longer exist in assets (cleanup old categories)
      bool hasChanges = false;
      _categories.removeWhere((cat) {
        if (!assetCategoryNames.contains(cat.name)) {
          print('Removing old category not in assets: ${cat.name}');
          hasChanges = true;
          return true;
        }
        return false;
      });
      
      // Add new categories from assets that don't exist in current list
      for (var assetCat in assetCategories) {
        if (!_categories.any((cat) => cat.name == assetCat.name)) {
          // Add new category from assets
          _categories.add(assetCat);
          hasChanges = true;
          print('Added new category from assets: ${assetCat.name}');
        }
      }
      
      if (hasChanges) {
        await _saveCategories();
        print('Synced categories with assets (removed old, added new)');
      }
    } catch (e) {
      print('Error merging with assets: $e');
    }
  }
  

  Future<void> _loadFromAssets() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/categories.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> categoriesData = data['categories'] ?? [];
      _categories = categoriesData.map((category) => CategoryModel.fromMap(category)).toList();
      _statistics = data['statistics'] ?? {};
      print('Loaded ${_categories.length} categories from assets');
    } catch (e) {
      print('Error loading categories from assets: $e');
      _categories = _getDefaultCategories();
      _statistics = _getDefaultStatistics();
    }
  }

  List<CategoryModel> _getDefaultCategories() {
    return [
      CategoryModel(
        id: '1',
        name: 'Kinh tụng hàng ngày',
        description: 'Các kinh được tụng đọc hàng ngày trong tu tập',
        color: '#FF6B6B',
        icon: 'lotus',
        isActive: true,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        sutraCount: 0,
        order: 1,
      ),
      CategoryModel(
        id: '2',
        name: 'Kinh cầu siêu',
        description: 'Các kinh dùng để cầu siêu, hồi hướng công đức cho người đã khuất',
        color: '#4ECDC4',
        icon: 'book',
        isActive: true,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        sutraCount: 0,
        order: 2,
      ),
      CategoryModel(
        id: '3',
        name: 'Kinh sám hối',
        description: 'Các kinh về sám hối, sửa đổi lỗi lầm và thanh tịnh tâm ý',
        color: '#45B7D1',
        icon: 'library',
        isActive: true,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        sutraCount: 0,
        order: 3,
      ),
      CategoryModel(
        id: '4',
        name: 'Kinh cầu an',
        description: 'Các kinh dùng để cầu an, cầu phúc cho người sống',
        color: '#96CEB4',
        icon: 'category',
        isActive: true,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        sutraCount: 0,
        order: 4,
      ),
      CategoryModel(
        id: '5',
        name: 'Kinh tịnh độ',
        description: 'Các kinh về cõi Tịnh Độ và Phật A Di Đà',
        color: '#FFEAA7',
        icon: 'lotus',
        isActive: true,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        sutraCount: 0,
        order: 5,
      ),
    ];
  }

  Map<String, dynamic> _getDefaultStatistics() {
    return {
      'totalCategories': 5,
      'activeCategories': 5,
      'inactiveCategories': 0,
      'totalSutras': 0,
      'averageSutrasPerCategory': 0.0,
    };
  }

  // Get active categories
  List<CategoryModel> getActiveCategories() {
    return _categories.where((category) => category.isActive).toList();
  }

  // Get category by ID
  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get category by name
  CategoryModel? getCategoryByName(String name) {
    try {
      return _categories.firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }

  // Search categories
  List<CategoryModel> searchCategories(String query) {
    if (query.isEmpty) return _categories;
    
    return _categories.where((category) =>
        category.name.toLowerCase().contains(query.toLowerCase()) ||
        category.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Add new category
  Future<bool> addCategory(CategoryModel category) async {
    try {
      // Check if name already exists
      if (_categories.any((c) => c.name == category.name)) {
        print('Category name already exists: ${category.name}');
        return false;
      }

      _categories.add(category);
      await _saveCategories();
      print('Category added successfully: ${category.name}');
      return true;
    } catch (e) {
      print('Error adding category: $e');
      return false;
    }
  }

  // Update category
  Future<bool> updateCategory(String id, CategoryModel updatedCategory) async {
    try {
      final index = _categories.indexWhere((category) => category.id == id);
      if (index != -1) {
        _categories[index] = updatedCategory;
        await _saveCategories();
        print('Category updated successfully: ${updatedCategory.name}');
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating category: $e');
      return false;
    }
  }

  // Delete category
  Future<bool> deleteCategory(String id) async {
    try {
      _categories.removeWhere((category) => category.id == id);
      await _saveCategories();
      print('Category deleted successfully: $id');
      return true;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }

  // Toggle category active status
  Future<bool> toggleCategoryActive(String id) async {
    try {
      final index = _categories.indexWhere((category) => category.id == id);
      if (index != -1) {
        _categories[index] = _categories[index].copyWith(
          isActive: !_categories[index].isActive,
          updatedAt: DateTime.now().toIso8601String(),
        );
        await _saveCategories();
        print('Category active toggled: ${_categories[index].name}');
        return true;
      }
      return false;
    } catch (e) {
      print('Error toggling category active: $e');
      return false;
    }
  }

  // Update sutra count for category
  Future<bool> updateSutraCount(String categoryId, int count) async {
    try {
      final index = _categories.indexWhere((category) => category.id == categoryId);
      if (index != -1) {
        _categories[index] = _categories[index].copyWith(
          sutraCount: count,
          updatedAt: DateTime.now().toIso8601String(),
        );
        await _saveCategories();
        print('Sutra count updated for category: ${_categories[index].name}');
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating sutra count: $e');
      return false;
    }
  }

  // Sync sutra counts from actual sutra data
  // This counts sutras by category name and updates each category's sutraCount
  Future<void> syncSutraCounts(Map<String, int> categoryCounts) async {
    try {
      bool hasChanges = false;
      for (var category in _categories) {
        final count = categoryCounts[category.name] ?? 0;
        if (category.sutraCount != count) {
          final index = _categories.indexWhere((cat) => cat.id == category.id);
          if (index != -1) {
            _categories[index] = _categories[index].copyWith(
              sutraCount: count,
              updatedAt: DateTime.now().toIso8601String(),
            );
            hasChanges = true;
            print('Synced sutra count for "${category.name}": $count');
          }
        }
      }
      
      if (hasChanges) {
        await _saveCategories();
        print('Sutra counts synced successfully');
      }
    } catch (e) {
      print('Error syncing sutra counts: $e');
    }
  }

  // Save categories to file
  Future<void> _saveCategories() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/categories.json');
      
      final Map<String, dynamic> data = {
        'categories': _categories.map((category) => category.toMap()).toList(),
        'statistics': _getUpdatedStatistics(),
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      await file.writeAsString(json.encode(data));
      print('Categories saved successfully to: ${file.path}');
    } catch (e) {
      print('Error saving categories: $e');
    }
  }

  // Get updated statistics
  Map<String, dynamic> _getUpdatedStatistics() {
    return {
      'totalCategories': _categories.length,
      'activeCategories': _categories.where((category) => category.isActive).length,
      'inactiveCategories': _categories.where((category) => !category.isActive).length,
      'totalSutras': _categories.fold(0, (sum, category) => sum + category.sutraCount),
      'averageSutrasPerCategory': _categories.isNotEmpty 
          ? (_categories.fold(0, (sum, category) => sum + category.sutraCount) / _categories.length).toStringAsFixed(2)
          : '0.00',
    };
  }

  // Get category names for dropdown
  List<String> getCategoryNames() {
    return _categories.map((category) => category.name).toList();
  }

  // Get active category names
  List<String> getActiveCategoryNames() {
    return _categories.where((category) => category.isActive).map((category) => category.name).toList();
  }
}

