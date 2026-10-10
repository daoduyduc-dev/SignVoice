import 'package:flutter/foundation.dart';
import '../models/favorite_model.dart';
import '../services/favorites/favorites_service.dart';

/// Provider for user favorites
class FavoritesProvider extends ChangeNotifier {
  final FavoritesService _favoritesService;

  List<FavoriteModel> _favorites = [];
  bool _isLoading = false;
  String? _errorMessage;

  FavoritesProvider({FavoritesService? favoritesService})
      : _favoritesService = favoritesService ?? FavoritesService.instance;

  // Getters
  List<FavoriteModel> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load user favorites
  Future<void> loadFavorites() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _favorites = await _favoritesService.getFavorites();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add favorite
  Future<bool> addFavorite(String entryId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final favorite = await _favoritesService.addFavorite(entryId);
      _favorites.add(favorite);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remove favorite
  Future<bool> removeFavorite(String entryId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _favoritesService.removeFavorite(entryId);
      _favorites.removeWhere((f) => f.entryId == entryId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle favorite (add if not exists, remove if exists)
  Future<bool> toggleFavorite(String entryId) async {
    if (isFavorite(entryId)) {
      return await removeFavorite(entryId);
    } else {
      return await addFavorite(entryId);
    }
  }

  /// Check if entry is favorited
  bool isFavorite(String entryId) {
    return _favorites.any((f) => f.entryId == entryId);
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
