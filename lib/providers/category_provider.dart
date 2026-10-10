import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../services/category/category_service.dart';

/// Provider for categories
class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService;

  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  bool _isLoading = false;
  String? _errorMessage;

  CategoryProvider({CategoryService? categoryService})
      : _categoryService = categoryService ?? CategoryService.instance;

  // Getters
  List<CategoryModel> get categories => _categories;
  CategoryModel? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all categories
  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _categoryService.getCategories();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load category by slug
  Future<void> loadCategoryBySlug(String slug) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedCategory = await _categoryService.getCategoryBySlug(slug);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new category (admin only)
  Future<bool> createCategory({
    required String name,
    required String slug,
    String? description,
    String? icon,
    int? sortOrder,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final category = await _categoryService.createCategory(
        name: name,
        slug: slug,
        description: description,
        icon: icon,
        sortOrder: sortOrder,
      );
      _categories.add(category);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear selected category
  void clearSelectedCategory() {
    _selectedCategory = null;
    notifyListeners();
  }
}
