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
        name: 'Tịnh Độ',
        description: 'Các kinh về cõi Tịnh Độ và Phật A Di Đà',
        color: '#FF6B6B',
        icon: 'lotus',
        isActive: true,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        sutraCount: 0,
        order: 1,
      ),
    ];
  }

  Map<String, dynamic> _getDefaultStatistics() {
    return {
      'totalCategories': 1,
      'activeCategories': 1,
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

