import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/staff_stats_model.dart';
import '../models/dictionary_entry_model.dart';
import '../services/staff/staff_service.dart';

/// Provider for staff operations
class StaffProvider extends ChangeNotifier {
  final StaffService _staffService;

  List<DictionaryEntryModel> _content = [];
  DictionaryEntryModel? _selectedContent;
  StaffStatsModel? _stats;
  List<UserModel> _users = [];
  Map<String, dynamic> _contentPagination = {};
  Map<String, dynamic> _usersPagination = {};
  bool _isLoading = false;
  String? _errorMessage;

  StaffProvider({StaffService? staffService})
      : _staffService = staffService ?? StaffService.instance;

  // Getters
  List<DictionaryEntryModel> get content => _content;
  DictionaryEntryModel? get selectedContent => _selectedContent;
  StaffStatsModel? get stats => _stats;
  List<UserModel> get users => _users;
  Map<String, dynamic> get contentPagination => _contentPagination;
  Map<String, dynamic> get usersPagination => _usersPagination;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load content with filters
  Future<void> loadContent({
    int page = 1,
    int limit = 20,
    String? status,
    String? category,
    String? search,
    String? sortBy,
    String? order,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _staffService.getContent(
        page: page,
        limit: limit,
        status: status,
        category: category,
        search: search,
        sortBy: sortBy,
        order: order,
      );
      _content = result['entries'] as List<DictionaryEntryModel>;
      _contentPagination = result['pagination'] as Map<String, dynamic>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load content by ID
  Future<void> loadContentById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedContent = await _staffService.getContentById(id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update content
  Future<bool> updateContent(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _staffService.updateContent(id, data);
      final index = _content.indexWhere((c) => c.id == id);
      if (index != -1) {
        _content[index] = updated;
      }
      if (_selectedContent?.id == id) {
        _selectedContent = updated;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Approve content
  Future<bool> approveContent(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _staffService.approveContent(id);
      final index = _content.indexWhere((c) => c.id == id);
      if (index != -1) {
        _content[index] = updated;
      }
      if (_selectedContent?.id == id) {
        _selectedContent = updated;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reject content
  Future<bool> rejectContent(String id, String reason) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _staffService.rejectContent(id, reason);
      final index = _content.indexWhere((c) => c.id == id);
      if (index != -1) {
        _content[index] = updated;
      }
      if (_selectedContent?.id == id) {
        _selectedContent = updated;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load users
  Future<void> loadUsers({
    int page = 1,
    int limit = 20,
    String? search,
    String? role,
    String? status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _staffService.getUsers(
        page: page,
        limit: limit,
        search: search,
        role: role,
        status: status,
      );
      _users = result['users'] as List<UserModel>;
      _usersPagination = result['pagination'] as Map<String, dynamic>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load staff statistics
  Future<void> loadStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stats = await _staffService.getStats();
    } catch (e) {
      _errorMessage = e.toString();
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

  /// Clear selected content
  void clearSelectedContent() {
    _selectedContent = null;
    notifyListeners();
  }
}
