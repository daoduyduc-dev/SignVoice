import 'package:flutter/foundation.dart';
import '../models/dictionary_entry_model.dart';
import '../services/dictionary/dictionary_service.dart';

/// Provider for dictionary entries
class DictionaryProvider extends ChangeNotifier {
  final DictionaryService _dictionaryService;

  List<DictionaryEntryModel> _entries = [];
  DictionaryEntryModel? _selectedEntry;
  String? _searchQuery;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  String? _errorMessage;

  DictionaryProvider({DictionaryService? dictionaryService})
      : _dictionaryService = dictionaryService ?? DictionaryService.instance;

  // Getters
  List<DictionaryEntryModel> get entries => _entries;
  DictionaryEntryModel? get selectedEntry => _selectedEntry;
  String? get searchQuery => _searchQuery;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load dictionary entries with optional filters
  Future<void> loadEntries({
    String? categoryId,
    String? search,
    String? difficulty,
    int limit = 20,
    bool reset = false,
  }) async {
    if (_isLoading) return;

    if (reset) {
      _currentPage = 1;
      _entries = [];
      _hasMore = true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final skip = (_currentPage - 1) * limit;
      final result = await _dictionaryService.getEntries(
        categoryId: categoryId,
        search: search,
        difficulty: difficulty,
        limit: limit,
        skip: skip,
      );

      if (reset) {
        _entries = result;
      } else {
        _entries.addAll(result);
      }

      _hasMore = result.length == limit;
      _searchQuery = search;
      _currentPage++;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load a single entry by ID
  Future<void> loadEntryById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedEntry = await _dictionaryService.getEntryById(id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load popular entries
  Future<void> loadPopularEntries({int limit = 10}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _entries = await _dictionaryService.getPopularEntries(limit: limit);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more entries (pagination)
  Future<void> loadMore({
    String? categoryId,
    String? difficulty,
  }) async {
    if (!_hasMore || _isLoading) return;

    await loadEntries(
      categoryId: categoryId,
      search: _searchQuery,
      difficulty: difficulty,
      reset: false,
    );
  }

  /// Set search query
  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear selected entry
  void clearSelectedEntry() {
    _selectedEntry = null;
    notifyListeners();
  }
}
